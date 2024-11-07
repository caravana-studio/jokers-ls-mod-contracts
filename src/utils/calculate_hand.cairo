use alexandria_sorting::merge_sort::MergeSort;
use jokers_ls_mod::constants::specials::{SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID, SPECIAL_FLUSH_WITH_FOUR_CARDS_ID};
use jokers_ls_mod::models::data::card::{Card, Suit, Value};
use jokers_ls_mod::models::data::poker_hand::PokerHand;

fn calculate_hand(
    cards: @Array<Card>, ref current_special_cards_index: Felt252Dict<Nullable<u32>>
) -> (PokerHand, Felt252Dict<bool>) {
    let mut values_count: Felt252Dict<u8> = Default::default();
    let mut suits_count: Felt252Dict<u8> = Default::default();

    let mut counts: Array<u8> = array![];
    let cards_sorted = MergeSort::sort(cards.clone().span());

    let mut jokers = 0;
    let mut span_cards_sorted = cards_sorted.span();
    loop {
        match span_cards_sorted.pop_front() {
            Option::Some(card) => {
                if *card.suit != Suit::Joker {
                    let value_card = values_count.get((*card.value).into());
                    let suit_card = suits_count.get((*card.suit).into());

                    if value_card == 0 {
                        counts.append((*card.value).into());
                    }

                    values_count.insert((*card.value).into(), value_card + 1);
                    suits_count.insert((*card.suit).into(), suit_card + 1);
                } else {
                    jokers += 1;
                }
            },
            Option::None => { break; }
        };
    };

    // is_jokers_hand
    let len_cards: u8 = cards.len().try_into().unwrap();
    if len_cards == jokers {
        let mut hits: Felt252Dict<bool> = Default::default();
        if jokers == 5 {
            return (PokerHand::RoyalFlush, hits);
        } else if jokers == 4 {
            return (PokerHand::FourOfAKind, hits);
        } else if jokers == 3 {
            return (PokerHand::ThreeOfAKind, hits);
        } else if jokers == 2 {
            return (PokerHand::OnePair, hits);
        } else {
            return (PokerHand::HighCard, hits);
        }
    }

    let (len_flush, len_straight) = get_len_flush_and_straigh(ref current_special_cards_index);

    let (is_flush, suit_flush) = if suits_count.get(Suit::Clubs.into()) + jokers >= len_flush {
        (true, Suit::Clubs)
    } else if suits_count.get(Suit::Diamonds.into()) + jokers >= len_flush {
        (true, Suit::Diamonds)
    } else if suits_count.get(Suit::Hearts.into()) + jokers >= len_flush {
        (true, Suit::Hearts)
    } else if suits_count.get(Suit::Spades.into()) + jokers >= len_flush {
        (true, Suit::Spades)
    } else {
        (false, Suit::None)
    };

    let mut temp_jokers = jokers;
    let mut straight_values_map: Felt252Dict<bool> = Default::default();
    let is_straight = if cards_sorted.len() >= len_straight.into() {
        if jokers == 4 && cards_sorted.len() == 5 {
            let mut idx = 0;
            loop {
                if idx == cards_sorted.len() - 1 {
                    break true;
                }
                let value = *cards_sorted.at(idx).value;
                if value != Value::Joker {
                    straight_values_map.insert(value.into(), true);
                }
                idx += 1;
            };
            true
        } else {
            let mut idx = 0;
            let mut consecutive = 1;
            loop {
                if idx == cards_sorted.len() - 1 {
                    break true;
                }

                let actual_value = (*cards_sorted.at(idx).value).into();
                let next_value = (*cards_sorted.at(idx + 1).value).into();

                if next_value == Value::Joker.into() {
                    consecutive += 1;
                    straight_values_map.insert(actual_value.into(), true);
                } else if actual_value + 1 == next_value {
                    consecutive += 1;
                    straight_values_map.insert(actual_value.into(), true);
                    straight_values_map.insert(next_value.into(), true);
                } else {
                    if actual_value == next_value {
                        idx += 1;
                        continue;
                    }

                    let gap = next_value - actual_value - 1;
                    if gap <= temp_jokers {
                        consecutive += 1;
                        temp_jokers -= 1;
                        straight_values_map.insert(actual_value.into(), true);
                        straight_values_map.insert(next_value.into(), true);
                    }
                }
                idx += 1;
            };

            if values_count.get(Value::Ace.into()) >= 1 {
                let first_value = (*cards_sorted.at(0).value).into();
                let gap = first_value - 1;

                if gap <= temp_jokers {
                    consecutive += 1;
                    temp_jokers -= gap;
                    straight_values_map.insert(Value::Ace.into(), true);
                    straight_values_map.insert(first_value.into(), true);
                }
            }

            consecutive >= len_straight
        }
    } else {
        false
    };

    if is_royal_flush(is_flush, is_straight, jokers, cards, 5) {
        let mut hits: Felt252Dict<bool> = Default::default();
        let mut idx = 0;
        loop {
            if idx == cards.len() {
                break;
            }
            if straight_values_map.get((*cards.at(idx)).value.into()) {
                hits.insert(idx.into(), true)
            }
            idx += 1;
        };
        return (PokerHand::RoyalFlush, hits);
    }

    if is_flush && is_straight {
        let mut hits: Felt252Dict<bool> = Default::default();
        let mut idx = 0;
        loop {
            if idx == cards.len() {
                break;
            }
            if straight_values_map.get((*cards.at(idx)).value.into()) {
                hits.insert(idx.into(), true)
            }
            idx += 1;
        };
        return (PokerHand::StraightFlush, hits);
    }

    let (five_of_a_kind, _) = check_same_kind(jokers, @counts, ref values_count, PokerHand::FiveOfAKind);
    if five_of_a_kind {
        let mut hits: Felt252Dict<bool> = Default::default();
        hits.insert(0, true);
        hits.insert(1, true);
        hits.insert(2, true);
        hits.insert(3, true);
        hits.insert(4, true);
        return (PokerHand::FiveOfAKind, hits);
    }

    let (four_of_a_kind, value) = check_same_kind(jokers, @counts, ref values_count, PokerHand::FourOfAKind);
    if four_of_a_kind {
        let mut hits: Felt252Dict<bool> = Default::default();
        let list_hits = get_idxs_by_value(cards, value);
        fill_hits(ref hits, cards, Suit::None, list_hits);
        return (PokerHand::FourOfAKind, hits);
    }

    if is_full_house(jokers, @counts, ref values_count) {
        let mut hits: Felt252Dict<bool> = Default::default();
        hits.insert(0, true);
        hits.insert(1, true);
        hits.insert(2, true);
        hits.insert(3, true);
        hits.insert(4, true);
        return (PokerHand::FullHouse, hits);
    }

    if is_straight {
        let mut hits: Felt252Dict<bool> = Default::default();
        let mut idx = 0;
        loop {
            if idx == cards.len() {
                break;
            }
            if straight_values_map.get((*cards.at(idx)).value.into()) {
                hits.insert(idx.into(), true)
            }
            idx += 1;
        };
        return (PokerHand::Straight, hits);
    }

    if is_flush {
        let mut hits: Felt252Dict<bool> = Default::default();
        fill_hits(ref hits, cards, suit_flush, array![]);
        return (PokerHand::Flush, hits);
    }

    let (three_of_a_kind, value) = check_same_kind(jokers, @counts, ref values_count, PokerHand::ThreeOfAKind);
    if three_of_a_kind {
        let mut hits: Felt252Dict<bool> = Default::default();
        let list_hits = get_idxs_by_value(cards, value);
        fill_hits(ref hits, cards, Suit::None, list_hits);
        return (PokerHand::ThreeOfAKind, hits);
    }

    let (two_pair, value_1, value_2) = is_two_pair(jokers, @counts, ref values_count);
    if two_pair {
        let mut hits: Felt252Dict<bool> = Default::default();
        let list_hits = get_idxs_by_value(cards, value_1);
        fill_hits(ref hits, cards, Suit::None, list_hits);
        let list_hits = get_idxs_by_value(cards, value_2);
        fill_hits(ref hits, cards, Suit::None, list_hits);
        return (PokerHand::TwoPair, hits);
    }

    let (one_pair, value) = check_same_kind(jokers, @counts, ref values_count, PokerHand::OnePair);
    if one_pair {
        let mut hits: Felt252Dict<bool> = Default::default();
        let list_hits = get_idxs_by_value(cards, value);
        fill_hits(ref hits, cards, Suit::None, list_hits);
        return (PokerHand::OnePair, hits);
    }

    let (_, high_card_idx) = get_high_card(cards);
    let mut hits: Felt252Dict<bool> = Default::default();
    hits.insert(high_card_idx.into(), true);
    (PokerHand::HighCard, hits)
}

fn fill_hits(ref hits: Felt252Dict<bool>, cards: @Array<Card>, suit: Suit, idx_hits: Array<u32>) {
    if suit != Suit::None {
        let mut idx = 0;
        loop {
            if idx == cards.len() {
                break;
            }
            let card = *cards.at(idx);
            if card.suit == suit {
                hits.insert(idx.into(), true);
            }
            idx += 1;
        }
    } else if idx_hits.len() > 0 {
        let mut idx = 0;
        loop {
            if idx == idx_hits.len() {
                break;
            }
            let idx_hit = *idx_hits.at(idx);
            hits.insert(idx_hit.into(), true);
            idx += 1;
        }
    }
}

fn is_royal_flush(is_flush: bool, is_straight: bool, jokers: u8, cards: @Array<Card>, len_straight: u8) -> bool {
    if !is_flush || !is_straight {
        return false;
    } else {
        let mut found_values = 0;
        let mut idx = 0;
        loop {
            if idx == cards.len() {
                break;
            }
            let card = *cards.at(idx);
            if card.value == Value::Ten
                || card.value == Value::Jack
                || card.value == Value::Queen
                || card.value == Value::King
                || card.value == Value::Ace {
                found_values += 1;
            }
            idx += 1;
        };
        found_values + jokers == len_straight
    }
}

fn get_idxs_by_value(cards: @Array<Card>, value: u8) -> Array<u32> {
    let mut ret = array![];
    let mut idx = 0;
    loop {
        if idx == cards.len() {
            break;
        }
        let card = *cards.at(idx);
        if card.value.into() == value {
            ret.append(idx);
        }
        idx += 1;
    };
    ret
}

fn get_len_flush_and_straigh(ref current_special_cards_index: Felt252Dict<Nullable<u32>>) -> (u8, u8) {
    let mut len_flush = 5;
    let mut len_straight = 5;

    if !(current_special_cards_index.get(SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID.into()).is_null()) {
        len_straight = 4;
    }
    if !(current_special_cards_index.get(SPECIAL_FLUSH_WITH_FOUR_CARDS_ID.into()).is_null()) {
        len_flush = 4;
    }
    (len_flush, len_straight)
}

fn get_high_card(cards: @Array<Card>) -> (u8, u32) {
    let mut high_card_value: u8 = (*cards.at(0)).value.into();
    let mut high_card_idx = 0;
    let mut idx = 1;
    loop {
        if cards.len() == idx {
            break;
        }
        let card = *cards.at(idx);
        if card.value.into() > high_card_value {
            high_card_value = card.value.into();
            high_card_idx = idx;
        }
        idx += 1;
    };
    (high_card_value, high_card_idx)
}

fn check_same_kind(
    jokers: u8, counts: @Array<u8>, ref values_count: Felt252Dict<u8>, poker_hand: PokerHand
) -> (bool, u8) {
    let equal_needed_cards = get_cards_needed_by_poker_hand(poker_hand);
    let mut ret = false;
    let mut max_value = 0;
    let mut idx = 0;
    loop {
        if counts.len() == idx {
            break;
        }
        let card_value = *counts.at(idx);
        let count = values_count.get(card_value.into());
        if count + jokers == equal_needed_cards {
            ret = true;
            if card_value > max_value {
                max_value = card_value;
            }
        }
        idx += 1;
    };
    (ret, max_value)
}

fn get_cards_needed_by_poker_hand(poker_hand: PokerHand) -> u8 {
    if poker_hand == PokerHand::FiveOfAKind {
        5
    } else if poker_hand == PokerHand::FourOfAKind {
        4
    } else if poker_hand == PokerHand::ThreeOfAKind {
        3
    } else if poker_hand == PokerHand::OnePair {
        2
    } else {
        panic!("pokerhand not supported")
    }
}

fn is_full_house(jokers: u8, counts: @Array<u8>, ref values_count: Felt252Dict<u8>) -> bool {
    let mut idx = 0;
    let mut pairs_count = 0;
    let mut is_three_of_a_kind = false;
    loop {
        if counts.len() == idx {
            break false;
        }
        let card_value = *counts.at(idx);
        let count = values_count.get(card_value.into());
        if count == 2 {
            pairs_count += 1;
        }
        if count == 3 {
            is_three_of_a_kind = true;
        }
        idx += 1;
    };
    (pairs_count == 1 && is_three_of_a_kind) || (pairs_count == 2 && jokers == 1)
}

fn is_two_pair(jokers: u8, counts: @Array<u8>, ref values_count: Felt252Dict<u8>) -> (bool, u8, u8) {
    let mut idx = 0;
    let mut pairs_count = 0;
    let mut value_1 = 0;
    let mut value_2 = 0;
    loop {
        if counts.len() == idx {
            break false;
        }
        let card_value = *counts.at(idx);
        let count = values_count.get(card_value.into());
        if count == 2 {
            if value_1 == 0 || value_1 == card_value {
                value_1 = card_value;
            } else {
                value_2 = card_value;
            }
            pairs_count += 1;
        }
        idx += 1;
    };
    (pairs_count == 2, value_1, value_2)
}
