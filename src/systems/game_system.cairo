use dojo::world::{IWorld, IWorldDispatcher};

use jokers_of_neon::models::data::poker_hand::PokerHand;

#[dojo::interface]
trait IGameSystem {
    fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32;
    fn create_level(ref world: IWorldDispatcher, game_id: u32);
    fn create_reward(ref world: IWorldDispatcher, game_id: u32, reward_index: u8);
    fn select_reward(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
    fn select_deck(ref world: IWorldDispatcher, game_id: u32, deck_id: u8);
    fn select_special_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
    fn select_modifier_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
    fn play(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>);
    fn discard(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>);
    fn end_turn(ref world: IWorldDispatcher, game_id: u32);
    fn discard_effect_card(ref world: IWorldDispatcher, game_id: u32, card_index: u32);
    fn discard_special_card(ref world: IWorldDispatcher, game_id: u32, special_card_index: u32);
    fn use_adventurer(ref world: IWorldDispatcher, game_id: u32, adventurer_id: u32);
    fn skip_adventurer(ref world: IWorldDispatcher, game_id: u32);
    fn select_aventurer_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
}

mod errors {
    const GAME_NOT_FOUND: felt252 = 'Game: game not found';
    const CALLER_NOT_OWNER: felt252 = 'Game: caller not owner';
    const INVALID_CARD_INDEX_LEN: felt252 = 'Game: invalid card index len';
    const INVALID_CARD_ELEM: felt252 = 'Game: invalid card element';
    const ONLY_EFFECT_CARD: felt252 = 'Game: only effect cards';
    const GAME_NOT_IN_GAME: felt252 = 'Game: is not IN_GAME';
    const GAME_NOT_SELECT_SPECIAL_CARDS: felt252 = 'Game:is not SELECT_SPECIAL_CARD';
    const GAME_NOT_SELECT_MODIFIER_CARDS: felt252 = 'Game:is not SELCT_MODIFIER_CARD';
    const USE_INVALID_CARD: felt252 = 'Game: use an invalid card';
    const INVALID_DECK_ID: felt252 = 'Game: use an invalid deck';

    const WRONG_SUBSTATE_BEAST: felt252 = 'Wrong substate BEAST';
    const WRONG_SUBSTATE_CREATE_LEVEL: felt252 = 'Wrong substate CREATE_LEVEL';
    const WRONG_SUBSTATE_CREATE_REWARD: felt252 = 'Wrong substate CREATE_REWARD';
    const WRONG_SUBSTATE_REWARD: felt252 = 'Wrong substate REWARD';
    const WRONG_SUBSTATE_DRAFT_DECK: felt252 = 'Wrong substate DRAFT_DECK';
    const WRONG_SUBSTATE_DRAFT_MODIFIERS: felt252 = 'Wrong substate DRAFT_MODIFIERS';
    const WRONG_SUBSTATE_DRAFT_SPECIALS: felt252 = 'Wrong substate DRAFT_SPECIALS';
    const WRONG_SUBSTATE_SELECT_REWARD: felt252 = 'Wrong substate SELECT_REWARD';
    const WRONG_SUBSTATE_DRAFT_ADVENTURER: felt252 = 'Wrong substate SELECT_ADVENTURE';
    const WRONG_SUBSTATE_ADVENTURER_CARDS: felt252 = 'Wrong substate SELECT_ADV_CARDS';
}

#[dojo::contract]
mod game_system {
    use core::nullable::NullableTrait;
    use dojo::world::Resource::Contract;
    use jokers_of_neon::constants::card::{JOKER_CARD, NEON_JOKER_CARD, INVALID_CARD};
    use jokers_of_neon::constants::packs::{
        SPECIAL_CARDS_PACK_ID, MODIFIER_CARDS_PACK_ID, REWARD_CARDS_PACK_ID, SPECIALS_BLISTER_PACK_ID
    };
    use jokers_of_neon::constants::reward::{REWARD_HP_POTION, REWARD_BLISTER_PACK, REWARD_SPECIAL_CARDS};
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
        SpecialCashEvent, PlayerHealed
    };
    use jokers_of_neon::models::data::game_deck::{GameDeckStore, GameDeckImpl};
    use jokers_of_neon::models::data::last_beast_level::{LastBeastLevel, LastBeastLevelStore};
    use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};
    use jokers_of_neon::models::data::reward::{Reward, RewardType, RewardStore};
    use jokers_of_neon::models::status::game::game::{Game, GameStore, GameState, GameSubState};
    use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
    use jokers_of_neon::models::status::round::adventurer::AdventurerTrait;
    use jokers_of_neon::models::data::beast::{
        GameModeBeast, GameModeBeastStore
    };
    use jokers_of_neon::models::status::round::beast::BeastTrait;
    use jokers_of_neon::models::status::round::challenge::ChallengeTrait;
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
    use jokers_of_neon::models::status::round::level::LevelTrait;
    use jokers_of_neon::models::status::shop::shop::{BlisterPackResult};
    use jokers_of_neon::store::{Store, StoreTrait};
    use jokers_of_neon::systems::rage_system::{IRageSystemDispatcher, IRageSystemDispatcherTrait};
    use jokers_of_neon::utils::calculate_hand::calculate_hand;
    use jokers_of_neon::utils::constants::{
        RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_SILENT_JOKERS, RAGE_CARD_SILENT_HEARTS, RAGE_CARD_SILENT_CLUBS,
        RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_SILENT_SPADES, RAGE_CARD_ZERO_WASTE, is_neon_card, is_modifier_card
    };
    use jokers_of_neon::utils::level::create_level;
    use jokers_of_neon::utils::packs::{open_blister_pack, select_cards_from_blister};
    use jokers_of_neon::utils::rage::is_rage_card_active;
    use jokers_of_neon::utils::random::RandomImpl;
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
                player_hp: 100,
                player_level: 1,
                current_player_hp: 100,
                obstacles_cleared: 0,
                beasts_defeated: 0,
                max_hands: 5,
                max_discard: 5,
                max_jokers: 5,
                player_score: 0,
                level: 1,
                len_hand: 8,
                len_max_current_special_cards: 5,
                len_current_special_cards: 0,
                current_jokers: 0,
                state: GameState::IN_GAME,
                substate: GameSubState::DRAFT_DECK,
            };
            store.set_game(game);
            emit!(world, (game));

            let level_config = store.get_level_config();
            LastBeastLevelStore::set(
                @LastBeastLevel { game_id: game_id, current_probability: level_config.initial_probability, level: 0 },
                world
            );

            RewardStore::set(
                @Reward {
                    game_id, rewards_ids: array![REWARD_HP_POTION, REWARD_BLISTER_PACK, REWARD_SPECIAL_CARDS].span()
                },
                world
            );

            let game_mode_beast = GameModeBeast { game_id, cost_discard: 1, cost_play: 2, energy_max_player: 3 };
            GameModeBeastStore::set(@game_mode_beast, world);

            let create_game_event = CreateGameEvent { player: get_caller_address(), game_id };
            emit!(world, (create_game_event));
            game_id
        }

        fn create_level(ref world: IWorldDispatcher, game_id: u32) {
            let mut store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
            assert(game.substate == GameSubState::CREATE_LEVEL, errors::WRONG_SUBSTATE_CREATE_LEVEL);

            game.substate = LevelTrait::calculate(world, game_id);
            match game.substate {
                GameSubState::BEAST => { BeastTrait::create(world, ref store, game_id); },
                GameSubState::OBSTACLE => { ChallengeTrait::create(world, ref store, game_id); },
                _ => {},
            }
            game.level += 1;
            store.set_game(game);
        }

        fn play(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let game = store.get_game(game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);

            match game.substate {
                GameSubState::BEAST => { BeastTrait::play(world, game_id, cards_index, modifiers_index); },
                GameSubState::OBSTACLE => { ChallengeTrait::play(world, game_id, cards_index, modifiers_index); },
                _ => {},
            }
        }

        fn discard(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let game = store.get_game(game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);

            match game.substate {
                GameSubState::BEAST => { BeastTrait::discard(world, game_id, cards_index, modifiers_index); },
                GameSubState::OBSTACLE => { ChallengeTrait::discard(world, game_id, cards_index, modifiers_index); },
                _ => {},
            }
        }

        fn end_turn(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);

            let game = store.get_game(game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.substate == GameSubState::BEAST, errors::WRONG_SUBSTATE_BEAST);

            BeastTrait::end_turn(world, game_id);
        }

        fn create_reward(ref world: IWorldDispatcher, game_id: u32, reward_index: u8) {
            let mut game = GameStore::get(world, game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.substate == GameSubState::CREATE_REWARD, errors::WRONG_SUBSTATE_REWARD);

            let reward: RewardType = (*RewardStore::get(world, game_id).rewards_ids.at(reward_index.into())).into();
            match reward {
                RewardType::HP_POTION => {
                    game.substate = GameSubState::CREATE_LEVEL;

                    let mut randomizer = RandomImpl::new(world);
                    let hp_heal = randomizer.between::<u32>(25, 50);
                    game
                        .current_player_hp =
                            if game.current_player_hp + hp_heal >= game.player_hp {
                                game.player_hp
                            } else {
                                game.current_player_hp + hp_heal
                            };
                    emit!(world, PlayerHealed { game_id, potion_heal: hp_heal, current_hp: game.player_hp });
                },
                RewardType::BLISTER_PACK => {
                    game.substate = GameSubState::REWARD_CARDS_PACK;

                    let mut store = StoreTrait::new(world);
                    let cards = open_blister_pack(world, ref store, game, REWARD_CARDS_PACK_ID);
                    let blister_pack_result = BlisterPackResult { game_id, cards_picked: false, cards };
                    emit!(world, (blister_pack_result));
                    store.set_blister_pack_result(blister_pack_result);
                },
                RewardType::SPECIAL_CARDS => {
                    game.substate = GameSubState::REWARD_SPECIALS;

                    let mut store = StoreTrait::new(world);
                    let cards = open_blister_pack(world, ref store, game, SPECIAL_CARDS_PACK_ID);
                    let blister_pack_result = BlisterPackResult { game_id, cards_picked: false, cards };
                    emit!(world, (blister_pack_result));
                    store.set_blister_pack_result(blister_pack_result);
                },
                _ => {}
            }
            GameStore::set(@game, world)
        }

        fn select_reward(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut game = GameStore::get(world, game_id);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(
                game.substate == GameSubState::REWARD_SPECIALS || game.substate == GameSubState::REWARD_CARDS_PACK,
                errors::WRONG_SUBSTATE_SELECT_REWARD
            );

            let mut store = StoreTrait::new(world);
            match game.substate {
                GameSubState::REWARD_SPECIALS => { assert(cards_index.len() <= 1, errors::INVALID_CARD_INDEX_LEN); },
                GameSubState::REWARD_CARDS_PACK => { assert(cards_index.len() <= 3, errors::INVALID_CARD_INDEX_LEN); },
                _ => {}
            }
            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            select_cards_from_blister(world, ref game, blister_pack_result.cards, cards_index);
            blister_pack_result.cards_picked = true;
            store.set_blister_pack_result(blister_pack_result);

            game.substate = GameSubState::CREATE_LEVEL;
            store.set_game(game);
            self.create_level(game_id)
        }

        fn select_deck(ref world: IWorldDispatcher, game_id: u32, deck_id: u8) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.substate == GameSubState::DRAFT_DECK, errors::WRONG_SUBSTATE_DRAFT_DECK);
            assert(deck_id < 3, errors::INVALID_DECK_ID);

            GameDeckImpl::init(ref store, game_id, deck_id);
            game.substate = GameSubState::DRAFT_SPECIALS;
            store.set_game(game);

            let cards = open_blister_pack(world, ref store, game, SPECIAL_CARDS_PACK_ID);
            let blister_pack_result = BlisterPackResult { game_id, cards_picked: false, cards };
            emit!(world, (blister_pack_result));
            store.set_blister_pack_result(blister_pack_result);
        }

        fn use_adventurer(ref world: IWorldDispatcher, game_id: u32, adventurer_id: u32) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.substate == GameSubState::DRAFT_ADVENTURER, errors::WRONG_SUBSTATE_DRAFT_ADVENTURER);

            AdventurerTrait::use_adventurer(world, adventurer_id, ref game);

            game.substate = GameSubState::DRAFT_ADVENTURER_CARDS;
            store.set_game(game);

            let cards = open_blister_pack(world, ref store, game, SPECIALS_BLISTER_PACK_ID);
            let blister_pack_result = BlisterPackResult { game_id, cards_picked: false, cards };
            emit!(world, (blister_pack_result));
            store.set_blister_pack_result(blister_pack_result);
        }

        fn skip_adventurer(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.substate == GameSubState::DRAFT_ADVENTURER, errors::WRONG_SUBSTATE_DRAFT_ADVENTURER);

            game.substate = GameSubState::CREATE_LEVEL;
            store.set_game(game);
        }

        fn select_aventurer_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.substate == GameSubState::DRAFT_ADVENTURER_CARDS, errors::WRONG_SUBSTATE_ADVENTURER_CARDS);

            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            assert(cards_index.len() <= 2, errors::INVALID_CARD_INDEX_LEN);

            select_cards_from_blister(world, ref game, blister_pack_result.cards, cards_index);

            game.substate = GameSubState::CREATE_LEVEL;
            store.set_game(game);
        }

        fn select_special_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.substate == GameSubState::DRAFT_SPECIALS, errors::WRONG_SUBSTATE_DRAFT_SPECIALS);

            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            assert(cards_index.len() <= 2, errors::INVALID_CARD_INDEX_LEN);

            select_cards_from_blister(world, ref game, blister_pack_result.cards, cards_index);

            game.substate = GameSubState::DRAFT_MODIFIERS;
            store.set_game(game);

            let cards = open_blister_pack(world, ref store, game, MODIFIER_CARDS_PACK_ID);
            let blister_pack_result = BlisterPackResult { game_id, cards_picked: false, cards };
            emit!(world, (blister_pack_result));
            store.set_blister_pack_result(blister_pack_result);
        }

        fn select_modifier_cards(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.substate == GameSubState::DRAFT_MODIFIERS, errors::WRONG_SUBSTATE_DRAFT_MODIFIERS);

            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            assert(cards_index.len() <= 3, errors::INVALID_CARD_INDEX_LEN);

            select_cards_from_blister(world, ref game, blister_pack_result.cards, cards_index);

            blister_pack_result.cards_picked = true;
            store.set_blister_pack_result(blister_pack_result);

            game.substate = GameSubState::DRAFT_ADVENTURER;
            store.set_game(game);
        }

        fn discard_effect_card(ref world: IWorldDispatcher, game_id: u32, card_index: u32) {
            let mut store: Store = StoreTrait::new(world);
            let game = store.get_game(game_id);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(card_index >= 0 && card_index < game.len_hand, errors::INVALID_CARD_ELEM);
            let current_hand_card = store.get_current_hand_card(game_id, card_index);
            assert(is_modifier_card(current_hand_card.card_id), errors::ONLY_EFFECT_CARD);

            CurrentHandCardTrait::refresh(world, game.id, array![card_index]);
        }

        fn discard_special_card(ref world: IWorldDispatcher, game_id: u32, special_card_index: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
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
                        let mut game_mode_beast = GameModeBeastStore::get(world, game.id);
                        game_mode_beast.energy_max_player += 1;
                        GameModeBeastStore::set(@game_mode_beast, world);
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
}
