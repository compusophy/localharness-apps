use host::display;
use host::compose;

const SIN_TABLE: [i32; 91] = [
    0, 17, 35, 52, 70, 87, 105, 122, 139, 156, 174, 191, 208, 225, 242, 259, 276, 292, 309, 326, 342, 358, 375, 391, 407, 423, 438, 454, 469, 485, 500, 515, 530, 545, 559, 574, 588, 602, 616, 629, 643, 656, 669, 682, 695, 707, 719, 731, 743, 755, 766, 777, 788, 799, 809, 819, 829, 839, 848, 857, 866, 875, 883, 891, 899, 906, 914, 921, 927, 934, 940, 946, 951, 956, 961, 966, 970, 974, 978, 982, 985, 988, 990, 993, 995, 996, 998, 999, 999, 1000, 1000
];

fn sin_deg(deg: i32) -> i32 {
    let mut d = deg % 360;
    if d < 0 {
        d = d + 360;
    }
    if d <= 90 {
        SIN_TABLE[d]
    } else if d <= 180 {
        SIN_TABLE[180 - d]
    } else if d <= 270 {
        -SIN_TABLE[d - 180]
    } else {
        -SIN_TABLE[360 - d]
    }
}

fn cos_deg(deg: i32) -> i32 {
    sin_deg(deg + 90)
}

fn isqrt(n: i32) -> i32 {
    if n <= 0 {
        return 0;
    }
    let mut x = n;
    let mut y = (x + 1) / 2;
    while y < x {
        x = y;
        y = (x + n / x) / 2;
    }
    x
}

fn fill_circle(cx: i32, cy: i32, r: i32, color: i32) {
    let mut y = cy - r;
    while y <= cy + r {
        let dy = y - cy;
        let r2 = r * r;
        let dy2 = dy * dy;
        if r2 >= dy2 {
            let dx = isqrt(r2 - dy2);
            display::fill_rect(cx - dx, y, dx * 2 + 1, 1, color);
        }
        y = y + 1;
    }
}

fn draw_thick_line(x0: i32, y0: i32, x1: i32, y1: i32, thickness: i32, color: i32) {
    let mut dx = -thickness / 2;
    while dx <= thickness / 2 {
        let mut dy = -thickness / 2;
        while dy <= thickness / 2 {
            display::draw_line(x0 + dx, y0 + dy, x1 + dx, y1 + dy, color);
            dy = dy + 1;
        }
        dx = dx + 1;
    }
}

fn frame(t: i32) {
    // Background room
    display::clear(0x18151D);
    
    // Wooden Floor at bottom
    display::fill_rect(0, 470, 512, 42, 0x2A1B12);
    display::fill_rect(0, 470, 512, 3, 0x3D281C);

    // 1. BASE / PEDESTAL (y: 390 to 475)
    // Feet
    display::fill_rect(160, 465, 30, 10, 0x210F06);
    display::fill_rect(322, 465, 30, 10, 0x210F06);
    
    // Lower Base block
    display::fill_rect(166, 400, 180, 65, 0x3B1D0E);
    display::fill_rect(161, 395, 190, 8, 0x542B16);
    display::fill_rect(161, 460, 190, 8, 0x210F06);
    
    // Base inner panel
    display::fill_rect(181, 410, 150, 45, 0x2A1409);
    display::fill_rect(183, 412, 146, 41, 0x472312);

    // 2. TRUNK / WAIST CABINET (y: 200 to 395)
    // Outer trunk frame
    display::fill_rect(181, 200, 150, 195, 0x3B1D0E);
    display::fill_rect(181, 200, 6, 195, 0x542B16);
    display::fill_rect(325, 200, 6, 195, 0x210F06);

    // Trunk Glass Door interior shadow
    display::fill_rect(191, 210, 130, 175, 0x120A05);

    // Inside trunk: Brass weights on chains
    // Left weight
    display::draw_line(236, 210, 236, 280, 0x8B6508);
    display::fill_rect(232, 280, 8, 30, 0xD4AF37);
    display::fill_rect(231, 278, 10, 3, 0x8B6508);
    display::fill_rect(231, 309, 10, 3, 0x8B6508);

    // Right weight
    display::draw_line(276, 210, 276, 260, 0x8B6508);
    display::fill_rect(272, 260, 8, 30, 0xD4AF37);
    display::fill_rect(271, 258, 10, 3, 0x8B6508);
    display::fill_rect(271, 289, 10, 3, 0x8B6508);

    // Swinging Pendulum!
    let swing_angle = (sin_deg(t / 4) * 18) / 1000;
    let pend_x = 256 + (sin_deg(swing_angle) * 140) / 1000;
    let pend_y = 210 + (cos_deg(swing_angle) * 140) / 1000;
    draw_thick_line(256, 210, pend_x, pend_y, 2, 0xD4AF37);
    fill_circle(pend_x, pend_y, 14, 0xD4AF37);
    fill_circle(pend_x, pend_y, 11, 0xF5D77F);
    fill_circle(pend_x, pend_y, 5, 0x8B6508);

    // Glass door frame outline
    display::fill_rect(187, 206, 138, 183, 0x542B16);
    display::fill_rect(191, 210, 130, 175, 0x120A05);
    display::draw_line(195, 220, 240, 380, 0x2A2530);

    // 3. HEAD HOUSING / BONNET (y: 30 to 200)
    // Crown Arch / Swan-neck pediment
    let mut px = 160;
    while px <= 352 {
        let arch_h = 30 - ((px - 256) * (px - 256)) / 320;
        if arch_h > 0 {
            display::fill_rect(px, 50 - arch_h, 1, arch_h + 15, 0x542B16);
        }
        px = px + 1;
    }

    // Top Brass Finial
    fill_circle(256, 20, 7, 0xD4AF37);
    display::fill_rect(254, 26, 5, 10, 0x8B6508);

    // Main Head Box Frame
    display::fill_rect(166, 50, 180, 150, 0x3B1D0E);
    display::fill_rect(161, 45, 190, 8, 0x703C20);
    display::fill_rect(161, 195, 190, 8, 0x542B16);

    // Decorative side columns on head
    display::fill_rect(168, 55, 10, 140, 0x542B16);
    display::fill_rect(169, 55, 3, 140, 0x703C20);
    display::fill_rect(334, 55, 10, 140, 0x210F06);
    display::fill_rect(335, 55, 3, 140, 0x542B16);

    // Clock Face Cavity / Frame
    fill_circle(256, 125, 68, 0x210F06);
    fill_circle(256, 125, 65, 0x8B6508);
    fill_circle(256, 125, 63, 0xD4AF37);
    fill_circle(256, 125, 60, 0x120A05);

    // COMPOSE THE CLOCK FACE MODULE INSIDE THE HOUSING!
    let _handle = compose::spawn_module("clock-face", 196, 65, 120, 120);

    display::present();
}
