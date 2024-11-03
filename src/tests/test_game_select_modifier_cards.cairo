mod test_select_modifier_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::constants::modifiers::{
        POINTS_MODIFIER_1_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_1_ID, MULTI_MODIFIER_4_ID, SUIT_SPADES_MODIFIER_ID
    };
    use jokers_ls_mod::models::data::game_deck::{GameDeck, GameDeckStore, DeckCard, DeckCardStore};
    use jokers_ls_mod::models::status::game::game::{Game, GameState};
    use jokers_ls_mod::models::status::shop::shop::BlisterPackResult;
    use jokers_ls_mod::store::{Store, StoreTrait};
    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_ls_mod::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_ls_mod::tests::utils::{mock_game, mock_game_deck};
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_select_modifier_cards() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        game.state = GameState::SELECT_MODIFIER_CARDS;
        store.set_game(game);

        mock_game_deck(world, game.id);

        // Mock BlisterPackResult
        let cards = array![
            POINTS_MODIFIER_4_ID,
            POINTS_MODIFIER_1_ID,
            MULTI_MODIFIER_4_ID,
            MULTI_MODIFIER_1_ID,
            SUIT_SPADES_MODIFIER_ID,
        ]; // 5 modifiers
        store.set_blister_pack_result(BlisterPackResult { game_id: game.id, cards_picked: false, cards: cards.span() });

        let game_deck_before = GameDeckStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.select_modifier_cards(game.id, array![0, 1, 2, 3, 4]);

        let game_deck_after = GameDeckStore::get(world, game.id);
        assert(game_deck_after.len == game_deck_before.len + 5, 'wrong len_deck_cards');

        let blister_pack = store.get_blister_pack_result(game.id);
        assert(blister_pack.cards_picked == true, 'cards_picked should be true');

        let MODIFIER_PICKED_1 = DeckCardStore::get(world, game.id, game_deck_after.len - 5);
        assert(MODIFIER_PICKED_1.card_id == POINTS_MODIFIER_4_ID, 'wrong modifier card 1');

        let MODIFIER_PICKED_2 = DeckCardStore::get(world, game.id, game_deck_after.len - 4);
        assert(MODIFIER_PICKED_2.card_id == POINTS_MODIFIER_1_ID, 'wrong modifier card 2');

        let MODIFIER_PICKED_3 = DeckCardStore::get(world, game.id, game_deck_after.len - 3);
        assert(MODIFIER_PICKED_3.card_id == MULTI_MODIFIER_4_ID, 'wrong modifier card 3');

        let MODIFIER_PICKED_4 = DeckCardStore::get(world, game.id, game_deck_after.len - 2);
        assert(MODIFIER_PICKED_4.card_id == MULTI_MODIFIER_1_ID, 'wrong modifier card 4');

        let MODIFIER_PICKED_5 = DeckCardStore::get(world, game.id, game_deck_after.len - 1);
        assert(MODIFIER_PICKED_5.card_id == SUIT_SPADES_MODIFIER_ID, 'wrong modifier card 5');
    }
}
