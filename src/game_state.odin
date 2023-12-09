package main

Game_State :: struct {
    world: World,
    player: ^Player,
    graphics: Graphics
}

game_state_create :: proc() -> Game_State {
    game_state := Game_State{}
    
    append(&game_state.world.entities, Player{entity=Entity{sprite_id=.player, position={200, 200}}})
    append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position={0, 0}}})
    append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position={100, 100}}})
    append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position={100, 200}}})

    game_state.player = &game_state.world.entities[0].(Player)

    return game_state
}
