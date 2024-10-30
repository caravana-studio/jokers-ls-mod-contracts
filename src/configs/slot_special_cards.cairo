#[derive(Copy, Drop, Serde)]
struct SlotSpecialCardsConfig {
    max_special_cards: u32,
    initial_price: u32
}

impl SlotSpecialCardsConfigDefault of Default<SlotSpecialCardsConfig> {
    fn default() -> SlotSpecialCardsConfig {
        SlotSpecialCardsConfig { max_special_cards: 7, initial_price: 300 }
    }
}
