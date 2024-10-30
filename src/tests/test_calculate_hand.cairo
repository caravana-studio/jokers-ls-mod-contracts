use core::nullable::NullableTrait;
use jokers_of_neon::constants::specials::{SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID, SPECIAL_FLUSH_WITH_FOUR_CARDS_ID};
use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value};
use jokers_of_neon::models::data::poker_hand::PokerHand;
use jokers_of_neon::tests::setup;
use jokers_of_neon::utils::calculate_hand::calculate_hand;

#[test]
#[available_gas(300000000000)]
fn test_royal_flush() {
    let hand = array![
        CardTrait::new(Value::Ten, Suit::Hearts, 0),
        CardTrait::new(Value::Jack, Suit::Hearts, 0),
        CardTrait::new(Value::Queen, Suit::Hearts, 0),
        CardTrait::new(Value::King, Suit::Hearts, 0),
        CardTrait::new(Value::Ace, Suit::Hearts, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::RoyalFlush, 'error royal flush');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_straight_flush() {
    let hand = array![
        CardTrait::new(Value::Six, Suit::Clubs, 0),
        CardTrait::new(Value::Seven, Suit::Clubs, 0),
        CardTrait::new(Value::Eight, Suit::Clubs, 0),
        CardTrait::new(Value::Nine, Suit::Clubs, 0),
        CardTrait::new(Value::Ten, Suit::Clubs, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::StraightFlush, 'error straight flush');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_four_of_a_kind() {
    let hand = array![
        CardTrait::new(Value::Queen, Suit::Hearts, 0),
        CardTrait::new(Value::Queen, Suit::Clubs, 0),
        CardTrait::new(Value::Queen, Suit::Diamonds, 0),
        CardTrait::new(Value::Queen, Suit::Spades, 0),
        CardTrait::new(Value::Two, Suit::Spades, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::FourOfAKind, 'error four of a kind');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(!hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_five_of_a_kind() {
    let hand = array![
        CardTrait::new(Value::Queen, Suit::Hearts, 0),
        CardTrait::new(Value::Queen, Suit::Clubs, 0),
        CardTrait::new(Value::Queen, Suit::Diamonds, 0),
        CardTrait::new(Value::Queen, Suit::Spades, 0),
        CardTrait::new(Value::Queen, Suit::Spades, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::FiveOfAKind, 'error five of a kind');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_straight_happy_path() {
    let hand = array![
        CardTrait::new(Value::Three, Suit::Hearts, 0),
        CardTrait::new(Value::Four, Suit::Spades, 0),
        CardTrait::new(Value::Five, Suit::Diamonds, 0),
        CardTrait::new(Value::Six, Suit::Clubs, 0),
        CardTrait::new(Value::Seven, Suit::Hearts, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Straight, 'error straight');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_straight_with_ace() {
    let hand = array![
        CardTrait::new(Value::Ten, Suit::Hearts, 0),
        CardTrait::new(Value::Jack, Suit::Spades, 0),
        CardTrait::new(Value::Queen, Suit::Diamonds, 0),
        CardTrait::new(Value::King, Suit::Clubs, 0),
        CardTrait::new(Value::Ace, Suit::Hearts, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Straight, 'error straight with ace');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_high_card_with_ace() {
    let hand = array![
        CardTrait::new(Value::King, Suit::Hearts, 0),
        CardTrait::new(Value::Jack, Suit::Spades, 0),
        CardTrait::new(Value::Ace, Suit::Hearts, 0),
        CardTrait::new(Value::Two, Suit::Diamonds, 0),
        CardTrait::new(Value::Ten, Suit::Clubs, 0),
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::HighCard, 'error straight with ace');
    assert(!hits.get(0), 'error hit posicion 0');
    assert(!hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(!hits.get(3), 'error hit posicion 3');
    assert(!hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_easy_straight_first_cards() {
    let hand = array![
        CardTrait::new(Value::Three, Suit::Hearts, 0),
        CardTrait::new(Value::Four, Suit::Spades, 0),
        CardTrait::new(Value::Five, Suit::Diamonds, 0),
        CardTrait::new(Value::Six, Suit::Clubs, 0),
        CardTrait::new(Value::Nine, Suit::Hearts, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    current_special_cards_index
        .insert(SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Straight, 'error straight');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(!hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_easy_straight_last_cards() {
    let hand = array![
        CardTrait::new(Value::Two, Suit::Hearts, 0),
        CardTrait::new(Value::Four, Suit::Spades, 0),
        CardTrait::new(Value::Five, Suit::Diamonds, 0),
        CardTrait::new(Value::Six, Suit::Clubs, 0),
        CardTrait::new(Value::Seven, Suit::Hearts, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    current_special_cards_index
        .insert(SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Straight, 'error straight');
    assert(!hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_full_house() {
    let hand = array![
        CardTrait::new(Value::Nine, Suit::Hearts, 0),
        CardTrait::new(Value::Nine, Suit::Clubs, 0),
        CardTrait::new(Value::Nine, Suit::Diamonds, 0),
        CardTrait::new(Value::King, Suit::Spades, 0),
        CardTrait::new(Value::King, Suit::Diamonds, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::FullHouse, 'error full house');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_flush() {
    let hand = array![
        CardTrait::new(Value::Two, Suit::Diamonds, 0),
        CardTrait::new(Value::Five, Suit::Diamonds, 0),
        CardTrait::new(Value::Seven, Suit::Diamonds, 0),
        CardTrait::new(Value::Jack, Suit::Diamonds, 0),
        CardTrait::new(Value::King, Suit::Diamonds, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Flush, 'error flush');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_easy_flush() {
    let hand = array![
        CardTrait::new(Value::Two, Suit::Diamonds, 0),
        CardTrait::new(Value::Seven, Suit::Diamonds, 0),
        CardTrait::new(Value::Five, Suit::Clubs, 0),
        CardTrait::new(Value::Jack, Suit::Diamonds, 0),
        CardTrait::new(Value::King, Suit::Diamonds, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    current_special_cards_index.insert(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Flush, 'error flush');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(!hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
    assert(hits.get(4), 'error hit posicion 4');
}

#[test]
#[available_gas(300000000000)]
fn test_easy_flush_case_2() {
    let hand = array![
        CardTrait::new(Value::Two, Suit::Clubs, 0),
        CardTrait::new(Value::Five, Suit::Clubs, 0),
        CardTrait::new(Value::Jack, Suit::Clubs, 0),
        CardTrait::new(Value::Queen, Suit::Clubs, 0),
        CardTrait::new(Value::Ace, Suit::Spades, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    current_special_cards_index.insert(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::Flush, 'error flush');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
}

#[test]
#[available_gas(300000000000)]
fn test_three_of_a_kind() {
    let hand = array![
        CardTrait::new(Value::Three, Suit::Clubs, 0),
        CardTrait::new(Value::Three, Suit::Diamonds, 0),
        CardTrait::new(Value::Three, Suit::Hearts, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::ThreeOfAKind, 'error three of a kind');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
}

#[test]
fn test_two_pair() {
    let hand = array![
        CardTrait::new(Value::Four, Suit::Hearts, 0),
        CardTrait::new(Value::Four, Suit::Spades, 0),
        CardTrait::new(Value::Eight, Suit::Clubs, 0),
        CardTrait::new(Value::Eight, Suit::Diamonds, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::TwoPair, 'error two pair');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
    assert(hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
}

#[test]
#[available_gas(300000000000)]
fn test_one_pair() {
    let hand = array![CardTrait::new(Value::Two, Suit::Clubs, 0), CardTrait::new(Value::Two, Suit::Diamonds, 0)];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::OnePair, 'error one pair');
    assert(hits.get(0), 'error hit posicion 0');
    assert(hits.get(1), 'error hit posicion 1');
}

#[test]
#[available_gas(300000000000)]
fn test_high_card() {
    let hand = array![
        CardTrait::new(Value::Two, Suit::Clubs, 0),
        CardTrait::new(Value::Five, Suit::Hearts, 0),
        CardTrait::new(Value::Seven, Suit::Spades, 0),
        CardTrait::new(Value::Jack, Suit::Diamonds, 0)
    ];

    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
    assert(result == PokerHand::HighCard, 'error high card');
    assert(!hits.get(0), 'error hit posicion 0');
    assert(!hits.get(1), 'error hit posicion 1');
    assert(!hits.get(2), 'error hit posicion 2');
    assert(hits.get(3), 'error hit posicion 3');
}

mod jokers {
    use jokers_of_neon::constants::specials::{SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID, SPECIAL_FLUSH_WITH_FOUR_CARDS_ID};
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::tests::setup;
    use jokers_of_neon::utils::calculate_hand::calculate_hand;
    use jokers_of_neon::utils::constants::{JOKER_CARD, NEON_JOKER_CARD};

    fn JOKER() -> Card {
        Card { id: JOKER_CARD, suit: Suit::Joker, value: Value::Joker, points: 100, multi_add: 1 }
    }

    fn NEON_JOKER() -> Card {
        Card { id: JOKER_CARD, suit: Suit::Joker, value: Value::Joker, points: 100, multi_add: 1 }
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_five_jokers() {
        let hand = array![JOKER(), JOKER(), JOKER(), JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::RoyalFlush, 'error pokerhand');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_four_jokers() {
        let hand = array![JOKER(), JOKER(), JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FourOfAKind, 'error pokerhand');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_three_jokers() {
        let hand = array![JOKER(), JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::ThreeOfAKind, 'error pokerhand');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_two_jokers() {
        let hand = array![JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::OnePair, 'error pokerhand');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_one_joker() {
        let hand = array![JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::HighCard, 'error pokerhand');
    }

    // RoyalFlush
    #[test]
    #[available_gas(300000000000)]
    fn test_one_card_and_four_jokers_royal_flush() {
        let hand = array![JOKER(), JOKER(), CardTrait::new(Value::Queen, Suit::Hearts, 0), JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::RoyalFlush, 'error pokerhand');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_two_cards_and_three_jokers_royal_flush() {
        let hand = array![
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Ace, Suit::Hearts, 0),
            CardTrait::new(Value::Ten, Suit::Hearts, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::RoyalFlush, 'error pokerhand');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_three_cards_and_two_jokers_royal_flush() {
        let hand = array![
            JOKER(),
            CardTrait::new(Value::Ten, Suit::Hearts, 0),
            CardTrait::new(Value::Jack, Suit::Hearts, 0),
            CardTrait::new(Value::King, Suit::Hearts, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::RoyalFlush, 'error pokerhand');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_four_cards_and_one_joker_royal_flush() {
        let hand = array![
            JOKER(),
            CardTrait::new(Value::Ace, Suit::Hearts, 0),
            CardTrait::new(Value::Jack, Suit::Hearts, 0),
            CardTrait::new(Value::Queen, Suit::Hearts, 0),
            CardTrait::new(Value::King, Suit::Hearts, 0),
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::RoyalFlush, 'error pokerhand');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    // StraightFlush
    #[test]
    #[available_gas(300000000000)]
    fn test_one_card_and_four_jokers() {
        let hand = array![JOKER(), JOKER(), CardTrait::new(Value::Four, Suit::Hearts, 0), JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::StraightFlush, 'error pokerhand');
        assert(hits.get(2), 'error hit posicion 2');
    }

    // Five
    #[test]
    #[available_gas(300000000000)]
    fn test_two_cards_and_three_jokers() {
        let hand = array![
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FiveOfAKind, 'error pokerhand');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_three_cards_and_two_jokers() {
        let hand = array![
            JOKER(),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FiveOfAKind, 'error pokerhand');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_four_cards_and_one_joker() {
        let hand = array![
            JOKER(),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FiveOfAKind, 'error pokerhand');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    // Four
    #[test]
    #[available_gas(300000000000)]
    fn test_one_card_and_three_jokers() {
        let hand = array![JOKER(), JOKER(), JOKER(), CardTrait::new(Value::Four, Suit::Hearts, 0)];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FourOfAKind, 'error pokerhand');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_two_cards_and_two_jokers() {
        let hand = array![
            JOKER(), JOKER(), CardTrait::new(Value::Four, Suit::Hearts, 0), CardTrait::new(Value::Four, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FourOfAKind, 'error pokerhand');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_three_cards_and_one_jokers() {
        let hand = array![
            JOKER(),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FourOfAKind, 'error pokerhand');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    // Full House
    #[test]
    #[available_gas(300000000000)]
    fn test_full_house_with_one_joker() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Seven, Suit::Clubs, 0),
            CardTrait::new(Value::Seven, Suit::Diamonds, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FullHouse, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    // Straight
    #[test]
    #[available_gas(300000000000)]
    fn test_straight_gap_1_and_two_jokers() {
        let hand = array![
            CardTrait::new(Value::Five, Suit::Hearts, 0),
            CardTrait::new(Value::Three, Suit::Clubs, 0),
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Seven, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low() {
        let hand = array![
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            CardTrait::new(Value::Two, Suit::Hearts, 0),
            CardTrait::new(Value::Three, Suit::Diamonds, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Five, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low_one_gap() {
        let hand = array![
            CardTrait::new(Value::Two, Suit::Diamonds, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            JOKER(),
            CardTrait::new(Value::Five, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_shouldnt_work() {
        let hand = array![
            CardTrait::new(Value::Nine, Suit::Diamonds, 0),
            CardTrait::new(Value::Jack, Suit::Hearts, 0),
            CardTrait::new(Value::Queen, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::OnePair, 'error pokerhand');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_case_2_shouldnt_work() {
        let hand = array![
            CardTrait::new(Value::Nine, Suit::Diamonds, 0),
            CardTrait::new(Value::Ten, Suit::Hearts, 0),
            CardTrait::new(Value::King, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::OnePair, 'error pokerhand');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_case_3_shouldnt_work() {
        let hand = array![
            CardTrait::new(Value::Eight, Suit::Diamonds, 0),
            CardTrait::new(Value::Nine, Suit::Hearts, 0),
            CardTrait::new(Value::King, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::OnePair, 'error pokerhand');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_low_straight_one_gap_with_easy_straight() {
        let hand = array![
            CardTrait::new(Value::Three, Suit::Spades, 0),
            CardTrait::new(Value::Four, Suit::Diamonds, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        current_special_cards_index
            .insert(SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error straight');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_low_straight_two_gaps_with_easy_straight() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Spades, 0), CardTrait::new(Value::Ace, Suit::Hearts, 0), JOKER(), JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        current_special_cards_index
            .insert(SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error straight');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_royal_flush_shouldnt_work() {
        let hand = array![
            CardTrait::new(Value::Jack, Suit::Hearts, 0),
            CardTrait::new(Value::Queen, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0),
            JOKER(),
            CardTrait::new(Value::Three, Suit::Clubs, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        current_special_cards_index
            .insert(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Flush, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_royal_flush_shouldnt_work_case_2() {
        let hand = array![
            CardTrait::new(Value::Ace, Suit::Clubs, 0),
            CardTrait::new(Value::Ace, Suit::Clubs, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0),
            JOKER(),
            JOKER(),
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        current_special_cards_index
            .insert(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::FiveOfAKind, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_royal_flush_shouldnt_work_case_3() {
        let hand = array![
            CardTrait::new(Value::Queen, Suit::Diamonds, 0),
            CardTrait::new(Value::King, Suit::Diamonds, 0),
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            JOKER(),
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        current_special_cards_index
            .insert(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Flush, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_flush_with_easy_flush_shouldnt_work() {
        let hand = array![
            CardTrait::new(Value::Eight, Suit::Diamonds, 0),
            CardTrait::new(Value::Nine, Suit::Diamonds, 0),
            CardTrait::new(Value::Ten, Suit::Clubs, 0),
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        current_special_cards_index
            .insert(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into(), NullableTrait::new(Zeroable::zero()));
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Flush, 'error flush');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(!hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low_one_gap_end() {
        let hand = array![
            CardTrait::new(Value::Two, Suit::Diamonds, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            JOKER(),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low_two_gaps() {
        let hand = array![
            CardTrait::new(Value::Two, Suit::Diamonds, 0),
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Five, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low_two_gaps_end() {
        let hand = array![
            CardTrait::new(Value::Two, Suit::Diamonds, 0),
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            CardTrait::new(Value::Ace, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_gap_2_and_two_jokers() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Diamonds, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Seven, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low_gap_2_and_two_jokers() {
        let hand = array![
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            JOKER(),
            JOKER(),
            CardTrait::new(Value::Five, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_low_gap_1_and_a_joker() {
        let hand = array![
            CardTrait::new(Value::Ace, Suit::Diamonds, 0),
            CardTrait::new(Value::Three, Suit::Clubs, 0),
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            JOKER(),
            CardTrait::new(Value::Five, Suit::Hearts, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(1), 'error hit posicion 2');
        assert(hits.get(4), 'error hit posicion 4');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_and_one_joker_in_the_end() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            CardTrait::new(Value::Six, Suit::Hearts, 0),
            CardTrait::new(Value::Five, Suit::Diamonds, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_and_two_jokers_in_the_end() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            CardTrait::new(Value::Five, Suit::Diamonds, 0),
            JOKER(),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_straight_gap_1_and_one_joker() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            JOKER(),
            CardTrait::new(Value::Six, Suit::Hearts, 0),
            CardTrait::new(Value::Seven, Suit::Diamonds, 0)
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Straight, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(3), 'error hit posicion 3');
        assert(hits.get(4), 'error hit posicion 4');
    }

    // Flush
    #[test]
    #[available_gas(300000000000)]
    fn test_flush_three_cards_and_two_jokers() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Seven, Suit::Hearts, 0),
            CardTrait::new(Value::Queen, Suit::Hearts, 0),
            JOKER(),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Flush, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_flush_one_jokers_almost_straight() {
        let hand = array![
            CardTrait::new(Value::Nine, Suit::Clubs, 0),
            CardTrait::new(Value::Jack, Suit::Clubs, 0),
            CardTrait::new(Value::Queen, Suit::Clubs, 0),
            CardTrait::new(Value::Ace, Suit::Clubs, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Flush, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_flush_four_cards_and_one_jokers() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Seven, Suit::Hearts, 0),
            CardTrait::new(Value::Queen, Suit::Hearts, 0),
            CardTrait::new(Value::Three, Suit::Hearts, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::Flush, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
        assert(hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    // Three
    #[test]
    #[available_gas(300000000000)]
    fn test_three_of_the_kind_one_pair_and_one_joker() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0), CardTrait::new(Value::Four, Suit::Clubs, 0), JOKER(),
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::ThreeOfAKind, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
        assert(hits.get(1), 'error hit posicion 1');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_three_of_the_kind_one_card_and_two_jokers() {
        let hand = array![CardTrait::new(Value::Four, Suit::Hearts, 0), JOKER(), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::ThreeOfAKind, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_three_of_the_kind_three_cards_and_two_jokers() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Two, Suit::Diamonds, 0),
            JOKER(),
            CardTrait::new(Value::Queen, Suit::Clubs, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::ThreeOfAKind, 'error pokerhand');
        assert(!hits.get(0), 'error hit posicion 0');
        assert(!hits.get(1), 'error hit posicion 1');
        assert(hits.get(3), 'error hit posicion 3');
    }

    // Pair
    #[test]
    #[available_gas(300000000000)]
    fn test_pair_one_card_one_joker() {
        let hand = array![CardTrait::new(Value::Four, Suit::Hearts, 0), JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::OnePair, 'error pokerhand');
        assert(hits.get(0), 'error hit posicion 0');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_pair_four_cards_and_one_joker() {
        let hand = array![
            CardTrait::new(Value::Four, Suit::Hearts, 0),
            CardTrait::new(Value::Seven, Suit::Diamonds, 0),
            CardTrait::new(Value::Two, Suit::Diamonds, 0),
            CardTrait::new(Value::Queen, Suit::Clubs, 0),
            JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, mut hits) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::OnePair, 'error pokerhand');
        assert(!hits.get(0), 'error hit posicion 0');
        assert(!hits.get(1), 'error hit posicion 1');
        assert(!hits.get(2), 'error hit posicion 2');
        assert(hits.get(3), 'error hit posicion 3');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_issue_royal_flush_four_jokers_one_card() {
        let hand = array![CardTrait::new(Value::Seven, Suit::Diamonds, 0), JOKER(), JOKER(), JOKER(), NEON_JOKER()];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::StraightFlush, 'error pokerhand');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_issue_straight_flush_four_card_and_two_jokers() {
        let hand = array![
            CardTrait::new(Value::Jack, Suit::Diamonds, 0),
            CardTrait::new(Value::Queen, Suit::Diamonds, 0),
            CardTrait::new(Value::King, Suit::Diamonds, 0),
            JOKER(),
            NEON_JOKER()
        ];

        let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
        let (result, _) = calculate_hand(@hand, ref current_special_cards_index);
        assert(result == PokerHand::RoyalFlush, 'error pokerhand');
    }
}
