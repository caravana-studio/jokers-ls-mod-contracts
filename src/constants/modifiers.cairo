use jokers_of_neon::constants::effect::{
    POINTS_MODIFIER_1_EFFECT_ID, POINTS_MODIFIER_2_EFFECT_ID, POINTS_MODIFIER_3_EFFECT_ID, POINTS_MODIFIER_4_EFFECT_ID,
    MULTI_MODIFIER_1_EFFECT_ID, MULTI_MODIFIER_2_EFFECT_ID, MULTI_MODIFIER_3_EFFECT_ID, MULTI_MODIFIER_4_EFFECT_ID,
    SUIT_CLUBS_MODIFIER_EFFECT_ID, SUIT_DIAMONDS_MODIFIER_EFFECT_ID, SUIT_HEARTS_MODIFIER_EFFECT_ID,
    SUIT_SPADES_MODIFIER_EFFECT_ID, SPECIAL_LUCKY_SEVEN_EFFECT_ID,
};
use jokers_of_neon::models::data::effect_card::{EffectCard, TypeEffectCard};

const POINTS_MODIFIER_1_ID: u32 = 600;
const POINTS_MODIFIER_2_ID: u32 = 601;
const POINTS_MODIFIER_3_ID: u32 = 602;
const POINTS_MODIFIER_4_ID: u32 = 603;
const MULTI_MODIFIER_1_ID: u32 = 604;
const MULTI_MODIFIER_2_ID: u32 = 605;
const MULTI_MODIFIER_3_ID: u32 = 606;
const MULTI_MODIFIER_4_ID: u32 = 607;

fn POINTS_MODIFIER_1() -> EffectCard {
    EffectCard {
        id: POINTS_MODIFIER_1_ID,
        price: 100,
        probability: 12,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: POINTS_MODIFIER_1_EFFECT_ID,
    }
}

fn POINTS_MODIFIER_2() -> EffectCard {
    EffectCard {
        id: POINTS_MODIFIER_2_ID,
        price: 200,
        probability: 8,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: POINTS_MODIFIER_2_EFFECT_ID,
    }
}

fn POINTS_MODIFIER_3() -> EffectCard {
    EffectCard {
        id: POINTS_MODIFIER_3_ID,
        price: 750,
        probability: 6,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: POINTS_MODIFIER_3_EFFECT_ID,
    }
}

fn POINTS_MODIFIER_4() -> EffectCard {
    EffectCard {
        id: POINTS_MODIFIER_4_ID,
        price: 1600,
        probability: 3,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: POINTS_MODIFIER_4_EFFECT_ID,
    }
}

fn MULTI_MODIFIER_1() -> EffectCard {
    EffectCard {
        id: MULTI_MODIFIER_1_ID,
        price: 200,
        probability: 10,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: MULTI_MODIFIER_1_EFFECT_ID,
    }
}

fn MULTI_MODIFIER_2() -> EffectCard {
    EffectCard {
        id: MULTI_MODIFIER_2_ID,
        price: 300,
        probability: 6,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: MULTI_MODIFIER_2_EFFECT_ID,
    }
}

fn MULTI_MODIFIER_3() -> EffectCard {
    EffectCard {
        id: MULTI_MODIFIER_3_ID,
        price: 750,
        probability: 3,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: MULTI_MODIFIER_3_EFFECT_ID,
    }
}

fn MULTI_MODIFIER_4() -> EffectCard {
    EffectCard {
        id: MULTI_MODIFIER_4_ID,
        price: 1600,
        probability: 1,
        type_effect_card: TypeEffectCard::Modifier,
        effect_id: MULTI_MODIFIER_4_EFFECT_ID,
    }
}

fn modifiers_ids_all() -> Array<u32> {
    array![
        POINTS_MODIFIER_1_ID,
        POINTS_MODIFIER_2_ID,
        POINTS_MODIFIER_3_ID,
        POINTS_MODIFIER_4_ID,
        MULTI_MODIFIER_1_ID,
        MULTI_MODIFIER_2_ID,
        MULTI_MODIFIER_3_ID,
        MULTI_MODIFIER_4_ID,
    ]
}
