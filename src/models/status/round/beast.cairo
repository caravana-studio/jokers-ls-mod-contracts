use core::nullable::NullableTrait;
use dojo::world::Resource::Contract;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use jokers_ls_mod::constants::beast::{all_beast, beast_loot_survivor, is_loot_survivor_beast};
use jokers_ls_mod::constants::card::INVALID_CARD;
use jokers_ls_mod::constants::reward::{REWARD_HP_POTION, REWARD_SPECIAL_CARDS};
use jokers_ls_mod::interfaces::erc721::{IERC721SystemDispatcher, IERC721SystemDispatcherTrait};
use jokers_ls_mod::models::data::beast::{
    GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore, TypeBeast, BeastStats,
};
use jokers_ls_mod::models::data::events::{
    PlayWinGameEvent, PlayGameOverEvent, BeastAttack, PlayerAttack, BeastIsMintable, BeastNFT, PlayerScore
};
use jokers_ls_mod::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
use jokers_ls_mod::models::data::reward::RewardTrait;
use jokers_ls_mod::models::status::game::game::{Game, GameStore, GameState, GameSubState};
use jokers_ls_mod::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_ls_mod::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
use jokers_ls_mod::store::{Store, StoreTrait};
use jokers_ls_mod::systems::rage_system::{IRageSystemDispatcher, IRageSystemDispatcherTrait};
use jokers_ls_mod::utils::adventurer::{is_mainnet, NFT_ADDRESS_MAINNET};
use jokers_ls_mod::utils::constants::{
    RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_SILENT_JOKERS, RAGE_CARD_SILENT_HEARTS, RAGE_CARD_SILENT_CLUBS,
    RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_SILENT_SPADES, RAGE_CARD_ZERO_WASTE, is_neon_card, is_modifier_card
};

use jokers_ls_mod::utils::game::play;
use jokers_ls_mod::utils::level::create_level;
use jokers_ls_mod::utils::rage::is_rage_card_active;
use jokers_ls_mod::utils::random::{Random, RandomImpl, RandomTrait};
use starknet::{ContractAddress, get_caller_address, ClassHash, get_tx_info};

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

        let game_mode_beast = GameModeBeastStore::get(world, game.id);

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

        if beast.current_health.is_zero() {
            let play_win_game_event = PlayWinGameEvent {
                player: get_caller_address(), game_id, level: game.level, player_score: 0
            };
            emit!(world, (play_win_game_event));
            game.player_score += (beast.tier).into() * 500 + (beast.level).into() * 100;
            game.beasts_defeated += 1;
            game.player_level += 1;
            game.player_hp += 10;
            game.current_player_hp += 10;

            game.substate = GameSubState::CREATE_REWARD;
            RewardTrait::beast(world, game_id);

            if is_mainnet(get_tx_info().unbox().chain_id) {
                if !is_loot_survivor_beast(beast.beast_id) {
                    let beast_stats = BeastStats {
                        tier: beast.tier, level: beast.level, beast_id: beast.beast_id.try_into().unwrap()
                    };
                    let erc721_dispatcher = IERC721SystemDispatcher { contract_address: NFT_ADDRESS_MAINNET() };
                    let owner = erc721_dispatcher.get_owner(beast_stats);
                    if owner.is_zero() {
                        erc721_dispatcher.safe_mint(get_caller_address(), beast_stats);
                        let token_id: u256 = erc721_dispatcher.total_supply();
                        emit!(
                            world,
                            (BeastNFT {
                                player: get_caller_address(),
                                tier: beast.tier,
                                level: beast.level,
                                beast_id: beast.beast_id.try_into().unwrap(),
                                token_id: token_id.try_into().unwrap()
                            })
                        );
                    }
                }
            }
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

                emit!(world, (PlayerScore {
                    player: game.owner,
                    player_name: game.player_name,
                    player_score: game.player_score,
                    player_level: game.player_level,
                    obstacles_cleared: game.obstacles_cleared,
                    beasts_defeated: game.beasts_defeated
                }));

                game.state = GameState::FINISHED;
            }
        }
        store.set_game(game);
        if player_beast.energy.is_zero() && game.substate != GameSubState::CREATE_REWARD {
            Self::end_turn(world, game_id);
        }
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

            emit!(world, (PlayerScore {
                player: game.owner,
                player_name: game.player_name,
                player_score: game.player_score,
                player_level: game.player_level,
                obstacles_cleared: game.obstacles_cleared,
                beasts_defeated: game.beasts_defeated
            }));

            game.state = GameState::FINISHED;
            store.set_game(game);
        }

        if player_beast.energy.is_zero() {
            Self::end_turn(world, game_id);
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
    let mut randomizer = RandomImpl::new(world);
    let beast_dmg = randomizer.between::<u32>(0, 5 * game.level) + beast.attack;

    game.current_player_hp = if beast_dmg > game.current_player_hp {
        0
    } else {
        game.current_player_hp - beast_dmg
    };
    emit!(world, (BeastAttack { player: get_caller_address(), attack: beast_dmg }));

    if game.current_player_hp.is_zero() {
        let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
        emit!(world, (play_game_over_event));

        emit!(world, (PlayerScore {
            player: game.owner,
            player_name: game.player_name,
            player_score: game.player_score,
            player_level: game.player_level,
            obstacles_cleared: game.obstacles_cleared,
            beasts_defeated: game.beasts_defeated
        }));

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

    let beast_id: u32 = if level < 7 {
        let rnd = randomizer.between::<u32>(0, beast_loot_survivor().len() - 1);
        *beast_loot_survivor().at(rnd)
    } else {
        let rnd = randomizer.between::<u32>(0, all_beast().len() - 1);
        *all_beast().at(rnd)
    };

    let random = randomizer.between::<u32>(1, 100);
    let (tier, health, attack): (u8, u32, u32) = _generate_stats(level, beast_id, random);
    let type_beast: TypeBeast = if is_loot_survivor_beast(beast_id) {
        TypeBeast::LOOT_SURVIVOR
    } else {
        TypeBeast::JOKERS_OF_NEON
    };

    BeastStore::set(
        @Beast {
            game_id: game_id,
            beast_id: beast_id,
            tier: tier,
            level: level,
            health: health,
            current_health: health,
            attack: attack,
            type_beast: type_beast
        },
        world
    );

    emit!(
        world,
        (
            Beast {
                game_id: game_id,
                beast_id: beast_id,
                tier: tier,
                level: level,
                health: health,
                current_health: health,
                attack: attack,
                type_beast: type_beast
            },
        )
    );

    match type_beast {
        TypeBeast::JOKERS_OF_NEON => {
            let beast_stats = BeastStats { tier, level, beast_id: beast_id.try_into().unwrap() };
            let erc721_dispatcher = IERC721SystemDispatcher { contract_address: NFT_ADDRESS_MAINNET() };
            let owner = erc721_dispatcher.get_owner(beast_stats);
            emit!(
                world,
                (
                    BeastIsMintable {
                        player: get_caller_address(),
                        tier: beast_stats.tier,
                        level: beast_stats.level,
                        beast_id: beast_stats.beast_id,
                        is_mintable: owner.is_zero()
                    },
                )
            );
        },
        _ => {}
    };
}

// tier, health, attack
fn _generate_stats(level: u8, beast_id: u32, random: u32) -> (u8, u32, u32) {
    let random_tier: u8 = _obtain_random_tier(random);

    let beast_hp: u32 = _calculate_beast_hp(level);
    let stats: (u8, u32, u32) = if level <= 4 {
        (random_tier, beast_hp, 10)
    } else if level <= 8 {
        (random_tier, beast_hp, 20)
    } else if level <= 12 {
        (random_tier, beast_hp, 30)
    } else if level <= 16 {
        (random_tier, beast_hp, 40)
    } else {
        (random_tier, beast_hp, 50)
    };

    if beast_id >= 101 && beast_id <= 108 {
        let (tier, health, attack) = stats;
        (tier, health + (health / 10), attack + 20)
    } else {
        stats
    }
}

// Tier 1: 00 - 40
// Tier 2: 41 - 70
// Tier 3: 71 - 85
// Tier 4: 86 - 95
// Tier 5: 96 - 100
fn _obtain_random_tier(random: u32) -> u8 {
    if random <= 40 {
        5
    } else if random <= 70 {
        4
    } else if random <= 85 {
        3
    } else if random <= 95 {
        2
    } else {
        1
    }
}

fn _calculate_beast_hp(level: u8) -> u32 {
    if level <= 2 {
        300 * level.into()
    } else if level <= 10 {
        600 * level.into() - 600
    } else if level <= 20 {
        1200 * level.into() - 6600
    } else if level <= 25 {
        3000 * level.into() - 42600
    } else if level <= 30 {
        7000 * level.into() - 142600
    } else {
        20000 * level.into() - 532600
    }
}
