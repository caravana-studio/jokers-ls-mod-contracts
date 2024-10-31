#[dojo::interface]
trait IBeastSystem {
    fn play(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>);
    fn discard(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>);
    fn end_turn(ref world: IWorldDispatcher, game_id: u32);
}

#[dojo::contract]
mod beast_system {
    use core::nullable::NullableTrait;
    use dojo::world::Resource::Contract;
    use jokers_of_neon::constants::card::INVALID_CARD;
    use jokers_of_neon::models::data::events::{PlayWinGameEvent, PlayGameOverEvent};
    use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
    use jokers_of_neon::models::game_mode::beast::{
        GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore
    };
    use jokers_of_neon::models::status::game::game::{Game, GameState, GameSubState};
    use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
    use jokers_of_neon::store::{Store, StoreTrait};
    use jokers_of_neon::systems::rage_system::{IRageSystemDispatcher, IRageSystemDispatcherTrait};
    use jokers_of_neon::utils::constants::{
        RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_SILENT_JOKERS, RAGE_CARD_SILENT_HEARTS, RAGE_CARD_SILENT_CLUBS,
        RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_SILENT_SPADES, RAGE_CARD_ZERO_WASTE, is_neon_card, is_modifier_card
    };
    use jokers_of_neon::utils::game::play;
    use jokers_of_neon::utils::level::create_level;
    use jokers_of_neon::utils::rage::is_rage_card_active;
    use starknet::{ContractAddress, get_caller_address, ClassHash};

    mod errors {
        const GAME_NOT_FOUND: felt252 = 'Game: game not found';
        const CALLER_NOT_OWNER: felt252 = 'Game: caller not owner';
        const INVALID_CARD_INDEX_LEN: felt252 = 'Game: invalid card index len';
        const INVALID_CARD_ELEM: felt252 = 'Game: invalid card element';
        const ARRAY_REPEATED_ELEMENTS: felt252 = 'Game: array repeated elements';
        const ONLY_EFFECT_CARD: felt252 = 'Game: only effect cards';
        const GAME_NOT_IN_GAME: felt252 = 'Game: is not IN_GAME';
        const GAME_NOT_IN_BEAST: felt252 = 'Game: is not BEAST';
        const USE_INVALID_CARD: felt252 = 'Game: use an invalid card';
    }

    #[abi(embed_v0)]
    impl BeastImpl of super::IBeastSystem<ContractState> {
        fn play(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
            assert(game.substate == GameSubState::BEAST, errors::GAME_NOT_IN_BEAST);
            assert(cards_index.len() > 0 && cards_index.len() <= game.len_hand, errors::INVALID_CARD_INDEX_LEN);

            let rage_round = RageRoundStore::get(world, game_id);

            let score = play(world, ref game, @cards_index, @modifiers_index);

            let player_attack = score; // TODO:

            let mut beast = BeastStore::get(world, game.id);
            beast.health = if player_attack < beast.health {
                beast.health - player_attack
            } else {
                0
            };
            BeastStore::set(@beast, world);

            let mut game_mode_beast = GameModeBeastStore::get(world, game.id);

            let mut player_beast = PlayerBeastStore::get(world, game.id);
            player_beast.energy -= game_mode_beast.cost_play;
            PlayerBeastStore::set(@player_beast, world);

            if beast.health.is_zero() {
                println!("gane");
                let play_win_game_event = PlayWinGameEvent {
                    player: get_caller_address(), game_id, level: game.level, player_score: 0
                };
                emit!(world, (play_win_game_event));
                game.state = GameState::IN_GAME;
                game.substate = GameSubState::NONE;
                game.player_score += 1;

                if is_rage_card_active(@rage_round, RAGE_CARD_DIMINISHED_HOLD) {
                    // return the cards to the deck
                    game.len_hand += 2;
                }
                let (_, rage_system_address) = match world.resource(selector_from_tag!("jokers_of_neon-rage_system")) {
                    Contract((class_hash, contract_address)) => Option::Some((class_hash, contract_address)),
                    _ => Option::None
                }.unwrap();
                IRageSystemDispatcher { contract_address: rage_system_address.try_into().unwrap() }.calculate(game.id);

                create_level(world, ref store, game);
            } else if player_beast.energy.is_zero() {
                println!("energia en zero - me ataca la bestia");
                self._attack_beast(world, ref store, ref game, ref player_beast, ref beast, ref game_mode_beast);
            } else {
                println!("repartiendo cartas");
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

                CurrentHandCardTrait::refresh(world, game_id, cards);

                // The player has no more cards in his hand and in the deck
                let game_deck = GameDeckStore::get(world, game.id);
                if game_deck.round_len.is_zero() && self.player_has_empty_hand(ref store, @game) { // TODO: GameOver
                    let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id };
                    emit!(world, (play_game_over_event));
                    game.state = GameState::FINISHED;
                }
            }
            store.set_game(game);
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

            CurrentHandCardTrait::refresh(world, game.id, cards);

            let mut game_mode_beast = GameModeBeastStore::get(world, game.id);

            let mut player_beast = PlayerBeastStore::get(world, game.id);
            player_beast.energy -= game_mode_beast.cost_discard;
            PlayerBeastStore::set(@player_beast, world);

            let game_deck = GameDeckStore::get(world, game_id);
            if game_deck.round_len.is_zero() && self.player_has_empty_hand(ref store, @game) {
                let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
                emit!(world, (play_game_over_event));
                game.state = GameState::FINISHED;
                store.set_game(game);
            }
        }
        fn end_turn(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);
            let mut beast = BeastStore::get(world, game.id);
            let mut game_mode_beast = GameModeBeastStore::get(world, game.id);
            let mut player_beast = PlayerBeastStore::get(world, game.id);
            println!("me ataca la bestia");
            self._attack_beast(world, ref store, ref game, ref player_beast, ref beast, ref game_mode_beast);
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

        fn _attack_beast(
            self: @ContractState,
            world: IWorldDispatcher,
            ref store: Store,
            ref game: Game,
            ref player_beast: PlayerBeast,
            ref beast: Beast,
            ref game_mode_beast: GameModeBeast
        ) {
            player_beast
                .health = if beast.attack > player_beast.health {
                    0
                } else {
                    player_beast.health - beast.attack
                };

            if player_beast.health.is_zero() {
                let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
                emit!(world, (play_game_over_event));
                game.state = GameState::FINISHED;
                store.set_game(game);
            } else {
                // reset energy
                player_beast.energy = game_mode_beast.energy_max_player;
            }
            PlayerBeastStore::set(@player_beast, world);
        }
    }
}
