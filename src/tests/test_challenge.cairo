mod test_challenge {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::{
        challenge::{CHALLENGE_STRAIGHT, CHALLENGE_CLUBS, CHALLENGE_HEARTS, CHALLENGE_TEN},
        card::{SIX_CLUBS_ID, SEVEN_CLUBS_ID, EIGHT_CLUBS_ID, NINE_HEARTS_ID, TEN_CLUBS_ID}
    };
    use jokers_of_neon::models::data::challenge::{Challenge, ChallengeStore, ChallengePlayer, ChallengePlayerStore};

    use jokers_of_neon::models::status::game::game::{Game, GameState, GameSubState, GameStore};
    use jokers_of_neon::models::status::round::challenge::ChallengeImpl;
    use jokers_of_neon::store::{Store, StoreTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{mock_current_hand_cards_ids, mock_game};

    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_complete_all_challenges() {
        let (world, _) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.substate = GameSubState::OBSTACLE;
        store.set_game(game);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, SEVEN_CLUBS_ID, EIGHT_CLUBS_ID, NINE_HEARTS_ID, TEN_CLUBS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        ChallengeStore::set(
            @Challenge {
                game_id: game.id,
                active_ids: array![CHALLENGE_STRAIGHT, CHALLENGE_CLUBS, CHALLENGE_HEARTS, CHALLENGE_TEN].span()
            },
            world
        );

        ChallengePlayerStore::set(@ChallengePlayer { game_id: game.id, discards: 5, plays: 5 }, world);

        set_contract_address(PLAYER());
        ChallengeImpl::play(world, game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
    }
}
