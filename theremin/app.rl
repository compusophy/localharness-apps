use host::display;

pub fn frame(t: i32) {
    display::clear(0x220000);
    let r = 50 + (host::math::sin(t / 4) * 30) / 256;
    display::fill_rect(256 - r, 256 - r, r * 2, r * 2, 0xff3333);
    // Label "THEREMIN"
    let label = [84, 72, 69, 82, 69, 77, 73, 78];
    for i in 0..8 {
        display::draw_char(200 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
