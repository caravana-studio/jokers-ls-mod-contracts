use jokers_ls_mod::constants::effect::{
    SPECIAL_MULTI_FOR_HEARTS_EFFECT_ID, SPECIAL_MULTI_FOR_DIAMONDS_EFFECT_ID, SPECIAL_MULTI_FOR_CLUBS_EFFECT_ID,
    SPECIAL_MULTI_FOR_SPADES_EFFECT_ID, SPECIAL_INCREASE_LEVEL_PAIR_EFFECT_ID,
    SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT_ID, SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT_ID,
    SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT_ID, SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT_ID,
    SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT_ID, SPECIAL_JOKER_BOOSTER_EFFECT_ID, SPECIAL_MODIFIER_BOOSTER_EFFECT_ID,
    SPECIAL_POINTS_FOR_FIGURES_EFFECT_ID, SPECIAL_MULTI_ACES_EFFECT_ID, SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT_ID,
    SPECIAL_HAND_THIEF_EFFECT_ID, SPECIAL_NEON_BONUS_EFFECT_ID, SPECIAL_DEADLINE_EFFECT_ID,
    SPECIAL_INITIAL_ADVANTAGE_EFFECT_ID, SPECIAL_LUCKY_SEVEN_EFFECT_ID
};
use jokers_ls_mod::models::data::effect_card::{EffectCard, TypeEffectCard};

const SPECIAL_MULTI_FOR_HEART_ID: u32 = 300;
const SPECIAL_MULTI_FOR_CLUB_ID: u32 = 301;
const SPECIAL_MULTI_FOR_DIAMOND_ID: u32 = 302;
const SPECIAL_MULTI_FOR_SPADE_ID: u32 = 303;
const SPECIAL_INCREASE_LEVEL_PAIR_ID: u32 = 304;
const SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID: u32 = 305;
const SPECIAL_INCREASE_LEVEL_STRAIGHT_ID: u32 = 306;
const SPECIAL_INCREASE_LEVEL_FLUSH_ID: u32 = 307;
const SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID: u32 = 308;
const SPECIAL_FLUSH_WITH_FOUR_CARDS_ID: u32 = 309;
const SPECIAL_JOKER_BOOSTER_ID: u32 = 310;
const SPECIAL_MODIFIER_BOOSTER_ID: u32 = 311;
const SPECIAL_POINTS_FOR_FIGURES_ID: u32 = 312;
const SPECIAL_MULTI_ACES_ID: u32 = 313;
const SPECIAL_ALL_CARDS_TO_HEARTS_ID: u32 = 314;
const SPECIAL_HAND_THIEF_ID: u32 = 315;
const SPECIAL_EXTRA_HELP_ID: u32 = 316;
const SPECIAL_LUCKY_SEVEN_ID: u32 = 317;
const SPECIAL_NEON_BONUS_ID: u32 = 318;
const SPECIAL_DEADLINE_ID: u32 = 319;
const SPECIAL_INITIAL_ADVANTAGE_ID: u32 = 320;
const SPECIAL_LUCKY_HAND_ID: u32 = 321;

fn SPECIAL_MULTI_FOR_HEART() -> EffectCard {
    EffectCard {
        id: SPECIAL_MULTI_FOR_HEART_ID,
        price: 3000,
        probability: 5,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_MULTI_FOR_HEARTS_EFFECT_ID,
    }
}

fn SPECIAL_MULTI_FOR_DIAMOND() -> EffectCard {
    EffectCard {
        id: SPECIAL_MULTI_FOR_DIAMOND_ID,
        price: 3000,
        probability: 5,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_MULTI_FOR_DIAMONDS_EFFECT_ID,
    }
}

fn SPECIAL_MULTI_FOR_CLUB() -> EffectCard {
    EffectCard {
        id: SPECIAL_MULTI_FOR_CLUB_ID,
        price: 3000,
        probability: 5,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_MULTI_FOR_CLUBS_EFFECT_ID,
    }
}

fn SPECIAL_MULTI_FOR_SPADE() -> EffectCard {
    EffectCard {
        id: SPECIAL_MULTI_FOR_SPADE_ID,
        price: 3000,
        probability: 5,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_MULTI_FOR_SPADES_EFFECT_ID,
    }
}

fn SPECIAL_INCREASE_LEVEL_PAIR() -> EffectCard {
    EffectCard {
        id: SPECIAL_INCREASE_LEVEL_PAIR_ID,
        price: 2000,
        probability: 8,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_INCREASE_LEVEL_PAIR_EFFECT_ID,
    }
}

fn SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR() -> EffectCard {
    EffectCard {
        id: SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID,
        price: 2000,
        probability: 8,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT_ID,
    }
}

fn SPECIAL_INCREASE_LEVEL_STRAIGHT() -> EffectCard {
    EffectCard {
        id: SPECIAL_INCREASE_LEVEL_STRAIGHT_ID,
        price: 2000,
        probability: 8,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT_ID,
    }
}

fn SPECIAL_INCREASE_LEVEL_FLUSH() -> EffectCard {
    EffectCard {
        id: SPECIAL_INCREASE_LEVEL_FLUSH_ID,
        price: 2000,
        probability: 8,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT_ID,
    }
}

fn SPECIAL_STRAIGHT_WITH_FOUR_CARDS() -> EffectCard {
    EffectCard {
        id: SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID,
        price: 3400,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT_ID,
    }
}

fn SPECIAL_FLUSH_WITH_FOUR_CARDS() -> EffectCard {
    EffectCard {
        id: SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
        price: 3400,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT_ID,
    }
}

fn SPECIAL_JOKER_BOOSTER() -> EffectCard {
    EffectCard {
        id: SPECIAL_JOKER_BOOSTER_ID,
        price: 6600,
        probability: 3,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_JOKER_BOOSTER_EFFECT_ID,
    }
}

fn SPECIAL_MODIFIER_BOOSTER() -> EffectCard {
    EffectCard {
        id: SPECIAL_MODIFIER_BOOSTER_ID,
        price: 7000,
        probability: 3,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_MODIFIER_BOOSTER_EFFECT_ID,
    }
}

fn SPECIAL_POINTS_FOR_FIGURES() -> EffectCard {
    EffectCard {
        id: SPECIAL_POINTS_FOR_FIGURES_ID,
        price: 4000,
        probability: 3,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_POINTS_FOR_FIGURES_EFFECT_ID,
    }
}

fn SPECIAL_MULTI_ACES() -> EffectCard {
    EffectCard {
        id: SPECIAL_MULTI_ACES_ID,
        price: 4000,
        probability: 3,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_MULTI_ACES_EFFECT_ID,
    }
}

fn SPECIAL_ALL_CARDS_TO_HEARTS() -> EffectCard {
    EffectCard {
        id: SPECIAL_ALL_CARDS_TO_HEARTS_ID,
        price: 4000,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT_ID,
    }
}

fn SPECIAL_HAND_THIEF() -> EffectCard {
    EffectCard {
        id: SPECIAL_HAND_THIEF_ID,
        price: 5000,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_HAND_THIEF_EFFECT_ID,
    }
}

fn SPECIAL_EXTRA_HELP() -> EffectCard {
    EffectCard {
        id: SPECIAL_EXTRA_HELP_ID, price: 5000, probability: 4, type_effect_card: TypeEffectCard::Special, effect_id: 0,
    }
}

fn SPECIAL_LUCKY_SEVEN() -> EffectCard {
    EffectCard {
        id: SPECIAL_LUCKY_SEVEN_ID,
        price: 6000,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_LUCKY_SEVEN_EFFECT_ID,
    }
}

fn SPECIAL_NEON_BONUS() -> EffectCard {
    EffectCard {
        id: SPECIAL_NEON_BONUS_ID,
        price: 4000,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_NEON_BONUS_EFFECT_ID,
    }
}

fn SPECIAL_DEADLINE() -> EffectCard {
    EffectCard {
        id: SPECIAL_DEADLINE_ID,
        price: 6600,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_DEADLINE_EFFECT_ID,
    }
}

fn SPECIAL_INITIAL_ADVANTAGE() -> EffectCard {
    EffectCard {
        id: SPECIAL_INITIAL_ADVANTAGE_ID,
        price: 6600,
        probability: 4,
        type_effect_card: TypeEffectCard::Special,
        effect_id: SPECIAL_INITIAL_ADVANTAGE_EFFECT_ID,
    }
}

fn INVALID_EFFECT_CARD() -> EffectCard {
    EffectCard { id: 0, price: 0, probability: 0, type_effect_card: TypeEffectCard::Special, effect_id: 0, }
}

fn SPECIAL_LUCKY_HAND() -> EffectCard {
    EffectCard {
        id: SPECIAL_LUCKY_HAND_ID, price: 5000, probability: 4, type_effect_card: TypeEffectCard::Special, effect_id: 0,
    }
}

fn specials_ids_all() -> Array<u32> {
    array![
        SPECIAL_MULTI_FOR_HEART_ID,
        SPECIAL_MULTI_FOR_CLUB_ID,
        SPECIAL_MULTI_FOR_DIAMOND_ID,
        SPECIAL_MULTI_FOR_SPADE_ID,
        SPECIAL_INCREASE_LEVEL_PAIR_ID,
        SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID,
        SPECIAL_INCREASE_LEVEL_STRAIGHT_ID,
        SPECIAL_INCREASE_LEVEL_FLUSH_ID,
        SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID,
        SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
        SPECIAL_JOKER_BOOSTER_ID,
        SPECIAL_MODIFIER_BOOSTER_ID,
        SPECIAL_POINTS_FOR_FIGURES_ID,
        SPECIAL_MULTI_ACES_ID,
        SPECIAL_ALL_CARDS_TO_HEARTS_ID,
        SPECIAL_HAND_THIEF_ID,
        SPECIAL_EXTRA_HELP_ID,
        SPECIAL_LUCKY_SEVEN_ID,
        SPECIAL_NEON_BONUS_ID,
        SPECIAL_DEADLINE_ID,
        SPECIAL_INITIAL_ADVANTAGE_ID,
        SPECIAL_LUCKY_HAND_ID,
    ]
}

fn common_specials_ids() -> Array<u32> {
    array![
        SPECIAL_MULTI_FOR_HEART_ID,
        SPECIAL_MULTI_FOR_CLUB_ID,
        SPECIAL_MULTI_FOR_DIAMOND_ID,
        SPECIAL_MULTI_FOR_SPADE_ID,
        SPECIAL_INCREASE_LEVEL_PAIR_ID,
        SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID,
        SPECIAL_LUCKY_HAND_ID,
    ]
}

fn uncommon_specials_ids() -> Array<u32> {
    array![
        SPECIAL_INCREASE_LEVEL_STRAIGHT_ID,
        SPECIAL_INCREASE_LEVEL_FLUSH_ID,
        SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID,
        SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
        SPECIAL_MULTI_ACES_ID,
        SPECIAL_NEON_BONUS_ID
    ]
}

fn rare_specials_ids() -> Array<u32> {
    array![SPECIAL_HAND_THIEF_ID, SPECIAL_LUCKY_SEVEN_ID, SPECIAL_POINTS_FOR_FIGURES_ID, SPECIAL_ALL_CARDS_TO_HEARTS_ID]
}

fn epic_specials_ids() -> Array<u32> {
    array![SPECIAL_EXTRA_HELP_ID, SPECIAL_JOKER_BOOSTER_ID, SPECIAL_DEADLINE_ID]
}

fn legendary_specials_ids() -> Array<u32> {
    array![SPECIAL_INITIAL_ADVANTAGE_ID, SPECIAL_MODIFIER_BOOSTER_ID]
}
