use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
use jokers_of_neon::models::game_mode::beast::{
    GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore
};
use jokers_of_neon::models::status::game::game::{Game, GameState, GameSubState};
use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::utils::constants::{
    RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_SILENT_JOKERS, RAGE_CARD_SILENT_HEARTS, RAGE_CARD_SILENT_CLUBS,
    RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_SILENT_SPADES, RAGE_CARD_ZERO_WASTE, is_neon_card, is_modifier_card
};
use jokers_of_neon::utils::rage::is_rage_card_active;
use jokers_of_neon::utils::random::{Random, RandomImpl, RandomTrait};

fn create_level(world: IWorldDispatcher, ref store: Store, game: Game) {
    if true {
        create_beast_level(world, ref store, game);
    }
}

fn create_beast_level(world: IWorldDispatcher, ref store: Store, game: Game) {
    let mut store: Store = StoreTrait::new(world);
    let mut game = store.get_game(game.id);
    game.substate = GameSubState::BEAST;
    // Active `Rage Cards`
    let rage_round = RageRoundStore::get(world, game.id);

    if is_rage_card_active(@rage_round, RAGE_CARD_DIMINISHED_HOLD) {
        game.len_hand -= 2;
    }
    store.set_game(game);

    let game_mode_beast = GameModeBeast { game_id: game.id, cost_discard: 1, cost_play: 2, energy_max_player: 3 };
    GameModeBeastStore::set(@game_mode_beast, world);

    let beast = Beast { game_id: game.id, tier: 5, level: 5, health: 300, attack: 15 };
    BeastStore::set(@beast, world);

    let player_beast = PlayerBeast { game_id: game.id, health: 100, energy: game_mode_beast.energy_max_player };
    PlayerBeastStore::set(@player_beast, world);

    let mut game_deck = GameDeckStore::get(world, game.id);
    game_deck.restore(world);
    CurrentHandCardTrait::create(world, game);
}
