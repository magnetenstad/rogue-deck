package main

import rl "vendor:raylib"

DEV :: true
DESKTOP :: false

when DEV && DESKTOP {
    WINDOW_WIDTH :: 1920
    WINDOW_HEIGHT :: 2070
} else when DEV {
    WINDOW_WIDTH :: 800
    WINDOW_HEIGHT :: 480
} else {
    WINDOW_WIDTH :: 1920
    WINDOW_HEIGHT :: 1080
}

window_setup :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Rogue Deck")
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(60)
    when DEV && DESKTOP {
        rl.SetWindowPosition(1920*2, -256)
    }
}
