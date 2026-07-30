use host::display;

const MAP_SIZE: i32 = 8;

fn get_map(x: i32, y: i32) -> i32 {
    if x < 0 || x >= MAP_SIZE || y < 0 || y >= MAP_SIZE {
        return 1;
    }
    if y == 0 || y == 7 || x == 0 || x == 7 {
        return 1;
    }
    if x == 3 && y == 3 {
        return 1;
    }
    if x == 4 && y == 5 {
        return 1;
    }
    0
}

fn init_game() {
    display::state_set(0, 3 * 256 + 128); // Player X = 3.5
    display::state_set(1, 2 * 256 + 128); // Player Y = 2.5
    display::state_set(2, 90);           // Angle = 90 deg
    display::state_set(3, 1);            // Playing
    display::state_set(4, 0);            // Score
    display::state_set(5, 0);            // Muzzle flash counter
    display::state_set(6, 0);            // Last pointer down
    display::state_set(7, 5 * 256 + 128); // Enemy X = 5.5
    display::state_set(8, 5 * 256 + 128); // Enemy Y = 5.5
    display::state_set(9, 1);            // Enemy alive
}

fn sin_deg(deg: i32) -> i32 {
    let mut a = deg % 360;
    if a < 0 { a = a + 360; }
    if a <= 90 {
        return (a * 256) / 90;
    } else if a <= 180 {
        return ((180 - a) * 256) / 90;
    } else if a <= 270 {
        return -(((a - 180) * 256) / 90);
    } else {
        return -(((360 - a) * 256) / 90);
    }
}

fn cos_deg(deg: i32) -> i32 {
    sin_deg(deg + 90)
}

pub fn frame(t: i32) {
    let state = display::state_get(3);
    if state == 0 {
        init_game();
    }

    let p_x = display::state_get(0);
    let p_y = display::state_get(1);
    let mut angle = display::state_get(2);

    let px_in = display::pointer_x();
    let py_in = display::pointer_y();
    let pd_in = display::pointer_down();
    let last_pd = display::state_get(6);
    display::state_set(6, pd_in);

    let screen_w = display::width();
    let screen_h = display::height();

    let mut move_forward = 0;
    let mut move_back = 0;
    let mut turn_left = 0;
    let mut turn_right = 0;
    let mut shoot = 0;

    if pd_in != 0 {
        if py_in > screen_h - 100 {
            if px_in < 100 {
                turn_left = 1;
            } else if px_in < 200 {
                move_forward = 1;
            } else if px_in < 300 {
                move_back = 1;
            } else if px_in < 400 {
                turn_right = 1;
            } else {
                if last_pd == 0 { shoot = 1; }
            }
        } else {
            if last_pd == 0 { shoot = 1; }
        }
    }

    if turn_left != 0 {
        angle = (angle + 355) % 360;
    }
    if turn_right != 0 {
        angle = (angle + 5) % 360;
    }
    display::state_set(2, angle);

    let speed = 12;
    if move_forward != 0 {
        let dx = (cos_deg(angle) * speed) / 256;
        let dy = (sin_deg(angle) * speed) / 256;
        let new_x = p_x + dx;
        let new_y = p_y + dy;
        if get_map(new_x / 256, p_y / 256) == 0 { display::state_set(0, new_x); }
        if get_map(p_x / 256, new_y / 256) == 0 { display::state_set(1, new_y); }
    }
    if move_back != 0 {
        let dx = (cos_deg(angle) * speed) / 256;
        let dy = (sin_deg(angle) * speed) / 256;
        let new_x = p_x - dx;
        let new_y = p_y - dy;
        if get_map(new_x / 256, p_y / 256) == 0 { display::state_set(0, new_x); }
        if get_map(p_x / 256, new_y / 256) == 0 { display::state_set(1, new_y); }
    }

    let cur_px = display::state_get(0);
    let cur_py = display::state_get(1);

    display::clear(0x111122);

    let view_h = screen_h - 100;
    display::fill_rect(0, 0, screen_w, view_h / 2, 0x222233);
    display::fill_rect(0, view_h / 2, screen_w, view_h / 2, 0x444444);

    let num_rays = 64;
    let slice_w = screen_w / num_rays;
    let fov = 60;
    let start_angle = angle - fov / 2;

    let mut r = 0;
    while r < num_rays {
        let ray_angle = (start_angle + (r * fov) / num_rays + 360) % 360;
        let cos_a = cos_deg(ray_angle);
        let sin_a = sin_deg(ray_angle);

        let mut dist = 0;
        let mut hit = 0;
        let mut hit_x = 0;
        let mut hit_y = 0;

        let mut step = 1;
        while step < 40 {
            dist = step * 16;
            hit_x = cur_px + (cos_a * dist) / 256;
            hit_y = cur_py + (sin_a * dist) / 256;
            let cell_x = hit_x / 256;
            let cell_y = hit_y / 256;

            if get_map(cell_x, cell_y) != 0 {
                hit = 1;
                break;
            }
            step = step + 1;
        }

        if hit != 0 {
            let corr_angle = (ray_angle - angle + 360) % 360;
            let corrected_dist = (dist * cos_deg(corr_angle)) / 256;
            let wall_h = if corrected_dist > 0 { (view_h * 180) / (corrected_dist + 1) } else { view_h };
            let wall_h_clamped = if wall_h > view_h { view_h } else { wall_h };

            let wall_y = (view_h - wall_h_clamped) / 2;
            let shade = if dist > 300 { 0x333366 } else if dist > 150 { 0x5555aa } else { 0x8888ff };

            display::fill_rect(r * slice_w, wall_y, slice_w, wall_h_clamped, shade);
        }

        r = r + 1;
    }

    if display::state_get(9) != 0 {
        let en_x = display::state_get(7);
        let en_y = display::state_get(8);
        let dx = en_x - cur_px;
        let dy = en_y - cur_py;

        let dist_to_enemy = (dx * dx + dy * dy);
        if dist_to_enemy > 100 {
            let target_angle = 45;
            let angle_diff = (angle - target_angle + 360) % 360;
            if angle_diff < 30 || angle_diff > 330 {
                let e_size = 40;
                let e_x = screen_w / 2 - e_size / 2;
                let e_y = view_h / 2 - e_size / 2;
                display::fill_rect(e_x, e_y, e_size, e_size, 0xff2222);
                display::fill_rect(e_x + 10, e_y + 10, e_size - 20, e_size - 20, 0xffff00);
            }
        }
    }

    let mut flash = display::state_get(5);
    if shoot != 0 {
        flash = 3;
        if display::state_get(9) != 0 {
            display::state_set(9, 0);
            let score = display::state_get(4) + 1;
            display::state_set(4, score);
        }
    }

    let cx = screen_w / 2;
    let cy = view_h / 2;
    display::fill_rect(cx - 8, cy - 1, 16, 2, 0x00ff00);
    display::fill_rect(cx - 1, cy - 8, 2, 16, 0x00ff00);

    let gun_x = screen_w / 2 - 30;
    let gun_y = view_h - 80;
    display::fill_rect(gun_x, gun_y, 60, 80, 0x444444);
    display::fill_rect(gun_x + 20, gun_y - 30, 20, 30, 0x222222);

    if flash > 0 {
        display::fill_rect(gun_x + 10, gun_y - 50, 40, 20, 0xffff00);
        display::state_set(5, flash - 1);
    }

    display::fill_rect(0, view_h, screen_w, 100, 0x111111);
    display::fill_rect(5, view_h + 10, 80, 80, 0x333333);
    display::draw_char(35, view_h + 40, 76, 0xffffff, 2);

    display::fill_rect(95, view_h + 10, 80, 80, 0x333333);
    display::draw_char(125, view_h + 40, 70, 0xffffff, 2);

    display::fill_rect(185, view_h + 10, 80, 80, 0x333333);
    display::draw_char(215, view_h + 40, 66, 0xffffff, 2);

    display::fill_rect(275, view_h + 10, 80, 80, 0x333333);
    display::draw_char(305, view_h + 40, 82, 0xffffff, 2);

    display::fill_rect(365, view_h + 10, 140, 80, 0xaa2222);
    display::draw_char(410, view_h + 40, 83, 0xffffff, 2);

    display::fill_rect(0, 0, screen_w, 24, 0x000000);
    display::draw_number(10, 5, display::state_get(4), 0x00ff00, 2);

    display::present();
}
