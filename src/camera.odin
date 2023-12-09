package main

import rl "vendor:raylib"
import "core:math/linalg"
import "core:fmt"

Camera :: struct {
    position: FVec2,
    target_id: int,
    view_size: IVec2,
}

camera_step :: proc(camera: ^Camera, game_state: ^Game_State) {
    target_entity := game_state.world.entities[camera.target_id]

    target_position := 
        f_vec_2(target_entity.position) - f_vec_2(camera.view_size) / 2
    target_position.x = mround(target_position.x, 16)
    target_position.y = mround(target_position.y, 9)
 
    camera.position = move_towards(camera.position, target_position, 0.1)
}
