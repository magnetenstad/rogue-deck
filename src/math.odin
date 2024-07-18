//+vet unused shadowing using-stmt style semicolon
package main

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

mround :: proc(value: $T, multiple: T) -> T {
	return T(math.round(f32(value) / f32(multiple))) * multiple
}

mfloor :: proc(value: $T, multiple: T) -> T {
	return T(math.floor(f32(value) / f32(multiple))) * multiple
}

floor_v :: proc(value: $T) -> T {
	return {math.floor(value.x), math.floor(value.y)}
}

FVec2 :: rl.Vector2
IVec2 :: distinct [2]int

f_vec_2_from_i_vec :: proc(ivec: IVec2) -> FVec2 {
	return FVec2{f32(ivec.x), f32(ivec.y)}
}

f_vec_2_from_i :: proc(x: $T, y: T) -> FVec2 {
	return FVec2{f32(x), f32(y)}
}

f_vec_2 :: proc {
	f_vec_2_from_i,
	f_vec_2_from_i_vec,
}

i_vec_2_from_f_vec :: proc(fvec: FVec2) -> IVec2 {
	return IVec2{int(math.floor(fvec.x)), int(math.floor(fvec.y))}
}

i_vec_2_from_f :: proc(x: f32, y: f32) -> IVec2 {
	return IVec2{int(math.floor(x)), int(math.floor(y))}
}

i_vec_2 :: proc {
	i_vec_2_from_f,
	i_vec_2_from_f_vec,
}

f_rect :: proc(x, y, width, height: $T) -> rl.Rectangle {
	return rl.Rectangle{f32(x), f32(y), f32(width), f32(height)}
}

@(private = "file")
_move_towards_vec :: proc(
	position: FVec2,
	target: FVec2,
	multiplier: f32,
	min_length: f32 = ONE_PIXEL,
) -> FVec2 {
	difference := (target - position)
	if linalg.length(difference) < min_length {
		return target
	} else if linalg.length(difference) * multiplier < min_length {
		return position + linalg.normalize(difference) * min_length
	} else {
		return position + difference * multiplier
	}
}

@(private = "file")
_move_towards_scalar :: proc(
	position: $T/f32,
	target: T,
	multiplier: f32,
	min_length: f32 = ONE_PIXEL,
) -> T {
	difference := target - position
	length := math.abs(difference)
	if length < min_length {
		return target
	} else if length * multiplier < min_length {
		return position + math.sign(difference) * min_length
	} else {
		return position + difference * multiplier
	}
}

// For use in world space
move_towards :: proc {
	_move_towards_vec,
	_move_towards_scalar,
}

point_in_rect :: proc(point: $T, rect: ^rl.Rectangle) -> bool {
	return(
		rect.x <= f32(point.x) &&
		f32(point.x) <= rect.x + rect.width &&
		rect.y <= f32(point.y) &&
		f32(point.y) <= rect.y + rect.height \
	)
}

sort_indices_by :: proc(data: $T/[]$E, less: proc(i, j: E) -> bool) -> []int {
	indices := make([]int, len(data))
	for &i in indices {
		i = -1
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
