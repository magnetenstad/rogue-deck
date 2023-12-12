package main

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

mround :: proc(value: f32, multiple: f32) -> f32 {
    return math.round(value / multiple) * multiple
}

FVec2 :: rl.Vector2
IVec2 :: distinct [2]int

f_vec_2_from_i_vec :: proc(ivec: IVec2) -> FVec2 {
    return FVec2 { f32(ivec.x), f32(ivec.y) }
}

f_vec_2_from_i :: proc(x: $T, y: T) -> FVec2 {
    return FVec2 { f32(x), f32(y) }
}

f_vec_2 :: proc{
    f_vec_2_from_i,
    f_vec_2_from_i_vec,
}

i_vec_2_from_f_vec :: proc(fvec: FVec2) -> IVec2 {
    return IVec2 { int(fvec.x), int(fvec.y) }
}

i_vec_2_from_f :: proc(x: f32, y: f32) -> IVec2 {
    return IVec2 { int(x), int(y) }
}

i_vec_2 :: proc{
    i_vec_2_from_f,
    i_vec_2_from_f_vec,
}

move_towards :: proc(position: FVec2, target: FVec2, 
        multiplier: f32) -> FVec2 {
    difference := (target - position)
    if linalg.length(difference) < ONE_PIXEL {
        return target
    } else if linalg.length(difference) * multiplier < ONE_PIXEL {
        return position + linalg.normalize(difference) / GRID_SIZE
    } else {
        return position + difference * multiplier
    }
}

array_contains :: proc(array: [dynamic]$T, item: T) -> bool {
    for i in array {
        if item == i {
            return true
        }
    }
    return false
}
