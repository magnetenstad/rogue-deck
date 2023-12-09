package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

World :: struct {
    chunks: map[rl.Vector2]Chunk,
    entities: [dynamic]Entity,
}

Chunk :: struct {
    entity_ids: [dynamic]int
}

world_to_chunk_entity_union :: proc(entity: ^Entity) -> rl.Vector2 {
    return world_to_chunk(entity.position)
}

world_to_chunk_vector :: proc(position: rl.Vector2) -> rl.Vector2 {
    return rl.Vector2 { 
        math.floor(position.x / CHUNK_WIDTH), 
        math.floor(position.y / CHUNK_HEIGHT),
    }
}

world_to_chunk :: proc{
    world_to_chunk_entity_union,
    world_to_chunk_vector,
}

world_add_entity :: proc(world: ^World, entity: Entity) -> int {
    entity := entity
    entity.id = len(world.entities)
    append(&world.entities, entity)
    chunk_add_entity(world, entity.id)
    return entity.id
}

// Places the given entity in the chunk that matches its position
@(private="file")
chunk_add_entity :: proc(world: ^World, entity_id: int) {
    entity := &world.entities[entity_id]
    chunk_position := world_to_chunk(entity.position)

    if chunk_position not_in world.chunks {
        world.chunks[chunk_position] = Chunk{}
        fmt.println(chunk_position)
    }
    chunk := &world.chunks[chunk_position]
    append(&chunk.entity_ids, entity.id)
    entity.chunk = chunk_position
}

world_get_entities_around :: proc(world: ^World, 
        world_position: rl.Vector2) -> [dynamic]int {

    entity_ids: [dynamic]int
    
    X :: CHUNK_RENDER_DISTANCE_X
    Y :: CHUNK_RENDER_DISTANCE_Y
    chunk_center := world_to_chunk(world_position)

    for x := -X; x <= X; x += 1 {
        for y := -Y; y <= Y; y += 1 {
            chunk_position := chunk_center + { f32(x), f32(y) }
            if chunk_position not_in world.chunks do continue;

            chunk := world.chunks[chunk_position]
            append(&entity_ids, ..chunk.entity_ids[:])
        }
    }
    
    return entity_ids
}

chunk_validate :: proc(world: ^World, entity_id: int) {
    entity := &world.entities[entity_id]
    
    chunk_position := world_to_chunk(entity)
    if entity.chunk == chunk_position do return

    chunk_before := &world.chunks[entity.chunk]
    removed := false

    for _, i in chunk_before.entity_ids {
        if chunk_before.entity_ids[i] == entity.id {
            unordered_remove(&chunk_before.entity_ids, i)
            removed = true
            break
        }
    }
    assert(removed)

    chunk_add_entity(world, entity_id)
}
