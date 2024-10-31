use jokers_of_neon::store::{Store, StoreTrait};

fn PLAYER() -> starknet::ContractAddress {
    starknet::contract_address_const::<'PLAYER'>()
}

#[test]
#[available_gas(30000000000000000)]
fn test_complete_all_challenges() {// let (world, systems) = setup::spawn_game();
// let mut store = StoreTrait::new(world);
// let mut game = mock_game(ref store, PLAYER());

// Mock hand
// let hand_cards_ids = array![SIX_CLUBS_ID, SEVEN_CLUBS_ID, EIGHT_CLUBS_ID, NINE_HEARTS_ID, TEN_CLUBS_ID];
// mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

// set_contract_address(PLAYER());
// ChallengeImpl::play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
}
