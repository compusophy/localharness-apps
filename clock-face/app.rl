use host::display;

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
    let w = display::width();
    let h = display::height();
    let cx = w / 2;
    let cy = h / 2;
    let r = if cx < cy { cx - 12 } else { cy - 12 };

    if r < 20 {
        return;
    }

    display::clear(0x000000);

    // Outer brass rim
    fill_circle(cx, cy, r + 8, 0x8B6508);
    fill_circle(cx, cy, r + 4, 0xD4AF37);
    fill_circle(cx, cy, r + 1, 0x5C4033);

    // Dial background (creamy parchment)
    fill_circle(cx, cy, r, 0xFBF8EE);

    // Inner subtle gold accent circle
    let inner_r = (r * 88) / 100;
    let mut a = 0;
    while a < 360 {
        let x = cx + (cos_deg(a) * inner_r) / 1000;
        let y = cy + (sin_deg(a) * inner_r) / 1000;
        display::set_pixel(x, y, 0xC5A059);
        a = a + 4;
    }

    // Ticks around perimeter
    let tick_r1 = (r * 82) / 100;
    let tick_r2 = (r * 94) / 100;
    let major_r1 = (r * 76) / 100;

    let mut tick = 0;
    while tick < 60 {
        let deg = tick * 6 - 90;
        let c = cos_deg(deg);
        let s = sin_deg(deg);

        let is_major = (tick % 5) == 0;
        let r_start = if is_major { major_r1 } else { tick_r1 };
        let x1 = cx + (c * r_start) / 1000;
        let y1 = cy + (s * r_start) / 1000;
        let x2 = cx + (c * tick_r2) / 1000;
        let y2 = cy + (s * tick_r2) / 1000;

        let col = if is_major { 0x3D2314 } else { 0x8B7355 };
        if is_major {
            draw_thick_line(x1, y1, x2, y2, 2, col);
        } else {
            display::draw_line(x1, y1, x2, y2, col);
        }
        tick = tick + 1;
    }

    // Numbers 1 to 12
    let num_r = (r * 68) / 100;
    let scale = if r > 150 { 2 } else { 1 };
    let mut num = 1;
    while num <= 12 {
        let deg = num * 30 - 90;
        let nx = cx + (cos_deg(deg) * num_r) / 1000;
        let ny = cy + (sin_deg(deg) * num_r) / 1000;

        let offset = if num >= 10 { scale * 6 } else { scale * 3 };
        display::draw_number(nx - offset, ny - (scale * 4), num, 0x2B1810, scale);
        num = num + 1;
    }

    // Hands calculation
    let sec_deg = ((t / 30) % 360) - 90;
    let min_deg = ((t / 360) % 360) - 90;
    let hour_deg = ((t / 4320) % 360) - 90 + 300;

    // Hour Hand
    let hr_len = (r * 48) / 100;
    let hx = cx + (cos_deg(hour_deg) * hr_len) / 1000;
    let hy = cy + (sin_deg(hour_deg) * hr_len) / 1000;
    draw_thick_line(cx, cy, hx, hy, 4, 0x1A0C06);

    // Minute Hand
    let mn_len = (r * 72) / 100;
    let mx = cx + (cos_deg(min_deg) * mn_len) / 1000;
    let my = cy + (sin_deg(min_deg) * mn_len) / 1000;
    draw_thick_line(cx, cy, mx, my, 3, 0x2B1810);

    // Second Hand
    let sc_len = (r * 82) / 100;
    let sx = cx + (cos_deg(sec_deg) * sc_len) / 1000;
    let sy = cy + (sin_deg(sec_deg) * sc_len) / 1000;
    display::draw_line(cx, cy, sx, sy, 0xB22222);

    // Second hand tail
    let stx = cx - (cos_deg(sec_deg) * (r * 18) / 100) / 1000;
    let sty = cy - (sin_deg(sec_deg) * (r * 18) / 100) / 1000;
    display::draw_line(cx, cy, stx, sty, 0xB22222);

    // Center brass cap
    fill_circle(cx, cy, (r * 6) / 100 + 2, 0xD4AF37);
    fill_circle(cx, cy, (r * 3) / 100 + 1, 0x2B1810);

    display::present();
}
