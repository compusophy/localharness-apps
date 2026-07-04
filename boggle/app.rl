use host::display;

fn rand_letter(seed: i32) -> i32 {
    let letters = [
        65, 65, 66, 67, 68, 69, 69, 70, 71, 72, 73, 73, 74, 75, 76, 77,
        78, 78, 79, 79, 80, 81, 82, 83, 84, 84, 85, 86, 87, 88, 89, 90
    ];
    let idx = seed % 32;
    letters[idx]
}

fn is_adjacent(idx1: i32, idx2: i32) -> bool {
    if idx1 < 0 || idx2 < 0 {
        return true;
    }
    let r1 = idx1 / 4;
    let c1 = idx1 % 4;
    let r2 = idx2 / 4;
    let c2 = idx2 % 4;
    let dr = r1 - r2;
    let dc = c1 - c2;
    dr >= -1 && dr <= 1 && dc >= -1 && dc <= 1
}

fn frame(t: i32) {
    let w = display::width();
    let h = display::height();
    
    // Colors
    let bg_color = 0x1E293B;      // Slate 800
    let board_bg = 0x334155;      // Slate 700
    let tile_bg = 0xF8FAFC;       // Slate 50
    let tile_sel_bg = 0x38BDF8;   // Sky 400
    let text_dark = 0x0F172A;     // Slate 900
    let text_light = 0xF1F5F9;    // Slate 100
    let accent_color = 0xF59E0B;  // Amber 500
    
    display::clear(bg_color);
    
    let state = display::state_get(0);
    
    if state == 0 {
        // --- TITLE SCREEN ---
        display::draw_char(w / 2 - 40, h / 2 - 60, 66, accent_color, 4); // B
        display::draw_char(w / 2 - 20, h / 2 - 60, 79, accent_color, 4); // O
        display::draw_char(w / 2, h / 2 - 60, 71, accent_color, 4);      // G
        display::draw_char(w / 2 + 20, h / 2 - 60, 71, accent_color, 4);  // G
        display::draw_char(w / 2 + 40, h / 2 - 60, 76, accent_color, 4);  // L
        display::draw_char(w / 2 + 60, h / 2 - 60, 69, accent_color, 4);  // E
        
        // Play Button
        let btn_x = w / 2 - 60;
        let btn_y = h / 2 + 20;
        let btn_w = 120;
        let btn_h = 30;
        display::fill_rect(btn_x, btn_y, btn_w, btn_h, accent_color);
        display::draw_char(btn_x + 25, btn_y + 10, 80, text_dark, 1); // P
        display::draw_char(btn_x + 35, btn_y + 10, 76, text_dark, 1); // L
        display::draw_char(btn_x + 45, btn_y + 10, 65, text_dark, 1); // A
        display::draw_char(btn_x + 55, btn_y + 10, 89, text_dark, 1); // Y
        
        // Click detection
        if display::pointer_down() != 0 {
            let px = display::pointer_x();
            let py = display::pointer_y();
            if px >= btn_x && px < btn_x + btn_w && py >= btn_y && py < btn_y + btn_h {
                // Initialize Board
                for i in 0..16 {
                    let letter = rand_letter(t + i * 17);
                    display::state_set(3 + i, letter);
                    display::state_set(19 + i, 0); // Unselected
                }
                display::state_set(0, 1); // Set state to Playing
                display::state_set(1, t); // Set start time
                display::state_set(2, 0); // Word length = 0
                display::state_set(35, -1); // Last selected = -1
                display::state_set(36, 0); // Score = 0
                display::state_set(37, t); // Debounce
            }
        }
    } else if state == 1 {
        // --- PLAYING STATE ---
        let start_time = display::state_get(1);
        let elapsed_sec = (t - start_time) / 1000;
        let total_time = 180; // 3 minutes
        let time_left = total_time - elapsed_sec;
        
        if time_left <= 0 {
            display::state_set(0, 2); // Game Over
        }
        
        // Draw Header (Score & Timer)
        display::draw_char(20, 20, 83, text_light, 1); // S
        display::draw_char(28, 20, 67, text_light, 1); // C
        display::draw_char(36, 20, 79, text_light, 1); // O
        display::draw_char(44, 20, 82, text_light, 1); // R
        display::draw_char(52, 20, 69, text_light, 1); // E
        display::draw_char(60, 20, 58, text_light, 1); // :
        display::draw_number(70, 20, display::state_get(36), accent_color, 1);
        
        display::draw_char(w - 100, 20, 84, text_light, 1); // T
        display::draw_char(w - 92, 20, 73, text_light, 1);  // I
        display::draw_char(w - 84, 20, 77, text_light, 1);  // M
        display::draw_char(w - 76, 20, 69, text_light, 1);  // E
        display::draw_char(w - 68, 20, 58, text_light, 1);  // :
        display::draw_number(w - 58, 20, time_left, accent_color, 1);
        
        // Draw 4x4 Board Background
        let board_x = w / 2 - 100;
        let board_y = 60;
        let board_size = 200;
        display::fill_rect(board_x, board_y, board_size, board_size, board_bg);
        
        // Draw Tiles
        let px = display::pointer_x();
        let py = display::pointer_y();
        let p_down = display::pointer_down() != 0;
        let last_click = display::state_get(37);
        let can_click = t - last_click > 250; // Debounce 250ms
        
        for r in 0..4 {
            for c in 0..4 {
                let idx = r * 4 + c;
                let tx = board_x + 10 + c * 46;
                let ty = board_y + 10 + r * 46;
                let tw = 40;
                let th = 40;
                
                let is_sel = display::state_get(19 + idx) != 0;
                let bg = if is_sel { tile_sel_bg } else { tile_bg };
                
                display::fill_rect(tx, ty, tw, th, bg);
                
                // Draw Letter
                let letter = display::state_get(3 + idx);
                display::draw_char(tx + 14, ty + 12, letter, text_dark, 2);
                
                // Click on tile
                if p_down && can_click {
                    if px >= tx && px < tx + tw && py >= ty && py < ty + th {
                        let last_sel = display::state_get(35);
                        if !is_sel && is_adjacent(last_sel, idx) {
                            // Select tile
                            display::state_set(19 + idx, 1);
                            let word_len = display::state_get(2);
                            display::state_set(38 + word_len, idx);
                            display::state_set(2, word_len + 1);
                            display::state_set(35, idx);
                            display::state_set(37, t); // Update debounce
                        }
                    }
                }
            }
        }
        
        // Draw Current Word
        let word_len = display::state_get(2);
        let word_y = board_y + board_size + 15;
        display::draw_char(20, word_y, 87, text_light, 1); // W
        display::draw_char(28, word_y, 79, text_light, 1); // O
        display::draw_char(36, word_y, 82, text_light, 1); // R
        display::draw_char(44, word_y, 68, text_light, 1); // D
        display::draw_char(52, word_y, 58, text_light, 1); // :
        
        for i in 0..word_len {
            let tile_idx = display::state_get(38 + i);
            let letter = display::state_get(3 + tile_idx);
            display::draw_char(70 + i * 12, word_y, letter, accent_color, 1);
        }
        
        // Submit Button
        let sub_x = w / 2 - 90;
        let sub_y = word_y + 20;
        let sub_w = 80;
        let sub_h = 25;
        display::fill_rect(sub_x, sub_y, sub_w, sub_h, 0x10B981); // Green 500
        display::draw_char(sub_x + 15, sub_y + 8, 83, text_light, 1); // S
        display::draw_char(sub_x + 23, sub_y + 8, 85, text_light, 1); // U
        display::draw_char(sub_x + 31, sub_y + 8, 66, text_light, 1); // B
        display::draw_char(sub_x + 39, sub_y + 8, 77, text_light, 1); // M
        display::draw_char(sub_x + 47, sub_y + 8, 73, text_light, 1); // I
        display::draw_char(sub_x + 55, sub_y + 8, 84, text_light, 1); // T
        
        // Clear Button
        let clr_x = w / 2 + 10;
        let clr_y = word_y + 20;
        let clr_w = 80;
        let clr_h = 25;
        display::fill_rect(clr_x, clr_y, clr_w, clr_h, 0xEF4444); // Red 500
        display::draw_char(clr_x + 20, clr_y + 8, 67, text_light, 1); // C
        display::draw_char(clr_x + 28, clr_y + 8, 76, text_light, 1); // L
        display::draw_char(clr_x + 36, clr_y + 8, 69, text_light, 1); // E
        display::draw_char(clr_x + 44, clr_y + 8, 65, text_light, 1); // A
        display::draw_char(clr_x + 52, clr_y + 8, 82, text_light, 1); // R
        
        // Handle Submit
        if p_down && can_click {
            if px >= sub_x && px < sub_x + sub_w && py >= sub_y && py < sub_y + sub_h {
                if word_len >= 3 {
                    // Score word
                    let pts = if word_len == 3 || word_len == 4 {
                        1
                    } else if word_len == 5 {
                        2
                    } else if word_len == 6 {
                        3
                    } else if word_len == 7 {
                        5
                    } else {
                        11
                    };
                    let cur_score = display::state_get(36);
                    display::state_set(36, cur_score + pts);
                }
                // Reset selection
                for i in 0..16 {
                    display::state_set(19 + i, 0);
                }
                display::state_set(2, 0); // Word length = 0
                display::state_set(35, -1); // Last selected = -1
                display::state_set(37, t);
            }
            
            // Handle Clear
            if px >= clr_x && px < clr_x + clr_w && py >= clr_y && py < clr_y + clr_h {
                for i in 0..16 {
                    display::state_set(19 + i, 0);
                }
                display::state_set(2, 0); // Word length = 0
                display::state_set(35, -1); // Last selected = -1
                display::state_set(37, t);
            }
        }
    } else {
        // --- GAME OVER STATE ---
        display::draw_char(w / 2 - 45, h / 2 - 40, 71, accent_color, 3); // G
        display::draw_char(w / 2 - 25, h / 2 - 40, 65, accent_color, 3); // A
        display::draw_char(w / 2 - 5, h / 2 - 40, 77, accent_color, 3);  // M
        display::draw_char(w / 2 + 15, h / 2 - 40, 69, accent_color, 3);  // E
        
        display::draw_char(w / 2 - 45, h / 2 - 10, 79, accent_color, 3); // O
        display::draw_char(w / 2 - 25, h / 2 - 10, 86, accent_color, 3); // V
        display::draw_char(w / 2 - 5, h / 2 - 10, 69, accent_color, 3);  // E
        display::draw_char(w / 2 + 15, h / 2 - 10, 82, accent_color, 3);  // R
        
        // Final Score
        display::draw_char(w / 2 - 50, h / 2 + 30, 70, text_light, 1); // F
        display::draw_char(w / 2 - 42, h / 2 + 30, 73, text_light, 1); // I
        display::draw_char(w / 2 - 34, h / 2 + 30, 78, text_light, 1); // N
        display::draw_char(w / 2 - 26, h / 2 + 30, 65, text_light, 1); // A
        display::draw_char(w / 2 - 18, h / 2 + 30, 76, text_light, 1); // L
        display::draw_char(w / 2 - 10, h / 2 + 30, 58, text_light, 1); // :
        display::draw_number(w / 2 + 5, h / 2 + 30, display::state_get(36), accent_color, 1);
        
        // Restart Button
        let btn_x = w / 2 - 60;
        let btn_y = h / 2 + 60;
        let btn_w = 120;
        let btn_h = 30;
        display::fill_rect(btn_x, btn_y, btn_w, btn_h, accent_color);
        display::draw_char(btn_x + 20, btn_y + 10, 82, text_dark, 1); // R
        display::draw_char(btn_x + 30, btn_y + 10, 69, text_dark, 1); // E
        display::draw_char(btn_x + 40, btn_y + 10, 83, text_dark, 1); // S
        display::draw_char(btn_x + 50, btn_y + 10, 84, text_dark, 1); // T
        display::draw_char(btn_x + 60, btn_y + 10, 65, text_dark, 1); // A
        display::draw_char(btn_x + 70, btn_y + 10, 82, text_dark, 1); // R
        display::draw_char(btn_x + 80, btn_y + 10, 84, text_dark, 1); // T
        
        if display::pointer_down() != 0 {
            let px = display::pointer_x();
            let py = display::pointer_y();
            if px >= btn_x && px < btn_x + btn_w && py >= btn_y && py < btn_y + btn_h {
                display::state_set(0, 0); // Back to title
            }
        }
    }
    
    display::present();
}