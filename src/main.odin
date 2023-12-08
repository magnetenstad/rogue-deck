package main

import "vendor:raylib"

main :: proc() {
    game_state := GameState{}
    window_setup()

    for !raylib.WindowShouldClose() {
        main_step(&game_state)
        main_draw(&game_state)
    }

    raylib.CloseWindow()
}

GameState :: struct {
}

main_step :: proc(state: ^GameState) {

}

main_draw :: proc(state: ^GameState) {
    raylib.BeginDrawing()
    defer raylib.EndDrawing()

    raylib.ClearBackground(raylib.GRAY)
}
