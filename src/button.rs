use raylib::prelude::*;

#[derive(Clone)]
pub struct Button {
    pub pos: Vector2,
    pub size: Vector2,
    text: String,
    font_size: f32,
    padding: f32,
}

impl Button {
    pub fn new(
        d: &mut RaylibDrawHandle<'_>,
        pos: Vector2,
        text: &str,
        font_size: f32,
        padding: f32,
    ) -> Self {
        let text_size = d.measure_text(text, font_size as i32) as f32;
        let size = Vector2::new(text_size + padding, font_size + padding);
        let pos = Vector2::new(pos.x - (text_size / 2.0) - padding, pos.y - padding);
        Self {
            pos,
            size,
            text: String::from(text),
            font_size,
            padding,
        }
    }
    pub fn draw(&self, d: &mut RaylibDrawHandle<'_>, inverted: bool) -> Self {
        let (rec_color, text_color) = if inverted {
            (Color::BLACK, Color::WHITE)
        } else {
            (Color::new(0, 0, 0, 0), Color::BLACK)
        };
        d.draw_rectangle_v(self.pos, self.size, rec_color);
        d.draw_text_ex(
            d.get_font_default(),
            &self.text,
            self.pos + Vector2::new(self.padding / 2.0, self.padding / 2.0),
            self.font_size,
            2.0,
            text_color,
        );
        self.clone()
    }
    pub fn draw_if<F>(&self, d: &mut RaylibDrawHandle, f: F) -> Self
    where
        F: FnOnce() -> bool,
    {
        if f() {
            let (rec_color, text_color) = (Color::BLACK, Color::WHITE);
            d.draw_rectangle_v(self.pos, self.size, rec_color);
            d.draw_text_ex(
                d.get_font_default(),
                &self.text,
                self.pos + Vector2::new(self.padding / 2.0, self.padding / 2.0),
                self.font_size,
                2.0,
                text_color,
            );
        }
        self.clone()
    }
    pub fn is_cursor_inside(&self, mouse_coords: Vector2) -> bool {
        mouse_coords.y > self.pos.y
            && mouse_coords.y < self.pos.y + self.size.y
            && mouse_coords.x > self.pos.x
            && mouse_coords.x < self.pos.x + self.size.x
    }
}
