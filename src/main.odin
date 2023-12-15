//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"
import "core:os"

@(private="file")
_game_state : Game_State

get_game_state :: proc() -> ^Game_State {
    return &_game_state
}

get_player :: proc() -> ^Entity {
    game_state := get_game_state()
    player, _ := world_get_entity(&game_state.world, 
        game_state.player_id).(^Entity)
    return player
}

main :: proc() {
    // Read save file and create game state
    data_read, ok := os.read_entire_file("saves/data.json")
    if ok && LOAD_SAVE {
        _game_state = game_state_deserialize(data_read)
    } else {
        _game_state = game_state_create()
    }
    graphics_create(&_game_state)

    // Main loop
    for !rl.WindowShouldClose() {
        _main_step(&_game_state)
        _main_draw(&_game_state)
    }

    // Write save file and close
    data_to_write, _ :=  game_state_serialize(&_game_state)
    os.write_entire_file("saves/data.json", data_to_write)
    rl.CloseWindow()
}

@(private="file")
_main_step :: proc(game_state: ^Game_State) {
    player := get_player()

    // Entities
    switch game_state.phase {
        case .turn_player:
            player_step(player)

        case .turn_enemy:
            for entity_id in world_get_entities_around(
                    &game_state.world, player.position) {
                entity, _ := world_get_entity(&game_state.world, 
                    entity_id).(^Entity)
                enemy_step(entity)
            }
            game_state.phase = .turn_player
    }
    
    for entity_id in world_get_entities_around(
            &game_state.world, player.position) {
        
        entity, _ := world_get_entity(&game_state.world, 
            entity_id).(^Entity)
        entity_step(entity)
    }

    // Camera
    camera := &game_state.graphics.camera
    camera_step(camera, &game_state.world)

    // Hand
    hand_step(&game_state.hand, &game_state.deck, &game_state.world, camera)
}

@(private="file")
_main_draw :: proc(game_state: ^Game_State) {
    camera := &game_state.graphics.camera
    scale := camera_surface_scale(camera)
    player := get_player()

    // Draw onto texture
    rl.BeginTextureMode(game_state.graphics.surface)
    {
        // Background
        rl.ClearBackground({0, 0, 0, 255})
        for x in 0 ..= SURFACE_WIDTH / GRID_SIZE {
            for y in 0 ..= SURFACE_HEIGHT / GRID_SIZE {
                if ((x % 2) + (y % 2)) != 1 do continue
                rl.DrawRectangleV(
                    camera_world_to_surface(camera, IVec2 { x, y }),
                    {GRID_SIZE, GRID_SIZE},
                    {40, 26, 30, 255})
            }
        }
        
        // Entities
        for entity_id in world_get_entities_around(
                &game_state.world, player.position) {

            entity, _ := world_get_entity(&game_state.world, 
                entity_id).(^Entity)
            entity_draw(entity)
        }

        // Card range
        card_index, is_hovering := game_state.hand.hover_index.(int)
        if is_hovering {
            card := &game_state.hand.cards[card_index]
            rect := camera_world_to_surface(camera, 
                card_get_range_rect(&card.card))
            rl.DrawRectangleLinesEx(rect, 1, rl.WHITE)
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
            mfloor(camera.position.x, scale)- camera.position.x,
            mfloor(camera.position.y, scale) - camera.position.y,
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
 