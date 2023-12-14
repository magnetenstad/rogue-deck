//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"
import "core:time"
import "core:slice"

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
wasd: []rl.KeyboardKey = {.W, .A, .S, .D}

player_get_key :: proc() -> rl.KeyboardKey {
    for key in wasd {
        if rl.IsKeyDown(key) && !slice.contains(key_queue[:], key) {
            append(&key_queue, key)
        }
    }
    for i := 0; i < len(key_queue); i += 1 {
        if !rl.IsKeyDown(key_queue[i]) {
            ordered_remove(&key_queue, i)
            i -= 1
        }
    }
    key: rl.KeyboardKey = .KEY_NULL
    if len(key_queue) > 0 {
        key = key_queue[len(key_queue) - 1]
    }
    return key
}
