use jokers_ls_mod::constants::card::{JOKER_CARD, NEON_JOKER_CARD};

// poker_hands
const POKER_HAND_ROYAL_FLUSH: u32 = 1;
const POKER_HAND_STRAIGHT_FLUSH: u32 = 2;
const POKER_HAND_FIVE_OF_A_KIND: u32 = 3;
const POKER_HAND_FOUR_OF_A_KIND: u32 = 4;
const POKER_HAND_FULL_HOUSE: u32 = 5;
const POKER_HAND_STRAIGHT: u32 = 6;
const POKER_HAND_FLUSH: u32 = 7;
const POKER_HAND_THREE_OF_A_KIND: u32 = 8;
const POKER_HAND_TWO_PAIR: u32 = 9;
const POKER_HAND_ONE_PAIR: u32 = 10;
const POKER_HAND_HIGH_CARD: u32 = 11;

const BASIC_BLISTER_PACK: u32 = 1;
const ADVANCED_BLISTER_PACK: u32 = 2;
const JOKER_BLISTER_PACK: u32 = 3;
const SPECIALS_BLISTER_PACK: u32 = 4;
const MODIFIER_BLISTER_PACK: u32 = 5;
const FIGURES_BLISTER_PACK: u32 = 6;
const DECEITFUL_JOKER_BLISTER_PACK: u32 = 7;
const LOVERS_BLISTER_PACK: u32 = 8;
const SPECIAL_BET_BLISTER_PACK: u32 = 9;

const RAGE_CARD_SILENT_HEARTS: u32 = 401;
const RAGE_CARD_SILENT_CLUBS: u32 = 402;
const RAGE_CARD_SILENT_DIAMONDS: u32 = 403;
const RAGE_CARD_SILENT_SPADES: u32 = 404;
const RAGE_CARD_SILENT_JOKERS: u32 = 405;
const RAGE_CARD_DIMINISHED_HOLD: u32 = 406;
const RAGE_CARD_ZERO_WASTE: u32 = 407;

fn poker_hands_all() -> Array<u32> {
    array![
        POKER_HAND_ROYAL_FLUSH,
        POKER_HAND_STRAIGHT_FLUSH,
        POKER_HAND_FIVE_OF_A_KIND,
        POKER_HAND_FOUR_OF_A_KIND,
        POKER_HAND_FULL_HOUSE,
        POKER_HAND_STRAIGHT,
        POKER_HAND_FLUSH,
        POKER_HAND_THREE_OF_A_KIND,
        POKER_HAND_TWO_PAIR,
        POKER_HAND_ONE_PAIR,
        POKER_HAND_HIGH_CARD
    ]
}

fn is_neon_card(card_id: u32) -> bool {
    card_id >= 200 && card_id <= 251 || card_id == NEON_JOKER_CARD
}

fn jokers_all() -> Array<u32> {
    array![JOKER_CARD, NEON_JOKER_CARD]
}

fn common_cards_all() -> Array<u32> {
    let mut idx = 0;
    let mut result = array![];
    loop {
        if idx == 52 {
            break;
        }
        result.append(idx);
        idx += 1;
    };
    result
}

fn blister_packs_all() -> Array<u32> {
    array![
        BASIC_BLISTER_PACK,
        ADVANCED_BLISTER_PACK,
        JOKER_BLISTER_PACK,
        SPECIALS_BLISTER_PACK,
        MODIFIER_BLISTER_PACK,
        FIGURES_BLISTER_PACK,
        DECEITFUL_JOKER_BLISTER_PACK,
        LOVERS_BLISTER_PACK,
        SPECIAL_BET_BLISTER_PACK
    ]
}

fn blister_packs_all_without_jokers() -> Array<u32> {
    array![
        BASIC_BLISTER_PACK,
        SPECIALS_BLISTER_PACK,
        MODIFIER_BLISTER_PACK,
        FIGURES_BLISTER_PACK,
        LOVERS_BLISTER_PACK,
        SPECIAL_BET_BLISTER_PACK
    ]
}

fn is_special_card(card_id: u32) -> bool {
    card_id >= 300 && card_id <= 400
}

fn is_modifier_card(card_id: u32) -> bool {
    card_id >= 600 && card_id <= 700
}

fn rage_cards_all() -> Array<u32> {
    array![
        RAGE_CARD_SILENT_HEARTS,
        RAGE_CARD_SILENT_CLUBS,
        RAGE_CARD_SILENT_DIAMONDS,
        RAGE_CARD_SILENT_SPADES,
        RAGE_CARD_SILENT_JOKERS,
        RAGE_CARD_DIMINISHED_HOLD,
        RAGE_CARD_ZERO_WASTE,
    ]
}

fn is_rage_card(card_id: u32) -> bool {
    card_id >= 401 && card_id <= 407
}
