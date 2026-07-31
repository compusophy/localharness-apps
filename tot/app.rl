use host::display;

pub fn frame(t: i32) {
    display::clear(0x002222);
    let a = t / 3;
    let cos_a = host::math::cos(a);
    let sin_a = host::math::sin(a);
    let dx = (cos_a * 80) / 256;
    let dy = (sin_a * 80) / 256;
    display::draw_line(256 - dx, 256 - dy, 256 + dx, 256 + dy, 0x00ffff);
    display::draw_line(256 + dy, 256 - dx, 256 - dy, 256 + dx, 0x00ffff);
    let label = [84, 79, 84];
    for i in 0..3 {
        display::draw_char(234 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
