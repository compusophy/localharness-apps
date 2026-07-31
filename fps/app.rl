use host::display;

pub fn frame(t: i32) {
    display::clear(0x222200);
    let x = 100 + (host::math::sin(t / 4) * 150) / 256;
    let y = 100 + (host::math::cos(t / 3) * 150) / 256;
    display::fill_rect(256 + x, 256 + y, 40, 40, 0xffff33);
    let label = [70, 80, 83];
    for i in 0..3 {
        display::draw_char(234 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
