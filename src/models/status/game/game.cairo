use starknet::ContractAddress;

#[derive(Serde, Copy, Drop, IntrospectPacked, PartialEq)]
enum GameSubState {
    BEAST,
    OBSTACLE,
    CREATE_LEVEL,
    CREATE_REWARD,
    REWARD_SPECIALS,
    REWARD_CARDS_PACK,
    DRAFT_MODIFIERS,
    DRAFT_SPECIALS,
    DRAFT_DECK,
    DRAFT_ADVENTURER,
    DRAFT_ADVENTURER_CARDS
}

#[derive(Serde, Copy, Drop, IntrospectPacked, PartialEq)]
enum GameState {
    IN_GAME,
    FINISHED
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
#[dojo::event]
struct Game {
    #[key]
    id: u32,
    owner: ContractAddress,
    player_name: felt252,
    player_hp: u32,
    current_player_hp: u32,
    max_hands: u8,
    max_discard: u8,
    max_jokers: u8,
    player_score: u32,
    level: u32,
    len_hand: u32,
    len_max_current_special_cards: u32,
    len_current_special_cards: u32,
    current_jokers: u8,
    state: GameState,
    substate: GameSubState,
    cash: u32
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct CurrentSpecialCards {
    #[key]
    game_id: u32,
    #[key]
    idx: u32,
    effect_card_id: u32,
    is_temporary: bool,
    remaining: u32
}

impl DefaultGame of Default<Game> {
    fn default() -> Game {
        Game {
            id: 1,
            owner: Zeroable::zero(),
            player_name: Zeroable::zero(),
            player_hp: 500,
            current_player_hp: 500,
            max_hands: 5,
            max_discard: 5,
            max_jokers: 5,
            player_score: 0,
            level: 1,
            len_hand: 8,
            len_max_current_special_cards: 5,
            len_current_special_cards: 0,
            current_jokers: 0,
            state: GameState::IN_GAME,
            substate: GameSubState::CREATE_LEVEL,
            cash: 0
        }
    }
}
