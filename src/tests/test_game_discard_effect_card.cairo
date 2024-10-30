mod test_discard_effect_card {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::card::KING_SPADES_ID;
    use jokers_of_neon::constants::modifiers::{POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID};
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeck, DeckCard};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};
    use jokers_of_neon::models::status::round::round::{Round};

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_round};
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_discard_effect_card() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        let round = mock_round(ref store, @game, 300);

        // Mock hand
        let hand_cards_ids = array![KING_SPADES_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let index = 1;

        set_contract_address(PLAYER());
        systems.game_system.discard_effect_card(game.id, index);

        let round_after = store.get_round(game.id);
        assert(round.discard == round_after.discard, 'wrong round discard');
    }
}

mod test_discard_effect_card_validations {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::card::JACK_CLUBS_ID;
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeck};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};
    use jokers_of_neon::models::status::round::round::{Round};

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_round};
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
        systems.game_system.discard_effect_card(NON_EXISTENT_GAME_ID, 1);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: caller not owner', 'ENTRYPOINT_FAILED'))]
    fn test_caller_not_owner() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        let ANYONE = starknet::contract_address_const::<'ANYONE'>();
        set_contract_address(ANYONE);

        systems.game_system.discard_effect_card(game.id, 1);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: invalid card element', 'ENTRYPOINT_FAILED'))]
    fn test_invalid_card_elem() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        set_contract_address(PLAYER());
        systems.game_system.discard_effect_card(game.id, 10000);
    }

    #[test]
    #[available_gas(30000000000000000)]
    #[should_panic(expected: ('Game: only effect cards', 'ENTRYPOINT_FAILED'))]
    fn test_invalid_only_effect_card() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        // Mock hand
        let hand_cards_ids = array![JACK_CLUBS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.discard_effect_card(game.id, 0);
    }
}
