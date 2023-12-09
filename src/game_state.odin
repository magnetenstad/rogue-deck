package main

import rl "vendor:raylib"
import "core:math"
import "core:math/rand"
import "core:fmt"

Game_State :: struct {
    world: World,
    player_id: int,
    graphics: Graphics
}

game_state_create :: proc() -> Game_State {
    game_state := Game_State{}
    
    game_state.player_id = world_add_entity(&game_state.world, 
        Entity{sprite_id=.player, position={2, 2}, variant=Player{}})

    rng := rand.create(0)
    for i in 0..=100 {
        position := rl.Vector2{ 
            math.floor(rand.float32(&rng) * SURFACE_WIDTH / GRID_SIZE), 
            math.floor(rand.float32(&rng) * SURFACE_HEIGHT / GRID_SIZE), 
        }
        world_add_entity(&game_state.world, Entity{sprite_id=.skeleton, position=position, variant=Enemy{}})
    }

    return game_state
}
