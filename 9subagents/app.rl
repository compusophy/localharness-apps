use host::display;
use host::compose;

fn draw_label(idx: i32, x: i32, y: i32) {
    if idx == 0 {
        // THEREMIN
        let name = [84, 72, 69, 82, 69, 77, 73, 78];
        for i in 0..8 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 1 {
        // MOUTH
        let name = [77, 79, 85, 84, 72];
        for i in 0..5 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 2 {
        // EYE
        let name = [69, 89, 69];
        for i in 0..3 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 3 {
        // FPS
        let name = [70, 80, 83];
        for i in 0..3 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 4 {
        // BOGGLE
        let name = [66, 79, 71, 71, 76, 69];
        for i in 0..6 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 5 {
        // TOT
        let name = [84, 79, 84];
        for i in 0..3 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 6 {
        // FRIENDO
        let name = [70, 82, 73, 69, 78, 68, 79];
        for i in 0..7 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 7 {
        // CONSOLE
        let name = [67, 79, 78, 83, 79, 76, 69];
        for i in 0..7 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
    } else if idx == 8 {
        // MARIO
        let name = [77, 65, 82, 73, 79];
        for i in 0..5 { display::draw_char(x + i * 7, y, name[i], 0xffffff, 1); }
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
    display::clear(0x0a0a16);

    // Top Header Bar
    display::fill_rect(0, 0, 512, 22, 0x16162e);
    display::fill_rect(0, 21, 512, 1, 0x00e5ff);

    // Header Title: "9 SUBAGENTS GRID PANEL"
    let title = [57, 32, 83, 85, 66, 65, 71, 69, 78, 84, 83, 32, 71, 82, 73, 68, 32, 80, 65, 78, 69, 76];
    for i in 0..22 {
        display::draw_char(8 + i * 7, 7, title[i], 0x00e5ff, 1);
    }

    for idx in 0..9 {
        let col = idx % 3;
        let row = idx / 3;
        let x = 4 + col * 168;
        let y = 26 + row * 160;
        let w = 164;
        let h = 156;

        // Cell header bar
        display::fill_rect(x, y, w, 16, 0x1d1d3b);
        display::fill_rect(x, y, w, 1, 0x3d3d7a);

        // Draw subagent name label
        draw_label(idx, x + 6, y + 4);

        // Spawn subagent module into cell viewport
        let handle = spawn_subagent(idx, x, y + 16, w, h - 16);

        // Handle click to focus input
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
