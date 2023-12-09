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
    velocity: rl.Vector2,
    variant: Entity_Union,
}

entity_step :: proc(entity: ^Entity) {

    switch e in entity.variant {
        case Player: player_step(entity)
        case Enemy: enemy_step(entity)
    }

    entity.position += entity.velocity
    entity.velocity *= 0.95

    chunk_validate(&get_game_state().world, entity.id)
}

entity_draw :: proc(entity: ^Entity) {
    texture := get_game_state().graphics.sprites[entity.sprite_id]
    rl.DrawTexture(texture, 
        i32(entity.position.x), i32(entity.position.y), rl.WHITE)
}
