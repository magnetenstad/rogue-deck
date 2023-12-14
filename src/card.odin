//+vet unused shadowing using-stmt style semicolon
package main

import "core:math/rand"
import rl "vendor:raylib"

Card :: struct {
    name: string,
    cost: int,
    attack: int,
    play: proc(IVec2, ^World) -> bool,
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
    target_position: Maybe(IVec2),
}

hand_step :: proc(hand: ^Hand, camera: ^Camera) {
    margin :: 32
    origin := f_vec_2(rl.GetScreenWidth(), rl.GetScreenHeight())
    origin.x /= 2
    origin.y -= CARD_HEIGHT / 2 + margin
    width := f32(len(hand.cards) * (CARD_WIDTH + margin))
    sorted_indices := sort_indices_by(
        hand.cards[:], 
        proc(a: PhysicalCard, b: PhysicalCard) -> bool { 
            return a.z_index > b.z_index 
        },
    )

    for i in sorted_indices {
        card := &hand.cards[i]
        hover_index, is_hovering := hand.hover_index.(int)
        
        // Targets
        offset := FVec2 { 
            f32(i) * (CARD_WIDTH + margin) - width / 2, 
            0,
        }
        card.target_position = origin + offset
        
        mouse_position := rl.GetMousePosition()
        card_rect := card_get_rect(card)

        if !is_hovering && point_in_rect(mouse_position, &card_rect) {
            hand.hover_index = i
        }

        if is_hovering && hover_index == i {
            card.target_scale = 2
            card.z_index = 1
            card.target_position.y -= CARD_HEIGHT / 2

            if rl.IsMouseButtonDown(.LEFT) {
                hand.target_position = camera_world_mouse_position(camera)
            } else if !point_in_rect(mouse_position, &card_rect) {
                hand.hover_index = nil
                hand.target_position = nil
            }
        } else {
            card.target_scale = 1
            card.z_index = 0
        }

        // Move towards targets
        card.position = move_towards(
            card.position, card.target_position, 0.1)
        card.scale = move_towards(card.scale, card.target_scale, 0.2)
    }
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

    hover_index, is_hovering := hand.hover_index.(int)
    target_position, is_targeting := hand.target_position.(IVec2)
    if is_hovering && is_targeting {
        card := hand.cards[hover_index]
        rl.DrawLineV(card.position, 
            camera_world_to_gui(camera, target_position), rl.WHITE)
    }
}

card_is_playable_at :: proc(card: ^Card, 
        world: ^World, position: IVec2) -> bool {
    // TODO
    return true
}

@(private="file")
card_play :: proc (card: ^Card, 
        world: ^World, position: IVec2) -> bool {
    if !card_is_playable_at(card, world, position) do return false
    card.play(position, world)
    return true
}

card_draw_to_screen :: proc(card: ^PhysicalCard) {
    rect := card_get_rect(card)
    rl.DrawRectangleRounded(rect, 0.2, 8, rl.WHITE)
    rl.DrawRectangleRoundedLines(rect, 0.2, 8, 8, rl.BLACK)
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
