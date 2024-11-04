use jokers_of_neon::constants::card::{JOKER_CARD, NEON_JOKER_CARD};
use jokers_of_neon::constants::modifiers::modifiers_ids_all;
use jokers_of_neon::constants::specials::{
    specials_ids_all, SPECIAL_ALL_CARDS_TO_HEARTS_ID, common_specials_ids, uncommon_specials_ids, rare_specials_ids,
    epic_specials_ids, legendary_specials_ids
};
use jokers_of_neon::models::data::blister_pack::BlisterPack;
use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, ValueEnumerableImpl};
use jokers_of_neon::utils::constants::{jokers_all, common_cards_all};

const BASIC_BLISTER_PACK_ID: u32 = 1;
const ADVANCED_BLISTER_PACK_ID: u32 = 2;
const JOKER_BLISTER_PACK_ID: u32 = 3;
const SPECIALS_BLISTER_PACK_ID: u32 = 4;
const MODIFIER_BLISTER_PACK_ID: u32 = 5;
const FIGURES_BLISTER_PACK_ID: u32 = 6;
const DECEITFUL_JOKER_BLISTER_PACK_ID: u32 = 7;
const LOVERS_BLISTER_PACK_ID: u32 = 8;
const SPECIAL_BET_BLISTER_PACK_ID: u32 = 9;

const EMPTY_PACK_ID: u32 = 999;

const SPECIAL_CARDS_PACK_ID: u32 = 20;
const MODIFIER_CARDS_PACK_ID: u32 = 21;
const REWARD_CARDS_PACK_ID: u32 = 22;

fn blister_packs_ids_all() -> Array<u32> {
    array![
        BASIC_BLISTER_PACK_ID,
        ADVANCED_BLISTER_PACK_ID,
        JOKER_BLISTER_PACK_ID,
        SPECIALS_BLISTER_PACK_ID,
        MODIFIER_BLISTER_PACK_ID,
        FIGURES_BLISTER_PACK_ID,
        DECEITFUL_JOKER_BLISTER_PACK_ID,
        LOVERS_BLISTER_PACK_ID,
        SPECIAL_BET_BLISTER_PACK_ID
    ]
}

fn BASIC_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: BASIC_BLISTER_PACK_ID,
        cost: 1000,
        name: 'basic_pack',
        probability: 50,
        size: 5,
        cards: array![
            array![].span(),
            specials_ids_all().span(),
            modifiers_ids_all().span(),
            array![JOKER_CARD].span(),
            array![NEON_JOKER_CARD].span(),
            common_cards_all().span()
        ]
            .span(),
        probs: array![100, 2, 5, 4, 1, 88].span(),
    }
}

fn ADVANCED_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: ADVANCED_BLISTER_PACK_ID,
        cost: 1500,
        name: 'advanced_pack',
        probability: 50,
        size: 5,
        cards: array![
            array![].span(),
            specials_ids_all().span(),
            modifiers_ids_all().span(),
            array![JOKER_CARD].span(),
            array![NEON_JOKER_CARD].span(),
            common_cards_all().span()
        ]
            .span(),
        probs: array![100, 4, 10, 8, 2, 76].span(),
    }
}

fn JOKER_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: JOKER_BLISTER_PACK_ID,
        cost: 1500,
        name: 'joker_pack',
        probability: 50,
        size: 5,
        cards: array![
            array![].span(), array![JOKER_CARD].span(), array![NEON_JOKER_CARD].span(), common_cards_all().span()
        ]
            .span(),
        probs: array![100, 29, 1, 70].span(),
    }
}

fn SPECIALS_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: SPECIALS_BLISTER_PACK_ID,
        cost: 2000,
        name: 'specials_pack',
        probability: 50,
        size: 5,
        cards: array![array![].span(), specials_ids_all().span(), modifiers_ids_all().span(), common_cards_all().span()]
            .span(),
        probs: array![100, 20, 15, 65].span(),
    }
}

fn MODIFIER_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: MODIFIER_BLISTER_PACK_ID,
        cost: 1600,
        name: 'modifiers_pack',
        probability: 50,
        size: 5,
        cards: array![array![].span(), modifiers_ids_all().span(), common_cards_all().span()].span(),
        probs: array![100, 50, 50].span(),
    }
}

fn FIGURES_BLISTER_PACK() -> BlisterPack {
    let figures_cards = array![
        CardTrait::generate_id(Value::Jack, Suit::Hearts),
        CardTrait::generate_id(Value::Queen, Suit::Hearts),
        CardTrait::generate_id(Value::King, Suit::Hearts),
        CardTrait::generate_id(Value::Jack, Suit::Spades),
        CardTrait::generate_id(Value::Queen, Suit::Spades),
        CardTrait::generate_id(Value::King, Suit::Spades),
        CardTrait::generate_id(Value::Jack, Suit::Diamonds),
        CardTrait::generate_id(Value::Queen, Suit::Diamonds),
        CardTrait::generate_id(Value::King, Suit::Diamonds),
        CardTrait::generate_id(Value::Jack, Suit::Clubs),
        CardTrait::generate_id(Value::Queen, Suit::Clubs),
        CardTrait::generate_id(Value::King, Suit::Clubs),
    ];

    BlisterPack {
        id: FIGURES_BLISTER_PACK_ID,
        cost: 1000,
        name: 'figures_pack',
        probability: 50,
        size: 5,
        cards: array![array![].span(), figures_cards.span(), common_cards_all().span()].span(),
        probs: array![100, 70, 30].span(),
    }
}

fn DECEITFUL_JOKER_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: DECEITFUL_JOKER_BLISTER_PACK_ID,
        cost: 1700,
        name: 'deceitful_joker_pack',
        probability: 50,
        size: 4,
        cards: array![
            array![JOKER_CARD.into()].span(),
            array![JOKER_CARD].span(),
            array![NEON_JOKER_CARD].span(),
            common_cards_all().span()
        ]
            .span(),
        probs: array![100, 9, 1, 90].span(),
    }
}

fn LOVERS_BLISTER_PACK() -> BlisterPack {
    let hearts_ace = array![
        CardTrait::generate_id(Value::Ace, Suit::Hearts), CardTrait::generate_id(Value::Ace, Suit::Hearts)
    ];
    let values_all = ValueEnumerableImpl::all();
    let mut idx = 0;
    let mut heart_cards = array![];
    loop {
        if idx == values_all.len() {
            break;
        }
        heart_cards.append(CardTrait::generate_id(*values_all[idx], Suit::Hearts));
        heart_cards.append(CardTrait::generate_neon_id(*values_all[idx], Suit::Hearts));
        idx += 1;
    };

    BlisterPack {
        id: LOVERS_BLISTER_PACK_ID,
        cost: 1500,
        name: 'lovers_pack',
        probability: 50,
        size: 4,
        cards: array![
            hearts_ace.span(),
            array![SPECIAL_ALL_CARDS_TO_HEARTS_ID].span(),
            array![CardTrait::generate_id(Value::Ace, Suit::Hearts)].span(),
            heart_cards.span(),
        ]
            .span(),
        probs: array![100, 1, 29, 70].span(),
    }
}

fn SPECIAL_BET_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: SPECIAL_BET_BLISTER_PACK_ID,
        cost: 1000,
        name: 'special_bet_pack',
        probability: 50,
        size: 3,
        cards: array![array![].span(), specials_ids_all().span(), modifiers_ids_all().span(), common_cards_all().span()]
            .span(),
        probs: array![100, 5, 10, 85].span(),
    }
}

fn EMPTY_BLISTER_PACK() -> BlisterPack {
    BlisterPack {
        id: EMPTY_PACK_ID, cost: 0, name: '', probability: 0, size: 0, cards: array![].span(), probs: array![].span(),
    }
}

fn SPECIAL_CARDS_PACK() -> BlisterPack {
    BlisterPack {
        id: SPECIAL_CARDS_PACK_ID,
        cost: 0,
        name: 'special_cards_pack',
        probability: 100,
        size: 5,
        cards: array![
            array![].span(),
            legendary_specials_ids().span(),
            epic_specials_ids().span(),
            rare_specials_ids().span(),
            uncommon_specials_ids().span(),
            common_specials_ids().span()
        ]
            .span(),
        probs: array![100, 5, 10, 15, 25, 45].span(),
    }
}

fn MODIFIER_CARDS_PACK() -> BlisterPack {
    BlisterPack {
        id: MODIFIER_CARDS_PACK_ID,
        cost: 0,
        name: 'modifier_cards_pack',
        probability: 100,
        size: 6,
        cards: array![array![].span(), modifiers_ids_all().span()].span(),
        probs: array![100, 100].span(),
    }
}

fn REWARD_PACK() -> BlisterPack {
    BlisterPack {
        id: REWARD_CARDS_PACK_ID,
        cost: 0,
        name: 'reward_cards_pack',
        probability: 100,
        size: 5,
        cards: array![array![].span(), array![JOKER_CARD].span(), modifiers_ids_all().span()].span(),
        probs: array![100, 20, 80].span(),
    }
}
