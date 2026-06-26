use host::display;

pub fn frame(_t: i32) {
    display::clear(0x808080);
    display::present();
}