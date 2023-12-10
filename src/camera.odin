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

camera_get_mouse_position :: proc(camera: ^Camera) -> FVec2 {
    mouse_screen_position := rl.GetMousePosition()

    screen_width := f32(rl.GetScreenWidth())
    screen_height := f32(rl.GetScreenHeight())
    surface_width := f32(SURFACE_WIDTH)
    surface_height := f32(SURFACE_HEIGHT)
    scale := min(
        screen_width / surface_width, 
        screen_height / surface_height)

    return (mouse_screen_position - FVec2{ 
        ((screen_width - surface_width * scale) * 0.5),
        ((screen_height - surface_height * scale) * 0.5),
    }) / scale
}


camera_get_mouse_world_position :: proc(camera: ^Camera) -> IVec2 {
    mouse_screen_position := camera_get_mouse_position(camera)
    world_position := mouse_screen_position / GRID_SIZE + camera.position
    return i_vec_2(world_position)
}
