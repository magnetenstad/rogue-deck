//+vet unused shadowing using-stmt style semicolon
package main

import "core:math"
import "core:math/rand"
import "core:encoding/json"

Game_State :: struct {
    world: World,
    graphics: Graphics,
    hand: Hand,
    deck: Deck,
    player_id: int,
    current_entity_id: int,
}

@(private="file")
_Serializable_Game_State :: struct {
    entities: [dynamic]Entity,
    player_id: int,
}

game_state_create :: proc() -> Game_State {
    game_state := Game_State{}
    rng := rand.create(0)
    
    game_state.player_id = world_add_entity(&game_state.world, 
        Entity{
            kind = .player, 
            sprite_id = .player, 
            position = {8, 8},
            health = 10,
        })

    // World
    for i in 0 ..< 16 {
        position := i_vec_2( 
            math.floor(rand.float32(&rng) * SURFACE_WIDTH / GRID_SIZE), 
            math.floor(rand.float32(&rng) * SURFACE_HEIGHT / GRID_SIZE), 
        )
        world_add_entity(&game_state.world, 
            Entity{
                kind = .enemy, 
                sprite_id = .skeleton, 
                position = position,
                health = 2,
            })
    }

    // Deck
    card_ids: []Card_Id = { 
        // .skeleton,
        .teleport,
        .teleport,
        .teleport,
        .dagger,
        .dagger,
        .fire_ball,
    }
    for _ in 0 ..< 100 {
        card_id := rand.choice(card_ids)
        card := card_get(card_id)
        append(&game_state.deck.cards, card)
    }

    // Hand
    game_state.hand.cards_max = 8
    game_state.hand.cards_regen = 1
    game_state.hand.mana_max = 10
    game_state.hand.mana_regen = 2
    for _ in 0 ..< 4 {
        hand_draw_from_deck(&game_state.hand, &game_state.deck)
    }

    return game_state
}

game_state_serialize :: proc(
        game_state: ^Game_State) -> (data: []byte, err: json.Marshal_Error) {

    serializable := _Serializable_Game_State{
        entities=game_state.world.entities,
        player_id=game_state.player_id,
    }
    return json.marshal(serializable)
}

game_state_deserialize :: proc(data: []byte) -> Game_State {
    serializable: _Serializable_Game_State
    json.unmarshal(data, &serializable)
    
    game_state := Game_State{}
    game_state.world.entities = serializable.entities
    game_state.player_id = serializable.player_id
    for entity in game_state.world.entities {
        chunk_add_entity(&game_state.world, entity.id)
    }

    return game_state
}

select_next_entity :: proc(game_state: ^Game_State) {
    index := -1
    for entity, i in game_state.world.entities {
        if entity.id == game_state.current_entity_id {
            index = (i + 1) % len(game_state.world.entities)
            break
        }
    }
    if index != -1 {
        entity := &game_state.world.entities[index]
        entity.done = false
        game_state.current_entity_id = entity.id
        if game_state.current_entity_id == game_state.player_id {
            player_start_turn(game_state)
        }
    }
}

is_player_turn :: proc() -> bool {
    game_state := get_game_state()
    return game_state.current_entity_id == game_state.player_id
}
