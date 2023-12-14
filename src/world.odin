//+vet unused shadowing using-stmt style semicolon
package main

import "core:math"

World :: struct {
    chunks: map[IVec2]Chunk,
    entities: [dynamic]Entity,
}

Chunk :: struct {
    entity_ids: [dynamic]int,
}

world_to_chunk_entity :: proc(entity: ^Entity) -> IVec2 {
    return world_to_chunk_ivec(entity.position)
}

world_to_chunk_ivec :: proc(position: IVec2) -> IVec2 {
    return IVec2 { 
        position.x / CHUNK_WIDTH, 
        position.y / CHUNK_HEIGHT,
    }
}

world_to_chunk_vector :: proc(position: FVec2) -> IVec2 {
    return IVec2 { 
        int(math.floor(position.x / CHUNK_WIDTH)), 
        int(math.floor(position.y / CHUNK_HEIGHT)),
    }
}

world_to_chunk :: proc{
    world_to_chunk_entity,
    world_to_chunk_vector,
    world_to_chunk_ivec,
}

world_add_entity :: proc(world: ^World, entity: Entity) -> int {
    entity := entity
    entity.id = len(world.entities)
    append(&world.entities, entity)
    chunk_add_entity(world, entity.id)
    return entity.id
}

// Places the given entity in the chunk that matches its position
chunk_add_entity :: proc(world: ^World, entity_id: int) {
    entity := &world.entities[entity_id]
    chunk_position := world_to_chunk(entity.position)

    if chunk_position not_in world.chunks {
        world.chunks[chunk_position] = Chunk{}
        print(chunk_position)
    }
    chunk := &world.chunks[chunk_position]
    append(&chunk.entity_ids, entity.id)
    entity.chunk = chunk_position
}

world_get_entities_around :: proc(world: ^World, 
        world_position: IVec2) -> [dynamic]int {

    entity_ids: [dynamic]int
    
    X :: CHUNK_RENDER_DISTANCE_X
    Y :: CHUNK_RENDER_DISTANCE_Y
    chunk_center := world_to_chunk(world_position)

    for x := -X; x <= X; x += 1 {
        for y := -Y; y <= Y; y += 1 {
            chunk_position := chunk_center + { x, y }
            if chunk_position not_in world.chunks do continue

            chunk := world.chunks[chunk_position]
            append(&entity_ids, ..chunk.entity_ids[:])
        }
    }
    
    return entity_ids
}

chunk_validate :: proc(world: ^World, entity: ^Entity) {
    
    chunk_position := world_to_chunk(entity)
    if entity.chunk == chunk_position do return

    chunk_before := &world.chunks[entity.chunk]
    removed := false

    for entity_id, i in chunk_before.entity_ids {
        if entity_id == entity.id {
            unordered_remove(&chunk_before.entity_ids, i)
            removed = true
            break
        }
    }
    assert(removed)

    chunk_add_entity(world, entity.id)
}

world_get_entity :: proc(world: ^World, 
        world_position: IVec2) -> Maybe(int) {

    chunk_position := world_to_chunk(world_position)
    if chunk_position not_in world.chunks do return nil

    chunk := world.chunks[chunk_position]
    for entity_id in chunk.entity_ids {
        entity := &world.entities[entity_id]
        if entity.position == world_position do return entity_id
    }
    return nil
}

world_empty :: proc(world: ^World, world_position: IVec2) -> bool {
    _, not_empty := world_get_entity(world, world_position).(int)
    return !not_empty
}
