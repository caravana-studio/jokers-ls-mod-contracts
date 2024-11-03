mod test_discard_special_card {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::constants::specials::{
        SPECIAL_MULTI_FOR_HEART_ID, SPECIAL_INCREASE_LEVEL_PAIR_ID, SPECIAL_JOKER_BOOSTER_ID, SPECIAL_MULTI_ACES_ID,
        SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
    };
    use jokers_ls_mod::models::status::game::game::Game;
    use jokers_ls_mod::store::{Store, StoreTrait};

    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_ls_mod::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_ls_mod::tests::utils::{mock_game, mock_special_cards};
    use jokers_ls_mod::utils::shop::get_current_special_cards;
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_discard_special_card() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Mock Special cards
        let special_cards = array![
            SPECIAL_MULTI_FOR_HEART_ID,
            SPECIAL_INCREASE_LEVEL_PAIR_ID,
            SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
            SPECIAL_JOKER_BOOSTER_ID,
            SPECIAL_MULTI_ACES_ID
        ];
        mock_special_cards(ref store, ref game, special_cards);

        set_contract_address(PLAYER());
        systems.game_system.discard_special_card(game.id, special_card_index: 2);

        let game_after: Game = store.get_game(game.id);
        let special_cards_after = get_current_special_cards(ref store, @game_after);
        let special_cards_expected = array![
            SPECIAL_MULTI_FOR_HEART_ID, SPECIAL_INCREASE_LEVEL_PAIR_ID, SPECIAL_JOKER_BOOSTER_ID, SPECIAL_MULTI_ACES_ID
        ];

        assert(special_cards_after == special_cards_expected, 'wrong special cards after');
        assert(game_after.len_current_special_cards == special_cards_expected.len(), 'wrong len special cards');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_discard_first_special_card() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Mock Special cards
        let special_cards = array![
            SPECIAL_MULTI_FOR_HEART_ID,
            SPECIAL_INCREASE_LEVEL_PAIR_ID,
            SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
            SPECIAL_JOKER_BOOSTER_ID,
            SPECIAL_MULTI_ACES_ID
        ];
        mock_special_cards(ref store, ref game, special_cards);

        set_contract_address(PLAYER());
        systems.game_system.discard_special_card(game.id, special_card_index: 0);

        let game_after: Game = store.get_game(game.id);
        let special_cards_after = get_current_special_cards(ref store, @game_after);
        let special_cards_expected = array![
            SPECIAL_INCREASE_LEVEL_PAIR_ID,
            SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
            SPECIAL_JOKER_BOOSTER_ID,
            SPECIAL_MULTI_ACES_ID
        ];

        assert(game_after.len_current_special_cards == special_cards_expected.len(), 'wrong len special cards');
        assert(special_cards_after == special_cards_expected, 'wrong special cards after');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_discard_last_special_card() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Mock Special cards
        let special_cards = array![
            SPECIAL_MULTI_FOR_HEART_ID,
            SPECIAL_INCREASE_LEVEL_PAIR_ID,
            SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
            SPECIAL_JOKER_BOOSTER_ID,
            SPECIAL_MULTI_ACES_ID
        ];
        mock_special_cards(ref store, ref game, special_cards);

        set_contract_address(PLAYER());
        systems.game_system.discard_special_card(game.id, special_card_index: 4);

        let game_after: Game = store.get_game(game.id);
        let special_cards_after = get_current_special_cards(ref store, @game_after);
        let special_cards_expected = array![
            SPECIAL_MULTI_FOR_HEART_ID,
            SPECIAL_INCREASE_LEVEL_PAIR_ID,
            SPECIAL_FLUSH_WITH_FOUR_CARDS_ID,
            SPECIAL_JOKER_BOOSTER_ID
        ];

        assert(game_after.len_current_special_cards == special_cards_expected.len(), 'wrong len special cards');
        assert(special_cards_after == special_cards_expected, 'wrong special cards after');
    }
}

mod test_discard_special_card_validations {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::store::{Store, StoreTrait};

    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};

    use jokers_ls_mod::tests::setup::{setup, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait};
    use jokers_ls_mod::tests::utils::mock_game;
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: game not found', 'ENTRYPOINT_FAILED'))]
    fn test_game_not_found() {
        let (_, systems) = setup::spawn_game();
        let NON_EXISTENT_GAME_ID = 1;
        systems.game_system.discard_special_card(NON_EXISTENT_GAME_ID, 0);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: caller not owner', 'ENTRYPOINT_FAILED'))]
    fn test_caller_not_owner() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        let ANYONE = starknet::contract_address_const::<'ANYONE'>();
        set_contract_address(ANYONE);

        systems.game_system.discard_special_card(game.id, 0);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: invalid card element', 'ENTRYPOINT_FAILED'))]
    fn test_invalid_card_elem() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        set_contract_address(PLAYER());
        systems.game_system.discard_special_card(game.id, 10000);
    }
}
