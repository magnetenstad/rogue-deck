package main

import rl "vendor:raylib"

player_step :: proc(player: ^Entity) {
    if player.kind != .player do return
    game_state := get_game_state()
    if game_state.phase != .turn_player do return

    if (rl.IsKeyPressed(.W)) { player.position.y -= 1 }
    if (rl.IsKeyPressed(.A)) { player.position.x -= 1 }
    if (rl.IsKeyPressed(.S)) { player.position.y += 1 }
    if (rl.IsKeyPressed(.D)) { player.position.x += 1 }

    if rl.IsKeyPressed(.W) || 
        rl.IsKeyPressed(.A) || 
        rl.IsKeyPressed(.S) || 
        rl.IsKeyPressed(.D)
    {
        game_state.phase = .turn_enemy
    }
}
