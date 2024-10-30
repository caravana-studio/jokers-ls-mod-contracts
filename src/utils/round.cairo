use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::models::data::game_deck::{GameDeckStore, GameDeckImpl};
use jokers_of_neon::models::status::game::game::Game;
use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_of_neon::models::status::round::current_hand_card::CurrentHandCardTrait;
use jokers_of_neon::models::status::round::deck_card::DeckCardTrait;
use jokers_of_neon::models::status::round::round::Round;
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::utils::constants::{RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_ZERO_WASTE};
use jokers_of_neon::utils::rage::is_rage_card_active;

fn create_round(world: IWorldDispatcher, game: Game) {
    let mut game = game;
    let mut store: Store = StoreTrait::new(world);

    // Active `Rage Cards`
    let rage_round = RageRoundStore::get(world, game.id);

    if is_rage_card_active(@rage_round, RAGE_CARD_DIMINISHED_HOLD) {
        game.len_hand -= 2;
        store.set_game(game);
    }

    let round_discards = if is_rage_card_active(@rage_round, RAGE_CARD_ZERO_WASTE) {
        Zeroable::zero()
    } else {
        game.max_discard
    };

    let level_score = calculate_level_score(game.level);

    let mut round = Round {
        game_id: game.id, player_score: 0, level_score, hands: game.max_hands, discard: round_discards,
    };
    store.set_round(round);

    let mut game_deck = GameDeckStore::get(world, game.id);
    game_deck.restore(world);
    CurrentHandCardTrait::create(world, ref round, game);
}

fn calculate_level_score(level: u32) -> u32 {
    if level <= 2 {
        300 * level
    } else if level <= 10 {
        600 * level - 600
    } else if level <= 20 {
        1200 * level - 6600
    } else if level <= 25 {
        3000 * level - 42600
    } else if level <= 30 {
        7000 * level - 142600
    } else {
        20000 * level - 532600
    }
}
