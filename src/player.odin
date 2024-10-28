#+vet unused shadowing using-stmt style semicolon
package main

import "core:slice"
import "core:time"
import rl "vendor:raylib"

@(private = "file")
_time_last_input := time.now()

player_step :: proc(player: ^Entity) {
	assert(player.kind == .player)
	assert(is_player_turn())

	game_state := get_game_state()
	hand_step_player(game_state)

	costs, _ := slice.mapper(
		game_state.hand.cards[:],
		proc(c: PhysicalCard) -> int {return c.card.cost},
	)
	if slice.max(costs) > game_state.hand.mana {
		player_end_turn(game_state)
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
	for _ in 0 ..< game_state.hand.mana_regen {
		game_state.hand.mana = min(
			game_state.hand.mana_max,
			game_state.hand.mana + 1,
		)
	}
}
