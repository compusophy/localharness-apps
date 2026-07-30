use host::display;

pub fn frame(t: i32) {
    let w = display::width();
    let h = display::height();
    display::clear(0xffffff);

    // Outer eye outline
    let cx = w / 2;
    let cy = h / 2;
    let r = w / 2 - 4;

    display::fill_rect(2, 2, w - 4, h - 4, 0xeeeeee);

    // Pupil movement
    let offset_x = ((t / 10) % 20) - 10;
    let pupil_r = 16;
    display::fill_rect(cx + offset_x - pupil_r, cy - pupil_r, pupil_r * 2, pupil_r * 2, 0x2244aa);
    display::fill_rect(cx + offset_x - 6, cy - 6, 12, 12, 0x000000);

    display::present();
}
