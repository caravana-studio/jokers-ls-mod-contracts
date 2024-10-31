#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Challenge {
    #[key]
    game_id: u32,
    active_ids: Span<u32>,
}

#[derive(Copy, Drop, InstropectPacked, Serde)]
#[dojo::model]
struct ChallengePlayer {
    #[key]
    game_id: u32,
    discards: u8,
    plays: u8
}
