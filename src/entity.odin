package main

import rl "vendor:raylib"
import "core:math"

Entity_Union :: union {
    Entity,
    Player,
    Enemy,
}

Entity :: struct {
    sprite_id: Sprite_Id,
    position: rl.Vector2,
    velocity: rl.Vector2,
}

entity_union_step :: proc(entity: ^Entity_Union) {
    switch e in entity {
        case Entity: entity_step(&e)
        case Player: player_step(&e); entity_step(&e)
        case Enemy: enemy_step(&e); entity_step(&e)
    }
}

entity_step :: proc(entity: ^Entity) {
    entity.position += entity.velocity
    entity.velocity *= 0.95
}

entity_union_draw :: proc(entity: ^Entity_Union, game_state: ^Game_State) {
    switch e in entity {
        case Entity: entity_draw(&e, game_state);
        case Player: entity_draw(&e, game_state);
        case Enemy: entity_draw(&e, game_state);
    }
}

entity_draw :: proc(entity: ^Entity, game_state: ^Game_State) {
    texture := game_state.sprites[entity.sprite_id]
    rl.DrawTexture(texture, 
        i32(entity.position.x), i32(entity.position.y), rl.WHITE)
}
