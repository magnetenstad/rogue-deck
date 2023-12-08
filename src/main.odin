package main

import "vendor:raylib"
import "core:fmt"

main :: proc() {
    fmt.println(raylib.rlGetVersion())

    game_state := game_state_setup()
    window_setup()

    for !raylib.WindowShouldClose() {
        main_step(&game_state)
        main_draw(&game_state)
    }

    raylib.CloseWindow()
}

Game_State :: struct {
    world: World,
    player: ^Player,
    sprites: map[Sprite_Id]raylib.Texture
}

game_state_setup :: proc() -> Game_State {
    game_state := Game_State{}
    game_state.sprites = load_sprites()
    
    append(&game_state.world.entities, Entity{})
    append(&game_state.world.entities, Entity{})
    append(&game_state.world.entities, Entity{})

    return game_state
}

main_step :: proc(state: ^Game_State) {
    for _, i in state.world.entities {
        entity_step(&state.world.entities[i])
    }
}

main_draw :: proc(state: ^Game_State) {
    raylib.BeginDrawing()
    defer raylib.EndDrawing()

    raylib.ClearBackground(raylib.GRAY)
    
    for _, i in state.world.entities {
        entity_draw(&state.world.entities[i], state)
    }
}
