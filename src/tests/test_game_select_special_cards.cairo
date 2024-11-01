mod test_select_special_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::specials::{
        SPECIAL_POINTS_FOR_FIGURES_ID, SPECIAL_HAND_THIEF_ID, SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID,
        SPECIAL_JOKER_BOOSTER_ID, SPECIAL_MULTI_FOR_DIAMOND_ID
    };
    use jokers_of_neon::models::status::game::game::{Game, GameState};
    use jokers_of_neon::models::status::shop::shop::BlisterPackResult;
    use jokers_of_neon::store::{Store, StoreTrait};
    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{mock_game};
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_select_special_cards() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        game.state = GameState::SELECT_SPECIAL_CARDS;
        store.set_game(game);

        // Mock BlisterPackResult
        let cards = array![
            SPECIAL_POINTS_FOR_FIGURES_ID,
            SPECIAL_HAND_THIEF_ID,
            SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID,
            SPECIAL_JOKER_BOOSTER_ID,
            SPECIAL_MULTI_FOR_DIAMOND_ID,
        ]; // 5 special
        store.set_blister_pack_result(BlisterPackResult { game_id: game.id, cards_picked: false, cards: cards.span() });

        set_contract_address(PLAYER());
        systems.game_system.select_special_cards(game.id, array![4]);

        let game_after = store.get_game(game.id);
        assert(game_after.state == GameState::SELECT_MODIFIER_CARDS, 'wrong GameState');

        // last special must be `SPECIAL_MULTI_FOR_DIAMOND`
        let SPECIAL_PICKED = store.get_current_special_cards(game.id, game_after.len_current_special_cards - 1);
        assert(SPECIAL_PICKED.effect_card_id == SPECIAL_MULTI_FOR_DIAMOND_ID, 'wrong special card');
    }
}
