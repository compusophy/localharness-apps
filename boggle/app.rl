use host::display;

pub fn frame(t: i32) {
    display::clear(0x220022);
    let shift = (t / 10) % 40;
    for i in 0..10 {
        let p = i * 40 + shift;
        display::draw_line(p, 0, p, 512, 0xff33ff);
        display::draw_line(0, p, 512, p, 0xff33ff);
    }
    let label = [66, 79, 71, 71, 76, 69];
    for i in 0..6 {
        display::draw_char(214 + i * 14, 420, label[i], 0xffffff, 2);
    }
    display::present();
}
