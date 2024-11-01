#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct GameModeBeast {
    #[key]
    game_id: u32,
    cost_discard: u8,
    cost_play: u8,
    energy_max_player: u8
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct Beast {
    #[key]
    game_id: u32,
    tier: u8,
    level: u8,
    health: u32,
    attack: u32
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct PlayerBeast {
    #[key]
    game_id: u32,
    energy: u8
}
