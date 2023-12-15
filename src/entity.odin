//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"

Entity_Kind :: enum {
    player,
    enemy,
}

Entity :: struct {
    kind: Entity_Kind,
    id: int,
    chunk: IVec2,
    sprite_id: Sprite_Id,
    position: IVec2,
    draw_position: FVec2,
}

entity_step :: proc(entity: ^Entity) {
    game_state := get_game_state()

    entity.draw_position = move_towards(
        entity.draw_position, f_vec_2(entity.position), 0.25)
        
    chunk_validate(&game_state.world, entity)
}

entity_draw :: proc(entity: ^Entity) {
    graphics := &get_game_state().graphics
    texture := graphics.sprites[entity.sprite_id]
    scale := camera_surface_scale(&graphics.camera)
    rl.DrawTextureEx(texture, 
        entity.draw_position * GRID_SIZE - graphics.camera.position / scale, 
        0,
        1.0,
        rl.WHITE)
}
