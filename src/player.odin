package main

import rl "vendor:raylib"

player_step :: proc(player: ^Entity) {
    if (rl.IsKeyPressed(.W)) { player.position.y -= 1 }
    if (rl.IsKeyPressed(.A)) { player.position.x -= 1 }
    if (rl.IsKeyPressed(.S)) { player.position.y += 1 }
    if (rl.IsKeyPressed(.D)) { player.position.x += 1 }
}
