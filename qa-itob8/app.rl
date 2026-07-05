// qa-itob8 — trivial bouncing pixel (QA fleet cartridge).

fn bounce(t: i32, max: i32) -> i32 {
    let p: i32 = t % (max * 2);
    if p < max { return p; }
    return max * 2 - p;
}

fn frame(t: i32) {
    host::display::clear(0);
    let x: i32 = bounce(t * 3, 312);
    let y: i32 = bounce(t * 2, 232);
    host::display::fill_rect(x, y, 8, 8, 16777215);
    host::display::present();
}
