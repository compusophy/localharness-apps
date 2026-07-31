use host::display;

pub fn frame(t: i32) {
    display::clear(0x1a0520);
    let jump = (host::math::sin(t / 2) * 80) / 256;
    let y = if jump < 0 { 256 + jump } else { 256 - jump };
    display::fill_rect(206, y, 100, 100, 0xff0044);
    display::fill_rect(226, y + 20, 60, 60, 0xffcc00);
    let label = [77, 65, 82, 73, 79];
    for i in 0..5 {
        display::draw_char(220 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
