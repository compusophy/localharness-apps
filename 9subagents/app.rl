use host::display;
use host::compose;

fn draw_label(idx: i32, x: i32, y: i32) {
    if idx == 0 {
        // THEREMIN
        let name = [84, 72, 69, 82, 69, 77, 73, 78];
        for i in 0..8 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 1 {
        // MOUTH
        let name = [77, 79, 85, 84, 72];
        for i in 0..5 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 2 {
        // EYE
        let name = [69, 89, 69];
        for i in 0..3 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 3 {
        // FPS
        let name = [70, 80, 83];
        for i in 0..3 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 4 {
        // BOGGLE
        let name = [66, 79, 71, 71, 76, 69];
        for i in 0..6 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 5 {
        // TOT
        let name = [84, 79, 84];
        for i in 0..3 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 6 {
        // FRIENDO
        let name = [70, 82, 73, 69, 78, 68, 79];
        for i in 0..7 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 7 {
        // CONSOLE
        let name = [67, 79, 78, 83, 79, 76, 69];
        for i in 0..7 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    } else if idx == 8 {
        // MARIO
        let name = [77, 65, 82, 73, 79];
        for i in 0..5 { display::draw_char(x + i * 7, y, name[i], 0x00ffff, 1); }
    }
}

fn spawn_subagent(idx: i32, x: i32, y: i32, w: i32, h: i32) -> i32 {
    if idx == 0 {
        compose::spawn_module("theremin", x, y, w, h)
    } else if idx == 1 {
        compose::spawn_module("mouth", x, y, w, h)
    } else if idx == 2 {
        compose::spawn_module("eye", x, y, w, h)
    } else if idx == 3 {
        compose::spawn_module("fps", x, y, w, h)
    } else if idx == 4 {
        compose::spawn_module("boggle", x, y, w, h)
    } else if idx == 5 {
        compose::spawn_module("tot", x, y, w, h)
    } else if idx == 6 {
        compose::spawn_module("friendo", x, y, w, h)
    } else if idx == 7 {
        compose::spawn_module("console", x, y, w, h)
    } else if idx == 8 {
        compose::spawn_module("mario", x, y, w, h)
    } else {
        -1
    }
}

pub fn frame(_t: i32) {
    display::clear(0x000000);

    for idx in 0..9 {
        let col = idx % 3;
        let row = idx / 3;

        let x = if col == 0 { 0 } else if col == 1 { 171 } else { 342 };
        let y = if row == 0 { 0 } else if row == 1 { 171 } else { 342 };
        let w = 170;
        let h = 170;

        // 1. Spawn subagent module full cell size (170x170 square)
        let handle = spawn_subagent(idx, x, y, w, h);

        // 2. Overlay title bar over top of the subagent module
        display::fill_rect(x, y, w, 14, 0x111122);
        display::draw_line(x, y + 14, x + w, y + 14, 0x00ffff);
        draw_label(idx, x + 4, y + 3);

        // 3. Grid line borders
        display::fill_rect(x, y, 1, h, 0x333366);
        display::fill_rect(x, y, w, 1, 0x333366);

        // 4. Click handling for input focus
        if display::pointer_down() != 0 {
            let px = display::pointer_x();
            let py = display::pointer_y();
            if px >= x && px < x + w && py >= y && py < y + h {
                if handle >= 0 {
                    compose::focus_module(handle);
                }
            }
        }
    }

    display::present();
}
