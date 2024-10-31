#[derive(Copy, Drop, Serde)]
struct LevelConfig {
    initial_probability: u16,
    increment_by_round: u16,
    min_round_level_before_activate: u8,
    level_cooldown: u8
}

impl LevelConfigDefault of Default<LevelConfig> {
    fn default() -> LevelConfig {
        LevelConfig {
            initial_probability: 35, increment_by_round: 15, min_round_level_before_activate: 3, level_cooldown: 2
        }
    }
}
