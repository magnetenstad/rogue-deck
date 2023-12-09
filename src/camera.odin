package main

import rl "vendor:raylib"
import "core:math/linalg"

Camera :: struct {
    position: rl.Vector2,
    target_id: int,
    view_size: rl.Vector2,
}

camera_step :: proc(camera: ^Camera, game_state: ^Game_State) {
    target_entity := game_state.world.entities[camera.target_id]
    target_position := target_entity.position - camera.view_size / 2
    target_position.x = mround(target_position.x, 8)
    target_position.y = mround(target_position.y, 8)
 
    if linalg.length(camera.position - target_position) < ONE_PIXEL {
        camera.position = target_position
    } else {
        camera.position += (target_position - camera.position) * 0.2
    }
}
