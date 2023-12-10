package main

import rl "vendor:raylib"
import "core:time"
import "core:fmt"

time_last_input := time.now()

player_step :: proc(player: ^Entity) {
    if player.kind != .player do return
    game_state := get_game_state()
    if game_state.phase != .turn_player do return
    
    time_now := time.now()
    duration := time.duration_seconds(time.diff(time_last_input, time_now))
    key := player_get_key()

    if duration > INPUT_TIMER && key != .KEY_NULL {
        #partial switch key {
            case .W: { player.position.y -= 1 }
            case .A: { player.position.x -= 1 }
            case .S: { player.position.y += 1 }
            case .D: { player.position.x += 1 }
        }

        game_state.phase = .turn_enemy
        time_last_input = time_now
    }
}

key_queue: [dynamic]rl.KeyboardKey

player_get_key :: proc() -> rl.KeyboardKey {
    key_now := rl.GetKeyPressed()
    if key_now == .W || 
        key_now == .A || 
        key_now == .S || 
        key_now == .D 
    {
        append(&key_queue, key_now)
    }
    for len(key_queue) > 0 && !rl.IsKeyDown(key_queue[len(key_queue) - 1]) {
        pop(&key_queue)
    }
    key: rl.KeyboardKey = .KEY_NULL
    if len(key_queue) > 0 {
        key = key_queue[len(key_queue) - 1]
    }
    return key
}
