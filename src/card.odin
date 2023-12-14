//+vet unused shadowing using-stmt style semicolon
package main

import "core:math/rand"
import rl "vendor:raylib"

Card :: struct {
    name: string,
    cost: int,
    attack: int,
    play: proc(^World, IVec2) -> bool,
}

PhysicalCard :: struct {
    card: Card,
    position: FVec2,
    scale: f32,
    target_position: FVec2,
    target_scale: f32,
    z_index: int,
}

Deck :: struct {
    cards: [dynamic]Card,
}

Hand :: struct {
    cards: [dynamic]PhysicalCard,
    max_size: int,
    hover_index: Maybe(int),
    hover_target: Maybe(IVec2),
    hover_is_selected: bool,
}

hand_step :: proc(hand: ^Hand, deck: ^Deck, world: ^World, camera: ^Camera) {
    sorted_indices := sort_indices_by(
        hand.cards[:], 
        proc(a: PhysicalCard, b: PhysicalCard) -> bool { 
            return a.z_index > b.z_index 
        },
    )
    hover_index, is_hovering := hand.hover_index.(int)
    mouse_gui_position := rl.GetMousePosition()

    for i in sorted_indices {
        if is_hovering && hover_index == i do continue

        card := &hand.cards[i]
        card.target_position = _card_position(i, len(hand.cards))
        card.target_scale = 1
        card.z_index = 0
        
        card_rect := card_get_rect(card)
        if !is_hovering && point_in_rect(mouse_gui_position, &card_rect) {
            hand.hover_index = i
        }
    }
    
    if is_hovering {
        card := &hand.cards[hover_index]
        card.z_index = 1

        if !hand.hover_is_selected {
            card.target_scale = 2
            card.target_position = 
                _card_position(hover_index, len(hand.cards)) + 
                FVec2 { 0, - CARD_HEIGHT / 2}
        }

        if rl.IsMouseButtonPressed(.LEFT) {
            hand.hover_is_selected = true
        }
        if rl.IsMouseButtonPressed(.RIGHT) {
            _hand_unhover(hand)
        }

        card_rect := card_get_rect(card)
        mouse_in_rect := point_in_rect(mouse_gui_position, &card_rect)
        
        if hand.hover_is_selected {
            card.target_scale = 2

            if camera_mouse_in_surface(camera) {
                card.target_position = mouse_gui_position +
                    FVec2 { CARD_WIDTH * 2, CARD_HEIGHT / 2 }
            } else {
                card.target_position = mouse_gui_position
            }

            mouse_world_position := camera_world_mouse_position(camera)
            hand.hover_target = mouse_world_position

            if rl.IsMouseButtonReleased(.LEFT) {
                if camera_mouse_in_surface(camera) {
                    hand_play(hand, hover_index, 
                        deck, world, mouse_world_position)
                }
                _hand_unhover(hand)
            }
        } else if !mouse_in_rect {
            _hand_unhover(hand)
        }
    }

    for &card in hand.cards {
        card.position = move_towards(
            card.position, card.target_position, 0.1)
        card.scale = move_towards(card.scale, card.target_scale, 0.2)
    }
}

_hand_unhover :: proc(hand: ^Hand) {
    hand.hover_index = nil
    hand.hover_target = nil
    hand.hover_is_selected = false
}

_card_position :: proc(i: int, n: int) -> FVec2 {
    margin :: 32
    gui_size := camera_gui_size()
    origin := FVec2 { gui_size.x / 2, gui_size.y - CARD_HEIGHT / 2 - margin }
    width := f32(n) * (CARD_WIDTH + margin)
    offset := FVec2 { f32(i) * (CARD_WIDTH + margin) - width / 2, 0 }
    return origin + offset
}

hand_play :: proc(hand: ^Hand, index: int, deck: ^Deck, 
        world: ^World, position: IVec2) -> bool {
    if index >= len(hand.cards) do return false

    card := hand.cards[index]
    if !card_play(&card.card, world, position) do return false
    
    ordered_remove(&hand.cards, index)
    append(&deck.cards, card.card)
    rand.shuffle(deck.cards[:])
    return true
}

hand_draw_from_deck :: proc(hand: ^Hand, deck: ^Deck) -> bool {
    if len(hand.cards) >= hand.max_size do return false
    if len(deck.cards) == 0 do return false

    card := pop(&deck.cards)
    append(&hand.cards, PhysicalCard { card = card })
    return true
}

hand_draw_to_screen :: proc(hand: ^Hand, camera: ^Camera) {
    sorted_indices := sort_indices_by(
        hand.cards[:], 
        proc(a: PhysicalCard, b: PhysicalCard) -> bool { 
            return a.z_index < b.z_index 
        },
    )
    for i in sorted_indices {
        card_draw_to_screen(&hand.cards[i])
    }

    _, is_hovering := hand.hover_index.(int)
    hover_target, is_targeting := hand.hover_target.(IVec2)
    if is_hovering && is_targeting {
        gui_position := camera_world_to_gui(camera, hover_target)
        scale := camera_surface_scale(camera)
        rl.DrawRectangleRoundedLines(
            rl.Rectangle {
                gui_position.x,
                gui_position.y,
                GRID_SIZE * scale,
                GRID_SIZE * scale,
            }, 
            0.1, 16, 4, rl.WHITE)
    }
}

card_is_playable_at :: proc(card: ^Card, 
        world: ^World, position: IVec2) -> (playable: bool) {
    world_empty(world, position) or_return
    return true
}

@(private="file")
card_play :: proc (card: ^Card, 
        world: ^World, position: IVec2) -> bool {
    if !card_is_playable_at(card, world, position) do return false
    card.play(world, position)
    return true
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
