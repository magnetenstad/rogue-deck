package main

import rl "vendor:raylib"
import "core:math"

Entity_Union :: union {
    Player,
    Enemy,
}

Entity :: struct {
    id: int,
    chunk: rl.Vector2,
    sprite_id: Sprite_Id,
    position: rl.Vector2,
    draw_position: rl.Vector2,
    variant: Entity_Union,
}

entity_step :: proc(entity: ^Entity) {

    switch e in entity.variant {
        case Player: player_step(entity)
        case Enemy: enemy_step(entity)
    }

    entity.draw_position += (entity.position - entity.draw_position) * 0.2

    chunk_validate(&get_game_state().world, entity.id)
}

entity_draw :: proc(entity: ^Entity) {
    texture := get_game_state().graphics.sprites[entity.sprite_id]
    rl.DrawTexture(texture, 
        i32(entity.draw_position.x * GRID_SIZE), 
        i32(entity.draw_position.y * GRID_SIZE), 
        rl.WHITE)
}
