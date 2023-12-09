package main

import rl "vendor:raylib"
import "core:math/rand"

Game_State :: struct {
    world: World,
    player: ^Player,
    graphics: Graphics
}

game_state_create :: proc() -> Game_State {
    game_state := Game_State{}
    
    append(&game_state.world.entities, Player{entity=Entity{sprite_id=.player, position={200, 200}}})
    
    rng := rand.create(0)

    for i in 0..=100 {
        position := rl.Vector2{ rand.float32(&rng) * SURFACE_WIDTH, rand.float32(&rng) * SURFACE_HEIGHT }
        append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position=position}})
    }

    game_state.player = &game_state.world.entities[0].(Player)

    return game_state
}
