package main

import rl "vendor:raylib"
import "core:math/linalg"
import "core:fmt"

Camera :: struct {
    position: rl.Vector2,
    target_id: int,
    view_size: IVec2,
}

camera_step :: proc(camera: ^Camera, game_state: ^Game_State) {
    target_entity := game_state.world.entities[camera.target_id]

    target_entity_position := rl.Vector2{ 
        f32(target_entity.position.x), f32(target_entity.position.y) }
    camera_view_size := rl.Vector2{ 
            f32(camera.view_size.x), f32(camera.view_size.y) }
    target_position := target_entity_position - camera_view_size / 2
    target_position.x = mround(target_position.x, 16)
    target_position.y = mround(target_position.y, 9)
 
    camera.position = move_towards(camera.position, target_position, 0.1)
}
