use core::nullable::NullableTrait;
use dojo::world::Resource::Contract;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::beast::{all_beast, is_loot_survivor_beast};
use jokers_of_neon::constants::card::INVALID_CARD;
use jokers_of_neon::models::data::beast::{
    GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore, TypeBeast
};
use jokers_of_neon::models::data::events::{PlayWinGameEvent, PlayGameOverEvent, BeastAttack, PlayerAttack};
use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
use jokers_of_neon::models::status::game::game::{Game, GameStore, GameState, GameSubState};
use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::systems::rage_system::{IRageSystemDispatcher, IRageSystemDispatcherTrait};
use jokers_of_neon::utils::constants::{
    RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_SILENT_JOKERS, RAGE_CARD_SILENT_HEARTS, RAGE_CARD_SILENT_CLUBS,
    RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_SILENT_SPADES, RAGE_CARD_ZERO_WASTE, is_neon_card, is_modifier_card
};
use jokers_of_neon::utils::random::{Random, RandomImpl, RandomTrait};
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
    const PLAYER_WITHOUT_ENERGY: felt252 = 'Game: player without energy';
}

#[generate_trait]
impl BeastImpl of BeastTrait {
    fn create(world: IWorldDispatcher, ref store: Store, game_id: u32) {
        let mut game = store.get_game(game_id);
        game.substate = GameSubState::BEAST;
        // Active `Rage Cards`
        let rage_round = RageRoundStore::get(world, game_id);

        if is_rage_card_active(@rage_round, RAGE_CARD_DIMINISHED_HOLD) {
            game.len_hand -= 2;
        }
        store.set_game(game);

        let game_mode_beast = GameModeBeast { game_id, cost_discard: 1, cost_play: 2, energy_max_player: 3 };
        GameModeBeastStore::set(@game_mode_beast, world);

        _create_beast(world, game_id, game.level.try_into().unwrap());

        let player_beast = PlayerBeast { game_id, energy: game_mode_beast.energy_max_player };
        PlayerBeastStore::set(@player_beast, world);

        let mut game_deck = GameDeckStore::get(world, game_id);
        game_deck.restore(world);
        CurrentHandCardTrait::create(world, game);
    }

    fn play(world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
        let mut store: Store = StoreTrait::new(world);
        let mut game = store.get_game(game_id);

        assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
        assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
        assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
        assert(game.substate == GameSubState::BEAST, errors::GAME_NOT_IN_BEAST);
        assert(cards_index.len() > 0 && cards_index.len() <= game.len_hand, errors::INVALID_CARD_INDEX_LEN);

        let mut player_beast = PlayerBeastStore::get(world, game.id);
        let mut game_mode_beast = GameModeBeastStore::get(world, game.id);

        assert(player_beast.energy >= game_mode_beast.cost_play, errors::PLAYER_WITHOUT_ENERGY);

        let rage_round = RageRoundStore::get(world, game_id);

        let attack = play(world, ref game, @cards_index, @modifiers_index);

        emit!(world, (PlayerAttack { player: get_caller_address(), attack }));

        let mut beast = BeastStore::get(world, game.id);
        beast.current_health = if attack < beast.current_health {
            beast.current_health - attack
        } else {
            0
        };
        BeastStore::set(@beast, world);

        player_beast.energy -= game_mode_beast.cost_play;
        PlayerBeastStore::set(@player_beast, world);

        if beast.health.is_zero() {
            let play_win_game_event = PlayWinGameEvent {
                player: get_caller_address(), game_id, level: game.level, player_score: 0
            };
            emit!(world, (play_win_game_event));
            game.state = GameState::IN_GAME;
            game.substate = GameSubState::CREATE_LEVEL;
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
            // create_level(world, ref store, game); TODO:
        } else if player_beast.energy.is_zero() {
            _attack_beast(world, ref store, ref game, ref player_beast, ref beast, ref game_mode_beast);
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

            CurrentHandCardTrait::refresh(world, game_id, cards);

            // The player has no more cards in his hand and in the deck
            let game_deck = GameDeckStore::get(world, game.id);
            if game_deck.round_len.is_zero() && player_has_empty_hand(ref store, @game) { // TODO: GameOver
                let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id };
                emit!(world, (play_game_over_event));
                game.state = GameState::FINISHED;
            }
        }
        store.set_game(game);
    }

    fn discard(world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
        let mut store: Store = StoreTrait::new(world);
        let mut game = store.get_game(game_id);

        assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
        assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
        assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
        assert(game.substate == GameSubState::BEAST, errors::GAME_NOT_IN_BEAST);

        let mut game_mode_beast = GameModeBeastStore::get(world, game.id);
        let mut player_beast = PlayerBeastStore::get(world, game.id);

        assert(player_beast.energy >= game_mode_beast.cost_discard, errors::PLAYER_WITHOUT_ENERGY);

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

        player_beast.energy -= game_mode_beast.cost_discard;
        PlayerBeastStore::set(@player_beast, world);

        let game_deck = GameDeckStore::get(world, game_id);
        if game_deck.round_len.is_zero() && player_has_empty_hand(ref store, @game) {
            let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
            emit!(world, (play_game_over_event));
            game.state = GameState::FINISHED;
            store.set_game(game);
        }

        if player_beast.energy.is_zero() {
            let mut beast = BeastStore::get(world, game.id);
            _attack_beast(world, ref store, ref game, ref player_beast, ref beast, ref game_mode_beast);
        }
    }

    fn end_turn(world: IWorldDispatcher, game_id: u32) {
        let mut store: Store = StoreTrait::new(world);
        let mut game = store.get_game(game_id);

        assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
        assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
        assert(game.state == GameState::IN_GAME, errors::GAME_NOT_IN_GAME);
        assert(game.substate == GameSubState::BEAST, errors::GAME_NOT_IN_BEAST);

        let mut beast = BeastStore::get(world, game.id);
        let mut game_mode_beast = GameModeBeastStore::get(world, game.id);
        let mut player_beast = PlayerBeastStore::get(world, game.id);
        _attack_beast(world, ref store, ref game, ref player_beast, ref beast, ref game_mode_beast);
    }
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

fn _attack_beast(
    world: IWorldDispatcher,
    ref store: Store,
    ref game: Game,
    ref player_beast: PlayerBeast,
    ref beast: Beast,
    ref game_mode_beast: GameModeBeast
) {
    emit!(world, (BeastAttack { player: get_caller_address(), attack: beast.attack }));
    game
        .current_player_hp =
            if beast.attack > game.current_player_hp {
                0
            } else {
                game.current_player_hp - beast.attack
            };

    if game.current_player_hp.is_zero() {
        let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
        emit!(world, (play_game_over_event));
        game.state = GameState::FINISHED;
    } else {
        // reset energy
        player_beast.energy = game_mode_beast.energy_max_player;
    }
    store.set_game(game);
    PlayerBeastStore::set(@player_beast, world);
}

fn _create_beast(world: IWorldDispatcher, game_id: u32, level: u8) {
    let mut randomizer = RandomImpl::new(world);
    let beast_id = randomizer.between::<u32>(0, all_beast().len() - 1);
    let (tier, health, attack) = _generate_stats(level);
    let type_beast = if is_loot_survivor_beast(beast_id) {
        TypeBeast::LOOT_SURVIVOR
    } else {
        TypeBeast::JOKERS_OF_NEON
    };
    let beast = Beast { game_id, beast_id, tier, level, health, current_health: health, attack, type_beast };
    BeastStore::set(@beast, world);
    emit!(world, (beast));
}

fn _generate_stats(level: u8) -> (u8, u32, u32) { // tier, health, attack
    match level {
        0 => (0, 0, 0),
        1 => (1, 300, 15),
        2 => (1, 600, 25),
        3 => (1, 900, 35),
        4 => (1, 1200, 45),
        _ => (2, 2000, 50),
    }
}
