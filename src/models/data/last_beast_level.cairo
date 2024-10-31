#[derive(Copy, Drop, Serde)]
#[dojo::model]
#[dojo::event]
struct LastBeastLevel {
    #[key]
    game_id: u32,
    current_probability: u16,
    level: u8
}
