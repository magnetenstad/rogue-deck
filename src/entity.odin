package main

import rl "vendor:raylib"
import "core:math"

Entity :: struct {
    position: rl.Vector2,
    sprite_id: Sprite_Id,
}

Player :: struct {
    using entity: Entity,
}

entity_step :: proc(entity: ^Entity) {
    entity.position.x += math.sin(f32(rl.GetTime()))
}

entity_draw :: proc(entity: ^Entity, game_state: ^Game_State) {
    texture := game_state.sprites[entity.sprite_id]
    rl.DrawTexture(texture, 
        i32(entity.position.x), i32(entity.position.y), rl.WHITE)
}
