package main

import rl "vendor:raylib"

DEV :: true
DESKTOP :: true

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

SURFACE_WIDTH :: 480
SURFACE_HEIGHT :: 270
