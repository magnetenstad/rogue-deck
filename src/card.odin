package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

Card :: struct {
    name: string,
    cost: int,
}

Deck :: struct {
    cards: [dynamic]Card,
}

Hand :: struct {
    cards: [dynamic]Card,
    max_size: int,
}

hand_play :: proc(hand: ^Hand, index: int, deck: ^Deck, 
        world: ^World, position: IVec2) -> bool {
    if index >= len(hand.cards) do return false

    card := hand.cards[index]
    if !card_play(&card, world, position) do return false
    
    ordered_remove(&hand.cards, index)
    append(&deck.cards, card)
    rand.shuffle(deck.cards[:])
    return true
}

hand_draw_from_deck :: proc(hand: ^Hand, deck: ^Deck) -> bool {
    if len(hand.cards) >= hand.max_size do return false
    if len(deck.cards) == 0 do return false

    card := pop(&deck.cards)
    append(&hand.cards, card)
    return true
}

hand_draw_to_screen :: proc(hand: ^Hand) {
    margin :: 20
    origin := f_vec_2(rl.GetScreenWidth(), rl.GetScreenHeight())
    origin.x /= 2
    origin.y -= margin
    width := f32(len(hand.cards) * (CARD_WIDTH + margin))
    for i in 0 ..< len(hand.cards) {
        offset := FVec2 { 
            f32(i) * (CARD_WIDTH + margin) - width / 2, 
            -CARD_HEIGHT,
        }
        card_draw_to_screen(&hand.cards[i], origin + offset)
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
    // TODO
    return true
}

card_draw_to_screen :: proc(card: ^Card, position: FVec2) {
    rect := rl.Rectangle { 
        x = position.x, 
        y = position.y, 
        width = CARD_WIDTH, 
        height = CARD_HEIGHT, 
    }
    rl.DrawRectangleRounded(rect, 0.2, 8, rl.WHITE)
}
