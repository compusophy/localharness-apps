use host::display;
use host::audio;

pub fn frame(t: i32) {
    let w = display::width();
    let h = display::height();

    display::clear(0x0a0a1a);

    let mut grid_x = 64;
    while grid_x < w {
        display::fill_rect(grid_x, 0, 1, h, 0x1a1a3a);
        grid_x = grid_x + 64;
    }
    let mut grid_y = 64;
    while grid_y < h {
        display::fill_rect(0, grid_y, w, 1, 0x1a1a3a);
        grid_y = grid_y + 64;
    }

    let px = display::pointer_x();
    let py = display::pointer_y();
    let pd = display::pointer_down();

    let pitch = 200 + (px * 1000) / w;
    let mut vol = 100 - (py * 100) / h;
    if vol < 0 { vol = 0; }
    if vol > 100 { vol = 100; }

    let mut timer = display::state_get(22);
    if pd != 0 {
        if timer == 0 {
            audio::set_volume(vol);
            audio::tone(pitch, 50, 0);
            timer = 2;
        } else {
            timer = timer - 1;
        }

        let head = (display::state_get(21) + 1) % 10;
        display::state_set(21, head);
        display::state_set(head * 2, px);
        display::state_set(head * 2 + 1, py);
    } else {
        timer = 0;
    }
    display::state_set(22, timer);

    let head = display::state_get(21);
    let mut i = 0;
    while i < 10 {
        let idx = (head + 10 - i) % 10;
        let tx = display::state_get(idx * 2);
        let ty = display::state_get(idx * 2 + 1);

        if tx > 0 || ty > 0 {
            let radius = 12 - i;
            if radius > 1 {
                let alpha = 255 - i * 22;
                let color = (alpha << 16) | ((alpha / 2) << 8) | 255;
                display::fill_rect(tx - radius / 2, ty - radius / 2, radius, radius, color);
            }
        }
        i = i + 1;
    }

    if pd != 0 {
        display::fill_rect(px - 15, py - 1, 30, 2, 0x00ffff);
        display::fill_rect(px - 1, py - 15, 2, 30, 0x00ffff);
        display::fill_rect(px - 4, py - 4, 8, 8, 0xffffff);
    } else {
        display::fill_rect(px - 8, py - 1, 16, 2, 0x555577);
        display::fill_rect(px - 1, py - 8, 2, 16, 0x555577);
    }

    display::fill_rect(0, 0, w, 32, 0x000000);
    display::fill_rect(0, 31, w, 1, 0x00ffff);

    display::draw_char(10, 8, 70, 0x00ffff, 2);
    display::draw_number(30, 8, pitch, 0x00ffff, 2);

    display::draw_char(200, 8, 86, 0xff00ff, 2);
    display::draw_number(220, 8, vol, 0xff00ff, 2);

    if pd != 0 {
        display::fill_rect(380, 8, 110, 16, 0x00aa00);
        display::draw_char(390, 10, 80, 0xffffff, 1);
        display::draw_char(400, 10, 76, 0xffffff, 1);
        display::draw_char(410, 10, 65, 0xffffff, 1);
        display::draw_char(420, 10, 89, 0xffffff, 1);
    } else {
        display::fill_rect(380, 8, 110, 16, 0x333333);
        display::draw_char(390, 10, 72, 0x888888, 1);
        display::draw_char(400, 10, 79, 0x888888, 1);
        display::draw_char(410, 10, 76, 0x888888, 1);
        display::draw_char(420, 10, 68, 0x888888, 1);
    }

    display::present();
}
