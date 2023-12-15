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
    text_position := FVec2 {
        rect.x + rect.width * 0.1,
        rect.y + rect.height / 2,
    }
    draw_text(card.card.name, text_position, 24 * card.scale, rl.BLACK)
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

card_get :: proc(card_id: Card_Id) -> Card {
    switch card_id {
        case .skeleton:
            return Card {
                name = "Skeleton",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    world_add_entity(world, 
                        Entity{kind=.enemy, sprite_id=.skeleton, position=position})
                    return true
                },
                range = 5,
            }
        case .teleport:
            return Card {
                name = "Teleport",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    get_player().position = position
                    return true
                },
                range = 7,
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
                range = 1,
            }
    }
    return Card {
        name = "Empty",
        play = proc(world: ^World, position: IVec2) -> bool { 
            return true
        },
    }
}

card_get_range_rect :: proc(card: ^Card) -> rl.Rectangle {
    player := get_player()
    return f_rect(
        player.position.x - card.range,
        player.position.y - card.range,
        1 + card.range * 2,
        1 + card.range * 2,
    )
}
