use jokers_of_neon::models::data::card::Suit;
use jokers_of_neon::models::data::effect_card::Effect;
use jokers_of_neon::models::data::poker_hand::PokerHand;

const SPECIAL_MULTI_FOR_HEARTS_EFFECT_ID: u32 = 1;
const SPECIAL_MULTI_FOR_DIAMONDS_EFFECT_ID: u32 = 2;
const SPECIAL_MULTI_FOR_CLUBS_EFFECT_ID: u32 = 3;
const SPECIAL_MULTI_FOR_SPADES_EFFECT_ID: u32 = 4;
const SPECIAL_INCREASE_LEVEL_PAIR_EFFECT_ID: u32 = 5;
const SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT_ID: u32 = 6;
const SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT_ID: u32 = 7;
const SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT_ID: u32 = 8;
const SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT_ID: u32 = 9;
const SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT_ID: u32 = 10;
const SPECIAL_JOKER_BOOSTER_EFFECT_ID: u32 = 11;
const SPECIAL_MODIFIER_BOOSTER_EFFECT_ID: u32 = 12;
const SPECIAL_POINTS_FOR_FIGURES_EFFECT_ID: u32 = 13;
const SPECIAL_MULTI_ACES_EFFECT_ID: u32 = 14;
const SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT_ID: u32 = 15;
const SPECIAL_HAND_THIEF_EFFECT_ID: u32 = 16;
const POINTS_MODIFIER_1_EFFECT_ID: u32 = 17;
const POINTS_MODIFIER_2_EFFECT_ID: u32 = 18;
const POINTS_MODIFIER_3_EFFECT_ID: u32 = 19;
const POINTS_MODIFIER_4_EFFECT_ID: u32 = 20;
const MULTI_MODIFIER_1_EFFECT_ID: u32 = 21;
const MULTI_MODIFIER_2_EFFECT_ID: u32 = 22;
const MULTI_MODIFIER_3_EFFECT_ID: u32 = 23;
const MULTI_MODIFIER_4_EFFECT_ID: u32 = 24;
const SUIT_CLUBS_MODIFIER_EFFECT_ID: u32 = 25;
const SUIT_DIAMONDS_MODIFIER_EFFECT_ID: u32 = 26;
const SUIT_HEARTS_MODIFIER_EFFECT_ID: u32 = 27;
const SUIT_SPADES_MODIFIER_EFFECT_ID: u32 = 28;
const SPECIAL_LUCKY_SEVEN_EFFECT_ID: u32 = 29;
const SPECIAL_NEON_BONUS_EFFECT_ID: u32 = 30;
const SPECIAL_DEADLINE_EFFECT_ID: u32 = 31;
const SPECIAL_INITIAL_ADVANTAGE_EFFECT_ID: u32 = 32;

fn SPECIAL_MULTI_FOR_HEARTS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_MULTI_FOR_HEARTS_EFFECT_ID,
        multi_add: 2,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Hearts,
    }
}

fn SPECIAL_MULTI_FOR_DIAMONDS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_MULTI_FOR_DIAMONDS_EFFECT_ID,
        multi_add: 2,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Diamonds,
    }
}

fn SPECIAL_MULTI_FOR_CLUBS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_MULTI_FOR_CLUBS_EFFECT_ID,
        multi_add: 2,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Clubs,
    }
}

fn SPECIAL_MULTI_FOR_SPADES_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_MULTI_FOR_SPADES_EFFECT_ID,
        multi_add: 2,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Spades,
    }
}

fn SPECIAL_INCREASE_LEVEL_PAIR_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_INCREASE_LEVEL_PAIR_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::OnePair,
        suit: Suit::None,
    }
}

fn SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::TwoPair,
        suit: Suit::None,
    }
}

fn SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::Straight,
        suit: Suit::None,
    }
}

fn SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::Flush,
        suit: Suit::None,
    }
}

fn SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::Straight,
        suit: Suit::None,
    }
}

fn SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 50,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_JOKER_BOOSTER_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_JOKER_BOOSTER_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_MODIFIER_BOOSTER_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_MODIFIER_BOOSTER_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_POINTS_FOR_FIGURES_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_POINTS_FOR_FIGURES_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_MULTI_ACES_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_MULTI_ACES_EFFECT_ID,
        multi_add: 5,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_HAND_THIEF_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_HAND_THIEF_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_LUCKY_SEVEN_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_LUCKY_SEVEN_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 77,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_NEON_BONUS_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_NEON_BONUS_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 20,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SPECIAL_DEADLINE_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_DEADLINE_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn POINTS_MODIFIER_1_EFFECT() -> Effect {
    Effect {
        id: POINTS_MODIFIER_1_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 10,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn POINTS_MODIFIER_2_EFFECT() -> Effect {
    Effect {
        id: POINTS_MODIFIER_2_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 20,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn POINTS_MODIFIER_3_EFFECT() -> Effect {
    Effect {
        id: POINTS_MODIFIER_3_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 50,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn POINTS_MODIFIER_4_EFFECT() -> Effect {
    Effect {
        id: POINTS_MODIFIER_4_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 100,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn MULTI_MODIFIER_1_EFFECT() -> Effect {
    Effect {
        id: MULTI_MODIFIER_1_EFFECT_ID,
        multi_add: 1,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn MULTI_MODIFIER_2_EFFECT() -> Effect {
    Effect {
        id: MULTI_MODIFIER_2_EFFECT_ID,
        multi_add: 2,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn MULTI_MODIFIER_3_EFFECT() -> Effect {
    Effect {
        id: MULTI_MODIFIER_3_EFFECT_ID,
        multi_add: 5,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn MULTI_MODIFIER_4_EFFECT() -> Effect {
    Effect {
        id: MULTI_MODIFIER_4_EFFECT_ID,
        multi_add: 10,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn SUIT_CLUBS_MODIFIER_EFFECT() -> Effect {
    Effect {
        id: SUIT_CLUBS_MODIFIER_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Clubs,
    }
}

fn SUIT_DIAMONDS_MODIFIER_EFFECT() -> Effect {
    Effect {
        id: SUIT_DIAMONDS_MODIFIER_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Diamonds,
    }
}

fn SUIT_HEARTS_MODIFIER_EFFECT() -> Effect {
    Effect {
        id: SUIT_HEARTS_MODIFIER_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Hearts
    }
}

fn SUIT_SPADES_MODIFIER_EFFECT() -> Effect {
    Effect {
        id: SUIT_SPADES_MODIFIER_EFFECT_ID,
        multi_add: 0,
        multi_multi: 0,
        points: 0,
        poker_hand: PokerHand::None,
        suit: Suit::Spades
    }
}

fn SPECIAL_INITIAL_ADVANTAGE_EFFECT() -> Effect {
    Effect {
        id: SPECIAL_INITIAL_ADVANTAGE_EFFECT_ID,
        multi_add: 10,
        multi_multi: 0,
        points: 100,
        poker_hand: PokerHand::None,
        suit: Suit::None,
    }
}

fn EMPTY_EFFECT() -> Effect {
    Effect { id: 0, multi_add: 0, multi_multi: 0, points: 0, poker_hand: PokerHand::None, suit: Suit::None, }
}
