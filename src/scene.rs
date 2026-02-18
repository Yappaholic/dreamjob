use crate::{Button, GameState};
use raylib::prelude::*;
use rust_embed::Embed;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SceneInfo {
    title: String,
    options: Vec<String>,
}

#[derive(Embed)]
#[folder = "scenes"]
struct Scenes;

#[derive(Debug, Clone)]
pub struct Scene {
    pub id: usize,
    pub info: SceneInfo,
}

impl Scene {
    pub fn new(num: usize) -> Self {
        let filename = format!("00{}.json", num);
        let scene_info_text = Scenes::get(&filename).unwrap();
        let scene_info_text: &str = str::from_utf8(scene_info_text.data.as_ref()).unwrap();
        let info: SceneInfo = serde_json::from_str(scene_info_text).unwrap();
        Self { id: num, info }
    }
    pub fn draw(&self, d: &mut RaylibDrawHandle, game: &mut GameState) {
        self.draw_title(d, game);
        let (first_button, second_button) = self.draw_buttons(d, game);
        if d.is_mouse_button_released(MouseButton::MOUSE_BUTTON_LEFT) {
            let mouse_coords = d.get_mouse_position();
            if first_button.is_cursor_inside(mouse_coords) {
                game.next_scene();
            } else if second_button.is_cursor_inside(mouse_coords) {
                game.is_error = true;
                game.error_sound.play();
            }
        }
    }
    fn draw_buttons(&self, d: &mut RaylibDrawHandle, game: &GameState) -> (Button, Button) {
        let first_answer = Button::new(
            d,
            Vector2::new(
                ((game.window_width / 2) - 100) as f32,
                (game.window_height / 2) as f32,
            ),
            &self.info.options[0],
            56.0,
            20.0,
        )
        .draw(d, false);

        let second_answer = Button::new(
            d,
            Vector2::new(
                ((game.window_width / 2) + 100) as f32,
                (game.window_height / 2) as f32,
            ),
            &self.info.options[1],
            56.0,
            20.0,
        )
        .draw(d, false);
        (first_answer, second_answer)
    }
    fn draw_title(&self, d: &mut RaylibDrawHandle, game: &GameState) {
        d.draw_text(
            &self.info.title,
            game.window_width / 2 - d.measure_text(&self.info.title, 56) / 2,
            game.window_height / 3,
            56,
            Color::BLACK,
        );
    }
}
