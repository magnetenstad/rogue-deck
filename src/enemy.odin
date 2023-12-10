package main

import rl "vendor:raylib"
import "core:math/rand"

Enemy_Move :: enum {
    left,
    right,
    up,
    down,
    nothing,
}

enemy_moves: []Enemy_Move = { .left, .right, .up, .down, .nothing }

enemy_step :: proc(enemy: ^Entity) {
    if enemy.kind != .enemy do return
    game_state := get_game_state()
    if game_state.phase != .turn_enemy do return

    move := rand.choice(enemy_moves)
    if (move == .up) { enemy.position.y -= 1 }
    if (move == .left) { enemy.position.x -= 1 }
    if (move == .down) { enemy.position.y += 1 }
    if (move == .right) { enemy.position.x += 1 }
}
