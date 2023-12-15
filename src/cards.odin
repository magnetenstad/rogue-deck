package main

Card_Id :: enum {
    skeleton,
    teleport,
    dagger,
}

card_is_playable_at :: proc(card: ^Card, 
    world: ^World, position: IVec2) -> (playable: bool) {
return true
}

get_card :: proc(card_id: Card_Id) -> Card {
    switch card_id {
        case .skeleton:
            return Card {
                name = "Skeleton",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    world_add_entity(world, 
                        Entity{kind=.enemy, sprite_id=.skeleton, position=position})
                    return true
                },
            }
        case .teleport:
            return Card {
                name = "Teleport",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    state := get_game_state()
                    player, _ := world_get_entity(world, 
                        state.player_id).(^Entity)
                    player.position = position
                    return true
                },
            }
        case .dagger:
            return Card {
                name = "Dagger",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    entity, hit := world_get_entity(world, position).(^Entity)
                    if hit {
                        (entity.id != get_game_state().player_id) or_return
                        world_remove_entity(world, entity)
                    } 
                    return hit
                },
            }
    }
    return Card {
        name = "Empty",
        play = proc(world: ^World, position: IVec2) -> bool { 
            return true
        },
    }
}
