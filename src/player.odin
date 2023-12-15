//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"
import "core:time"
import "core:slice"

@(private="file")
_time_last_input := time.now()

player_step :: proc(player: ^Entity) {
    if player.kind != .player do return
    game_state := get_game_state()
    if game_state.phase != .turn_player do return
    
    time_now := time.now()
    duration := time.duration_seconds(time.diff(_time_last_input, time_now))
    key := _get_key()

    if duration > INPUT_TIMER && key != .KEY_NULL {
        #partial switch key {
            case .W: { player.position.y -= 1 }
            case .A: { player.position.x -= 1 }
            case .S: { player.position.y += 1 }
            case .D: { player.position.x += 1 }
        }
        _time_last_input = time_now
    }
}

@(private="file")
_key_queue: [dynamic]rl.KeyboardKey
@(private="file")
_wasd: []rl.KeyboardKey = {.W, .A, .S, .D}

@(private="file")
_get_key :: proc() -> rl.KeyboardKey {
    for key in _wasd {
        if rl.IsKeyDown(key) && !slice.contains(_key_queue[:], key) {
            append(&_key_queue, key)
        }
    }
    for i := 0; i < len(_key_queue); i += 1 {
        if !rl.IsKeyDown(_key_queue[i]) {
            ordered_remove(&_key_queue, i)
            i -= 1
        }
    }
    key: rl.KeyboardKey = .KEY_NULL
    if len(_key_queue) > 0 {
        key = _key_queue[len(_key_queue) - 1]
    }
    return key
}
