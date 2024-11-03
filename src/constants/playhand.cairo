use jokers_ls_mod::models::data::poker_hand::{LevelPokerHand, PokerHand};

fn ROYAL_FLUSH(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::RoyalFlush, level: level, multi: 13 + level.into(), points: 95 + level.into() * 5
    }
}

fn STRAIGHT_FLUSH(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::StraightFlush, level: level, multi: 7 + level.into(), points: 95 + level.into() * 5
    }
}

fn FIVE_OF_A_KIND(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::FiveOfAKind, level: level, multi: 6 + level.into(), points: 70 + level.into() * 5
    }
}

fn FOUR_OF_A_KIND(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::FourOfAKind, level: level, multi: 6 + level.into(), points: 55 + level.into() * 5
    }
}

fn FULL_HOUSE(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::FullHouse, level: level, multi: 3 + level.into(), points: 35 + level.into() * 5
    }
}

fn FLUSH(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::Flush, level: level, multi: 3 + level.into(), points: 30 + level.into() * 5
    }
}

fn STRAIGHT(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::Straight, level: level, multi: 3 + level.into(), points: 35 + level.into() * 5
    }
}

fn THREE_OF_A_KIND(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::ThreeOfAKind, level: level, multi: 2 + level.into(), points: 25 + level.into() * 5
    }
}

fn TWO_PAIR(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::TwoPair, level: level, multi: 2 + level.into(), points: 15 + level.into() * 5
    }
}

fn ONE_PAIR(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::OnePair, level: level, multi: 1 + level.into(), points: 5 + level.into() * 5
    }
}

fn HIGH_CARD(level: u8) -> LevelPokerHand {
    LevelPokerHand {
        poker_hand: PokerHand::HighCard, level: level, multi: 0 + level.into(), points: 0 + level.into() * 5
    }
}

fn NONE() -> LevelPokerHand {
    LevelPokerHand { poker_hand: PokerHand::None, level: 0, multi: 0, points: 0 }
}
