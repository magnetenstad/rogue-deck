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
        screen_width := f32(rl.GetScreenWidth())
        screen_height := f32(rl.GetScreenHeight())
        surface_width := f32(SURFACE_WIDTH)
        surface_height := f32(SURFACE_HEIGHT)
        scale := min(
            screen_width / surface_width, 
            screen_height / surface_height)

        rl.DrawTexturePro(
            texture, 
            { 0.0, 0.0, f32(texture.width), - f32(texture.height) },
            { 
                (screen_width - surface_width*scale)*0.5, 
                (screen_height - surface_height*scale)*0.5,
                surface_width*scale, 
                surface_height*scale,
            }, 
            { 0, 0 }, 0.0, rl.WHITE);
    }
    rl.EndDrawing()
}
