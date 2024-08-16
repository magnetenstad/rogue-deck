//+vet unused shadowing using-stmt style semicolon
package main

import "core:math"
import "core:math/rand"

World :: struct {
	chunks:               map[IVec2]_Chunk,
	entities:             [dynamic]Entity,
	next_world_object_id: int,
}

@(private = "file")
_Chunk :: struct {
	world_object_ids: [dynamic]int,
	tiles:            [CHUNK_WIDTH]([CHUNK_HEIGHT]Tile),
}

world_to_chunk_entity :: proc(entity: ^Entity) -> IVec2 {
	return world_to_chunk_i_vec(entity.position)
}

world_to_chunk_i_vec :: proc(position: IVec2) -> IVec2 {
	return IVec2{position.x / CHUNK_WIDTH, position.y / CHUNK_HEIGHT}
}

world_to_chunk_f_vec :: proc(position: FVec2) -> IVec2 {
	return IVec2 {
		int(math.floor(position.x / CHUNK_WIDTH)),
		int(math.floor(position.y / CHUNK_HEIGHT)),
	}
}

world_to_chunk :: proc {
	world_to_chunk_entity,
	world_to_chunk_f_vec,
	world_to_chunk_i_vec,
}

world_get_chunk :: proc(
	world: ^World,
	world_position: IVec2,
) -> Maybe(^_Chunk) {
	chunk_position := world_to_chunk(world_position)
	if chunk_position not_in world.chunks do return nil
	return &world.chunks[chunk_position]
}

world_add_entity :: proc(world: ^World, entity: Entity) -> int {
	entity := entity
	entity.id = world.next_world_object_id
	world.next_world_object_id += 1
	append(&world.entities, entity)
	chunk_add_entity(world, entity.id)
	return entity.id
}

world_remove_entity :: proc(world: ^World, entity: ^Entity) -> bool {
	index := world_get_entity_index(world, entity.id)
	if index < 0 do return false
	chunk_remove_entity(world, entity)
	unordered_remove(&world.entities, index)
	return true
}

world_get_tile :: proc(world: ^World, world_position: IVec2) -> Maybe(^Tile) {
	chunk_position := world_to_chunk(world_position)
	if chunk_position not_in world.chunks do return nil
	chunk_local_position :=
		world_position -
		{chunk_position.x * CHUNK_WIDTH, chunk_position.y * CHUNK_HEIGHT}
	chunk := &world.chunks[chunk_position]
	return &chunk.tiles[chunk_local_position.x][chunk_local_position.y]
}

// Places the given entity in the chunk that matches its position
chunk_add_entity :: proc(world: ^World, entity_id: int) {
	entity, _ := world_get_entity(world, entity_id).(^Entity)
	chunk_position := world_to_chunk(entity.position)

	if chunk_position not_in world.chunks {
		world.chunks[chunk_position] = _Chunk{}
		chunk_tile_random(&world.chunks[chunk_position])
		print(chunk_position)
	}
	chunk := &world.chunks[chunk_position]
	append(&chunk.world_object_ids, entity.id)
	entity.chunk = chunk_position
}

chunk_tile_random :: proc(chunk: ^_Chunk) {
	for x in 0 ..< CHUNK_WIDTH {
		for y in 0 ..< CHUNK_HEIGHT {
			tile_add_modifier(
				&chunk.tiles[x][y],
				rand.choice_enum(Tile_Modifier),
			)
		}
	}
}

// Removes the entity from entity.chunk
chunk_remove_entity :: proc(world: ^World, entity: ^Entity) -> bool {
	chunk := &world.chunks[entity.chunk]
	for entity_id, i in chunk.world_object_ids {
		if entity_id == entity.id {
			unordered_remove(&chunk.world_object_ids, i)
			return true
		}
	}
	return false
}

world_get_entities_around :: proc(
	world: ^World,
	world_position: IVec2,
) -> [dynamic]int {

	entity_ids: [dynamic]int

	X :: CHUNK_RENDER_DISTANCE_X
	Y :: CHUNK_RENDER_DISTANCE_Y
	chunk_center := world_to_chunk(world_position)

	for x := -X; x <= X; x += 1 {
		for y := -Y; y <= Y; y += 1 {
			chunk_position := chunk_center + {x, y}
			if chunk_position not_in world.chunks do continue

			chunk := world.chunks[chunk_position]
			append(&entity_ids, ..chunk.world_object_ids[:])
		}
	}

	return entity_ids
}

chunk_validate :: proc(world: ^World, entity: ^Entity) {
	chunk_position := world_to_chunk(entity)
	if entity.chunk == chunk_position do return
	assert(chunk_remove_entity(world, entity))
	chunk_add_entity(world, entity.id)
}

@(private = "file")
_world_get_entity_from_position :: proc(
	world: ^World,
	world_position: IVec2,
) -> Maybe(^Entity) {

	chunk, ok := world_get_chunk(world, world_position).(^_Chunk)
	if !ok do return nil

	for entity_id in chunk.world_object_ids {
		entity, _ := world_get_entity(world, entity_id).(^Entity)
		if entity.position == world_position {
			return entity
		}
	}
	return nil
}

@(private = "file")
_world_get_entity_from_id :: proc(
	world: ^World,
	entity_id: int,
) -> Maybe(^Entity) {
	index := world_get_entity_index(world, entity_id)
	if index < 0 {
		return nil
	} else {
		return &world.entities[index]
	}
}

world_get_entity :: proc {
	_world_get_entity_from_position,
	_world_get_entity_from_id,
}

// Return its index in world.entities, not its id.
// Returns -1 if it is not found.
world_get_entity_index :: proc(world: ^World, entity_id: int) -> int {
	for entity, i in world.entities {
		if entity.id == entity_id {
			return i
		}
	}
	return -1
}

world_is_empty :: proc(world: ^World, world_position: IVec2) -> bool {
	_, not_empty := world_get_entity(world, world_position).(^Entity)
	return !not_empty
}
