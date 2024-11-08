use jokers_ls_mod::models::data::card::Suit;
use jokers_ls_mod::models::data::poker_hand::PokerHand;
use jokers_ls_mod::models::status::shop::shop::CardItemType;
use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PokerHandEvent {
    #[key]
    player: ContractAddress,
    poker_hand: u8,
    multi: u32,
    points: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct CreateGameEvent {
    #[key]
    player: ContractAddress,
    game_id: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct CardScoreEvent {
    #[key]
    player: ContractAddress,
    index: u32,
    multi: u32,
    points: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayWinGameEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    level: u32,
    player_score: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct RoundScoreEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    player_score: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayGameOverEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct DetailEarnedEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    round_defeat: u32,
    level_bonus: u32,
    hands_left: u32,
    hands_left_cash: u32,
    discard_left: u32,
    discard_left_cash: u32,
    rage_card_defeated: u32,
    rage_card_defeated_cash: u32,
    total: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct SpecialModifierPointsEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    current_special_card_idx: u32,
    current_hand_card_idx: u32,
    points: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct SpecialModifierMultiEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    current_special_card_idx: u32,
    current_hand_card_idx: u32,
    multi: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct SpecialModifierSuitEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    current_special_card_idx: u32,
    current_hand_card_idx: u32,
    suit: Suit
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct SpecialPokerHandEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    current_special_card_idx: u32,
    multi: u32,
    points: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct SpecialGlobalEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    current_special_card_idx: u32,
    multi: u32,
    points: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct ModifierCardSuitEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    modifier_card_idx: u32,
    current_hand_card_idx: u32,
    suit: Suit
}

#[derive(Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct NeonPokerHandEvent {
    #[key]
    player: ContractAddress,
    game_id: u32,
    neon_cards_idx: Array<u32>,
    multi: u32,
    points: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayPokerHandEvent {
    #[key]
    game_id: u32,
    #[key]
    level: u32,
    #[key]
    count_hand: u8,
    poker_hand: PokerHand
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BuyCardEvent {
    #[key]
    game_id: u32,
    #[key]
    level: u32,
    #[key]
    idx: u32,
    #[key]
    item_type: CardItemType,
    card_id: u32,
    temporary: bool
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BuyPokerHandEvent {
    #[key]
    game_id: u32,
    #[key]
    level: u32,
    #[key]
    idx: u32,
    poker_hand: PokerHand,
    level_hand: u8
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BuyBlisterPackEvent {
    #[key]
    game_id: u32,
    #[key]
    level: u32,
    #[key]
    idx: u32,
    blister_pack_id: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BuyRerollEvent {
    #[key]
    game_id: u32,
    #[key]
    level: u32,
    reroll_cost: u32,
    reroll_executed: bool,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct SpecialCashEvent {
    #[key]
    player: ContractAddress,
    cash: u32,
    card_idx: u32,
    special_idx: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct ChallengeCompleted {
    #[key]
    player: ContractAddress,
    player_name: felt252,
    game_id: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct ItemChallengeCompleted {
    #[key]
    game_id: u32,
    challenge_id: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BeastAttack {
    #[key]
    player: ContractAddress,
    attack: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayerAttack {
    #[key]
    player: ContractAddress,
    attack: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayerHealed {
    #[key]
    game_id: u32,
    potion_heal: u32,
    current_hp: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct ObstacleAttack {
    #[key]
    player: ContractAddress,
    attack: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BeastIsMintable {
    #[key]
    player: ContractAddress,
    tier: u8,
    level: u8,
    beast_id: u8,
    is_mintable: bool
}
#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct BeastNFT {
    #[key]
    player: ContractAddress,
    tier: u8,
    level: u8,
    beast_id: u8,
    token_id: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct ObstacleHandScore {
    #[key]
    player: ContractAddress,
    hand_score: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
#[dojo::model]
struct PlayerScore {
    #[key]
    player: ContractAddress,
    player_name: felt252,
    player_score: u32,
    player_level: u32
}
