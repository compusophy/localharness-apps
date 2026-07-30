use host::display;

pub fn frame(t: i32) {
    let w = display::width();
    let h = display::height();
    display::clear(0xffffff);

    // Smiling / animated mouth
    let open_amount = ((t / 15) % 30);

    display::fill_rect(10, 10, w - 20, 20 + open_amount, 0xbb2222);
    // Teeth
    display::fill_rect(20, 10, w - 40, 10, 0xffffff);

    display::present();
}
