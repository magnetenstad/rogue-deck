package main

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
}

player_step :: proc(player: ^Player) {
    acceleration :: 0.1
    if (rl.IsKeyDown(.W)) { player.velocity.y -= acceleration }
    if (rl.IsKeyDown(.A)) { player.velocity.x -= acceleration }
    if (rl.IsKeyDown(.S)) { player.velocity.y += acceleration }
    if (rl.IsKeyDown(.D)) { player.velocity.x += acceleration }
}
