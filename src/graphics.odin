package main

import rl "vendor:raylib"
import "core:strings"

ASSETS_PATH :: "./assets/"

Graphics :: struct {
    sprites: map[Sprite_Id]rl.Texture,
    surface: rl.RenderTexture2D,
}

Sprite_Id :: enum {
    player,
    skeleton,
}

Sprite_Paths := [Sprite_Id]string {
    .player = "player.png",
    .skeleton = "skeleton.png",
}

graphics_create :: proc(game_state: ^Game_State) {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Rogue Deck")
    rl.SetWindowState({.WINDOW_RESIZABLE, .WINDOW_TOPMOST})
    rl.SetTargetFPS(60)

    when DEV && DESKTOP {
        rl.SetWindowPosition(1920*2, -256)
    }

    game_state.graphics.sprites = load_sprites()

    game_state.graphics.surface = rl.LoadRenderTexture(SURFACE_WIDTH, SURFACE_HEIGHT);
    rl.SetTextureFilter(game_state.graphics.surface.texture, rl.TextureFilter.POINT);
}

@(private="file")
load_sprites :: proc() -> map[Sprite_Id]rl.Texture {
    m := make(map[Sprite_Id]rl.Texture)

    for sprite_id in Sprite_Id {
        sprite_path := Sprite_Paths[sprite_id]
        full_path := strings.concatenate({ASSETS_PATH, sprite_path})
        m[sprite_id] = rl.LoadTexture(strings.clone_to_cstring(full_path))
    }
    return m
}