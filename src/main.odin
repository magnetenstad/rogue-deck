//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"
import "core:os"

@(private="file")
game_state : Game_State

get_game_state :: proc() -> ^Game_State {
    return &game_state
}

main :: proc() {
    // Read save file and create game state
    data_read, ok := os.read_entire_file("saves/data.json")
    if ok && LOAD_SAVE {
        game_state = game_state_deserialize(data_read)
    } else {
        game_state = game_state_create()
    }
    graphics_create(&game_state)

    // Main loop
    for !rl.WindowShouldClose() {
        main_step(&game_state)
        main_draw(&game_state)
    }

    // Write save file and close
    data_to_write, _ :=  game_state_serialize(&game_state)
    os.write_entire_file("saves/data.json", data_to_write)
    rl.CloseWindow()
}

main_step :: proc(game_state: ^Game_State) {
    player := &game_state.world.entities[game_state.player_id]

    // Entities
    switch game_state.phase {
        case .turn_player:
            player_step(player)

        case .turn_enemy:
            for entity_id in world_get_entities_around(
                    &game_state.world, player.position) {
                entity := &game_state.world.entities[entity_id]
                enemy_step(entity)
            }
            game_state.phase = .turn_player
    }
    
    for entity_id in world_get_entities_around(
            &game_state.world, player.position) {
        
        entity := &game_state.world.entities[entity_id]
        entity_step(entity)
    }

    // Camera
    camera := &game_state.graphics.camera
    camera_step(camera, &game_state.world)

    // Hand
    hand_step(&game_state.hand, &game_state.deck, &game_state.world, camera)
}

main_draw :: proc(game_state: ^Game_State) {
    camera := &game_state.graphics.camera
    scale := camera_surface_scale(camera)
    
    // Draw onto texture
    rl.BeginTextureMode(game_state.graphics.surface)
    {
        // Background
        rl.ClearBackground({0, 0, 0, 255})
        for x in 0 ..= SURFACE_WIDTH / GRID_SIZE {
            for y in 0 ..= SURFACE_HEIGHT / GRID_SIZE {
                if ((x % 2) + (y % 2)) != 1 do continue
                rl.DrawRectangleV(
                    (f_vec_2(x, y)) * GRID_SIZE - camera.position / scale,
                    {GRID_SIZE, GRID_SIZE},
                    {40, 26, 30, 255})
            }
        }
        
        // Entities
        player := &game_state.world.entities[game_state.player_id]
        for entity_id in world_get_entities_around(
                &game_state.world, player.position) {

            entity := &game_state.world.entities[entity_id]
            entity_draw(entity)
        }
    }
    rl.EndTextureMode()

    // Draw texture onto screen
    rl.BeginDrawing()
    {
        rl.ClearBackground(rl.BLACK)
        texture := game_state.graphics.surface.texture
        surface_origin := camera_surface_origin(camera)
        // Hack to make camera smooth
        subpixel := FVec2 {
            mround(camera.position.x, scale)- camera.position.x,
            mround(camera.position.y, scale) - camera.position.y,
        }

        rl.DrawTexturePro(
            texture, 
            { 0.0, 0.0, f32(texture.width), - f32(texture.height) },
            {
                surface_origin.x + subpixel.x,
                surface_origin.y + subpixel.y,
                f32(SURFACE_WIDTH)*scale, 
                f32(SURFACE_HEIGHT)*scale,
            }, 
            { 0, 0 }, 0.0, rl.WHITE)
        
        fps := cstr(format(rl.GetFPS()))
        rl.DrawText(fps, 16, 16, 16, rl.WHITE)

        // GUI
        hand_draw_to_screen(&game_state.hand, camera)
    }
    rl.EndDrawing()
}
 