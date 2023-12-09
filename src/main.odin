package main

import rl "vendor:raylib"
import "core:fmt"

game_state : Game_State

main :: proc() {
    fmt.println(rl.rlGetVersion())

    window_setup()
    game_state = game_state_setup()

    for !rl.WindowShouldClose() {
        main_step()
        main_draw()
    }

    rl.CloseWindow()
}

Game_State :: struct {
    world: World,
    player: ^Player,
    sprites: map[Sprite_Id]rl.Texture
}

game_state_setup :: proc() -> Game_State {
    game_state := Game_State{}
    game_state.sprites = load_sprites()
    
    append(&game_state.world.entities, Player{entity=Entity{sprite_id=.player, position={200, 200}}})
    append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position={0, 0}}})
    append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position={100, 100}}})
    append(&game_state.world.entities, Enemy{entity=Entity{sprite_id=.skeleton, position={100, 200}}})

    game_state.player = &game_state.world.entities[0].(Player)

    return game_state
}

main_step :: proc() {
    for _, i in game_state.world.entities {
        entity_union_step(&game_state.world.entities[i])
    }
}

main_draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.GRAY)
    
    for _, i in game_state.world.entities {
        entity_union_draw(&game_state.world.entities[i])
    }
}
