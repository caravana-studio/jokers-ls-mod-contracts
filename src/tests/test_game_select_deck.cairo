mod test_select_deck {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::card::{
        ACE_CLUBS_ID, ACE_DIAMONDS_ID, ACE_HEARTS_ID, ACE_SPADES_ID, JOKER_CARD, INVALID_CARD, OVERLORD_DECK,
        WARRIOR_DECK, WIZARD_DECK, traditional_cards_all
    };
    use jokers_of_neon::constants::modifiers::{POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID};
    use jokers_of_neon::models::data::game_deck::{GameDeck, GameDeckStore, DeckCard, DeckCardStore};
    use jokers_of_neon::models::status::game::game::{Game, GameState, GameSubState};
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
    fn test_overlord_deck() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.substate = GameSubState::DRAFT_DECK;
        store.set_game(game);

        set_contract_address(PLAYER());
        systems.game_system.select_deck(game.id, OVERLORD_DECK);

        let game_af = store.get_game(game.id);
        assert(game_af.player_hp == 100, 'wrong player hp');
        assert(game_af.current_player_hp == 100, 'wrong current hp');

        let game_deck = GameDeckStore::get(world, game.id);
        assert(game_deck.len == 58, 'wrong len_deck_cards');

        let card_54 = DeckCardStore::get(world, game.id, 54);
        assert(card_54.card_id == POINTS_MODIFIER_4_ID, 'wrong 55 common card');

        let card_55 = DeckCardStore::get(world, game.id, 55);
        assert(card_55.card_id == POINTS_MODIFIER_4_ID, 'wrong 56 common card');

        let card_56 = DeckCardStore::get(world, game.id, 56);
        assert(card_56.card_id == MULTI_MODIFIER_4_ID, 'wrong 57 common card');

        let card_57 = DeckCardStore::get(world, game.id, 57);
        assert(card_57.card_id == MULTI_MODIFIER_4_ID, 'wrong 58 common card');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_warrior_deck() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.substate = GameSubState::DRAFT_DECK;
        store.set_game(game);

        set_contract_address(PLAYER());
        systems.game_system.select_deck(game.id, WARRIOR_DECK);

        let game_af = store.get_game(game.id);
        assert(game_af.player_hp == 120, 'wrong player hp');
        assert(game_af.current_player_hp == 120, 'wrong current hp');

        let game_deck = GameDeckStore::get(world, game.id);
        assert(game_deck.len == 55, 'wrong len_deck_cards');

        let card_54 = DeckCardStore::get(world, game.id, 54);
        assert(card_54.card_id == MULTI_MODIFIER_4_ID, 'wrong 54 common card');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_wizard_deck() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.substate = GameSubState::DRAFT_DECK;
        store.set_game(game);

        set_contract_address(PLAYER());
        systems.game_system.select_deck(game.id, WIZARD_DECK);

        let game_af = store.get_game(game.id);
        assert(game_af.player_hp == 80, 'wrong player hp');
        assert(game_af.current_player_hp == 80, 'wrong current hp');

        let game_deck = GameDeckStore::get(world, game.id);
        assert(game_deck.len == 56, 'wrong len_deck_cards');

        let card_54 = DeckCardStore::get(world, game.id, 54);
        assert(card_54.card_id == JOKER_CARD, 'wrong 54 common card');

        let card_55 = DeckCardStore::get(world, game.id, 55);
        assert(card_55.card_id == JOKER_CARD, 'wrong 55 common card');
    }
}
