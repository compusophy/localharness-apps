use host::display;
use host::math;

// State Slots:
// 0: init flag (1 when initialized)
// 1: ball_x (fixed-point: x * 100)
// 2: ball_y (fixed-point: y * 100)
// 3: ball_vx (fixed-point velocity)
// 4: ball_vy (fixed-point velocity)
// 5: score
// 6: balls_left
// 7: state (0: ready in plunger, 1: launched/in-play, 2: game over)
// 8: left_flipper (0 down, 1 up)
// 9: right_flipper (0 down, 1 up)
// 10: bumper1_flash
// 11: bumper2_flash
// 12: bumper3_flash
// 13: plunger_power
// 14: high_score
// 15: drop_target1
// 16: drop_target2
// 17: drop_target3
// 18: spinner_angle
// 19: spinner_speed
// 20: rollover_l
// 21: rollover_m
// 22: rollover_r
// 23: multiplier
// 24: gate_passed
// 25: left_flipper_prev
// 26: right_flipper_prev

fn init_game() {
    display::state_set(0, 1);
    display::state_set(1, 46000);
    display::state_set(2, 43000);
    display::state_set(3, 0);
    display::state_set(4, 0);
    display::state_set(5, 0);
    display::state_set(6, 3);
    display::state_set(7, 0);
    display::state_set(8, 0);
    display::state_set(9, 0);
    display::state_set(10, 0);
    display::state_set(11, 0);
    display::state_set(12, 0);
    display::state_set(13, 0);
    display::state_set(15, 1);
    display::state_set(16, 1);
    display::state_set(17, 1);
    display::state_set(18, 0);
    display::state_set(19, 0);
    display::state_set(20, 0);
    display::state_set(21, 0);
    display::state_set(22, 0);
    display::state_set(23, 1);
    display::state_set(24, 0);
    display::state_set(25, 0);
    display::state_set(26, 0);
}

fn reset_ball() {
    display::state_set(1, 46000);
    display::state_set(2, 43000);
    display::state_set(3, 0);
    display::state_set(4, 0);
    display::state_set(7, 0);
    display::state_set(13, 0);
    display::state_set(24, 0);
}

fn draw_disk(cx: i32, cy: i32, r: i32, col: i32) {
    let mut dy = -r;
    while dy <= r {
        let mut dx = -r;
        while dx <= r {
            if dx * dx + dy * dy <= r * r {
                display::set_pixel(cx + dx, cy + dy, col);
            }
            dx = dx + 1;
        }
        dy = dy + 1;
    }
}

pub fn frame(t: i32) {
    if display::state_get(0) == 0 {
        init_game();
    }

    let mut bx = display::state_get(1);
    let mut by = display::state_get(2);
    let mut bvx = display::state_get(3);
    let mut bvy = display::state_get(4);
    let mut score = display::state_get(5);
    let mut balls = display::state_get(6);
    let mut gstate = display::state_get(7);
    let mut lf = 0;
    let mut rf = 0;
    let mut b1_hit = display::state_get(10);
    let mut b2_hit = display::state_get(11);
    let mut b3_hit = display::state_get(12);
    let mut plunger = display::state_get(13);
    let mut hi_score = display::state_get(14);
    let mut dt1 = display::state_get(15);
    let mut dt2 = display::state_get(16);
    let mut dt3 = display::state_get(17);
    let mut s_angle = display::state_get(18);
    let mut s_speed = display::state_get(19);
    let mut ro_l = display::state_get(20);
    let mut ro_m = display::state_get(21);
    let mut ro_r = display::state_get(22);
    let mut mult = display::state_get(23);
    let mut gate_passed = display::state_get(24);

    let lf_prev = display::state_get(25);
    let rf_prev = display::state_get(26);

    let px = display::pointer_x();
    let py = display::pointer_y();
    let p_down = display::pointer_down();

    // Spinner slowdown
    if s_speed > 0 {
        s_angle = (s_angle + s_speed) % 256;
        s_speed = s_speed - 1;
    }

    // Input Handling: Screen is split: Left half = Left Flipper, Right half = Right Flipper, Plunger zone = Bottom Right
    if p_down != 0 {
        if gstate == 2 {
            init_game();
            gstate = 0;
            score = 0;
            balls = 3;
            mult = 1;
        } else if gstate == 0 {
            if px >= 420 && py >= 300 {
                plunger = plunger + 32;
                if plunger > 950 { plunger = 950; }
            } else {
                if px < 256 { lf = 1; } else { rf = 1; }
            }
        } else {
            if px < 256 { lf = 1; } else { rf = 1; }
        }
    } else {
        if gstate == 0 && plunger > 60 {
            // Launch ball up right plunger chute
            bvy = -1800 - (plunger * 2);
            bvx = -40;
            gstate = 1;
            plunger = 0;
        } else {
            plunger = 0;
        }
    }

    display::state_set(8, lf);
    display::state_set(9, rf);

    // Dynamic Flipper swing detection (flips up this frame = high angular velocity)
    let lf_swinging = if lf == 1 && lf_prev == 0 { 1 } else { 0 };
    let rf_swinging = if rf == 1 && rf_prev == 0 { 1 } else { 0 };

    display::state_set(25, lf);
    display::state_set(26, rf);

    // Physics Engine
    if gstate == 1 {
        // Gravity
        bvy = bvy + 18;
        if bvy > 1400 { bvy = 1400; }
        if bvx > 1400 { bvx = 1400; }
        if bvx < -1400 { bvx = -1400; }

        // Air damping
        bvx = (bvx * 996) / 1000;

        bx = bx + bvx;
        by = by + bvy;

        let cur_x = bx / 100;
        let cur_y = by / 100;

        // Plunger Launch & Top Arch Guide
        if cur_y < 120 && cur_x > 380 {
            let def_dist = (cur_x - 380) + (120 - cur_y);
            if def_dist > 40 {
                bvx = -550;
                bvy = 220;
                bx = 370 * 100;
                gate_passed = 1;
            }
        }

        // One-Way Gate: ball can't fall back down plunger chute
        if gate_passed == 1 {
            if cur_x >= 436 && cur_y > 110 && cur_y < 480 {
                bx = 432 * 100;
                bvx = -bvx * 8 / 10 - 60;
            }
        } else {
            if cur_x <= 440 && cur_x >= 434 && cur_y > 130 && cur_y < 480 {
                bx = 444 * 100;
                bvx = 50;
            }
        }

        // Top Outer Arc
        if cur_y < 50 {
            by = 52 * 100;
            bvy = 250;
            bvx = bvx - 100;
        }

        // Left Outer Wall
        if cur_x < 55 {
            bx = 56 * 100;
            bvx = -bvx * 8 / 10;
        }

        // Right Outer Wall
        if cur_x > 470 {
            bx = 468 * 100;
            bvx = -bvx * 8 / 10;
        }

        // Top-Left Curve Deflector
        if cur_x < 120 && cur_y < 110 {
            if (120 - cur_x) + (110 - cur_y) > 65 {
                bvx = 350;
                bvy = 300;
                score = score + (100 * mult);
            }
        }

        // Rollover Lanes
        if cur_y >= 70 && cur_y <= 85 {
            if cur_x >= 140 && cur_x <= 170 && ro_l == 0 {
                ro_l = 1; score = score + (250 * mult);
            }
            if cur_x >= 225 && cur_x <= 255 && ro_m == 0 {
                ro_m = 1; score = score + (250 * mult);
            }
            if cur_x >= 310 && cur_x <= 340 && ro_r == 0 {
                ro_r = 1; score = score + (250 * mult);
            }
            if ro_l == 1 && ro_m == 1 && ro_r == 1 {
                mult = mult + 1;
                if mult > 5 { mult = 5; }
                ro_l = 0; ro_m = 0; ro_r = 0;
                score = score + 2000;
            }
        }

        // Drop Targets on Left
        if cur_x >= 56 && cur_x <= 78 {
            if dt1 == 1 && cur_y >= 175 && cur_y <= 195 {
                dt1 = 0; score = score + (500 * mult); bvx = 450;
            }
            if dt2 == 1 && cur_y >= 200 && cur_y <= 220 {
                dt2 = 0; score = score + (500 * mult); bvx = 450;
            }
            if dt3 == 1 && cur_y >= 225 && cur_y <= 245 {
                dt3 = 0; score = score + (500 * mult); bvx = 450;
            }
            if dt1 == 0 && dt2 == 0 && dt3 == 0 {
                dt1 = 1; dt2 = 1; dt3 = 1;
                score = score + (3000 * mult);
            }
        }

        // Spinner Lane
        if cur_x >= 365 && cur_x <= 390 && cur_y >= 200 && cur_y <= 230 {
            s_speed = s_speed + 15;
            if s_speed > 60 { s_speed = 60; }
            score = score + (50 * mult);
        }

        // Active Bumpers
        let dx1 = cur_x - 175;
        let dy1 = cur_y - 160;
        if dx1 * dx1 + dy1 * dy1 <= 28 * 28 {
            b1_hit = 12; score = score + (300 * mult);
            bvx = dx1 * 32; bvy = dy1 * 32;
        }

        let dx2 = cur_x - 305;
        let dy2 = cur_y - 160;
        if dx2 * dx2 + dy2 * dy2 <= 28 * 28 {
            b2_hit = 12; score = score + (300 * mult);
            bvx = dx2 * 32; bvy = dy2 * 32;
        }

        let dx3 = cur_x - 240;
        let dy3 = cur_y - 240;
        if dx3 * dx3 + dy3 * dy3 <= 32 * 32 {
            b3_hit = 12; score = score + (500 * mult);
            bvx = dx3 * 28; bvy = dy3 * 28;
        }

        // Slingshots
        if cur_x >= 85 && cur_x <= 140 && cur_y >= 330 && cur_y <= 395 {
            if cur_x - 85 < (cur_y - 330) * 50 / 65 {
                bvx = 550; bvy = -450; score = score + (150 * mult);
            }
        }
        if cur_x >= 340 && cur_x <= 395 && cur_y >= 330 && cur_y <= 395 {
            if 395 - cur_x < (cur_y - 330) * 50 / 65 {
                bvx = -550; bvy = -450; score = score + (150 * mult);
            }
        }

        // Inlane / Outlane Dividers
        if cur_x >= 78 && cur_x <= 84 && cur_y >= 380 && cur_y <= 450 {
            bvx = -bvx; bx = 76 * 100;
        }
        if cur_x >= 396 && cur_x <= 402 && cur_y >= 380 && cur_y <= 450 {
            bvx = -bvx; bx = 404 * 100;
        }

        // Bottom guide ramps into flipper area
        if cur_x >= 50 && cur_x <= 130 && cur_y >= 420 && cur_y <= 445 {
            let guide_y = 430 + (cur_x - 50) * 12 / 80;
            if cur_y >= guide_y - 10 && cur_y <= guide_y + 10 {
                by = (guide_y - 10) * 100;
                bvy = 120;
                bvx = bvx + 80;
            }
        }
        if cur_x >= 350 && cur_x <= 436 && cur_y >= 420 && cur_y <= 445 {
            let guide_y = 442 - (cur_x - 350) * 12 / 86;
            if cur_y >= guide_y - 10 && cur_y <= guide_y + 10 {
                by = (guide_y - 10) * 100;
                bvy = 120;
                bvx = bvx - 80;
            }
        }

        // ==================== ROBUST FLIPPER COLLISION ====================
        // Left Flipper: Root (130, 442) -> Tip: Down=(205, 468), Up=(195, 415)
        let l_tip_x = if lf != 0 { 195 } else { 205 };
        let l_tip_y = if lf != 0 { 415 } else { 468 };

        if cur_x >= 125 && cur_x <= 215 && cur_y >= 400 && cur_y <= 480 {
            let seg_dx = l_tip_x - 130;
            let seg_dy = l_tip_y - 442;
            let p_dx = cur_x - 130;
            let p_dy = cur_y - 442;

            let dot = p_dx * seg_dx + p_dy * seg_dy;
            let len_sq = seg_dx * seg_dx + seg_dy * seg_dy;

            let mut t_prog = (dot * 100) / len_sq;
            if t_prog < 0 { t_prog = 0; }
            if t_prog > 100 { t_prog = 100; }

            let closest_x = 130 + (seg_dx * t_prog) / 100;
            let closest_y = 442 + (seg_dy * t_prog) / 100;

            let dist_x = cur_x - closest_x;
            let dist_y = cur_y - closest_y;
            let dist_sq = dist_x * dist_x + dist_y * dist_y;

            // Ball radius is 8, flipper half-thickness is 6 -> threshold ~14
            if dist_sq <= 15 * 15 {
                if lf != 0 || lf_swinging != 0 {
                    // Upward flipper power scaled by tip distance
                    let power = if lf_swinging != 0 { 1400 } else { 950 };
                    bvy = -(power + (t_prog * 4));
                    bvx = 250 + (t_prog * 5);
                    score = score + (100 * mult);
                } else {
                    // Ball bouncing or rolling along down-flipper
                    bvy = -bvy * 4 / 10 - 180;
                    bvx = bvx + 100;
                }
                by = (closest_y - 12) * 100;
                bx = (closest_x + dist_x) * 100;
            }
        }

        // Right Flipper: Root (350, 442) -> Tip: Down=(275, 468), Up=(285, 415)
        let r_tip_x = if rf != 0 { 285 } else { 275 };
        let r_tip_y = if rf != 0 { 415 } else { 468 };

        if cur_x >= 265 && cur_x <= 355 && cur_y >= 400 && cur_y <= 480 {
            let seg_dx = r_tip_x - 350;
            let seg_dy = r_tip_y - 442;
            let p_dx = cur_x - 350;
            let p_dy = cur_y - 442;

            let dot = p_dx * seg_dx + p_dy * seg_dy;
            let len_sq = seg_dx * seg_dx + seg_dy * seg_dy;

            let mut t_prog = (dot * 100) / len_sq;
            if t_prog < 0 { t_prog = 0; }
            if t_prog > 100 { t_prog = 100; }

            let closest_x = 350 + (seg_dx * t_prog) / 100;
            let closest_y = 442 + (seg_dy * t_prog) / 100;

            let dist_x = cur_x - closest_x;
            let dist_y = cur_y - closest_y;
            let dist_sq = dist_x * dist_x + dist_y * dist_y;

            if dist_sq <= 15 * 15 {
                if rf != 0 || rf_swinging != 0 {
                    let power = if rf_swinging != 0 { 1400 } else { 950 };
                    bvy = -(power + (t_prog * 4));
                    bvx = -(250 + (t_prog * 5));
                    score = score + (100 * mult);
                } else {
                    bvy = -bvy * 4 / 10 - 180;
                    bvx = bvx - 100;
                }
                by = (closest_y - 12) * 100;
                bx = (closest_x + dist_x) * 100;
            }
        }

        // Bottom Drain
        if cur_y > 510 {
            balls = balls - 1;
            if balls <= 0 {
                gstate = 2;
                if score > hi_score { hi_score = score; }
            } else {
                reset_ball();
                bx = 46000;
                by = 43000;
                bvx = 0;
                bvy = 0;
                gstate = 0;
                gate_passed = 0;
            }
        }
    }

    if b1_hit > 0 { b1_hit = b1_hit - 1; }
    if b2_hit > 0 { b2_hit = b2_hit - 1; }
    if b3_hit > 0 { b3_hit = b3_hit - 1; }

    display::state_set(1, bx);
    display::state_set(2, by);
    display::state_set(3, bvx);
    display::state_set(4, bvy);
    display::state_set(5, score);
    display::state_set(6, balls);
    display::state_set(7, gstate);
    display::state_set(10, b1_hit);
    display::state_set(11, b2_hit);
    display::state_set(12, b3_hit);
    display::state_set(13, plunger);
    display::state_set(14, hi_score);
    display::state_set(15, dt1);
    display::state_set(16, dt2);
    display::state_set(17, dt3);
    display::state_set(18, s_angle);
    display::state_set(19, s_speed);
    display::state_set(20, ro_l);
    display::state_set(21, ro_m);
    display::state_set(22, ro_r);
    display::state_set(23, mult);
    display::state_set(24, gate_passed);

    // ==================== RENDERING ====================
    display::clear(0x0c0d14);

    // Playfield bed
    display::fill_rect(44, 44, 432, 458, 0x141829);

    // Decorative retro grid lines
    let mut grid_y = 60;
    while grid_y < 440 {
        display::fill_rect(50, grid_y, 385, 1, 0x1d2238);
        grid_y = grid_y + 35;
    }

    // Outer Cabinet Rails
    display::fill_rect(40, 40, 6, 465, 0x475569);
    display::fill_rect(474, 40, 6, 465, 0x475569);
    display::fill_rect(40, 40, 440, 6, 0x475569);

    // Top Launch Arch
    display::draw_line(380, 40, 474, 120, 0x64748b);
    display::draw_line(370, 42, 474, 130, 0x334155);

    // Top Left Guide
    display::fill_triangle(46, 46, 120, 46, 46, 120, 0x334155);
    display::draw_line(46, 120, 120, 46, 0x38bdf8);

    // Plunger Lane Divider & Spring Gate
    display::fill_rect(436, 125, 4, 355, 0x64748b);
    if gate_passed == 1 {
        display::draw_line(436, 125, 468, 125, 0xef4444);
    } else {
        display::draw_line(436, 125, 455, 95, 0x22c55e);
    }

    // Rollover Lanes
    display::fill_rect(130, 60, 4, 30, 0x94a3b8);
    display::fill_rect(215, 60, 4, 30, 0x94a3b8);
    display::fill_rect(300, 60, 4, 30, 0x94a3b8);
    display::fill_rect(350, 60, 4, 30, 0x94a3b8);

    let ro_col_l = if ro_l != 0 { 0xfacc15 } else { 0x334155 };
    let ro_col_m = if ro_m != 0 { 0xfacc15 } else { 0x334155 };
    let ro_col_r = if ro_r != 0 { 0xfacc15 } else { 0x334155 };
    display::fill_rect(145, 75, 20, 6, ro_col_l);
    display::fill_rect(230, 75, 20, 6, ro_col_m);
    display::fill_rect(315, 75, 20, 6, ro_col_r);

    // Drop Targets
    if dt1 == 1 { display::fill_rect(58, 178, 14, 18, 0x38bdf8); } else { display::fill_rect(58, 185, 14, 4, 0x1e293b); }
    if dt2 == 1 { display::fill_rect(58, 203, 14, 18, 0x38bdf8); } else { display::fill_rect(58, 210, 14, 4, 0x1e293b); }
    if dt3 == 1 { display::fill_rect(58, 228, 14, 18, 0x38bdf8); } else { display::fill_rect(58, 235, 14, 4, 0x1e293b); }

    // Spinner
    display::fill_rect(370, 195, 2, 40, 0x94a3b8);
    display::fill_rect(390, 195, 2, 40, 0x94a3b8);
    let spin_offset = (math::sin(s_angle) * 8) / 256;
    display::fill_rect(372, 212 + spin_offset, 17, 4, 0xf43f5e);

    // Bumpers
    let b1_outer = if b1_hit > 0 { 0xffffff } else { 0xd946ef };
    let b2_outer = if b2_hit > 0 { 0xffffff } else { 0xd946ef };
    let b3_outer = if b3_hit > 0 { 0xffffff } else { 0x06b6d4 };

    draw_disk(175, 160, 24, b1_outer);
    draw_disk(175, 160, 16, 0x18182f);
    draw_disk(175, 160, 8, b1_outer);

    draw_disk(305, 160, 24, b2_outer);
    draw_disk(305, 160, 16, 0x18182f);
    draw_disk(305, 160, 8, b2_outer);

    draw_disk(240, 240, 28, b3_outer);
    draw_disk(240, 240, 18, 0x18182f);
    draw_disk(240, 240, 10, b3_outer);

    // Slingshots
    display::fill_triangle(85, 330, 135, 395, 85, 395, 0x10b981);
    display::draw_line(85, 330, 135, 395, 0xa7f3d0);
    draw_disk(135, 395, 4, 0xffffff);

    display::fill_triangle(395, 330, 345, 395, 395, 395, 0x10b981);
    display::draw_line(395, 330, 345, 395, 0xa7f3d0);
    draw_disk(345, 395, 4, 0xffffff);

    // Inlane / Outlane Guides
    display::fill_rect(78, 380, 4, 65, 0x475569);
    display::fill_rect(396, 380, 4, 65, 0x475569);
    display::draw_line(46, 430, 130, 442, 0x64748b);
    display::draw_line(436, 430, 350, 442, 0x64748b);

    // Flippers
    let l_tip_x = if lf != 0 { 195 } else { 205 };
    let l_tip_y = if lf != 0 { 415 } else { 468 };
    let r_tip_x = if rf != 0 { 285 } else { 275 };
    let r_tip_y = if rf != 0 { 415 } else { 468 };

    let flip_color = 0xf43f5e;
    // Left Flipper Body & Rubber
    display::fill_triangle(130, 436, 130, 448, l_tip_x, l_tip_y, flip_color);
    draw_disk(130, 442, 7, 0xffffff);
    draw_disk(l_tip_x, l_tip_y, 5, 0xffffff);
    display::draw_line(130, 436, l_tip_x, l_tip_y - 3, 0xffe4e6);

    // Right Flipper Body & Rubber
    display::fill_triangle(350, 436, 350, 448, r_tip_x, r_tip_y, flip_color);
    draw_disk(350, 442, 7, 0xffffff);
    draw_disk(r_tip_x, r_tip_y, 5, 0xffffff);
    display::draw_line(350, 436, r_tip_x, r_tip_y - 3, 0xffe4e6);

    // Drain
    display::fill_rect(190, 495, 100, 15, 0x000000);

    // Plunger
    if gstate == 0 {
        let p_offset = plunger / 18;
        display::fill_rect(450, 455 + p_offset, 20, 30, 0xf97316);
        let mut sp_y = 430;
        while sp_y < 455 + p_offset {
            display::fill_rect(452, sp_y, 16, 2, 0xcbd5e1);
            sp_y = sp_y + 5;
        }
    }

    // Ball
    let ball_draw_x = bx / 100;
    let ball_draw_y = by / 100;
    draw_disk(ball_draw_x, ball_draw_y, 8, 0xe2e8f0);
    draw_disk(ball_draw_x - 2, ball_draw_y - 2, 3, 0xffffff);

    // HUD
    display::fill_rect(0, 0, 512, 38, 0x090a0f);
    display::draw_char(14, 13, 83, 0x38bdf8, 1);
    display::draw_char(22, 13, 67, 0x38bdf8, 1);
    display::draw_char(30, 13, 79, 0x38bdf8, 1);
    display::draw_char(38, 13, 82, 0x38bdf8, 1);
    display::draw_char(46, 13, 69, 0x38bdf8, 1);
    display::draw_number(58, 10, score, 0xffffff, 2);

    if mult > 1 {
        display::fill_rect(205, 8, 38, 22, 0x7c3aed);
        display::draw_number(212, 11, mult, 0xfacc15, 2);
        display::draw_char(228, 11, 88, 0xfacc15, 2);
    }

    display::draw_char(340, 13, 66, 0xf472b6, 1);
    display::draw_char(348, 13, 65, 0xf472b6, 1);
    display::draw_char(356, 13, 76, 0xf472b6, 1);
    display::draw_char(364, 13, 76, 0xf472b6, 1);
    display::draw_char(372, 13, 83, 0xf472b6, 1);
    display::draw_number(390, 10, balls, 0xffffff, 2);

    display::draw_char(430, 13, 72, 0x94a3b8, 1);
    display::draw_char(438, 13, 73, 0x94a3b8, 1);
    display::draw_number(450, 11, hi_score, 0xfacc15, 1);

    // Overlays & Prompts
    if gstate == 0 {
        display::draw_char(446, 310, 80, 0xf97316, 1);
        display::draw_char(454, 310, 85, 0xf97316, 1);
        display::draw_char(462, 310, 76, 0xf97316, 1);
        display::draw_char(470, 310, 76, 0xf97316, 1);

        display::fill_rect(90, 280, 85, 24, 0x1e293b);
        display::draw_char(100, 286, 76, 0x22c55e, 1);
        display::draw_char(108, 286, 69, 0x22c55e, 1);
        display::draw_char(116, 286, 70, 0x22c55e, 1);
        display::draw_char(124, 286, 84, 0x22c55e, 1);

        display::fill_rect(265, 280, 95, 24, 0x1e293b);
        display::draw_char(275, 286, 82, 0x22c55e, 1);
        display::draw_char(283, 286, 73, 0x22c55e, 1);
        display::draw_char(291, 286, 71, 0x22c55e, 1);
        display::draw_char(299, 286, 72, 0x22c55e, 1);
        display::draw_char(307, 286, 84, 0x22c55e, 1);
    } else if gstate == 2 {
        display::fill_rect(90, 200, 320, 110, 0x000000);
        display::fill_rect(95, 205, 310, 100, 0x18182f);
        display::draw_char(150, 220, 71, 0xef4444, 2);
        display::draw_char(166, 220, 65, 0xef4444, 2);
        display::draw_char(182, 220, 77, 0xef4444, 2);
        display::draw_char(198, 220, 69, 0xef4444, 2);
        display::draw_char(226, 220, 79, 0xef4444, 2);
        display::draw_char(242, 220, 86, 0xef4444, 2);
        display::draw_char(258, 220, 69, 0xef4444, 2);
        display::draw_char(274, 220, 82, 0xef4444, 2);

        display::draw_char(140, 265, 84, 0xfacc15, 1);
        display::draw_char(148, 265, 65, 0xfacc15, 1);
        display::draw_char(156, 265, 80, 0xfacc15, 1);
        display::draw_char(168, 265, 84, 0xfacc15, 1);
        display::draw_char(176, 265, 79, 0xfacc15, 1);
        display::draw_char(188, 265, 80, 0xfacc15, 1);
        display::draw_char(196, 265, 76, 0xfacc15, 1);
        display::draw_char(204, 265, 65, 0xfacc15, 1);
        display::draw_char(212, 265, 89, 0xfacc15, 1);
    }

    display::present();
}