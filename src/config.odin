package main

import "vendor:raylib"

DEV :: true

when DEV {
    WINDOW_WIDTH :: 1920
    WINDOW_HEIGHT :: 2070
} else {
    WINDOW_WIDTH :: 1920
    WINDOW_HEIGHT :: 1080
}

window_setup :: proc() {
    using raylib
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Rogue Deck")
    SetWindowState({.WINDOW_RESIZABLE})
    SetTargetFPS(60)
    when DEV {
        SetWindowPosition(1920*2, -256)
    }
}
