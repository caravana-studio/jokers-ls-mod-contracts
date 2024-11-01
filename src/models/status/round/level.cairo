use dojo::world::{IWorld, IWorldDispatcher};
use jokers_of_neon::models::data::last_beast_level::{LastBeastLevel, LastBeastLevelStore};
use jokers_of_neon::models::status::game::game::GameSubState;
use jokers_of_neon::models::status::{game::{game::GameStore}};
use jokers_of_neon::store::StoreTrait;
use jokers_of_neon::utils::constants::rage_cards_all;
use jokers_of_neon::utils::random::RandomImpl;
use jokers_of_neon::utils::shop::generate_unique_random_values;

#[generate_trait]
impl LevelImpl of LevelTrait {
    fn calculate(world: IWorldDispatcher, game_id: u32) -> GameSubState {
        let mut store = StoreTrait::new(world);
        let game = GameStore::get(world, game_id);
        let level_config = store.get_level_config();
        let mut last_active_level = LastBeastLevelStore::get(world, game_id);

        if game.level <= level_config.min_round_level_before_activate.into() {
            println!("dale 1");
            return GameSubState::OBSTACLE;
        }

        if last_active_level.level != 0 && game.level
            - last_active_level.level.into() <= level_config.level_cooldown.try_into().unwrap() {
            println!("dale 2");
            return GameSubState::OBSTACLE;
        }

        let mut randomizer = RandomImpl::new(world);
        let random = randomizer.between::<u16>(0, 100);
        if random <= last_active_level.current_probability {
            println!("dale 3");
            last_active_level.level = game.level.try_into().unwrap();
            last_active_level.current_probability = level_config.initial_probability;
            LastBeastLevelStore::set(@last_active_level, world);

            GameSubState::BEAST
        } else {
            println!("dale 4");
            if last_active_level.current_probability + level_config.increment_by_round <= 100 {
                last_active_level.current_probability = last_active_level.current_probability
                    + level_config.increment_by_round;
            } else {
                last_active_level.current_probability = 100;
            }
            LastBeastLevelStore::set(@last_active_level, world);

            GameSubState::OBSTACLE
        }
    }
}

