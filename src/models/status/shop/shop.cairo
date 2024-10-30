use jokers_of_neon::models::data::poker_hand::PokerHand;

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct CardItem {
    #[key]
    game_id: u32,
    #[key]
    idx: u32,
    #[key]
    item_type: CardItemType,
    card_id: u32,
    cost: u32,
    purchased: bool,
    temporary: bool
}

#[derive(Serde, Copy, Drop, IntrospectPacked, PartialEq)]
enum CardItemType {
    None,
    Common,
    Modifier,
    Special
}

impl CardItemTypeIntou8 of Into<CardItemType, u8> {
    fn into(self: CardItemType) -> u8 {
        match self {
            CardItemType::None => 0,
            CardItemType::Common => 1,
            CardItemType::Modifier => 2,
            CardItemType::Special => 3
        }
    }
}

impl CardItemTypeIntofelt252 of Into<CardItemType, felt252> {
    fn into(self: CardItemType) -> felt252 {
        match self {
            CardItemType::None => 0,
            CardItemType::Common => 1,
            CardItemType::Modifier => 2,
            CardItemType::Special => 3
        }
    }
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct BlisterPackItem {
    #[key]
    game_id: u32,
    #[key]
    idx: u32,
    blister_pack_id: u32,
    cost: u32,
    purchased: bool,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct BlisterPackResult {
    #[key]
    game_id: u32,
    cards_picked: bool,
    cards: Span<u32>
}
