mod test_challenge {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::constants::{
        challenge::{CHALLENGE_STRAIGHT, CHALLENGE_CLUBS, CHALLENGE_HEARTS, CHALLENGE_TEN},
        card::{SIX_CLUBS_ID, SEVEN_CLUBS_ID, EIGHT_CLUBS_ID, NINE_HEARTS_ID, TEN_CLUBS_ID}
    };
    use jokers_ls_mod::models::data::challenge::{Challenge, ChallengeStore, ChallengePlayer, ChallengePlayerStore};

    use jokers_ls_mod::models::status::game::game::{Game, GameState, GameSubState, GameStore};
    use jokers_ls_mod::models::status::round::challenge::ChallengeImpl;
    use jokers_ls_mod::store::{Store, StoreTrait};
    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_ls_mod::tests::setup::{setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait};
    use jokers_ls_mod::tests::utils::{mock_current_hand_cards_ids, mock_game};

    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_complete_all_challenges() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::OBSTACLE;
        store.set_game(game);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, SEVEN_CLUBS_ID, EIGHT_CLUBS_ID, NINE_HEARTS_ID, TEN_CLUBS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        ChallengeStore::set(
            @Challenge {
                game_id: game.id,
                active_ids: array![
                    (CHALLENGE_STRAIGHT, false),
                    (CHALLENGE_CLUBS, false),
                    (CHALLENGE_HEARTS, false),
                    (CHALLENGE_TEN, false)
                ]
                    .span()
            },
            world
        );

        ChallengePlayerStore::set(@ChallengePlayer { game_id: game.id, discards: 5, plays: 5 }, world);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

        let mut challenge = ChallengeStore::get(world, game.id);
        assert(challenge.active_ids.len() == 4, 'wrong len');
        assert(ChallengeImpl::is_completed(world, game.id), 'challenges should be completed');
        loop {
            match challenge.active_ids.pop_front() {
                Option::Some(challenge) => {
                    let (_, completed) = *challenge;
                    assert(completed, 'challenge should be completed');
                },
                Option::None => { break; }
            }
        };
    }
}
