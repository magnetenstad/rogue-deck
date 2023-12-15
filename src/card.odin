package main

import rl "vendor:raylib"

Card_Id :: enum {
    skeleton,
    teleport,
    dagger,
}

Card :: struct {
    name: string,
    cost: int,
    attack: int,
    play: proc(^World, IVec2) -> bool,
    range: int,
}

card_draw_to_screen :: proc(card: ^PhysicalCard) {
    rect := card_get_rect(card)
    rl.DrawRectangleRounded(rect, 0.2, 8, rl.WHITE)
    rl.DrawRectangleRoundedLines(rect, 0.2, 8, 8, rl.BLACK)
    rl.DrawText(
        cstr(card.card.name), 
        i32(rect.x + rect.width * 0.1),
        i32(rect.y + rect.height / 2),
        i32(16 * card.scale), rl.BLACK)
}

card_get_rect :: proc(card: ^PhysicalCard) -> rl.Rectangle {
    width := card.scale * CARD_WIDTH
    height := card.scale * CARD_HEIGHT
    return rl.Rectangle { 
        x = card.position.x - width / 2, 
        y = card.position.y - height / 2, 
        width = width, 
        height = height, 
    }
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
