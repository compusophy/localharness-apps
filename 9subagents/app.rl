use host::display;
use host::compose;

pub fn dims() -> i32 {
    (1024 << 16) | 1024
}

fn draw_label(idx: i32, x: i32, y: i32) {
    if idx == 0 {
        let name = [84, 72, 69, 82, 69, 77, 73, 78];
        for i in 0..8 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 1 {
        let name = [77, 79, 85, 84, 72];
        for i in 0..5 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 2 {
        let name = [69, 89, 69];
        for i in 0..3 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 3 {
        let name = [70, 80, 83];
        for i in 0..3 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 4 {
        let name = [66, 79, 71, 71, 76, 69];
        for i in 0..6 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 5 {
        let name = [84, 79, 84];
        for i in 0..3 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 6 {
        let name = [70, 82, 73, 69, 78, 68, 79];
        for i in 0..7 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 7 {
        let name = [67, 79, 78, 83, 79, 76, 69];
        for i in 0..7 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
    } else if idx == 8 {
        let name = [77, 65, 82, 73, 79];
        for i in 0..5 { display::draw_char(x + i * 12, y, name[i], 0x00ffff, 2); }
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
    display::clear(0x0a0a1a);

    for idx in 0..9 {
        let col = idx % 3;
        let row = idx / 3;

        let x = if col == 0 { 0 } else if col == 1 { 342 } else { 684 };
        let y = if row == 0 { 0 } else if row == 1 { 342 } else { 684 };
        let cell_w = 340;
        let cell_h = 340;
        let header_h = 26;

        // 1. Draw cell header bar
        display::fill_rect(x, y, cell_w, header_h, 0x181836);
        display::draw_line(x, y + header_h - 1, x + cell_w, y + header_h - 1, 0x00ffff);
        draw_label(idx, x + 8, y + 5);

        // 2. Spawn subagent module in the viewport under the header bar
        let mod_y = y + header_h;
        let mod_h = cell_h - header_h;
        let handle = spawn_subagent(idx, x, mod_y, cell_w, mod_h);

        // 3. Outer grid borders
        display::fill_rect(x, y, 1, cell_h, 0x3d3d7a);
        display::fill_rect(x, y, cell_w, 1, 0x3d3d7a);

        // 4. Click handling for input routing/focus
        if display::pointer_down() != 0 {
            let px = display::pointer_x();
            let py = display::pointer_y();
            if px >= x && px < x + cell_w && py >= y && py < y + cell_h {
                if handle >= 0 {
                    compose::focus_module(handle);
                }
            }
        }
    }

    display::present();
}
