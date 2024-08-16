//+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"

Tile_Modifier :: enum {
	fire,
	poison,
	water,
	snow,
	grass,
	blocked,
}

Tile :: struct {
	_modifiers: bit_set[Tile_Modifier],
}

tile_add_modifier :: proc(tile: ^Tile, modifier: Tile_Modifier) {
	switch (modifier) {
	case .blocked:
	case .fire:
		tile_remove_modifier(tile, .grass)
		tile_remove_modifier(tile, .water)
		tile_remove_modifier(tile, .snow)
	case .grass:
	case .poison:
	case .snow:
		tile_remove_modifier(tile, .fire)
		tile_remove_modifier(tile, .water)
	case .water:
		tile_remove_modifier(tile, .fire)
		tile_remove_modifier(tile, .snow)
	}
	tile._modifiers += {modifier}
}

tile_remove_modifier :: proc(tile: ^Tile, modifier: Tile_Modifier) {
	tile._modifiers -= {modifier}
}

tile_get_color :: proc(tile: ^Tile) -> rl.Color {
	if .fire in tile._modifiers do return {255, 10, 10, 255}
	if .water in tile._modifiers do return {10, 10, 255, 255}
	if .grass in tile._modifiers do return {10, 255, 10, 255}
	return COLOR_BACKGROUND_LIGHT
}
