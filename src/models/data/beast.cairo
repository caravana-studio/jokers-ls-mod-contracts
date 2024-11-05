#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct GameModeBeast {
    #[key]
    game_id: u32,
    cost_discard: u8,
    cost_play: u8,
    energy_max_player: u8
}

#[derive(Serde, Copy, Drop, IntrospectPacked, PartialEq)]
enum TypeBeast {
    LOOT_SURVIVOR,
    JOKERS_OF_NEON
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::event]
#[dojo::model]
struct Beast {
    #[key]
    game_id: u32,
    beast_id: u32,
    tier: u8,
    level: u8,
    health: u32,
    current_health: u32,
    attack: u32,
    type_beast: TypeBeast
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayerBeast {
    #[key]
    game_id: u32,
    energy: u8
}

#[derive(Copy, Drop, Serde)]
struct BeastStats {
    tier: u8,
    level: u8,
    beast_id: u8
}
