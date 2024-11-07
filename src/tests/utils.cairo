use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use jokers_ls_mod::configs::rage::RageRoundConfig;
use jokers_ls_mod::models::data::beast::{
    GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore, TypeBeast
};
use jokers_ls_mod::models::data::blister_pack::BlisterPack;
use jokers_ls_mod::models::data::card::{Card, CardTrait, Suit, Value, ValueEnumerableImpl};
use jokers_ls_mod::models::data::effect_card::{Effect, EffectCard, TypeEffectCard};
use jokers_ls_mod::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
use jokers_ls_mod::models::data::poker_hand::{LevelPokerHand, PokerHand};
use jokers_ls_mod::models::status::game::game::{Game, CurrentSpecialCards};
use jokers_ls_mod::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_ls_mod::models::status::round::current_hand_card::CurrentHandCard;
use jokers_ls_mod::models::status::shop::shop::{CardItem, CardItemType, BlisterPackItem};
use jokers_ls_mod::store::{Store, StoreTrait};
use starknet::ContractAddress;

fn mock_current_hand(
    ref store: Store, game_id: u32, value_cards: Array<Value>, suit_cards: Array<Suit>, effect_cards: Array<u32>
) {
    assert(value_cards.len() == suit_cards.len(), 'wrong len cards');
    assert(value_cards.len() + effect_cards.len() == 8, 'wrong total cards');

    let mut idx = 0;
    loop {
        if idx == value_cards.len() {
            break;
        }
        store
            .set_current_hand_card(
                CurrentHandCard {
                    game_id, idx, card_id: CardTrait::generate_id(*value_cards.at(idx), *suit_cards.at(idx))
                }
            );
        idx += 1;
    };

    let mut idy = 0;
    loop {
        if idy == effect_cards.len() {
            break;
        }
        let effect_card_id = *effect_cards.at(idy);
        store.set_current_hand_card(CurrentHandCard { game_id, idx, card_id: effect_card_id });
        idx += 1;
        idy += 1;
    }
}

fn mock_current_hand_cards_ids(ref store: Store, game_id: u32, cards_ids: Array<u32>,) {
    assert(cards_ids.len() <= 8, 'max cards exceeded');

    let mut idx = 0;
    loop {
        if idx == cards_ids.len() {
            break;
        }
        let card_id = *cards_ids.at(idx);
        store.set_current_hand_card(CurrentHandCard { game_id, idx, card_id });
        idx += 1;
    };
}

fn mock_special_cards(ref store: Store, ref game: Game, special_cards: Array<u32>) {
    game.len_current_special_cards = special_cards.len();
    store.set_game(game);

    let mut idx = 0;
    loop {
        if idx == special_cards.len() {
            break;
        }
        let effect_card_id = *special_cards.at(idx);

        store
            .set_current_special_cards(
                CurrentSpecialCards { game_id: game.id, idx, effect_card_id, is_temporary: false, remaining: 0 }
            );
        idx += 1;
    }
}

fn mock_game(ref store: Store, owner: ContractAddress) -> Game {
    let mut game: Game = Default::default();
    game.owner = owner;
    game.player_name = owner.into();
    store.set_game(game);

    game
}

fn mock_level_best(world: IWorldDispatcher, game_id: u32) {
    let game_mode_beast = GameModeBeast { game_id, cost_discard: 1, cost_play: 2, energy_max_player: 3 };
    GameModeBeastStore::set(@game_mode_beast, world);
    let beast = Beast {
        game_id,
        beast_id: 1,
        tier: 5,
        level: 5,
        health: 300,
        current_health: 300,
        attack: 15,
        type_beast: TypeBeast::LOOT_SURVIVOR
    };
    BeastStore::set(@beast, world);

    let player_beast = PlayerBeast { game_id, energy: game_mode_beast.energy_max_player };
    PlayerBeastStore::set(@player_beast, world);
}

fn mock_game_deck(world: IWorldDispatcher, game_id: u32) -> GameDeck {
    let game_deck = GameDeck { game_id, len: 54, round_len: 54 };
    GameDeckStore::set(@game_deck, world);
    game_deck
}

fn mock_rage_round(world: IWorldDispatcher, game_id: u32, active_rage_ids: Array<u32>) {
    RageRoundStore::set(
        @RageRound {
            game_id: game_id,
            is_active: true,
            current_probability: 100,
            active_rage_ids: active_rage_ids.span(),
            last_active_level: 1
        },
        world
    );
}
