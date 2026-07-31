use host::display;

pub fn frame(t: i32) {
    display::clear(0x002200);
    let h = 20 + (host::math::sin(t / 3) * 40) / 256;
    display::fill_rect(150, 256 - h / 2, 212, h, 0x33ff33);
    let label = [77, 79, 85, 84, 72];
    for i in 0..5 {
        display::draw_char(220 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
