package main

import rl "vendor:raylib"
import "core:fmt"

@(private="file")
game_state : Game_State

get_game_state :: proc() -> ^Game_State {
    return &game_state
}

main :: proc() {
    fmt.println(rl.rlGetVersion())

    game_state = game_state_create()
    graphics_create(&game_state)

    for !rl.WindowShouldClose() {
        main_step(&game_state)
        main_draw(&game_state)
    }

    rl.CloseWindow()
}

main_step :: proc(game_state: ^Game_State) {
    for _, i in game_state.world.entities {
        entity_union_step(&game_state.world.entities[i])
    }
}

main_draw :: proc(game_state: ^Game_State) {
    
    rl.BeginTextureMode(game_state.graphics.surface);
    {
        rl.ClearBackground({0, 0, 0, 255})

        for _, i in game_state.world.entities {
            entity_union_draw(&game_state.world.entities[i])
        }
    }
    rl.EndTextureMode();

    rl.BeginDrawing()
    {
        rl.ClearBackground(rl.GRAY)

        texture := game_state.graphics.surface.texture
        scale : f32 = 4

        rl.DrawTexturePro(
            texture, 
            { 0.0, 0.0, f32(texture.width), - f32(texture.height) },
            { 
                (f32(rl.GetScreenWidth()) - f32(SURFACE_WIDTH)*scale)*0.5, 
                (f32(rl.GetScreenHeight()) - f32(SURFACE_HEIGHT)*scale)*0.5,
                f32(SURFACE_WIDTH*scale), 
                f32(SURFACE_HEIGHT*scale),
            }, 
            { 0, 0 }, 0.0, rl.WHITE);
    }
    rl.EndDrawing()
}
