#+vet unused shadowing using-stmt style semicolon
package main

import "core:slice"
import "core:time"
import rl "vendor:raylib"

@(private = "file")
_time_last_input := time.now()
clicked_player := false

player_step :: proc(game_state: ^Game_State, player: ^Entity) {
	assert(player.kind == .player)
	assert(is_player_turn())

	hand_step_player(game_state)
	camera := &game_state.graphics.camera
	mouse_position := camera_world_mouse_position(camera)

	if mouse_position == player.position && rl.IsMouseButtonPressed(.LEFT) {
		clicked_player = true
	}
	if !rl.IsMouseButtonDown(.LEFT) {
		if clicked_player {
			player.position = mouse_position
			player.done = true
		}
		clicked_player = false
	}
}

player_draw_gui :: proc(game_state: ^Game_State, player: ^Entity) {
	assert(player.kind == .player)
	camera := &game_state.graphics.camera
	mouse_position := camera_world_mouse_position(camera)
	scale := camera_surface_scale(camera)

	if clicked_player ||
	   (mouse_position == player.position && is_player_turn()) {

		gui_position := camera_world_to_gui(camera, player.position)
		rl.DrawRectangleRoundedLines(
			rl.Rectangle {
				gui_position.x,
				gui_position.y,
				GRID_SIZE * scale,
				GRID_SIZE * scale,
			},
			0.1,
			16,
			4,
			rl.WHITE,
		)
	}

	if clicked_player {
		gui_position := camera_world_to_gui(camera, mouse_position)
		rl.DrawRectangleRoundedLines(
			rl.Rectangle {
				gui_position.x,
				gui_position.y,
				GRID_SIZE * scale,
				GRID_SIZE * scale,
			},
			0.1,
			16,
			4,
			rl.WHITE,
		)
	}
}

@(private = "file")
_key_queue: [dynamic]rl.KeyboardKey
@(private = "file")
_wasd: []rl.KeyboardKey = {.W, .A, .S, .D}

@(private = "file")
_get_key :: proc() -> rl.KeyboardKey {
	for key in _wasd {
		if rl.IsKeyDown(key) && !slice.contains(_key_queue[:], key) {
			append(&_key_queue, key)
		}
	}
	for i := 0; i < len(_key_queue); i += 1 {
		if !rl.IsKeyDown(_key_queue[i]) {
			ordered_remove(&_key_queue, i)
			i -= 1
		}
	}
	key: rl.KeyboardKey = .KEY_NULL
	if len(_key_queue) > 0 {
		key = _key_queue[len(_key_queue) - 1]
	}
	return key
}

player_end_turn :: proc(game_state: ^Game_State) {
	player := get_player()
	if player.done do return

	player.done = true
}

player_start_turn :: proc(game_state: ^Game_State) {
	for _ in 0 ..< game_state.hand.cards_regen {
		hand_draw_from_deck(&game_state.hand, &game_state.deck)
	}
}
