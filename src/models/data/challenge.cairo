#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct Challenge {
    #[key]
    game_id: u32,
    active_ids: Span<(u32, bool)>,
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::event]
#[dojo::model]
struct ChallengePlayer {
    #[key]
    game_id: u32,
    discards: u8,
    plays: u8
}
