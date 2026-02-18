mod button;
mod scene;

use raylib::ffi::KeyboardKey::*;
use raylib::prelude::*;
use rust_embed::Embed;
use std::io;

use crate::button::Button;
use crate::scene::Scene;

const LOGO: &str = "Dream Job";

#[derive(Debug)]
pub struct GameState<'a> {
    pub scene: Scene,
    pub window_height: i32,
    pub window_width: i32,
    pub is_main_menu: bool,
    pub quit: bool,
    pub loading: bool,
    pub is_error: bool,
    scene_n: usize,
    pub loading_sound: Sound<'a>,
    pub error_sound: Sound<'a>,
}

impl<'a> GameState<'a> {
    pub fn new(audio: &'a RaylibAudio) -> Self {
        Self {
            window_height: 0,
            window_width: 0,
            is_main_menu: true,
            quit: false,
            scene: Scene::new(1),
            loading: false,
            scene_n: 1,
            is_error: false,
            loading_sound: GameState::get_loading_sound(audio),
            error_sound: GameState::get_error_sound(audio),
        }
    }
    pub fn new_with_winsize(audio: &'a RaylibAudio, window_height: i32, window_width: i32) -> Self {
        Self {
            window_height,
            window_width,
            is_main_menu: true,
            quit: false,
            scene: Scene::new(1),
            loading: false,
            scene_n: 1,
            is_error: false,
            loading_sound: GameState::get_loading_sound(audio),
            error_sound: GameState::get_error_sound(audio),
        }
    }
    pub fn next_scene(&mut self) {
        self.loading = true;
        self.scene_n += 1;
        self.scene = Scene::new(self.scene_n);
        self.loading_sound.play();
    }
    pub fn get_scene(&mut self) -> Scene {
        self.scene.clone()
    }

    fn get_loading_sound(audio: &'a RaylibAudio) -> Sound<'a> {
        let tape_sound_file = Media::get("tape-insert.mp3").unwrap();
        let mut tape_sound_wave = audio
            .new_wave_from_memory(".mp3", &tape_sound_file.data.as_ref())
            .unwrap();
        let tape_sound_fps = tape_sound_wave.frame_count() / 20;
        tape_sound_wave.crop(
            (tape_sound_fps as f32 * 3.5) as i32,
            (tape_sound_fps as f32 * 8.0) as i32,
        );
        audio.new_sound_from_wave(&tape_sound_wave).unwrap()
    }
    fn get_error_sound(audio: &'a RaylibAudio) -> Sound<'a> {
        let error_sound_file = Media::get("error.mp3").unwrap();
        let mut error_sound_wave = audio
            .new_wave_from_memory(".mp3", &error_sound_file.data.as_ref())
            .unwrap();
        let error_sound_fps = error_sound_wave.frame_count() / 150;
        error_sound_wave.crop(
            (error_sound_fps as f32 * 31.5) as i32,
            (error_sound_fps * 32) as i32,
        );
        audio.new_sound_from_wave(&error_sound_wave).unwrap()
    }
}

#[derive(Embed)]
#[folder = "media"]
struct Media;

fn get_background() -> Result<Image, io::Error> {
    let wheat_field = Media::get("wheat_field.jpg").ok_or(io::Error::new(
        io::ErrorKind::InvalidData,
        "Failed to open media/ directory",
    ))?;

    if let Ok(mut image) = Image::load_image_from_mem(".jpg", wheat_field.data.as_ref()) {
        image.set_format(PixelFormat::PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
        Ok(image)
    } else {
        Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "Failed to load image from memory",
        ))
    }
}

fn draw_main_menu(d: &mut RaylibDrawHandle<'_>, game: &mut GameState) {
    d.draw_text(
        "Dream Job",
        (game.window_width / 2) - d.measure_text(LOGO, 72) / 2,
        game.window_height / 3,
        72,
        Color::BLACK,
    );

    let (start_button, exit_button) = main_menu_buttons(d, game.window_height, game.window_width);
    let mut mouse_coords = d.get_mouse_position();
    start_button.draw(d, start_button.is_cursor_inside(mouse_coords));
    exit_button.draw(d, exit_button.is_cursor_inside(mouse_coords));

    if d.is_mouse_button_released(MouseButton::MOUSE_BUTTON_LEFT) {
        mouse_coords = d.get_mouse_position();
        if start_button.is_cursor_inside(mouse_coords) {
            game.is_main_menu = false;
            game.loading = true;
            game.loading_sound.play();
        }
        if exit_button.is_cursor_inside(mouse_coords) {
            game.quit = true;
        }
    }
}

fn main_menu_buttons(
    d: &mut RaylibDrawHandle<'_>,
    window_height: i32,
    window_width: i32,
) -> (Button, Button) {
    let start_button = Button::new(
        d,
        Vector2::new((window_width / 2) as f32, (window_height / 2) as f32),
        "Start",
        56.0,
        20.0,
    );

    let exit_button = Button::new(
        d,
        Vector2::new(
            (window_width / 2) as f32,
            ((window_height / 2) + 100) as f32,
        ),
        "Exit",
        56.0,
        20.0,
    );
    (start_button, exit_button)
}

fn main() {
    let background = get_background().unwrap();

    let (mut rl, thread) = raylib::init()
        .title("Dream Job")
        .resizable()
        .fullscreen()
        .vsync()
        .build();
    let audio = RaylibAudio::init_audio_device().unwrap();

    rl.set_target_fps(60);
    let (window_height, window_width) = (rl.get_screen_height(), rl.get_screen_width());
    let mut game: GameState = GameState::new_with_winsize(&audio, window_height, window_width);

    let mut background_resized = background.clone();
    background_resized.resize(window_width, window_height);
    let mut background_texture = rl
        .load_texture_from_image(&thread, &background_resized)
        .unwrap();
    game.loading_sound.set_volume(1.0);

    while !rl.window_should_close() && !game.quit {
        // Rebuild image only if window is resized
        if rl.is_window_resized() {
            game.window_height = rl.get_screen_height();
            game.window_width = rl.get_screen_width();
            background_resized = background.clone();
            background_resized.resize(game.window_width, game.window_height);
            background_texture = rl
                .load_texture_from_image(&thread, &background_resized)
                .unwrap();
        }

        let mut d = rl.begin_drawing(&thread);

        if d.is_key_pressed(KEY_Q) {
            game.quit = true;
        }

        d.clear_background(Color::WHITE);
        d.draw_texture(&background_texture, 0, 0, Color::WHITE);

        // Blank loading screen
        if game.loading_sound.is_playing() {
            game.loading = true;
            continue;
        // Draw Error Screen
        } else if game.error_sound.is_playing() {
            game.is_error = true;
            background_resized.color_tint(Color::RED);
            d.draw_text(
                "WRONG",
                game.window_width / 2,
                game.window_height / 2,
                108,
                Color::RED,
            );
            continue;
        } else {
            game.loading = false;
            game.is_error = false;
        }
        // Load next scene
        if game.loading == false && game.is_main_menu == false {
            let scene = game.get_scene();
            scene.draw(&mut d, &mut game);
        } else if game.loading == false && game.is_main_menu == true {
            draw_main_menu(&mut d, &mut game);
        }
    }
}
