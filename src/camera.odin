//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"

Camera :: struct {
    position: FVec2,
    target_id: int,
    view_size: IVec2,
}

camera_step :: proc(camera: ^Camera, world: ^World) {
    target_entity := world.entities[camera.target_id]

    target_position := 
        f_vec_2(target_entity.position) - f_vec_2(camera.view_size) / 2
    target_position.x = mround(target_position.x, 16)
    target_position.y = mround(target_position.y, 9)
 
    camera.position = move_towards(camera.position, target_position, 0.1)
}

camera_gui_mouse_position :: proc(camera: ^Camera) -> FVec2 {
    mouse_screen_position := rl.GetMousePosition()
    origin := camera_surface_origin(camera)
    return mouse_screen_position - origin
}

camera_surface_mouse_position :: proc(camera: ^Camera) -> FVec2 {
    scale := camera_surface_scale(camera)
    return camera_gui_mouse_position(camera) / scale
}

camera_world_mouse_position :: proc(camera: ^Camera) -> IVec2 {
    return camera_gui_to_world(camera, camera_gui_mouse_position(camera))
}

camera_gui_size :: proc() -> FVec2 {
    return f_vec_2(rl.GetScreenWidth(), rl.GetScreenHeight())
}

camera_surface_scale :: proc(camera: ^Camera) -> f32 {
    screen_width := f32(rl.GetScreenWidth())
    screen_height := f32(rl.GetScreenHeight())
    surface_width := f32(SURFACE_WIDTH)
    surface_height := f32(SURFACE_HEIGHT)
    return min(
        screen_width / surface_width, 
        screen_height / surface_height,
    )
}

camera_surface_origin :: proc(camera: ^Camera) -> FVec2 {
    screen_width := f32(rl.GetScreenWidth())
    screen_height := f32(rl.GetScreenHeight())
    surface_width := f32(SURFACE_WIDTH)
    surface_height := f32(SURFACE_HEIGHT)
    scale := camera_surface_scale(camera)
    return FVec2 {
        (screen_width - surface_width * scale) * 0.5, 
        (screen_height - surface_height * scale) * 0.5,
    }
}

camera_world_to_surface :: proc(camera: ^Camera, position: IVec2) -> FVec2 {
    return (f_vec_2(position) - camera.position) * GRID_SIZE
}

camera_gui_to_world :: proc(camera: ^Camera, position: FVec2) -> IVec2 {
    scale := camera_surface_scale(camera)
    return i_vec_2(position / (GRID_SIZE * scale) + camera.position)
}

camera_world_to_gui :: proc(camera: ^Camera, position: IVec2) -> FVec2 {
    scale := camera_surface_scale(camera)
    origin := camera_surface_origin(camera)
    return origin + camera_world_to_surface(camera, position) * scale
}

camera_mouse_in_surface :: proc(camera: ^Camera) -> bool {
    mouse_surface_position := camera_surface_mouse_position(camera)
    return point_in_rect(mouse_surface_position, 
        &rl.Rectangle { 0, 0, SURFACE_WIDTH, SURFACE_HEIGHT })
}
