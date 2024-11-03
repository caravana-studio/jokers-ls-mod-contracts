use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};

use jokers_ls_mod::models::status::game::game::{Game, GameState, GameSubState};
use jokers_ls_mod::models::status::round::beast::BeastTrait;
use jokers_ls_mod::store::{Store, StoreTrait};
use jokers_ls_mod::utils::random::{Random, RandomImpl, RandomTrait};

fn create_level(world: IWorldDispatcher, ref store: Store, game: Game) {
    if true {
        BeastTrait::create(world, ref store, game.id);
    }
}

