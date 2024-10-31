use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};

use jokers_of_neon::models::status::game::game::{Game, GameState, GameSubState};
use jokers_of_neon::utils::random::{Random, RandomImpl, RandomTrait};
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::models::status::round::beast::BeastTrait;

fn create_level(world: IWorldDispatcher, ref store: Store, game: Game) {
    if true {
        BeastTrait::create(world, ref store, game.id);
    }
}


