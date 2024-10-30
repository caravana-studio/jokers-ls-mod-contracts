use jokers_of_neon::models::data::poker_hand::PokerHand;

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct Shop {
    #[key]
    game_id: u32,
    reroll_cost: u32,
    reroll_executed: bool,
    len_item_common_cards: u32,
    len_item_modifier_cards: u32,
    len_item_special_cards: u32,
    len_item_poker_hands: u32,
    len_item_blister_pack: u32,
}

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
struct PokerHandItem {
    #[key]
    game_id: u32,
    #[key]
    idx: u32,
    poker_hand: PokerHand,
    level: u8,
    cost: u32,
    purchased: bool,
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

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct SlotSpecialCardsItem {
    #[key]
    game_id: u32,
    cost: u32,
    purchased: bool,
}

impl DefaultShop of Default<Shop> {
    fn default() -> Shop {
        Shop {
            game_id: 1,
            reroll_cost: 100,
            reroll_executed: false,
            len_item_common_cards: 5,
            len_item_modifier_cards: 4,
            len_item_special_cards: 3,
            len_item_poker_hands: 3,
            len_item_blister_pack: 2,
        }
    }
}
