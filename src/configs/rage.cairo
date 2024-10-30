/// * `id` - A unique identifier for the configuration.
/// * `initial_probability` - The starting probability (0-100) of activating a rage round.
/// * `increment_by_round` - The amount by which the probability increases each round if not activated.
/// * `rages_quantity_for_x_round` - The base quantity used to calculate the number of active rages
///                                   per round.
/// * `max_active_rages` - The maximum number of rages that can be active simultaneously.
/// * `min_round_level_before_activate` - The minimum round level required before rage rounds
///                                       can be activated, preventing early activation.
#[derive(Copy, Drop, Serde)]
struct RageRoundConfig {
    initial_probability: u16,
    increment_by_round: u16,
    rages_quantity_for_x_round: u8,
    max_active_rages: u8,
    min_round_level_before_activate: u8,
    level_cooldown: u8
}

impl RageRoundConfigDefault of Default<RageRoundConfig> {
    fn default() -> RageRoundConfig {
        RageRoundConfig {
            initial_probability: 35,
            increment_by_round: 15,
            rages_quantity_for_x_round: 6,
            max_active_rages: 4,
            min_round_level_before_activate: 3,
            level_cooldown: 1
        }
    }
}
