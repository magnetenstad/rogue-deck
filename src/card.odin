package main

import rl "vendor:raylib"

Card_Id :: enum {
    skeleton,
    teleport,
    dagger,
    fire_ball,
}

Card :: struct {
    name: string,
    cost: int,
    attack: int,
    play: proc(^World, IVec2) -> bool,
    range: int,
    description: string,
}

card_draw_gui :: proc(card: ^PhysicalCard) {
    rect := card_get_rect(card)
    rl.DrawRectangleRounded(rect, 0.2, 8, rl.WHITE)
    rl.DrawRectangleRoundedLines(rect, 0.2, 8, 8, rl.BLACK)
    text_position := FVec2 {
        rect.x + rect.width * 0.1,
        rect.y + rect.height / 2,
    }
    draw_text(card.card.name, text_position, 
        size = 24 * card.scale, 
        color = rl.BLACK, 
        font = .nova_square_regular)

    description_position := text_position + FVec2 { 0, 32 } * card.scale
    draw_text(card.card.description, description_position, 
        size = 16 * card.scale, 
        color = rl.BLACK, 
        font = .nova_square_regular)

    cost_position := FVec2 {
        rect.x + rect.width * 0.1,
        rect.y + rect.width * 0.1,
    }
    draw_text(format(card.card.cost), cost_position, 
        size = 32 * card.scale, 
        color = rl.BLUE, 
        font = .lilita_one_regular)
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
                description = "Spawn a skelly",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    world_add_entity(world, 
                        Entity{kind=.enemy, sprite_id=.skeleton, position=position})
                    return true
                },
                range = 4,
                cost = 3,
            }
        case .teleport:
            return Card {
                name = "Teleport",
                description = "zooom",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    get_player().position = position
                    return true
                },
                range = 5,
                cost = 1,
            }
        case .dagger:
            return Card {
                name = "Dagger",
                description = "Deal 2 dmg",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    entity, hit := world_get_entity(world, position).(^Entity)
                    if hit {
                        (entity.id != get_game_state().player_id) or_return
                        entity.health -= 2
                        if entity.health <= 0 {
                            world_remove_entity(world, entity)
                        }
                    } 
                    return hit
                },
                range = 1,
                cost = 1,
            }
        case .fire_ball:
            return Card {
                name = "Fire Ball",
                description = "Deal 6 dmg",
                play = proc(world: ^World, position: IVec2) -> bool { 
                    entity, hit := world_get_entity(world, position).(^Entity)
                    if hit {
                        (entity.id != get_game_state().player_id) or_return
                        entity.health -= 6
                        if entity.health <= 0 {
                            world_remove_entity(world, entity)
                        }
                    } 
                    return hit
                },
                range = 2,
                cost = 4,
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
        card.range * 2,
        card.range * 2,
    )
}
