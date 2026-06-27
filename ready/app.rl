use host::display;
use host::agent;

fn is_clicked(bx: i32, by: i32, bw: i32, bh: i32, px: i32, py: i32, pd: i32) -> bool {
    pd != 0 && px >= bx && px < bx + bw && py >= by && py < by + bh
}

fn draw_label(id: i32, x: i32, y: i32, color: i32, scale: i32) {
    if id == 1 {
        // "SUBSCRIBE"
        display::draw_char(x, y, 83, color, scale); // S
        display::draw_char(x + 6*scale, y, 85, color, scale); // U
        display::draw_char(x + 12*scale, y, 66, color, scale); // B
        display::draw_char(x + 18*scale, y, 83, color, scale); // S
        display::draw_char(x + 24*scale, y, 67, color, scale); // C
        display::draw_char(x + 30*scale, y, 82, color, scale); // R
        display::draw_char(x + 36*scale, y, 73, color, scale); // I
        display::draw_char(x + 42*scale, y, 66, color, scale); // B
        display::draw_char(x + 48*scale, y, 69, color, scale); // E
    } else if id == 2 {
        // "UNSUBSCRIBE"
        display::draw_char(x, y, 85, color, scale); // U
        display::draw_char(x + 6*scale, y, 78, color, scale); // N
        display::draw_char(x + 12*scale, y, 83, color, scale); // S
        display::draw_char(x + 18*scale, y, 85, color, scale); // U
        display::draw_char(x + 24*scale, y, 66, color, scale); // B
        display::draw_char(x + 30*scale, y, 83, color, scale); // S
        display::draw_char(x + 36*scale, y, 67, color, scale); // C
        display::draw_char(x + 42*scale, y, 82, color, scale); // R
        display::draw_char(x + 48*scale, y, 73, color, scale); // I
        display::draw_char(x + 54*scale, y, 66, color, scale); // B
        display::draw_char(x + 60*scale, y, 69, color, scale); // E
    } else if id == 3 {
        // "READY UP"
        display::draw_char(x, y, 82, color, scale); // R
        display::draw_char(x + 6*scale, y, 69, color, scale); // E
        display::draw_char(x + 12*scale, y, 65, color, scale); // A
        display::draw_char(x + 18*scale, y, 68, color, scale); // D
        display::draw_char(x + 24*scale, y, 89, color, scale); // Y
        display::draw_char(x + 36*scale, y, 85, color, scale); // U
        display::draw_char(x + 42*scale, y, 80, color, scale); // P
    } else if id == 4 {
        // "CONNECT WALLET"
        display::draw_char(x, y, 67, color, scale); // C
        display::draw_char(x + 6*scale, y, 79, color, scale); // O
        display::draw_char(x + 12*scale, y, 78, color, scale); // N
        display::draw_char(x + 18*scale, y, 78, color, scale); // N
        display::draw_char(x + 24*scale, y, 69, color, scale); // E
        display::draw_char(x + 30*scale, y, 67, color, scale); // C
        display::draw_char(x + 36*scale, y, 84, color, scale); // T
        display::draw_char(x + 48*scale, y, 87, color, scale); // W
        display::draw_char(x + 54*scale, y, 65, color, scale); // A
        display::draw_char(x + 60*scale, y, 76, color, scale); // L
        display::draw_char(x + 66*scale, y, 76, color, scale); // L
        display::draw_char(x + 72*scale, y, 69, color, scale); // E
        display::draw_char(x + 78*scale, y, 84, color, scale); // T
    } else if id == 5 {
        // "SUBSCRIBERS: "
        display::draw_char(x, y, 83, color, scale); // S
        display::draw_char(x + 6*scale, y, 85, color, scale); // U
        display::draw_char(x + 12*scale, y, 66, color, scale); // B
        display::draw_char(x + 18*scale, y, 83, color, scale); // S
        display::draw_char(x + 24*scale, y, 67, color, scale); // C
        display::draw_char(x + 30*scale, y, 82, color, scale); // R
        display::draw_char(x + 36*scale, y, 73, color, scale); // I
        display::draw_char(x + 42*scale, y, 66, color, scale); // B
        display::draw_char(x + 48*scale, y, 69, color, scale); // E
        display::draw_char(x + 54*scale, y, 82, color, scale); // R
        display::draw_char(x + 60*scale, y, 83, color, scale); // S
        display::draw_char(x + 66*scale, y, 58, color, scale); // :
    }
}

fn draw_status(status: i32, x: i32, y: i32, color: i32, scale: i32) {
    if status == 1 {
        // "BROADCASTING..."
        display::draw_char(x, y, 66, color, scale); // B
        display::draw_char(x + 6*scale, y, 82, color, scale); // R
        display::draw_char(x + 12*scale, y, 79, color, scale); // O
        display::draw_char(x + 18*scale, y, 65, color, scale); // A
        display::draw_char(x + 24*scale, y, 68, color, scale); // D
        display::draw_char(x + 30*scale, y, 67, color, scale); // C
        display::draw_char(x + 36*scale, y, 65, color, scale); // A
        display::draw_char(x + 42*scale, y, 83, color, scale); // S
        display::draw_char(x + 48*scale, y, 84, color, scale); // T
        display::draw_char(x + 54*scale, y, 73, color, scale); // I
        display::draw_char(x + 60*scale, y, 78, color, scale); // N
        display::draw_char(x + 66*scale, y, 71, color, scale); // G
        display::draw_char(x + 72*scale, y, 46, color, scale); // .
        display::draw_char(x + 78*scale, y, 46, color, scale); // .
        display::draw_char(x + 84*scale, y, 46, color, scale); // .
    } else if status == 2 {
        // "SUBSCRIBING..."
        display::draw_char(x, y, 83, color, scale); // S
        display::draw_char(x + 6*scale, y, 85, color, scale); // U
        display::draw_char(x + 12*scale, y, 66, color, scale); // B
        display::draw_char(x + 18*scale, y, 83, color, scale); // S
        display::draw_char(x + 24*scale, y, 67, color, scale); // C
        display::draw_char(x + 30*scale, y, 82, color, scale); // R
        display::draw_char(x + 36*scale, y, 73, color, scale); // I
        display::draw_char(x + 42*scale, y, 66, color, scale); // B
        display::draw_char(x + 48*scale, y, 73, color, scale); // I
        display::draw_char(x + 54*scale, y, 78, color, scale); // N
        display::draw_char(x + 60*scale, y, 71, color, scale); // G
        display::draw_char(x + 66*scale, y, 46, color, scale); // .
        display::draw_char(x + 72*scale, y, 46, color, scale); // .
        display::draw_char(x + 78*scale, y, 46, color, scale); // .
    } else if status == 3 {
        // "UNSUBSCRIBING..."
        display::draw_char(x, y, 85, color, scale); // U
        display::draw_char(x + 6*scale, y, 78, color, scale); // N
        display::draw_char(x + 12*scale, y, 83, color, scale); // S
        display::draw_char(x + 18*scale, y, 85, color, scale); // U
        display::draw_char(x + 24*scale, y, 66, color, scale); // B
        display::draw_char(x + 30*scale, y, 83, color, scale); // S
        display::draw_char(x + 36*scale, y, 67, color, scale); // C
        display::draw_char(x + 42*scale, y, 82, color, scale); // R
        display::draw_char(x + 48*scale, y, 73, color, scale); // I
        display::draw_char(x + 54*scale, y, 66, color, scale); // B
        display::draw_char(x + 60*scale, y, 73, color, scale); // I
        display::draw_char(x + 66*scale, y, 78, color, scale); // N
        display::draw_char(x + 72*scale, y, 71, color, scale); // G
        display::draw_char(x + 78*scale, y, 46, color, scale); // .
        display::draw_char(x + 84*scale, y, 46, color, scale); // .
        display::draw_char(x + 90*scale, y, 46, color, scale); // .
    } else if status == 4 {
        // "CONNECTING..."
        display::draw_char(x, y, 67, color, scale); // C
        display::draw_char(x + 6*scale, y, 79, color, scale); // O
        display::draw_char(x + 12*scale, y, 78, color, scale); // N
        display::draw_char(x + 18*scale, y, 78, color, scale); // N
        display::draw_char(x + 24*scale, y, 69, color, scale); // E
        display::draw_char(x + 30*scale, y, 67, color, scale); // C
        display::draw_char(x + 36*scale, y, 84, color, scale); // T
        display::draw_char(x + 42*scale, y, 73, color, scale); // I
        display::draw_char(x + 48*scale, y, 78, color, scale); // N
        display::draw_char(x + 54*scale, y, 71, color, scale); // G
        display::draw_char(x + 60*scale, y, 46, color, scale); // .
        display::draw_char(x + 66*scale, y, 46, color, scale); // .
        display::draw_char(x + 72*scale, y, 46, color, scale); // .
    } else if status == 5 {
        // "BROADCAST SENT!"
        display::draw_char(x, y, 66, color, scale); // B
        display::draw_char(x + 6*scale, y, 82, color, scale); // R
        display::draw_char(x + 12*scale, y, 79, color, scale); // O
        display::draw_char(x + 18*scale, y, 65, color, scale); // A
        display::draw_char(x + 24*scale, y, 68, color, scale); // D
        display::draw_char(x + 30*scale, y, 67, color, scale); // C
        display::draw_char(x + 36*scale, y, 65, color, scale); // A
        display::draw_char(x + 42*scale, y, 83, color, scale); // S
        display::draw_char(x + 48*scale, y, 84, color, scale); // T
        display::draw_char(x + 58*scale, y, 83, color, scale); // S
        display::draw_char(x + 64*scale, y, 69, color, scale); // E
        display::draw_char(x + 70*scale, y, 78, color, scale); // N
        display::draw_char(x + 76*scale, y, 84, color, scale); // T
        display::draw_char(x + 82*scale, y, 33, color, scale); // !
    } else if status == 6 {
        // "SUBSCRIBED!"
        display::draw_char(x, y, 83, color, scale); // S
        display::draw_char(x + 6*scale, y, 85, color, scale); // U
        display::draw_char(x + 12*scale, y, 66, color, scale); // B
        display::draw_char(x + 18*scale, y, 83, color, scale); // S
        display::draw_char(x + 24*scale, y, 67, color, scale); // C
        display::draw_char(x + 30*scale, y, 82, color, scale); // R
        display::draw_char(x + 36*scale, y, 73, color, scale); // I
        display::draw_char(x + 42*scale, y, 66, color, scale); // B
        display::draw_char(x + 48*scale, y, 69, color, scale); // E
        display::draw_char(x + 54*scale, y, 68, color, scale); // D
        display::draw_char(x + 60*scale, y, 33, color, scale); // !
    } else if status == 7 {
        // "UNSUBSCRIBED!"
        display::draw_char(x, y, 85, color, scale); // U
        display::draw_char(x + 6*scale, y, 78, color, scale); // N
        display::draw_char(x + 12*scale, y, 83, color, scale); // S
        display::draw_char(x + 18*scale, y, 85, color, scale); // U
        display::draw_char(x + 24*scale, y, 66, color, scale); // B
        display::draw_char(x + 30*scale, y, 83, color, scale); // S
        display::draw_char(x + 36*scale, y, 67, color, scale); // C
        display::draw_char(x + 42*scale, y, 82, color, scale); // R
        display::draw_char(x + 48*scale, y, 73, color, scale); // I
        display::draw_char(x + 54*scale, y, 66, color, scale); // B
        display::draw_char(x + 60*scale, y, 69, color, scale); // E
        display::draw_char(x + 66*scale, y, 68, color, scale); // D
        display::draw_char(x + 72*scale, y, 33, color, scale); // !
    }
}

fn frame(t: i32) {
    display::clear(0x121214);
    
    let px = display::pointer_x();
    let py = display::pointer_y();
    let pd = display::pointer_down();
    
    // Decrement cooldown
    let mut cooldown = display::state_get(0);
    if cooldown > 0 {
        cooldown -= 1;
        display::state_set(0, cooldown);
    }
    
    // Decrement status timer
    let mut status_timer = display::state_get(2);
    let mut status = display::state_get(1);
    if status_timer > 0 {
        status_timer -= 1;
        display::state_set(2, status_timer);
        if status_timer == 0 {
            status = 0;
            display::state_set(1, 0);
        }
    }
    
    // Draw Title
    display::draw_char(20, 20, 82, 0xffffff, 2); // R
    display::draw_char(35, 20, 69, 0xffffff, 2); // E
    display::draw_char(50, 20, 65, 0xffffff, 2); // A
    display::draw_char(65, 20, 68, 0xffffff, 2); // D
    display::draw_char(80, 20, 89, 0xffffff, 2); // Y
    
    display::draw_char(105, 20, 85, 0xffffff, 2); // U
    display::draw_char(120, 20, 80, 0xffffff, 2); // P
    
    // Draw Subscriber Count
    draw_label(5, 20, 60, 0x88888c, 1); // "SUBSCRIBERS: "
    let sub_count = agent::subscriber_count();
    display::draw_number(100, 60, sub_count, 0x00ff00, 1);
    
    // Check if viewer has identity
    let has_id = agent::viewer_has_identity();
    
    if has_id == 0 {
        // Draw Connect Wallet Button
        let bx = 40;
        let by = 120;
        let bw = 240;
        let bh = 40;
        
        let hover = px >= bx && px < bx + bw && py >= by && py < by + bh;
        let btn_color = if hover { 0x4a4a55 } else { 0x2a2a30 };
        display::fill_rect(bx, by, bw, bh, btn_color);
        draw_label(4, bx + 20, by + 12, 0xffffff, 1); // "CONNECT WALLET"
        
        if cooldown == 0 && pd != 0 && hover {
            display::state_set(0, 60); // 1s cooldown
            display::state_set(1, 4); // Connecting
            display::state_set(2, 120); // 2s status timer
            agent::request_identity();
        }
    } else {
        // Draw Subscribe/Unsubscribe Button
        let sub_x = 40;
        let sub_y = 100;
        let sub_w = 240;
        let sub_h = 40;
        
        let sub_hover = px >= sub_x && px < sub_x + sub_w && py >= sub_y && py < sub_y + sub_h;
        let sub_btn_color = if sub_hover { 0x4a4a55 } else { 0x2a2a30 };
        display::fill_rect(sub_x, sub_y, sub_w, sub_h, sub_btn_color);
        
        let is_sub = agent::is_subscribed();
        if is_sub == 1 {
            draw_label(2, sub_x + 20, sub_y + 12, 0xff5555, 1); // "UNSUBSCRIBE"
        } else {
            draw_label(1, sub_x + 20, sub_y + 12, 0x55ff55, 1); // "SUBSCRIBE"
        }
        
        // Draw Ready Up Button
        let rdy_x = 40;
        let rdy_y = 160;
        let rdy_w = 240;
        let rdy_h = 40;
        
        let rdy_hover = px >= rdy_x && px < rdy_x + rdy_w && py >= rdy_y && py < rdy_y + rdy_h;
        let rdy_btn_color = if rdy_hover { 0x5a5a65 } else { 0x3a3a45 };
        display::fill_rect(rdy_x, rdy_y, rdy_w, rdy_h, rdy_btn_color);
        draw_label(3, rdy_x + 20, rdy_y + 12, 0xffffff, 1); // "READY UP"
        
        // Handle Clicks
        if cooldown == 0 && pd != 0 {
            if sub_hover {
                display::state_set(0, 60); // 1s cooldown
                display::state_set(2, 120); // 2s status timer
                if is_sub == 1 {
                    display::state_set(1, 3); // Unsubscribing
                    agent::unsubscribe();
                    display::state_set(1, 7); // Unsubscribed
                } else {
                    display::state_set(1, 2); // Subscribing
                    agent::subscribe();
                    display::state_set(1, 6); // Subscribed
                }
            } else if rdy_hover {
                display::state_set(0, 60); // 1s cooldown
                display::state_set(1, 1); // Broadcasting
                display::state_set(2, 120); // 2s status timer
                agent::broadcast("Ready Up!", "Someone is ready!");
                display::state_set(1, 5); // Broadcast sent
            }
        }
    }
    
    // Draw Status Message
    if status > 0 {
        draw_status(status, 40, 220, 0xffff00, 1);
    }
    
    display::present();
}
