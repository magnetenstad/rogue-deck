//+vet unused shadowing using-stmt style semicolon
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

enemy_step :: proc(enemy: ^Entity) {
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

	move := rand.choice(enemy_moves[:])
	if move == .up do enemy.position.y -= 1
	if move == .left do enemy.position.x -= 1
	if move == .down do enemy.position.y += 1
	if move == .right do enemy.position.x += 1

	enemy.done = true
}
