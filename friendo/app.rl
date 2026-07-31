use host::display;

pub fn frame(t: i32) {
    display::clear(0x331100);
    // Face
    display::fill_rect(156, 156, 200, 200, 0xffaa00);
    // Eyes
    display::fill_rect(196, 200, 30, 30, 0x000000);
    display::fill_rect(286, 200, 30, 30, 0x000000);
    // Mouth
    let smile = 10 + (host::math::sin(t / 4) * 20) / 256;
    display::fill_rect(196, 290, 120, smile, 0x000000);
    let label = [70, 82, 73, 69, 78, 68, 79];
    for i in 0..7 {
        display::draw_char(207 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
