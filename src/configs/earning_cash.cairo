#[derive(Copy, Drop, Serde)]
struct EarningCashConfig {
    base: u32,
    config_hands_played: u32,
    config_remaining_discards: u32,
    config_extra_points: u32
}

impl EarningCashConfigDefault of Default<EarningCashConfig> {
    fn default() -> EarningCashConfig {
        EarningCashConfig { base: 5, config_hands_played: 1, config_remaining_discards: 1, config_extra_points: 1 }
    }
}
