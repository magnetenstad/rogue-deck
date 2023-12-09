package main

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {
    fmt.println(rl.rlGetVersion())

    window_setup()
    game_state := game_state_setup()

    for !rl.WindowShouldClose() {
        main_step(&game_state)
        main_draw(&game_state)
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
    
    append(&game_state.world.entities, Entity{{0, 0}, .skeleton})
    append(&game_state.world.entities, Entity{{100, 100}, .skeleton})
    append(&game_state.world.entities, Entity{{100, 200}, .skeleton})

    return game_state
}

main_step :: proc(state: ^Game_State) {
    for _, i in state.world.entities {
        entity_step(&state.world.entities[i])
    }
}

main_draw :: proc(state: ^Game_State) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.GRAY)
    
    for _, i in state.world.entities {
        entity_draw(&state.world.entities[i], state)
    }
}
