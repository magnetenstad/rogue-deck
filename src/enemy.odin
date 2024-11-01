#+vet unused shadowing using-stmt style semicolon
package main

import "core:math/rand"

Enemy_Move :: enum {
	left,
	right,
	up,
	down,
	nothing,
}

enemy_moves: []Enemy_Move = {.left, .right, .up, .down, .nothing}

enemy_step :: proc(game_state: ^Game_State, enemy: ^Entity) {
	assert(enemy.kind == .enemy)
	if enemy.done do return

	enemy_moves: [dynamic]Enemy_Move = {.nothing}
	player := get_player()
	if player.position.x > enemy.position.x {
		append(&enemy_moves, Enemy_Move.right)
	}
	if player.position.x < enemy.position.x {
		append(&enemy_moves, Enemy_Move.left)
	}
	if player.position.y > enemy.position.y {
		append(&enemy_moves, Enemy_Move.down)
	}
	if player.position.y < enemy.position.y {
		append(&enemy_moves, Enemy_Move.up)
	}

	next_position := enemy.position
	move := rand.choice(enemy_moves[:])
	if move == .up do next_position.y -= 1
	if move == .left do next_position.x -= 1
	if move == .down do next_position.y += 1
	if move == .right do next_position.x += 1

	if world_is_empty(&game_state.world, next_position) {
		enemy.position = next_position
	}

	enemy.done = true
}
