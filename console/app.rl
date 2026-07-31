use host::display;

pub fn frame(t: i32) {
    display::clear(0x051a05);
    for i in 0..8 {
        let y = ((t * (i + 1) * 2) / 3) % 512;
        display::fill_rect(i * 64 + 10, y, 44, 60, 0x00ff66);
    }
    let label = [67, 79, 78, 83, 79, 76, 69];
    for i in 0..7 {
        display::draw_char(207 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
