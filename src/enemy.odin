//+vet unused shadowing using-stmt style semicolon
package main

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
    assert(enemy.kind == .enemy)
    if enemy.done do return

    move := rand.choice(enemy_moves)
    if (move == .up) { enemy.position.y -= 1 }
    if (move == .left) { enemy.position.x -= 1 }
    if (move == .down) { enemy.position.y += 1 }
    if (move == .right) { enemy.position.x += 1 }

    enemy.done = true
}
