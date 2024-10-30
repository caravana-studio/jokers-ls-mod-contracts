#[dojo::interface]
trait IRageSystem {
    /// Calculates whether a rage round should be activated based on the current game state and
    /// random chance. If activated, it sets the active rages and resets the probability; otherwise,
    /// it increases the probability for the next round.
    ///
    /// # Arguments
    /// * `world` - A reference to the world dispatcher
    /// * `game_id` - The unique identifier of the game instance.
    ///
    /// # Returns
    /// * `bool` - Returns `true` if a rage round is activated, `false` otherwise.
    ///
    /// # Behavior
    /// 1. Retrieves the rage configuration and the current state of the rage round from their respective stores.
    /// 2. Generates a random number between 0 and 100 to determine if the rage round is activated.
    /// 3. If the random number is less than or equal to the current probability of the rage round:
    ///    - Retrieves the game data to determine the number of active rages.
    ///    - Calculates the quantity of active rages based on the current round and configuration limits.
    ///    - Sets random rage IDs for activation.
    ///    - Resets the probability of the rage round to its initial value.
    /// 4. If the random number is higher, it increases the probability for the next round, ensuring it
    ///    does not exceed 100.
    fn calculate(ref world: IWorldDispatcher, game_id: u32);
}

#[dojo::contract]
mod rage_system {
    use jokers_of_neon::models::status::{game::{game::GameStore, rage::RageRoundStore}, round::round::RoundStore};
    use jokers_of_neon::store::StoreTrait;
    use jokers_of_neon::utils::constants::rage_cards_all;
    use jokers_of_neon::utils::random::RandomImpl;
    use jokers_of_neon::utils::shop::generate_unique_random_values;

    #[abi(embed_v0)]
    impl RageImpl of super::IRageSystem<ContractState> {
        fn calculate(ref world: IWorldDispatcher, game_id: u32) {
            let mut store = StoreTrait::new(world);
            let rage_config = store.get_rage_config();
            let game = GameStore::get(world, game_id);
            let mut rage_round = RageRoundStore::get(world, game_id);

            if game.level <= rage_config.min_round_level_before_activate.into() {
                rage_round.set_is_active(world, false);
                return;
            }

            if rage_round.last_active_level != 0 && game.level
                - rage_round.last_active_level.into() <= rage_config.level_cooldown.try_into().unwrap() {
                rage_round.set_is_active(world, false);
                return;
            }

            if game.level >= 40 {
                rage_round.current_probability = 100;
            }

            let mut randomizer = RandomImpl::new(world);
            let random = randomizer.between::<u16>(0, 100);
            // Rage round its active
            if random <= rage_round.current_probability {
                // Get active rages quantity
                let quantity_division = game.level.try_into().unwrap() / rage_config.rages_quantity_for_x_round;
                let mut active_rages_quantity = if quantity_division >= rage_config.max_active_rages {
                    rage_config.max_active_rages
                } else {
                    if quantity_division == 0 {
                        1
                    } else {
                        quantity_division
                    }
                };
                let rages_ids = generate_unique_random_values(
                    world, active_rages_quantity.into(), rage_cards_all(), array![]
                )
                    .span();

                // Reset probability
                rage_round.active_rage_ids = (rages_ids).clone();
                rage_round.current_probability = rage_config.initial_probability;
                rage_round.last_active_level = game.level.try_into().unwrap();
                rage_round.is_active = true;
            } else {
                // Increment probability
                rage_round.is_active = false;
                if rage_round.current_probability + rage_config.increment_by_round <= 100 {
                    rage_round.current_probability = rage_round.current_probability + rage_config.increment_by_round;
                } else {
                    rage_round.current_probability = 100;
                }
            }

            RageRoundStore::set(@rage_round, world);
        }
    }
}
