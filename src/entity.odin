package main

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

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
    draw_position: rl.Vector2,
}

entity_step :: proc(entity: ^Entity) {

    switch entity.kind {
        case .player: player_step(entity)
        case .enemy: enemy_step(entity)
    }

    entity_position := rl.Vector2{ 
        f32(entity.position.x), f32(entity.position.y) }
    
    entity.draw_position = move_towards(
        entity.draw_position, entity_position, 0.25)
        
    chunk_validate(&get_game_state().world, entity.id)
}

entity_draw :: proc(entity: ^Entity) {
    graphics := &get_game_state().graphics
    texture := graphics.sprites[entity.sprite_id]
    x := entity.draw_position.x - graphics.camera.position.x
    y := entity.draw_position.y - graphics.camera.position.y
    rl.DrawTexture(texture, 
        i32(x * GRID_SIZE), 
        i32(y * GRID_SIZE), 
        rl.WHITE)
}
