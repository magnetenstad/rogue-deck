package main

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

mround :: proc(value: f32, multiple: f32) -> f32 {
    return math.round(value / multiple) * multiple
}

IVec2 :: distinct [2]int

move_towards :: proc(position: rl.Vector2, target: rl.Vector2, 
        multiplier: f32) -> rl.Vector2 {
    difference := (target - position)
    if linalg.length(difference) < ONE_PIXEL {
        return target
    } else if linalg.length(difference) * multiplier < ONE_PIXEL {
        return position + linalg.normalize(difference) / GRID_SIZE
    } else {
        return position + difference * multiplier
    }
}