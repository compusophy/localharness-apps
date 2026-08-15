use host::display;
use host::math;

// Slot mappings:
// 0: initialized flag (1 if initialized)
// 1: ball_x (fixed point: x * 100)
// 2: ball_y (fixed point: y * 100)
// 3: ball_vx
// 4: ball_vy
// 5: score
// 6: balls_left
// 7: state (0 = in plunger / waiting to launch, 1 = in play, 2 = game over)
// 8: left_flipper (0 = down, 1 = up)
// 9: right_flipper (0 = down, 1 = up)
// 10: bumper1_hit_timer
// 11: bumper2_hit_timer
// 12: bumper3_hit_timer
// 13: plunger_power
// 14: high_score

fn init_game() {
    display::state_set(0, 1);
    display::state_set(1, 46000); // Plunger lane x
    display::state_set(2, 42000); // Plunger lane y
    display::state_set(3, 0);
    display::state_set(4, 0);
    display::state_set(5, 0); // score
    display::state_set(6, 3); // 3 balls
    display::state_set(7, 0); // waiting to launch
    display::state_set(8, 0);
    display::state_set(9, 0);
    display::state_set(10, 0);
    display::state_set(11, 0);
    display::state_set(12, 0);
    display::state_set(13, 0);
}

fn reset_ball() {
    display::state_set(1, 46000);
    display::state_set(2, 42000);
    display::state_set(3, 0);
    display::state_set(4, 0);
    display::state_set(7, 0); // waiting launch
    display::state_set(13, 0);
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

    let px = display::pointer_x();
    let py = display::pointer_y();
    let p_down = display::pointer_down();

    // Input Handling
    if p_down != 0 {
        if gstate == 2 {
            // Restart game on tap
            init_game();
            gstate = 0;
            score = 0;
            balls = 3;
        } else if gstate == 0 {
            // Charging plunger
            if px >= 430 && px <= 490 && py >= 350 {
                plunger = plunger + 25;
                if plunger > 800 {
                    plunger = 800;
                }
            } else {
                if px < 256 {
                    lf = 1;
                } else {
                    rf = 1;
                }
            }
        } else {
            // Flippers during play
            if px < 256 {
                lf = 1;
            } else {
                rf = 1;
            }
        }
    } else {
        if gstate == 0 && plunger > 50 {
            // Launch ball!
            bvy = -(plunger * 4);
            bvx = -150;
            gstate = 1;
            plunger = 0;
        } else {
            plunger = 0;
        }
    }

    display::state_set(8, lf);
    display::state_set(9, rf);

    // Physics Update
    if gstate == 1 {
        // Gravity
        bvy = bvy + 18;
        if bvy > 1200 {
            bvy = 1200;
        }

        // Velocity damping / friction
        bvx = (bvx * 995) / 1000;

        bx = bx + bvx;
        by = by + bvy;

        let cur_x = bx / 100;
        let cur_y = by / 100;

        // Outer cabinet boundary collisions
        if cur_x < 60 {
            bx = 60 * 100;
            bvx = -bvx * 8 / 10;
        }
        if cur_x > 470 {
            bx = 470 * 100;
            bvx = -bvx * 8 / 10;
        }
        if cur_y < 60 {
            by = 60 * 100;
            bvy = -bvy * 8 / 10;
        }

        // Plunger lane separator (x = 440, from y = 140 down to y = 470)
        if cur_x >= 435 && cur_x <= 445 && cur_y >= 140 && cur_y <= 480 {
            if bvx > 0 {
                bx = 434 * 100;
                bvx = -bvx * 8 / 10;
            } else {
                bx = 446 * 100;
                bvx = -bvx * 8 / 10;
            }
        }

        // Top-right curved guide (angles ball into field from plunger)
        if cur_x > 400 && cur_y < 120 {
            if cur_x + cur_y < 460 {
                bvy = 200;
                bvx = -300;
            }
        }

        // Left top corner bumper angle
        if cur_x < 130 && cur_y < 130 {
            if (130 - cur_x) + (130 - cur_y) > 70 {
                bvx = 250;
                bvy = 250;
                score = score + 50;
            }
        }

        // Bumper 1 (x: 180, y: 170, r: 24)
        let dx1 = cur_x - 180;
        let dy1 = cur_y - 170;
        let dist1_sq = dx1 * dx1 + dy1 * dy1;
        if dist1_sq <= 30 * 30 {
            b1_hit = 10;
            score = score + 200;
            bvx = dx1 * 25;
            bvy = dy1 * 25;
        }

        // Bumper 2 (x: 320, y: 170, r: 24)
        let dx2 = cur_x - 320;
        let dy2 = cur_y - 170;
        let dist2_sq = dx2 * dx2 + dy2 * dy2;
        if dist2_sq <= 30 * 30 {
            b2_hit = 10;
            score = score + 200;
            bvx = dx2 * 25;
            bvy = dy2 * 25;
        }

        // Bumper 3 (x: 250, y: 250, r: 28)
        let dx3 = cur_x - 250;
        let dy3 = cur_y - 250;
        let dist3_sq = dx3 * dx3 + dy3 * dy3;
        if dist3_sq <= 34 * 34 {
            b3_hit = 10;
            score = score + 300;
            bvx = dx3 * 22;
            bvy = dy3 * 22;
        }

        // Slingshots (left: 110,340 to 140,400; right: 390,340 to 360,400)
        if cur_x >= 90 && cur_x <= 150 && cur_y >= 330 && cur_y <= 400 {
            if cur_x - 90 < (cur_y - 330) * 5 / 7 {
                bvx = 400;
                bvy = -350;
                score = score + 100;
            }
        }
        if cur_x >= 350 && cur_x <= 410 && cur_y >= 330 && cur_y <= 400 {
            if 410 - cur_x < (cur_y - 330) * 5 / 7 {
                bvx = -400;
                bvy = -350;
                score = score + 100;
            }
        }

        // Left Flipper collision
        // Rest: (140, 440) -> (210, 460) | Up: (140, 440) -> (205, 415)
        let l_tip_y = if lf != 0 { 415 } else { 460 };
        if cur_x >= 135 && cur_x <= 215 && cur_y >= 410 && cur_y <= 465 {
            let prog = (cur_x - 135) * 100 / 80;
            let flip_surf_y = 440 + (l_tip_y - 440) * prog / 100;
            if cur_y >= flip_surf_y - 12 && cur_y <= flip_surf_y + 12 {
                if lf != 0 {
                    bvy = -750;
                    bvx = 200 + prog * 3;
                    score = score + 50;
                } else {
                    bvy = -bvy * 5 / 10 - 150;
                    bvx = bvx + 100;
                }
                by = (flip_surf_y - 14) * 100;
            }
        }

        // Right Flipper collision
        // Rest: (360, 440) -> (290, 460) | Up: (360, 440) -> (295, 415)
        let r_tip_y = if rf != 0 { 415 } else { 460 };
        if cur_x >= 285 && cur_x <= 365 && cur_y >= 410 && cur_y <= 465 {
            let prog = (365 - cur_x) * 100 / 80;
            let flip_surf_y = 440 + (r_tip_y - 440) * prog / 100;
            if cur_y >= flip_surf_y - 12 && cur_y <= flip_surf_y + 12 {
                if rf != 0 {
                    bvy = -750;
                    bvx = -(200 + prog * 3);
                    score = score + 50;
                } else {
                    bvy = -bvy * 5 / 10 - 150;
                    bvx = bvx - 100;
                }
                by = (flip_surf_y - 14) * 100;
            }
        }

        // Bottom Drain
        if cur_y > 510 {
            balls = balls - 1;
            if balls <= 0 {
                gstate = 2; // Game Over
                if score > hi_score {
                    hi_score = score;
                }
            } else {
                reset_ball();
                bx = 46000;
                by = 42000;
                bvx = 0;
                bvy = 0;
                gstate = 0;
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

    // ==================== RENDERING ====================
    display::clear(0x10121d); // Dark navy cabinet background

    // Cabinet border & side walls
    display::fill_rect(45, 45, 422, 455, 0x181c2e); // Playfield bed
    display::fill_rect(40, 40, 10, 465, 0x3d4461);  // Left outer wall
    display::fill_rect(472, 40, 10, 465, 0x3d4461); // Right outer wall
    display::fill_rect(40, 40, 442, 10, 0x3d4461);  // Top outer wall

    // Plunger Lane Divider
    display::fill_rect(438, 130, 4, 350, 0x5a6385);

    // Playfield art lines
    display::fill_rect(60, 60, 368, 2, 0x272e48);
    display::fill_rect(249, 60, 2, 80, 0x272e48);

    // Top Rollover Targets
    display::fill_rect(160, 80, 25, 6, 0x00e5ff);
    display::fill_rect(238, 80, 25, 6, 0x00e5ff);
    display::fill_rect(315, 80, 25, 6, 0x00e5ff);

    // Bumpers
    let b1_col = if b1_hit > 0 { 0xffffff } else { 0xff007f };
    let b2_col = if b2_hit > 0 { 0xffffff } else { 0xff007f };
    let b3_col = if b3_hit > 0 { 0xffffff } else { 0xffea00 };

    draw_disk(180, 170, 22, b1_col);
    draw_disk(180, 170, 14, 0x181c2e);
    draw_disk(180, 170, 6, b1_col);

    draw_disk(320, 170, 22, b2_col);
    draw_disk(320, 170, 14, 0x181c2e);
    draw_disk(320, 170, 6, b2_col);

    draw_disk(250, 250, 26, b3_col);
    draw_disk(250, 250, 16, 0x181c2e);
    draw_disk(250, 250, 8, b3_col);

    // Slingshots (left & right angled bounce blocks)
    display::fill_triangle(90, 340, 140, 400, 90, 400, 0x76ff03);
    display::fill_triangle(410, 340, 360, 400, 410, 400, 0x76ff03);

    // Bottom Drain Guide Walls
    display::draw_line(50, 430, 140, 440, 0x5a6385);
    display::draw_line(438, 430, 360, 440, 0x5a6385);

    // Flippers
    let l_tip_y = if lf != 0 { 415 } else { 460 };
    let l_tip_x = if lf != 0 { 205 } else { 210 };
    let r_tip_y = if rf != 0 { 415 } else { 460 };
    let r_tip_x = if rf != 0 { 295 } else { 290 };

    let flip_col = 0xff5252;
    display::fill_triangle(140, 436, 140, 444, l_tip_x, l_tip_y, flip_col);
    draw_disk(140, 440, 5, 0xffffff);
    draw_disk(l_tip_x, l_tip_y, 4, flip_col);

    display::fill_triangle(360, 436, 360, 444, r_tip_x, r_tip_y, flip_col);
    draw_disk(360, 440, 5, 0xffffff);
    draw_disk(r_tip_x, r_tip_y, 4, flip_col);

    // Plunger & Spring
    if gstate == 0 {
        let p_depth = plunger / 20;
        display::fill_rect(452, 450 + p_depth, 16, 30, 0xff9100);
        let mut py_spr = 425;
        while py_spr < 450 + p_depth {
            display::fill_rect(454, py_spr, 12, 2, 0xaaaaaa);
            py_spr = py_spr + 6;
        }
    }

    // Ball
    let ball_draw_x = bx / 100;
    let ball_draw_y = by / 100;
    draw_disk(ball_draw_x, ball_draw_y, 8, 0xe0e0e0);
    draw_disk(ball_draw_x - 2, ball_draw_y - 2, 3, 0xffffff); // shine highlight

    // Header HUD
    display::fill_rect(0, 0, 512, 35, 0x0a0c14);
    display::draw_char(15, 12, 83, 0x80d8ff, 1); // 'S'
    display::draw_char(23, 12, 67, 0x80d8ff, 1); // 'C'
    display::draw_char(31, 12, 79, 0x80d8ff, 1); // 'O'
    display::draw_char(39, 12, 82, 0x80d8ff, 1); // 'R'
    display::draw_char(47, 12, 69, 0x80d8ff, 1); // 'E'
    display::draw_number(60, 10, score, 0xffffff, 2);

    display::draw_char(360, 12, 66, 0xff80ab, 1); // 'B'
    display::draw_char(368, 12, 65, 0xff80ab, 1); // 'A'
    display::draw_char(376, 12, 76, 0xff80ab, 1); // 'L'
    display::draw_char(384, 12, 76, 0xff80ab, 1); // 'L'
    display::draw_char(392, 12, 83, 0xff80ab, 1); // 'S'
    display::draw_number(410, 10, balls, 0xffffff, 2);

    // Game State Overlays & Instructions
    if gstate == 0 {
        display::draw_char(445, 330, 80, 0xff9100, 1); // 'P'
        display::draw_char(453, 330, 85, 0xff9100, 1); // 'U'
        display::draw_char(461, 330, 76, 0xff9100, 1); // 'L'
        display::draw_char(469, 330, 76, 0xff9100, 1); // 'L'

        display::draw_char(120, 290, 84, 0x76ff03, 1); // 'T'
        display::draw_char(128, 290, 65, 0x76ff03, 1); // 'A'
        display::draw_char(136, 290, 80, 0x76ff03, 1); // 'P'
        display::draw_char(148, 290, 76, 0x76ff03, 1); // 'L'
        display::draw_char(156, 290, 69, 0x76ff03, 1); // 'E'
        display::draw_char(164, 290, 70, 0x76ff03, 1); // 'F'
        display::draw_char(172, 290, 84, 0x76ff03, 1); // 'T'

        display::draw_char(280, 290, 84, 0x76ff03, 1); // 'T'
        display::draw_char(288, 290, 65, 0x76ff03, 1); // 'A'
        display::draw_char(296, 290, 80, 0x76ff03, 1); // 'P'
        display::draw_char(308, 290, 82, 0x76ff03, 1); // 'R'
        display::draw_char(316, 290, 73, 0x76ff03, 1); // 'I'
        display::draw_char(324, 290, 71, 0x76ff03, 1); // 'G'
        display::draw_char(332, 290, 72, 0x76ff03, 1); // 'H'
        display::draw_char(340, 290, 84, 0x76ff03, 1); // 'T'
    } else if gstate == 2 {
        display::fill_rect(100, 210, 300, 90, 0x000000);
        display::draw_char(150, 225, 71, 0xff1744, 2); // 'G'
        display::draw_char(166, 225, 65, 0xff1744, 2); // 'A'
        display::draw_char(182, 225, 77, 0xff1744, 2); // 'M'
        display::draw_char(198, 225, 69, 0xff1744, 2); // 'E'
        display::draw_char(222, 225, 79, 0xff1744, 2); // 'O'
        display::draw_char(238, 225, 86, 0xff1744, 2); // 'V'
        display::draw_char(254, 225, 69, 0xff1744, 2); // 'E'
        display::draw_char(270, 225, 82, 0xff1744, 2); // 'R'

        display::draw_char(140, 265, 84, 0xffffff, 1); // 'T'
        display::draw_char(148, 265, 65, 0xffffff, 1); // 'A'
        display::draw_char(156, 265, 80, 0xffffff, 1); // 'P'
        display::draw_char(168, 265, 84, 0xffffff, 1); // 'T'
        display::draw_char(176, 265, 79, 0xffffff, 1); // 'O'
        display::draw_char(188, 265, 80, 0xffffff, 1); // 'P'
        display::draw_char(196, 265, 76, 0xffffff, 1); // 'L'
        display::draw_char(204, 265, 65, 0xffffff, 1); // 'A'
        display::draw_char(212, 265, 89, 0xffffff, 1); // 'Y'
    }

    display::present();
}