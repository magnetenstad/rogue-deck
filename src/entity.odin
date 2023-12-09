package main

import rl "vendor:raylib"
import "core:math"

Entity_Union :: union {
    Entity,
    Player,
}

Entity :: struct {
    position: rl.Vector2,
    sprite_id: Sprite_Id,
}

Player :: struct {
    using entity: Entity,
}

entity_step :: proc(entity: ^Entity_Union) {
    switch e in entity {
        case Entity:
            e.position.x += math.sin(f32(rl.GetTime()))
        case Player:
            player_step(&e)
    }
}

player_step :: proc(player: ^Player) {

}

entity_union_draw :: proc(entity: ^Entity_Union, game_state: ^Game_State) {
    switch e in entity {
        case Entity: entity_draw(&e, game_state);
        case Player: entity_draw(&e, game_state);
    }
}

entity_draw :: proc(entity: ^Entity, game_state: ^Game_State) {
    texture := game_state.sprites[entity.sprite_id]
    rl.DrawTexture(texture, 
        i32(entity.position.x), i32(entity.position.y), rl.WHITE)
}
