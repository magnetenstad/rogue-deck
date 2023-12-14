package main
//+vet unused shadowing using-stmt style semicolon

import "core:math"
import "core:math/linalg"
import "core:fmt"
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

move_towards_vec :: proc(position: FVec2, target: FVec2, 
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

move_towards_scalar :: proc(position: $T/f32, target: T, 
        multiplier: f32) -> T {
    difference := target - position
    length := math.abs(difference)
    if length < ONE_PIXEL {
        return target
    } else if length * multiplier < ONE_PIXEL {
        return position + math.sign(difference) / GRID_SIZE
    } else {
        return position + difference * multiplier
    }
}

move_towards :: proc {
    move_towards_vec,
    move_towards_scalar,
}

point_in_rect :: proc(point: FVec2, rect: ^rl.Rectangle) -> bool {
    return rect.x <= point.x && 
        point.x <= rect.x + rect.width &&
        rect.y <= point.y &&
        point.y <= rect.y + rect.height
}

sort_indices_by :: proc(data: $T/[]$E, less: proc(i, j: E) -> bool) -> []int {
	indices := make([]int, len(data))
	for i in 0 ..< len(data) {
        indices[i] = -1
    }
    for i in 0 ..< len(data) {
        a_i := i

        for b_i, j in indices {
            if b_i == -1 {
                indices[j] = a_i
                break
            }
            is_less := less(data[a_i], data[b_i])
            if is_less {
                indices[j] = a_i
                a_i = b_i
            }
        }
    }
    return indices
}

print :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(args, sep = sep, flush = flush)
}
