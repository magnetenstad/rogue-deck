package main

import rl "vendor:raylib"
import "core:math"
import "core:math/rand"
import "core:fmt"
import "core:encoding/json"
import "core:io"

Game_Phase :: enum {
    turn_player,
    turn_enemy,
}

Game_State :: struct {
    world: World,
    player_id: int,
    graphics: Graphics,
    selected_id: Maybe(int),
    phase: Game_Phase
}

@(private="file")
Serializable_Game_State :: struct {
    entities: [dynamic]Entity,
    player_id: int,
}

game_state_create :: proc() -> Game_State {
    game_state := Game_State{}
    
    game_state.player_id = world_add_entity(&game_state.world, 
        Entity{kind=.player, sprite_id=.player, position={2, 2}})

    rng := rand.create(0)
    for i in 0..=100 {
        position := i_vec_2( 
            math.floor(rand.float32(&rng) * SURFACE_WIDTH / GRID_SIZE), 
            math.floor(rand.float32(&rng) * SURFACE_HEIGHT / GRID_SIZE), 
        )
        world_add_entity(&game_state.world, Entity{kind=.enemy, 
            sprite_id=.skeleton, position=position})
    }

    return game_state
}

game_state_serialize :: proc(
        game_state: ^Game_State) -> (data: []byte, err: json.Marshal_Error) {

    serializable := Serializable_Game_State{
        entities=game_state.world.entities,
        player_id=game_state.player_id,
    }
    return json.marshal(serializable)
}

game_state_deserialize :: proc(data: []byte) -> Game_State {
    serializable: Serializable_Game_State
    json.unmarshal(data, &serializable)
    
    game_state := Game_State{}
    game_state.world.entities = serializable.entities
    game_state.player_id = serializable.player_id
    for &entity in game_state.world.entities {
        chunk_add_entity(&game_state.world, entity.id)
    }

    return game_state
}
