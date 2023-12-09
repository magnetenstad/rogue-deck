package main

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"
import "core:os"

@(private="file")
game_state : Game_State

get_game_state :: proc() -> ^Game_State {
    return &game_state
}

main :: proc() {
    
    data_read, ok := os.read_entire_file("saves/data.json")
    if ok {
        game_state = game_state_deserialize(data_read)
    } else {
        game_state = game_state_create()
    }
    
    graphics_create(&game_state)

    for !rl.WindowShouldClose() {
        main_step(&game_state)
        main_draw(&game_state)
    }

    data_to_write, _ :=  game_state_serialize(&game_state)
    os.write_entire_file("saves/data.json", data_to_write)
   
    rl.CloseWindow()
}

main_step :: proc(game_state: ^Game_State) {

    player := &game_state.world.entities[game_state.player_id]

    for entity_id in world_get_entities_around(
            &game_state.world, player.position) {
        
        entity := &game_state.world.entities[entity_id]
        entity_step(entity)
    }

    camera_step(&game_state.graphics.camera, game_state)
}

main_draw :: proc(game_state: ^Game_State) {
    
    rl.BeginTextureMode(game_state.graphics.surface);
    {
        rl.ClearBackground({0, 0, 0, 255})

        for x in 0 ..= SURFACE_WIDTH / GRID_SIZE {
            for y in 0 ..= SURFACE_HEIGHT / GRID_SIZE {
                if ((x % 2) + (y % 2)) != 1 do continue;
                rl.DrawRectangle(
                    i32((f32(x) - game_state.graphics.camera.position.x) * GRID_SIZE), 
                    i32((f32(y) - game_state.graphics.camera.position.y) * GRID_SIZE), 
                    GRID_SIZE, 
                    GRID_SIZE, 
                    {40, 26, 30, 255})
            }
        }
        
        player := &game_state.world.entities[game_state.player_id]
        for entity_id in world_get_entities_around(
                &game_state.world, player.position) {

            entity := &game_state.world.entities[entity_id]
            entity_draw(entity)
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
        
        fps := strings.clone_to_cstring(fmt.tprint(rl.GetFPS()))
        rl.DrawText(fps, 16, 16, 16, rl.WHITE)
    }
    rl.EndDrawing()
}
 