use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::modifiers::modifiers_ids_all;
use jokers_of_neon::constants::specials::specials_ids_all;
use jokers_of_neon::constants::{card::{JOKER_CARD, NEON_JOKER_CARD}, two_pow::two_pow};
use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl,};
use jokers_of_neon::models::data::poker_hand::{PokerHandImpl, PokerHand};
use jokers_of_neon::models::status::game::game::Game;
use jokers_of_neon::models::status::round::current_hand_card::CurrentHandCardTrait;
use jokers_of_neon::models::status::round::deck_card::DeckCardTrait;
use jokers_of_neon::models::status::round::round::Round;
use jokers_of_neon::models::status::shop::shop::{
    Shop, CardItem, CardItemType, BlisterPackItem, PokerHandItem, SlotSpecialCardsItem
};
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::utils::constants::{
    poker_hands_all, is_neon_card, is_special_card, blister_packs_all, blister_packs_all_without_jokers
};
use jokers_of_neon::utils::random::{Random, RandomImpl, RandomTrait};

fn item_in_array<
    T,
    impl TPartialEq: core::traits::PartialEq<T>,
    impl TCopy: core::traits::Copy<T>,
    impl TDrop: core::traits::Drop<T>,
>(
    array: @Array<T>, item: T
) -> bool {
    let mut array_span = array.span();
    let result = loop {
        match array_span.pop_front() {
            Option::Some(seen_elem) => { if *seen_elem == item {
                break true;
            } },
            Option::None => { break false; }
        };
    };
    result
}

fn generate_unique_random_values(
    world: IWorldDispatcher, size: u32, values: Array<u32>, exclude: Array<u32>
) -> Array<u32> {
    let mut elements: Array<u32> = ArrayTrait::new();
    let mut randomizer = RandomImpl::new(world);

    assert(size <= values.len(), 'error size unique values');
    loop {
        if elements.len() == size {
            break;
        }
        let new_elem = *values.at(randomizer.between::<u32>(0, values.len() - 1));
        if item_in_array(@exclude, new_elem) || item_in_array(@elements, new_elem) {
            continue;
        }
        elements.append(new_elem);
    };
    elements
}

fn get_current_special_cards(ref store: Store, game: @Game) -> Array<u32> {
    let mut current_special_cards = array![];
    let mut idx = 0;
    loop {
        if idx == *game.len_current_special_cards {
            break;
        }
        let current_special_card = store.get_current_special_cards(*game.id, idx);
        current_special_cards.append(current_special_card.effect_card_id);
        idx += 1;
    };
    current_special_cards
}

fn round_to_nearest(nearest: u32, value: u32) -> u32 {
    let half = nearest / 2;
    let mut result = value + half;
    result -= result % nearest;
    result
}

fn update_items_shop(world: IWorldDispatcher, game: Game) {
    let mut store: Store = StoreTrait::new(world);
    let shop = store.get_shop(game.id);

    let mut cards_id = array![];
    let mut idx = 0;
    loop {
        if idx == 52 {
            break;
        }
        cards_id.append(idx);
        idx += 1;
    };

    // check current_jokers
    if game.current_jokers < game.max_jokers {
        cards_id.append(JOKER_CARD);
        cards_id.append(NEON_JOKER_CARD);
    }

    idx = 200;
    loop {
        if idx == 252 {
            break;
        }
        cards_id.append(idx);
        idx += 1;
    };

    let cards_id_uniques = generate_unique_random_values(world, shop.len_item_common_cards, cards_id, array![]);
    idx = 0;
    loop {
        if idx == shop.len_item_common_cards {
            break;
        }

        let card_id = *cards_id_uniques.at(idx);
        let cost = if card_id == NEON_JOKER_CARD {
            5000
        } else if card_id == JOKER_CARD {
            1500
        } else if is_neon_card(card_id) {
            700
        } else {
            200
        };

        store
            .set_card_item(
                CardItem {
                    game_id: game.id,
                    idx,
                    item_type: CardItemType::Common,
                    card_id,
                    cost,
                    purchased: false,
                    temporary: false
                }
            );
        idx += 1;
    };

    let modifiers = get_modifiers_probability(ref store);
    let modifiers_uniques = generate_unique_random_values(world, shop.len_item_modifier_cards, modifiers, array![]);
    idx = 0;
    loop {
        if idx == shop.len_item_modifier_cards {
            break;
        }

        let card_id = *modifiers_uniques.at(idx);
        let modifier_card = store.get_effect_card(card_id);
        store
            .set_card_item(
                CardItem {
                    game_id: game.id,
                    idx,
                    item_type: CardItemType::Modifier,
                    card_id,
                    cost: modifier_card.price,
                    purchased: false,
                    temporary: false
                }
            );
        idx += 1;
    };

    let specials = get_specials_probability(ref store);
    let current_special_cards = get_current_special_cards(ref store, @game);
    let specials_uniques = generate_unique_random_values(
        world, shop.len_item_special_cards, specials, current_special_cards
    );
    let temporary_uniques = generate_unique_random_values(
        world, shop.len_item_special_cards, array![0, 1, 2, 3, 4, 5, 6, 7, 8, 9], array![]
    );
    idx = 0;
    loop {
        if idx == shop.len_item_special_cards {
            break;
        }
        let card_id = *specials_uniques.at(idx);
        let special_card = store.get_effect_card(card_id);
        if *temporary_uniques.at(idx) >= 5 {
            store
                .set_card_item(
                    CardItem {
                        game_id: game.id,
                        idx,
                        item_type: CardItemType::Special,
                        card_id,
                        cost: special_card.price,
                        purchased: false,
                        temporary: false
                    }
                );
        } else {
            store
                .set_card_item(
                    CardItem {
                        game_id: game.id,
                        idx,
                        item_type: CardItemType::Special,
                        card_id,
                        cost: round_to_nearest(100, (special_card.price / 3)),
                        purchased: false,
                        temporary: true
                    }
                );
        }
        idx += 1;
    };

    // filter poker hands if level are eq than 20
    let mut filtered_poker_hands = array![];
    idx = 0;
    loop {
        if idx == poker_hands_all().len() {
            break;
        }
        let poker_hand_id = *poker_hands_all().at(idx);
        let poker_hand = poker_hand_id.try_into().unwrap();
        let user_poker_hand = store.get_player_level_poker_hand(game.id, poker_hand);
        if user_poker_hand.level < 10 {
            filtered_poker_hands.append(poker_hand_id);
        }
        idx += 1;
    };

    let shop_poker_hand_quantity = if filtered_poker_hands.len() <= 3 {
        filtered_poker_hands.len()
    } else {
        shop.len_item_poker_hands
    };

    let poker_hands_uniques = generate_unique_random_values(
        world, shop_poker_hand_quantity, filtered_poker_hands, array![]
    );
    idx = 0;
    loop {
        if idx == shop_poker_hand_quantity {
            break;
        }
        let poker_hand: PokerHand = (*poker_hands_uniques.at(idx)).try_into().unwrap();
        let user_poker_hand = store.get_player_level_poker_hand(game.id, poker_hand);
        store
            .set_poker_hand_item(
                PokerHandItem {
                    game_id: game.id,
                    idx,
                    poker_hand: poker_hand,
                    level: user_poker_hand.level + 1,
                    cost: get_poker_hand_item_cost(user_poker_hand.level + 1),
                    purchased: false,
                }
            );
        idx += 1;
    };

    let blister_pack_prob = get_blister_pack_probability(ref store, @game);
    let blister_pack_id_uniques = generate_unique_random_values(
        world, shop.len_item_blister_pack, blister_pack_prob, array![]
    );
    idx = 0;
    loop {
        if idx == shop.len_item_blister_pack {
            break;
        }
        let blister_pack_id = *blister_pack_id_uniques.at(idx);
        let blister_pack = store.get_blister_pack(blister_pack_id);

        store
            .set_blister_pack_item(
                BlisterPackItem { game_id: game.id, idx, blister_pack_id, cost: blister_pack.cost, purchased: false, }
            );
        idx += 1;
    };

    let slot_special_cards_config = store.get_slot_special_cards_config();
    store
        .set_slot_special_cards_item(
            SlotSpecialCardsItem {
                game_id: game.id,
                cost: slot_special_cards_config.initial_price
                    * two_pow((game.len_max_current_special_cards - 1).into()).try_into().unwrap(),
                purchased: game.len_max_current_special_cards == slot_special_cards_config.max_special_cards
            }
        );
}

/// The poker hand item cost follows the formula: 1.5^(level - 1) * 100
/// # Arguments
/// * `user_poker_hand_level` - The level of the user poker hand.
/// # Returns
/// * The cost of the poker hand item.
fn get_poker_hand_item_cost(user_poker_hand_level: u8) -> u32 {
    if user_poker_hand_level == 1 {
        100
    } else if user_poker_hand_level == 2 {
        150
    } else if user_poker_hand_level == 3 {
        250
    } else if user_poker_hand_level == 4 {
        350
    } else if user_poker_hand_level == 5 {
        500
    } else if user_poker_hand_level == 6 {
        750
    } else if user_poker_hand_level == 7 {
        1150
    } else if user_poker_hand_level == 8 {
        1700
    } else if user_poker_hand_level == 9 {
        2550
    } else if user_poker_hand_level == 10 {
        3850
    } else {
        // TODO: if we see this price, its because we have something wrong
        9999999
    }
}

fn get_modifiers_probability(ref store: Store) -> Array<u32> {
    let modifiers = modifiers_ids_all();
    let mut modifiers_probability = array![];
    let mut idx = 0;
    loop {
        if idx == modifiers.len() {
            break;
        }
        let modifier_card = store.get_effect_card(*modifiers.at(idx));
        let mut idy = 0;
        loop {
            if idy == modifier_card.probability {
                break;
            }
            modifiers_probability.append(modifier_card.id);
            idy += 1;
        };
        idx += 1;
    };
    modifiers_probability
}

fn get_specials_probability(ref store: Store) -> Array<u32> {
    let specials = specials_ids_all();
    let mut specials_probability = array![];
    let mut idx = 0;
    loop {
        if idx == specials.len() {
            break;
        }
        let special_card = store.get_effect_card(*specials.at(idx));
        let mut idy = 0;
        loop {
            if idy == special_card.probability {
                break;
            }
            specials_probability.append(special_card.id);
            idy += 1;
        };
        idx += 1;
    };
    specials_probability
}

fn get_blister_pack_probability(ref store: Store, game: @Game) -> Array<u32> {
    // check current_jokers
    let blister_packs = if *game.current_jokers < *game.max_jokers {
        blister_packs_all()
    } else {
        blister_packs_all_without_jokers()
    };

    let mut blister_pack_probability = array![];
    let mut idx = 0;
    loop {
        if idx == blister_packs.len() {
            break;
        }
        let blister_pack = store.get_blister_pack(*blister_packs.at(idx));
        let mut idy = 0;
        loop {
            if idy == blister_pack.probability {
                break;
            }
            blister_pack_probability.append(blister_pack.id);
            idy += 1;
        };
        idx += 1;
    };
    blister_pack_probability
}

fn open_blister_pack(world: IWorldDispatcher, ref store: Store, game: Game, blister_pack_id: u32) -> Span<u32> {
    let mut ret = array![];
    let mut blister_pack = store.get_blister_pack(blister_pack_id);
    let mut count_cards = 0;

    let mut guaranteed_cards = array![].span();
    let mut cards = array![];
    let mut probs = array![];
    let mut idx = 0;
    loop {
        if idx == blister_pack.cards.len() {
            break;
        }
        if idx == 0 {
            guaranteed_cards = *blister_pack.cards.at(idx);
        } else {
            cards.append(*blister_pack.cards.at(idx));
            probs.append(*blister_pack.probs.at(idx));
        }
        idx += 1;
    };

    loop {
        match guaranteed_cards.pop_front() {
            Option::Some(card_id) => {
                ret.append(*card_id);
                count_cards += 1;
            },
            Option::None => { break; }
        }
    };

    let mut randomizer = RandomImpl::new(world);
    if count_cards < blister_pack.size {
        loop {
            if count_cards == blister_pack.size {
                break;
            }
            let number_random = randomizer.between::<u32>(0, 100);
            let index_content = get_index_content(probs.span(), number_random);
            let cards_temp = *cards.at(index_content);
            let card_id_random = *cards_temp.at(randomizer.between::<u32>(0, cards_temp.len() - 1));
            if is_special_card(card_id_random) {
                let current_special_cards = get_current_special_cards(ref store, @game);
                if item_in_array(@ret, card_id_random) || item_in_array(@current_special_cards, card_id_random) {
                    continue;
                }
            }
            ret.append(card_id_random);
            count_cards += 1;
        }
    }
    ret.span()
}

fn get_index_content(probs: Span<u32>, number_random: u32) -> u32 {
    let mut probs = probs;
    let mut acum = 0;
    let mut idx = 0;
    loop {
        match probs.pop_front() {
            Option::Some(prob) => {
                acum += *prob;

                if number_random < acum {
                    break idx;
                }
                idx += 1;
            },
            Option::None => { break 0; }
        }
    }
}
