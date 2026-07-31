use host::display;

pub fn frame(t: i32) {
    display::clear(0x000022);
    let open_h = 80 + (host::math::sin(t / 5) * 60) / 256;
    display::fill_rect(150, 256 - open_h / 2, 212, open_h, 0x3388ff);
    display::fill_rect(226, 226, 60, 60, 0xffffff);
    let label = [69, 89, 69];
    for i in 0..3 {
        display::draw_char(234 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
