package main

import "vendor:raylib"
import "core:strings"

ASSETS_PATH :: "./assets/"

Sprite_Id :: enum {
    player,
    skeleton,
}

Sprite_Paths := [Sprite_Id]string {
    .player = "player.png",
    .skeleton = "skeleton.png",
}

load_sprites :: proc() -> map[Sprite_Id]raylib.Texture {
    m := make(map[Sprite_Id]raylib.Texture)

    for sprite_id in Sprite_Id {
        sprite_path := Sprite_Paths[sprite_id]
        full_path := strings.concatenate({ASSETS_PATH, sprite_path})
        m[sprite_id] = raylib.LoadTexture(strings.clone_to_cstring(full_path))
    }

    return m
}
