package main

import "core:math"

mround :: proc(value: f32, multiple: f32) -> f32 {
    return math.floor(value / multiple) * multiple
}
