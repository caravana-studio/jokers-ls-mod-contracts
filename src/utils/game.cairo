use core::nullable::NullableTrait;
use dojo::world::Resource::Contract;
use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::card::{JOKER_CARD, NEON_JOKER_CARD, INVALID_CARD};
use jokers_of_neon::constants::packs::SPECIAL_CARDS_PACK_ID;
use jokers_of_neon::constants::specials::{
    SPECIAL_MULTI_FOR_HEART_ID, SPECIAL_MULTI_FOR_CLUB_ID, SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_MULTI_FOR_SPADE_ID,
    SPECIAL_INCREASE_LEVEL_PAIR_ID, SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID, SPECIAL_INCREASE_LEVEL_STRAIGHT_ID,
    SPECIAL_INCREASE_LEVEL_FLUSH_ID, SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID, SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
    SPECIAL_JOKER_BOOSTER_ID, SPECIAL_MODIFIER_BOOSTER_ID, SPECIAL_POINTS_FOR_FIGURES_ID, SPECIAL_MULTI_ACES_ID,
    SPECIAL_ALL_CARDS_TO_HEARTS_ID, SPECIAL_HAND_THIEF_ID, SPECIAL_EXTRA_HELP_ID, SPECIAL_LUCKY_SEVEN_ID,
    SPECIAL_NEON_BONUS_ID, SPECIAL_DEADLINE_ID, SPECIAL_INITIAL_ADVANTAGE_ID, SPECIAL_LUCKY_HAND_ID
};
use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl,};
use jokers_of_neon::models::data::effect_card::Effect;
use jokers_of_neon::models::data::events::{
    PokerHandEvent, CreateGameEvent, CardScoreEvent, PlayWinGameEvent, PlayGameOverEvent, DetailEarnedEvent,
    SpecialModifierPointsEvent, SpecialModifierMultiEvent, SpecialModifierSuitEvent, SpecialPokerHandEvent,
    SpecialGlobalEvent, ModifierCardSuitEvent, RoundScoreEvent, NeonPokerHandEvent, PlayPokerHandEvent, SpecialCashEvent
};
use jokers_of_neon::models::data::game_deck::{GameDeckStore, GameDeckImpl};
use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};
use jokers_of_neon::models::status::game::game::{Game, GameState};
use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
use jokers_of_neon::models::status::shop::shop::{BlisterPackResult};

use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::systems::rage_system::{IRageSystemDispatcher, IRageSystemDispatcherTrait};
use jokers_of_neon::utils::calculate_hand::calculate_hand;
use jokers_of_neon::utils::constants::{
    RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_SILENT_JOKERS, RAGE_CARD_SILENT_HEARTS, RAGE_CARD_SILENT_CLUBS,
    RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_SILENT_SPADES, RAGE_CARD_ZERO_WASTE, is_neon_card, is_modifier_card
};
use jokers_of_neon::utils::packs::{open_blister_pack, select_cards_from_blister};
use jokers_of_neon::utils::rage::is_rage_card_active;
use starknet::{ContractAddress, get_caller_address, ClassHash};

fn play(world: IWorldDispatcher, ref game: Game, cards_index: @Array<u32>, modifiers_index: @Array<u32>) -> u32 {
    let mut store: Store = StoreTrait::new(world);

    let rage_round = RageRoundStore::get(world, game.id);

    let mut current_special_cards_index = get_current_special_cards(ref store, @game);

    let (mut cards, effect_id_cards_1, effect_id_cards_2) = get_cards(
        world, ref store, game.id, cards_index, modifiers_index, ref current_special_cards_index
    );

    let (result_hand, mut hit_cards) = calculate_hand(@cards, ref current_special_cards_index);

    let mut points_acum = 0;
    let mut multi_acum = 0;

    apply_joker(
        world,
        game.id,
        cards_index,
        ref current_special_cards_index,
        @cards,
        ref hit_cards,
        ref points_acum,
        ref multi_acum,
        @rage_round
    );

    let silent_suits = get_silent_suits(@rage_round);

    calculate_score(world, @cards, ref hit_cards, cards_index, ref points_acum, ref multi_acum, @silent_suits);

    apply_modifiers(
        world,
        ref store,
        ref hit_cards,
        cards_index,
        ref current_special_cards_index,
        modifiers_index,
        effect_id_cards_1,
        effect_id_cards_2,
        ref points_acum,
        ref multi_acum
    );

    apply_special_global(world, @game, ref current_special_cards_index, ref points_acum, ref multi_acum);

    apply_special_every_card(
        world,
        game.id,
        cards_index,
        ref current_special_cards_index,
        @cards,
        ref hit_cards,
        ref points_acum,
        ref multi_acum,
        @silent_suits
    );

    apply_special_level_hand(
        world,
        ref store,
        game.id,
        ref current_special_cards_index,
        result_hand,
        ref hit_cards,
        cards_index,
        @cards,
        ref points_acum,
        ref multi_acum
    );
    points_acum * multi_acum
}

fn player_has_empty_hand(ref store: Store, game: @Game) -> bool {
    let mut i = 0;
    loop {
        if game.len_hand == @i {
            break true;
        }
        let deck_card = store.get_current_hand_card(*game.id, i);
        if deck_card.card_id != INVALID_CARD {
            break false;
        }
        i += 1;
    }
}

fn has_repeated_elements(array: @Array<u32>) -> bool {
    let mut array_span = array.span();
    let mut elements = array![];

    let repeated_elements = loop {
        match array_span.pop_front() {
            Option::Some(new_elem) => {
                let mut elements_span = elements.span();
                let result = loop {
                    match elements_span.pop_front() {
                        Option::Some(seen_elem) => { if *seen_elem == *new_elem {
                            break true;
                        } },
                        Option::None => { break false; }
                    };
                };
                if result {
                    break result;
                }
                elements.append(*new_elem);
            },
            Option::None => { break false; }
        };
    };
    repeated_elements
}

fn get_cards(
    world: IWorldDispatcher,
    ref store: Store,
    game_id: u32,
    cards_index: @Array<u32>,
    modifiers_index: @Array<u32>,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>
) -> (Array<Card>, Array<u32>, Array<u32>) {
    assert(!has_repeated_elements(cards_index), 'Game: array repeated elements');
    let mut cards = array![];
    let mut effect_id_cards_1 = array![];
    let mut effect_id_cards_2 = array![];
    let mut idx = 0;
    loop {
        if idx == cards_index.len() {
            break;
        }

        let current_hand_card = store.get_current_hand_card(game_id, *cards_index.at(idx));
        assert(current_hand_card.card_id != INVALID_CARD, 'Game: use an invalid card');

        let mut card = store.get_card(current_hand_card.card_id);

        let modifier_1_index = *modifiers_index.at(idx);
        if modifier_1_index != 100 { // TODO: Invalid
            let current_hand_modifier_card = store.get_current_hand_card(game_id, modifier_1_index);
            let effect_card = store.get_effect_card(current_hand_modifier_card.card_id);
            effect_id_cards_1.append(effect_card.effect_id);
            let effect = store.get_effect(effect_card.effect_id);
            if effect.suit != Suit::None && card.suit != Suit::Joker {
                card.suit = effect.suit;
                emit!(
                    world,
                    ModifierCardSuitEvent {
                        player: get_caller_address(),
                        game_id,
                        modifier_card_idx: *modifiers_index.at(idx),
                        current_hand_card_idx: *cards_index.at(idx),
                        suit: card.suit
                    }
                );
            }
        } else {
            effect_id_cards_1.append(100);
        }

        if !(current_special_cards_index.get(SPECIAL_ALL_CARDS_TO_HEARTS_ID.into()).is_null()) {
            if card.suit != Suit::Joker {
                card.suit = Suit::Hearts;
                emit!(
                    world,
                    SpecialModifierSuitEvent {
                        player: get_caller_address(),
                        game_id,
                        current_special_card_idx: current_special_cards_index
                            .get(SPECIAL_ALL_CARDS_TO_HEARTS_ID.into())
                            .deref(),
                        current_hand_card_idx: *cards_index.at(idx),
                        suit: card.suit
                    }
                );
            }
        }

        cards.append(card);
        idx += 1;
    };
    (cards, effect_id_cards_1, effect_id_cards_2)
}

fn calculate_score(
    world: IWorldDispatcher,
    cards: @Array<Card>,
    ref hit_cards: Felt252Dict<bool>,
    cards_index: @Array<u32>,
    ref points_acum: u32,
    ref multi_acum: u32,
    silent_suits: @Array<Suit>
) {
    let mut idx = 0;
    loop {
        if cards.len() == idx {
            break;
        }
        let hit = hit_cards.get(idx.into());
        if hit {
            let card = *cards.at(idx);
            let suit_is_silence = contains_suit(silent_suits, card.suit);
            if suit_is_silence { // Emitir evento de Rage Card Silent Suit
            } else {
                points_acum += card.points.into();
                multi_acum += card.multi_add.into();
                if card.points > 0 {
                    emit!(
                        world,
                        (CardScoreEvent {
                            player: get_caller_address(),
                            index: *cards_index.at(idx),
                            multi: 0,
                            points: card.points.into()
                        })
                    );
                }
                if card.multi_add > 0 {
                    emit!(
                        world,
                        (CardScoreEvent {
                            player: get_caller_address(), index: *cards_index.at(idx), multi: card.multi_add, points: 0
                        })
                    );
                }
            };
        }
        idx += 1;
    }
}

fn apply_joker(
    world: IWorldDispatcher,
    game_id: u32,
    cards_index: @Array<u32>,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
    cards: @Array<Card>,
    ref hit_cards: Felt252Dict<bool>,
    ref points_acum: u32,
    ref multi_acum: u32,
    rage_round: @RageRound
) {
    let mut idx = 0;
    loop {
        if cards.len() == idx {
            break;
        }
        let card = *cards.at(idx);
        if card.suit == Suit::Joker {
            if is_rage_card_active(rage_round, RAGE_CARD_SILENT_JOKERS) { // Emitir evento
                hit_cards.insert(idx.into(), false);
            } else {
                if !(current_special_cards_index.get(SPECIAL_JOKER_BOOSTER_ID.into()).is_null()) {
                    points_acum += card.points;
                    multi_acum += card.multi_add;
                    emit!(
                        world,
                        SpecialModifierPointsEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_JOKER_BOOSTER_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            points: card.points
                        }
                    );
                    emit!(
                        world,
                        SpecialModifierMultiEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_JOKER_BOOSTER_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            multi: card.multi_add
                        }
                    );
                }
                hit_cards.insert(idx.into(), true);
            }
        }
        idx += 1;
    };
}

fn apply_modifiers(
    world: IWorldDispatcher,
    ref store: Store,
    ref hit_cards: Felt252Dict<bool>,
    cards_index: @Array<u32>,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
    modifiers_index: @Array<u32>,
    effect_id_cards_1: Array<u32>,
    effect_id_cards_2: Array<u32>,
    ref points_acum: u32,
    ref multi_acum: u32
) {
    let mut idx = 0;
    loop {
        if cards_index.len() == idx {
            break;
        }
        let hit = hit_cards.get(idx.into());
        if hit {
            let effect_card_id_1 = *effect_id_cards_1.at(idx);
            if effect_card_id_1 != 100 { // TODO: Invalid
                let effect = store.get_effect(effect_card_id_1);
                if effect.suit == Suit::None {
                    let (points, multi_add) = if !(current_special_cards_index
                        .get(SPECIAL_MODIFIER_BOOSTER_ID.into())
                        .is_null()) {
                        (effect.points * 2, effect.multi_add * 2)
                    } else {
                        (effect.points, effect.multi_add)
                    };
                    points_acum += points;
                    multi_acum += multi_add;
                    emit!(
                        world,
                        (CardScoreEvent {
                            player: get_caller_address(), index: *modifiers_index.at(idx), multi: multi_add, points
                        })
                    );
                }
            }
        }
        idx += 1;
    };
}

fn apply_special_global(
    world: IWorldDispatcher,
    game: @Game,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
    ref points_acum: u32,
    ref multi_acum: u32
) {
    // let mut store = StoreTrait::new(world);
    if !(current_special_cards_index.get(SPECIAL_INITIAL_ADVANTAGE_ID.into()).is_null()) { // first hand
    // TODO: Pedir los puntos de energia
    // if *game.max_hands == *round.hands {
    //     let effect_card = store.get_effect_card(SPECIAL_INITIAL_ADVANTAGE_ID);
    //     let effect = store.get_effect(effect_card.effect_id);
    //     points_acum += effect.points;
    //     multi_acum += effect.multi_add;
    //     emit!(
    //         world,
    //         SpecialGlobalEvent {
    //             player: get_caller_address(),
    //             game_id: *game.id,
    //             current_special_card_idx: current_special_cards_index
    //                 .get(SPECIAL_INITIAL_ADVANTAGE_ID.into())
    //                 .deref(),
    //             multi: effect.multi_add,
    //             points: effect.points
    //         }
    //     );
    // }
    }
}

fn apply_special_every_card(
    world: IWorldDispatcher,
    game_id: u32,
    cards_index: @Array<u32>,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
    cards: @Array<Card>,
    ref hit_cards: Felt252Dict<bool>,
    ref points_acum: u32,
    ref multi_acum: u32,
    silent_suits: @Array<Suit>
) {
    let mut idx = 0;
    let mut store = StoreTrait::new(world);
    loop {
        if idx == cards.len() {
            break;
        }

        let hit = hit_cards.get(idx.into());
        let mut card = *cards.at(idx);
        if hit {
            let suit_is_silence = contains_suit(silent_suits, card.suit);
            if !(current_special_cards_index.get(SPECIAL_MULTI_FOR_HEART_ID.into()).is_null()) {
                if card.suit == Suit::Hearts && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_MULTI_FOR_HEART_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    multi_acum += effect.multi_add;
                    emit!(
                        world,
                        SpecialModifierMultiEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_MULTI_FOR_HEART_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            multi: effect.multi_add
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_MULTI_FOR_DIAMOND_ID.into()).is_null()) {
                if card.suit == Suit::Diamonds && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_MULTI_FOR_DIAMOND_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    multi_acum += effect.multi_add;
                    emit!(
                        world,
                        SpecialModifierMultiEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_MULTI_FOR_DIAMOND_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            multi: effect.multi_add
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_MULTI_FOR_CLUB_ID.into()).is_null()) {
                if card.suit == Suit::Clubs && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_MULTI_FOR_CLUB_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    multi_acum += effect.multi_add;
                    emit!(
                        world,
                        SpecialModifierMultiEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_MULTI_FOR_CLUB_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            multi: effect.multi_add
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_MULTI_FOR_SPADE_ID.into()).is_null()) {
                if card.suit == Suit::Spades && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_MULTI_FOR_SPADE_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    multi_acum += effect.multi_add;
                    emit!(
                        world,
                        SpecialModifierMultiEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_MULTI_FOR_SPADE_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            multi: effect.multi_add
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_POINTS_FOR_FIGURES_ID.into()).is_null()) {
                if (card.value == Value::Jack || card.value == Value::Queen || card.value == Value::King)
                    && !suit_is_silence {
                    points_acum += 50;
                    emit!(
                        world,
                        SpecialModifierPointsEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_POINTS_FOR_FIGURES_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            points: 50
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_MULTI_ACES_ID.into()).is_null()) {
                if card.value == Value::Ace && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_MULTI_ACES_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    multi_acum += effect.multi_add;
                    emit!(
                        world,
                        SpecialModifierMultiEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_MULTI_ACES_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            multi: effect.multi_add
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_LUCKY_SEVEN_ID.into()).is_null()) {
                if card.value == Value::Seven && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_LUCKY_SEVEN_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    points_acum += effect.points;
                    emit!(
                        world,
                        SpecialModifierPointsEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_LUCKY_SEVEN_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            points: effect.points
                        }
                    );
                }
            }

            if !(current_special_cards_index.get(SPECIAL_NEON_BONUS_ID.into()).is_null()) {
                if is_neon_card(card.id) && !suit_is_silence {
                    let effect_card = store.get_effect_card(SPECIAL_NEON_BONUS_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    points_acum += effect.points;
                    emit!(
                        world,
                        SpecialModifierPointsEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_NEON_BONUS_ID.into())
                                .deref(),
                            current_hand_card_idx: *cards_index.at(idx),
                            points: effect.points
                        }
                    );
                }
            }
        };
        idx += 1;
    }
}

fn apply_special_level_hand(
    world: IWorldDispatcher,
    ref store: Store,
    game_id: u32,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
    poker_hand: PokerHand,
    ref hit_cards: Felt252Dict<bool>,
    cards_index: @Array<u32>,
    cards: @Array<Card>,
    ref points_acum: u32,
    ref multi_acum: u32
) {
    let mut level_acum = 1;
    if !(current_special_cards_index.get(SPECIAL_INCREASE_LEVEL_PAIR_ID.into()).is_null()) {
        if poker_hand == PokerHand::OnePair {
            level_acum += 4;
            let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
            emit!(
                world,
                SpecialPokerHandEvent {
                    player: get_caller_address(),
                    game_id,
                    current_special_card_idx: current_special_cards_index
                        .get(SPECIAL_INCREASE_LEVEL_PAIR_ID.into())
                        .deref(),
                    multi: level_poker_hand.multi,
                    points: level_poker_hand.points
                }
            );
        }
    }
    if !(current_special_cards_index.get(SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID.into()).is_null()) {
        if poker_hand == PokerHand::TwoPair {
            level_acum += 4;
            let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
            emit!(
                world,
                SpecialPokerHandEvent {
                    player: get_caller_address(),
                    game_id,
                    current_special_card_idx: current_special_cards_index
                        .get(SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID.into())
                        .deref(),
                    multi: level_poker_hand.multi,
                    points: level_poker_hand.points
                }
            );
        }
    }
    if !(current_special_cards_index.get(SPECIAL_INCREASE_LEVEL_STRAIGHT_ID.into()).is_null()) {
        if poker_hand == PokerHand::Straight {
            level_acum += 4;
            let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
            emit!(
                world,
                SpecialPokerHandEvent {
                    player: get_caller_address(),
                    game_id,
                    current_special_card_idx: current_special_cards_index
                        .get(SPECIAL_INCREASE_LEVEL_STRAIGHT_ID.into())
                        .deref(),
                    multi: level_poker_hand.multi,
                    points: level_poker_hand.points
                }
            );
        }
    }
    if !(current_special_cards_index.get(SPECIAL_INCREASE_LEVEL_FLUSH_ID.into()).is_null()) {
        if poker_hand == PokerHand::Flush {
            level_acum += 4;
            let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
            emit!(
                world,
                SpecialPokerHandEvent {
                    player: get_caller_address(),
                    game_id,
                    current_special_card_idx: current_special_cards_index
                        .get(SPECIAL_INCREASE_LEVEL_FLUSH_ID.into())
                        .deref(),
                    multi: level_poker_hand.multi,
                    points: level_poker_hand.points
                }
            );
        }
    }

    let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
    points_acum += level_poker_hand.points;
    multi_acum += level_poker_hand.multi;
}

fn get_current_special_cards(ref store: Store, game: @Game) -> Felt252Dict<Nullable<u32>> {
    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let mut idx = 0;
    loop {
        if idx == *game.len_current_special_cards {
            break;
        }
        let current_special_card = store.get_current_special_cards(*game.id, idx);
        current_special_cards_index.insert(current_special_card.effect_card_id.into(), NullableTrait::new(idx));
        idx += 1;
    };
    current_special_cards_index
}

fn get_silent_suits(rage_round: @RageRound) -> Array<Suit> {
    let mut silent_suits = array![];
    if *rage_round.is_active {
        let mut active_rages = (*rage_round.active_rage_ids).clone();
        loop {
            match active_rages.pop_front() {
                Option::Some(rage_id) => {
                    if *rage_id == RAGE_CARD_SILENT_HEARTS {
                        silent_suits.append(Suit::Hearts);
                    } else if *rage_id == RAGE_CARD_SILENT_CLUBS {
                        silent_suits.append(Suit::Clubs);
                    } else if *rage_id == RAGE_CARD_SILENT_DIAMONDS {
                        silent_suits.append(Suit::Diamonds);
                    } else if *rage_id == RAGE_CARD_SILENT_SPADES {
                        silent_suits.append(Suit::Spades);
                    }
                },
                Option::None => { break Suit::None; }
            }
        };
    }
    silent_suits
}

fn contains_suit(suits: @Array<Suit>, suit: Suit) -> bool {
    let mut idx = 0;
    loop {
        if suits.len() == idx {
            break false;
        }

        if *suits[idx] == suit {
            break true;
        }

        idx += 1;
    }
}
