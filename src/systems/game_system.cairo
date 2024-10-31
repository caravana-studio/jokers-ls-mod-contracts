use dojo::world::{IWorld, IWorldDispatcher};

use jokers_of_neon::models::data::poker_hand::PokerHand;

#[dojo::interface]
trait IGameSystem {
    fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32;
    fn select_deck(ref world: IWorldDispatcher, game_id: u32, deck_id: u8);
    fn select_special_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
    fn select_modifier_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
    fn play(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>);
    fn discard(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>);
    fn check_hand(
        ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>
    ) -> PokerHand;
    fn discard_effect_card(ref world: IWorldDispatcher, game_id: u32, card_index: u32);
    fn discard_special_card(ref world: IWorldDispatcher, game_id: u32, special_card_index: u32);
}

mod errors {
    const GAME_NOT_FOUND: felt252 = 'Game: game not found';
    const CALLER_NOT_OWNER: felt252 = 'Game: caller not owner';
    const INVALID_CARD_INDEX_LEN: felt252 = 'Game: invalid card index len';
    const INVALID_CARD_ELEM: felt252 = 'Game: invalid card element';
    const ARRAY_REPEATED_ELEMENTS: felt252 = 'Game: array repeated elements';
    const ONLY_EFFECT_CARD: felt252 = 'Game: only effect cards';
    const GAME_NOT_IN_GAME: felt252 = 'Game: is not IN_GAME';
    const GAME_NOT_SELECT_SPECIAL_CARDS: felt252 = 'Game:is not SELECT_SPECIAL_CARD';
    const GAME_NOT_SELECT_DECK: felt252 = 'Game:is not SELECT_DECK';
    const GAME_NOT_SELECT_MODIFIER_CARDS: felt252 = 'Game:is not SELCT_MODIFIER_CARD';
    const USE_INVALID_CARD: felt252 = 'Game: use an invalid card';
    const INVALID_DECK_ID: felt252 = 'Game: use an invalid deck';
}

#[dojo::contract]
mod game_system {
    use core::nullable::NullableTrait;
    use dojo::world::Resource::Contract;
    use jokers_of_neon::constants::card::{JOKER_CARD, NEON_JOKER_CARD, INVALID_CARD};
    use jokers_of_neon::constants::packs::{SPECIAL_CARDS_PACK_ID, MODIFIER_CARDS_PACK_ID};
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
        SpecialGlobalEvent, ModifierCardSuitEvent, RoundScoreEvent, NeonPokerHandEvent, PlayPokerHandEvent,
        SpecialCashEvent
    };
    use jokers_of_neon::models::data::game_deck::{GameDeckStore, GameDeckImpl};
    use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};
    use jokers_of_neon::models::status::game::game::{Game, GameState, GameSubState};
    use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
    use jokers_of_neon::models::status::round::round::Round;
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
    use jokers_of_neon::utils::round::create_round;
    use starknet::{ContractAddress, get_caller_address, ClassHash};
    use super::IGameSystem;
    use super::errors;

    #[abi(embed_v0)]
    impl ActionsImpl of IGameSystem<ContractState> {
        fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32 {
            let mut store: Store = StoreTrait::new(world);

            let game_id = world.uuid() + 1;
            let player_id = get_caller_address();

            let game = Game {
                id: game_id,
                owner: player_id,
                player_name,
                max_hands: 5,
                max_discard: 5,
                max_jokers: 5,
                round: 1,
                player_score: 0,
                level: 1,
                len_hand: 8,
                len_max_current_special_cards: 5,
                len_current_special_cards: 0,
                current_jokers: 0,
                state: GameState::SELECT_DECK,
                substate: GameSubState::NONE,
                cash: 0
            };
            store.set_game(game);
            emit!(world, (game));

            let create_game_event = CreateGameEvent { player: get_caller_address(), game_id };
            emit!(world, (create_game_event));
            game_id
        }

        fn select_deck(ref world: IWorldDispatcher, game_id: u32, deck_id: u8) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.state == GameState::SELECT_DECK, errors::GAME_NOT_SELECT_DECK);

            assert(deck_id < 3, errors::INVALID_DECK_ID);

            GameDeckImpl::init(ref store, game_id, deck_id);
            game.state = GameState::SELECT_SPECIAL_CARDS;
            store.set_game(game);

            let cards = open_blister_pack(world, ref store, game, SPECIAL_CARDS_PACK_ID);
            store.set_blister_pack_result(BlisterPackResult { game_id, cards_picked: false, cards });
        }

        fn select_special_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.state == GameState::SELECT_SPECIAL_CARDS, errors::GAME_NOT_SELECT_SPECIAL_CARDS);

            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            assert(cards_index.len() <= 2, errors::INVALID_CARD_INDEX_LEN);

            select_cards_from_blister(world, ref game, blister_pack_result.cards, cards_index);

            blister_pack_result.cards_picked = true;
            store.set_blister_pack_result(blister_pack_result);

            let cards = open_blister_pack(world, ref store, game, MODIFIER_CARDS_PACK_ID);
            store.set_blister_pack_result(BlisterPackResult { game_id, cards_picked: false, cards });

            game.state = GameState::SELECT_MODIFIER_CARDS;
            store.set_game(game);
        }

        fn select_modifier_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.state == GameState::SELECT_MODIFIER_CARDS, errors::GAME_NOT_SELECT_MODIFIER_CARDS);

            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            assert(cards_index.len() <= 5, errors::INVALID_CARD_INDEX_LEN);

            select_cards_from_blister(world, ref game, blister_pack_result.cards, cards_index);

            blister_pack_result.cards_picked = true;
            store.set_blister_pack_result(blister_pack_result);

            // game.state = GameState::; / TODO:
            store.set_game(game);
        }

        fn play(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);

            // Check that the length of card_index is between 1 and game.len_hand
            assert(cards_index.len() > 0 && cards_index.len() <= game.len_hand, errors::INVALID_CARD_INDEX_LEN);
            let rage_round = RageRoundStore::get(world, game_id);

            let mut current_special_cards_index = self.get_current_special_cards(ref store, @game);

            let (mut cards, effect_id_cards_1, effect_id_cards_2) = self
                .get_cards(world, ref store, game.id, @cards_index, @modifiers_index, ref current_special_cards_index);

            let (result_hand, mut hit_cards) = calculate_hand(@cards, ref current_special_cards_index);

            let mut points_acum = 0;
            let mut multi_acum = 0;
            let mut cash_acum = 0;

            self
                .apply_joker(
                    world,
                    game_id,
                    @cards_index,
                    ref current_special_cards_index,
                    @cards,
                    ref hit_cards,
                    ref points_acum,
                    ref multi_acum,
                    @rage_round
                );

            let silent_suits = self.get_silent_suits(@rage_round);

            self
                .calculate_score(
                    world, @cards, ref hit_cards, @cards_index, ref points_acum, ref multi_acum, @silent_suits
                );

            self
                .apply_modifiers(
                    world,
                    ref store,
                    ref hit_cards,
                    @cards_index,
                    ref current_special_cards_index,
                    @modifiers_index,
                    effect_id_cards_1,
                    effect_id_cards_2,
                    ref points_acum,
                    ref multi_acum
                );

            let mut round = store.get_round(game.id);
            self
                .apply_special_global(
                    world, @game, @round, ref current_special_cards_index, ref points_acum, ref multi_acum
                );

            self
                .apply_special_every_card(
                    world,
                    game_id,
                    @cards_index,
                    ref current_special_cards_index,
                    @cards,
                    ref hit_cards,
                    ref points_acum,
                    ref multi_acum,
                    @silent_suits
                );

            self
                .apply_special_level_hand(
                    world,
                    ref store,
                    game_id,
                    @round,
                    ref current_special_cards_index,
                    result_hand,
                    ref hit_cards,
                    @cards_index,
                    @cards,
                    ref points_acum,
                    ref multi_acum
                );

            self
                .apply_cash_special(
                    world, ref current_special_cards_index, @cards, @cards_index, ref hit_cards, ref cash_acum
                );

            let mut round = store.get_round(game.id);
            round.hands -= 1;
            round.player_score += points_acum * multi_acum;
            game.cash += cash_acum;

            store.set_round(round);
            let round_score_event = RoundScoreEvent {
                player: get_caller_address(), game_id, player_score: round.player_score
            };
            emit!(world, (round_score_event));
            if round.player_score >= round.level_score {
                let play_win_game_event = PlayWinGameEvent {
                    player: get_caller_address(), game_id, level: game.level, player_score: round.player_score
                };
                emit!(world, (play_win_game_event));
                game.cash += self.calculate_earning_cash(world, ref store, round, game);
                game.state = GameState::AT_SHOP;
                game.player_score += round.player_score;
                self.sync_current_special_cards(ref store, ref game);

                if is_rage_card_active(@rage_round, RAGE_CARD_DIMINISHED_HOLD) {
                    // return the cards to the deck
                    game.len_hand += 2;
                }
                let (_, rage_system_address) = match world.resource(selector_from_tag!("jokers_of_neon-rage_system")) {
                    Contract((class_hash, contract_address)) => Option::Some((class_hash, contract_address)),
                    _ => Option::None
                }.unwrap();
                IRageSystemDispatcher { contract_address: rage_system_address.try_into().unwrap() }.calculate(game_id);
            } else {
                // The player ran out of hands
                if round.hands == 0 {
                    let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id };
                    emit!(world, (play_game_over_event));
                    game.state = GameState::FINISHED;
                    game.player_score += round.player_score;
                } else {
                    let mut cards = array![];
                    let mut idx = 0;
                    loop {
                        if idx == cards_index.len() {
                            break;
                        }
                        cards.append(*cards_index.at(idx));
                        idx += 1;
                    };

                    idx = 0;
                    loop {
                        if idx == modifiers_index.len() {
                            break;
                        }
                        let card_index = *modifiers_index.at(idx);
                        if card_index != 100 {
                            cards.append(card_index);
                        }
                        idx += 1;
                    };

                    CurrentHandCardTrait::refresh(world, ref round, cards);

                    // The player has no more cards in his hand and in the deck
                    let game_deck = GameDeckStore::get(world, game_id);
                    if game_deck.round_len.is_zero() && self.player_has_empty_hand(ref store, @game) {
                        let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id };
                        emit!(world, (play_game_over_event));
                        game.state = GameState::FINISHED;
                        game.player_score += round.player_score;
                    }
                }
            }
            store.set_game(game);

            // Track PlayPokerHand
            emit!(
                world,
                (PlayPokerHandEvent {
                    game_id, level: game.level, count_hand: game.max_hands - round.hands, poker_hand: result_hand
                })
            );
        }

        fn discard(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);

            let mut cards = array![];
            let mut idx = 0;
            loop {
                if idx == cards_index.len() {
                    break;
                }
                let current_hand_card = store.get_current_hand_card(game_id, *cards_index.at(idx));
                assert(current_hand_card.card_id != INVALID_CARD, errors::USE_INVALID_CARD);

                cards.append(*cards_index.at(idx));
                idx += 1;
            };

            idx = 0;
            loop {
                if idx == modifiers_index.len() {
                    break;
                }
                let card_index = *modifiers_index.at(idx);
                if card_index != 100 {
                    cards.append(card_index);
                }
                idx += 1;
            };

            let mut round = store.get_round(game.id);
            CurrentHandCardTrait::refresh(world, ref round, cards);

            // The player has no more cards in his hand and in the deck
            round.discard -= 1;
            store.set_round(round);

            let game_deck = GameDeckStore::get(world, game_id);
            if game_deck.round_len.is_zero() && self.player_has_empty_hand(ref store, @game) {
                let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
                emit!(world, (play_game_over_event));
                game.state = GameState::FINISHED;
                store.set_game(game);
            }
        }

        fn check_hand(
            ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>
        ) -> PokerHand {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            let mut current_special_cards_index = self.get_current_special_cards(ref store, @game);

            let (cards, _, _) = self
                .get_cards(world, ref store, game_id, @cards_index, @modifiers_index, ref current_special_cards_index,);
            let (poker_hand, _) = calculate_hand(@cards, ref current_special_cards_index);

            let poker_hand_details = store.get_level_poker_hand(poker_hand, 1);
            let poker_hand_event = PokerHandEvent {
                player: get_caller_address(),
                poker_hand: poker_hand.into(),
                multi: poker_hand_details.multi,
                points: poker_hand_details.points
            };
            emit!(world, (poker_hand_event));
            poker_hand
        }

        fn discard_effect_card(ref world: IWorldDispatcher, game_id: u32, card_index: u32) {
            let mut store: Store = StoreTrait::new(world);
            let game = store.get_game(game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(card_index >= 0 && card_index < game.len_hand, errors::INVALID_CARD_ELEM);
            let current_hand_card = store.get_current_hand_card(game_id, card_index);
            assert(is_modifier_card(current_hand_card.card_id), errors::ONLY_EFFECT_CARD);

            let mut round = store.get_round(game.id);
            CurrentHandCardTrait::refresh(world, ref round, array![card_index]);
        }

        fn discard_special_card(ref world: IWorldDispatcher, game_id: u32, special_card_index: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(special_card_index < game.len_current_special_cards, errors::INVALID_CARD_ELEM);

            let remove_special_card = store.get_current_special_cards(game.id, special_card_index);

            let mut idx = 0;
            let mut len_current_special_cards = game.len_current_special_cards;
            let mut new_current_special_cards = array![];
            loop {
                if idx == len_current_special_cards {
                    break;
                }
                let mut current_special_card = store.get_current_special_cards(game.id, idx);
                if special_card_index == idx {
                    game.len_current_special_cards -= 1;

                    if remove_special_card.effect_card_id == SPECIAL_HAND_THIEF_ID {
                        game.max_hands -= 1;
                        game.max_discard -= 1;
                    }
                    if remove_special_card.effect_card_id == SPECIAL_EXTRA_HELP_ID {
                        game.len_hand -= 2;
                    }
                } else {
                    new_current_special_cards.append(current_special_card);
                }
                idx += 1;
            };

            idx = 0;
            loop {
                if idx == game.len_current_special_cards {
                    break;
                }
                let mut new_current_special_card = *new_current_special_cards.at(idx);
                new_current_special_card.idx = idx;
                store.set_current_special_cards(new_current_special_card);
                idx += 1;
            };

            store.set_game(game);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn player_has_empty_hand(self: @ContractState, ref store: Store, game: @Game) -> bool {
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

        fn has_repeated_elements(self: @ContractState, array: @Array<u32>) -> bool {
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

        fn get_current_special_cards(
            self: @ContractState, ref store: Store, game: @Game
        ) -> Felt252Dict<Nullable<u32>> {
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

        fn get_cards(
            self: @ContractState,
            world: IWorldDispatcher,
            ref store: Store,
            game_id: u32,
            cards_index: @Array<u32>,
            modifiers_index: @Array<u32>,
            ref current_special_cards_index: Felt252Dict<Nullable<u32>>
        ) -> (Array<Card>, Array<u32>, Array<u32>) {
            assert(!self.has_repeated_elements(cards_index), errors::ARRAY_REPEATED_ELEMENTS);
            let mut cards = array![];
            let mut effect_id_cards_1 = array![];
            let mut effect_id_cards_2 = array![];
            let mut idx = 0;
            loop {
                if idx == cards_index.len() {
                    break;
                }

                let current_hand_card = store.get_current_hand_card(game_id, *cards_index.at(idx));
                assert(current_hand_card.card_id != INVALID_CARD, errors::USE_INVALID_CARD);

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

        /// Checks if all the cards in the poker hand are neon cards, in which case it will return the card indexes.
        /// Returns an empty array in case the hand is not a neon hand.
        ///
        /// # Arguments
        /// hit_cards: A dictionary with the indexes of the cards that are part of the hand.
        /// cards_index: The indexes of the cards that are part of the hand.
        /// cards: The array of cards that were played.
        ///
        /// # Returns
        /// An array of the cards indexes that are part of the neon hand.
        fn get_neon_hand_card_index(
            self: @ContractState, ref hit_cards: Felt252Dict<bool>, cards_index: @Array<u32>, cards: @Array<Card>,
        ) -> Array<u32> {
            let mut idx = 0;
            let mut is_neon_hand = true;
            let mut neon_idx = array![];
            loop {
                if cards.len() == idx {
                    break;
                }
                let hit = hit_cards.get(idx.into());
                if hit {
                    if !is_neon_card(*cards.at(idx).id) {
                        is_neon_hand = false;
                        break;
                    }
                    neon_idx.append(*cards_index.at(idx));
                }
                idx += 1;
            };

            let result = if is_neon_hand {
                neon_idx
            } else {
                array![]
            };
            result
        }

        fn calculate_score(
            self: @ContractState,
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
                    let suit_is_silence = self.contains_suit(silent_suits, card.suit);
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
                                    player: get_caller_address(),
                                    index: *cards_index.at(idx),
                                    multi: card.multi_add,
                                    points: 0
                                })
                            );
                        }
                    };
                }
                idx += 1;
            }
        }

        fn apply_joker(
            self: @ContractState,
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

        fn calculate_earning_cash(
            self: @ContractState, world: IWorldDispatcher, ref store: Store, round: Round, game: Game
        ) -> u32 {
            let config = store.get_config_earning_cash();

            let hands_left: u32 = (round.hands).into();
            let mut discard_left: u32 = (round.discard).into();
            let level_bonus = 500;

            let rage_round = RageRoundStore::get(world, game.id);
            let mut rage_card_defeated = 0;
            if rage_round.is_active {
                rage_card_defeated = rage_round.active_rage_ids.len();
                if is_rage_card_active(@rage_round, RAGE_CARD_ZERO_WASTE) {
                    discard_left = game.max_discard.into();
                }
            }

            let total = config.base * 100
                + level_bonus
                + hands_left * 150
                + discard_left * 150
                + rage_card_defeated * 500;

            let detail_earned = DetailEarnedEvent {
                player: game.owner,
                game_id: game.id,
                round_defeat: config.base * 100,
                level_bonus,
                hands_left,
                hands_left_cash: hands_left * 150,
                discard_left,
                discard_left_cash: discard_left * 150,
                rage_card_defeated,
                rage_card_defeated_cash: rage_card_defeated * 500,
                total
            };
            emit!(world, (detail_earned));
            total
        }

        fn apply_modifiers(
            self: @ContractState,
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
                                    player: get_caller_address(),
                                    index: *modifiers_index.at(idx),
                                    multi: multi_add,
                                    points
                                })
                            );
                        }
                    }
                }
                idx += 1;
            };
        }

        fn apply_special_global(
            self: @ContractState,
            world: IWorldDispatcher,
            game: @Game,
            round: @Round,
            ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
            ref points_acum: u32,
            ref multi_acum: u32
        ) {
            let mut store = StoreTrait::new(world);
            if !(current_special_cards_index.get(SPECIAL_INITIAL_ADVANTAGE_ID.into()).is_null()) {
                // first hand
                if *game.max_hands == *round.hands {
                    let effect_card = store.get_effect_card(SPECIAL_INITIAL_ADVANTAGE_ID);
                    let effect = store.get_effect(effect_card.effect_id);
                    points_acum += effect.points;
                    multi_acum += effect.multi_add;
                    emit!(
                        world,
                        SpecialGlobalEvent {
                            player: get_caller_address(),
                            game_id: *game.id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_INITIAL_ADVANTAGE_ID.into())
                                .deref(),
                            multi: effect.multi_add,
                            points: effect.points
                        }
                    );
                }
            }
        }

        fn apply_special_every_card(
            self: @ContractState,
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
                    let suit_is_silence = self.contains_suit(silent_suits, card.suit);
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
            self: @ContractState,
            world: IWorldDispatcher,
            ref store: Store,
            game_id: u32,
            round: @Round,
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
            if !(current_special_cards_index.get(SPECIAL_DEADLINE_ID.into()).is_null()) {
                if *round.hands == 1 {
                    level_acum += 10;
                    let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
                    emit!(
                        world,
                        SpecialPokerHandEvent {
                            player: get_caller_address(),
                            game_id,
                            current_special_card_idx: current_special_cards_index
                                .get(SPECIAL_DEADLINE_ID.into())
                                .deref(),
                            multi: level_poker_hand.multi,
                            points: level_poker_hand.points
                        }
                    );
                }
            }

            let neon_idx = self.get_neon_hand_card_index(ref hit_cards, cards_index, cards);
            if neon_idx.len() > 0 {
                level_acum += 4;
                let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);

                emit!(
                    world,
                    NeonPokerHandEvent {
                        player: get_caller_address(),
                        game_id,
                        neon_cards_idx: neon_idx,
                        multi: level_poker_hand.multi,
                        points: level_poker_hand.points
                    }
                );
            }

            let level_poker_hand = store.get_level_poker_hand(poker_hand, level_acum);
            points_acum += level_poker_hand.points;
            multi_acum += level_poker_hand.multi;
        }

        fn apply_cash_special(
            self: @ContractState,
            world: IWorldDispatcher,
            ref current_special_cards_index: Felt252Dict<Nullable<u32>>,
            cards: @Array<Card>,
            cards_index: @Array<u32>,
            ref hit_cards: Felt252Dict<bool>,
            ref cash_acum: u32,
        ) {
            if current_special_cards_index.get(SPECIAL_LUCKY_HAND_ID.into()).is_null() {
                return;
            }

            let mut idx = 0;
            loop {
                if idx == cards.len() {
                    break;
                }

                let hit = hit_cards.get(idx.into());
                let mut card = *cards.at(idx);
                if hit {
                    if card.suit == Suit::Diamonds {
                        cash_acum += 50;
                        emit!(
                            world,
                            SpecialCashEvent {
                                player: get_caller_address(),
                                cash: 50,
                                card_idx: *cards_index.at(idx),
                                special_idx: current_special_cards_index.get(SPECIAL_LUCKY_HAND_ID.into()).deref()
                            }
                        );
                    }
                }
                idx += 1;
            }
        }

        fn sync_current_special_cards(self: @ContractState, ref store: Store, ref game: Game) {
            let mut idx = 0;

            let mut new_current_special_cards = array![];
            let mut len_current_special_cards = game.len_current_special_cards;
            loop {
                if idx == len_current_special_cards {
                    break;
                }
                let mut current_special_card = store.get_current_special_cards(game.id, idx);
                if current_special_card.is_temporary {
                    current_special_card.remaining -= 1;
                    if current_special_card.remaining > 0 {
                        new_current_special_cards.append(current_special_card);
                    } else {
                        game.len_current_special_cards -= 1;

                        if current_special_card.effect_card_id == SPECIAL_HAND_THIEF_ID {
                            game.max_hands -= 1;
                            game.max_discard -= 1;
                        }
                        if current_special_card.effect_card_id == SPECIAL_EXTRA_HELP_ID {
                            game.len_hand -= 2;
                        }
                    }
                } else {
                    new_current_special_cards.append(current_special_card);
                }
                idx += 1;
            };

            idx = 0;
            loop {
                if idx == game.len_current_special_cards {
                    break;
                }
                let mut new_current_special_card = *new_current_special_cards.at(idx);
                new_current_special_card.idx = idx;
                store.set_current_special_cards(new_current_special_card);
                idx += 1;
            }
        }

        fn get_silent_suits(self: @ContractState, rage_round: @RageRound) -> Array<Suit> {
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

        fn contains_suit(self: @ContractState, suits: @Array<Suit>, suit: Suit) -> bool {
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
    }
}
