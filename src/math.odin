package main

import "core:math"

mround :: proc(value: f32, multiple: f32) -> f32 {
    return math.round(value / multiple) * multiple
}
