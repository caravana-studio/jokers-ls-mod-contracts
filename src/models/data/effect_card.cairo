use jokers_of_neon::models::data::card::{Card, Suit, Value};
use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};

#[derive(Copy, Drop, IntrospectPacked, Serde)]
struct EffectCard {
    id: u32,
    effect_id: u32,
    price: u32,
    probability: u32,
    type_effect_card: TypeEffectCard
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
struct Effect {
    id: u32,
    multi_add: u32,
    multi_multi: u32,
    points: u32,
    poker_hand: PokerHand,
    suit: Suit
}

#[derive(Serde, Copy, Drop, IntrospectPacked, PartialEq)]
enum TypeEffectCard {
    Modifier,
    Special
}

impl SuitIntoFelt252 of Into<TypeEffectCard, felt252> {
    fn into(self: TypeEffectCard) -> felt252 {
        match self {
            TypeEffectCard::Modifier => 1,
            TypeEffectCard::Special => 2,
        }
    }
}
