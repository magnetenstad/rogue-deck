package main

import "core:math"
import rl "vendor:raylib"

Enemy :: struct {
    using entity: Entity,
}

enemy_step :: proc(enemy: ^Enemy) {
    enemy.velocity.x += 0.05 * math.sin(f32(rl.GetTime()))
}
