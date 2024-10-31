mod store;

mod traits;

mod constants {
    mod card;
    mod effect;
    mod modifiers;
    mod packs;
    mod playhand;
    mod specials;
    mod two_pow;
}

mod models {
    mod data {
        mod beast;
        mod blister_pack;
        mod card;
        mod effect_card;
        mod events;
        mod game_deck;
        mod poker_hand;
    }
    mod status {
        mod game {
            mod game;
            mod rage;
        }
        mod round {
            mod beast;
            mod current_hand_card;
            mod deck_card;
        }
        mod shop {
            mod shop;
        }
    }
}

mod systems {
    mod game_system;
    mod poker_hand_system;
    mod rage_system;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_calculate_hand;
    // mod test_game_discard_effect_card;
    // mod test_game_discard_special_card;
    mod test_game_play_beast;
    mod test_game_select_deck;
    mod test_game_select_special_cards;
    mod utils;
}

mod utils {
    mod calculate_hand;
    mod constants;
    mod game;
    mod level;
    mod packs;
    mod rage;
    mod random;
    mod shop;
}

mod configs {
    mod earning_cash;
    mod rage;
    mod slot_special_cards;
}
