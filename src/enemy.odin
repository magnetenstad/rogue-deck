package main

import "core:math"
import rl "vendor:raylib"

Enemy :: struct {
}

enemy_step :: proc(enemy: ^Entity) {
    enemy.velocity.x += 0.05 * math.sin(f32(rl.GetTime()))
}
