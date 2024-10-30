mod test_shop {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeck, DeckCard};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards, GameState};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};
    use jokers_of_neon::models::status::round::round::{Round};

    use jokers_of_neon::models::status::shop::shop::{Shop, CardItem, CardItemType, PokerHandItem};
    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};

    use jokers_of_neon::systems::shop_system::{shop_system, IShopSystemDispatcher, IShopSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{get_current_shop_common_card_items};

    use jokers_of_neon::tests::utils::{mock_game, mock_current_hand, mock_shop, mock_empty_shop};
    use jokers_of_neon::utils::shop::{item_in_array, get_current_special_cards};
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_reroll() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        let shop = mock_empty_shop(ref store, game.id);

        set_contract_address(PLAYER());
        systems.shop_system.reroll(game.id);

        let shop_after = store.get_shop(game.id);
        assert(shop_after.reroll_executed == true, 'wrong reroll executed');

        let game_after = store.get_game(game.id);
        assert(game_after.cash == game.cash - shop.reroll_cost, 'wrong game cash');

        let common_cards_after = get_current_shop_common_card_items(ref store, game.id);
        assert(common_cards_after.len().is_non_zero(), 'wrong common cards len');
    }
}

mod test_shop_buy_card_item {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::modifiers::{SUIT_HEARTS_MODIFIER_ID, MULTI_MODIFIER_1_ID};
    use jokers_of_neon::constants::specials::{SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_EXTRA_HELP_ID};
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore, DeckCardStore, DeckCard};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards, GameState};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};
    use jokers_of_neon::models::status::round::round::{Round};

    use jokers_of_neon::models::status::shop::shop::PokerHandItem;
    use jokers_of_neon::models::status::shop::shop::{
        Shop, CardItem, CardItemType, BlisterPackResult, SlotSpecialCardsItem
    };

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};

    use jokers_of_neon::systems::shop_system::{shop_system, IShopSystemDispatcher, IShopSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{
        init_player_level_poker_hands, mock_game, mock_current_hand, mock_shop, mock_empty_shop, mock_game_deck
    };
    use jokers_of_neon::utils::constants::{poker_hands_all, BASIC_BLISTER_PACK};

    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_common_card() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_game_deck(world, game.id);

        // Commons shop cards
        let SIX_OF_CLUBS = CardTrait::new(Value::Six, Suit::Clubs, 6);

        mock_shop(
            ref store,
            game.id,
            commons: array![SIX_OF_CLUBS.id,].span(),
            modifiers: array![].span(),
            specials: array![].span(),
            temp_specials: array![].span(),
            blister_packs: array![].span(),
            poker_hands: array![].span()
        );

        let game_deck_before = GameDeckStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.shop_system.buy_card_item(game.id, 0, CardItemType::Common);

        let game_after = store.get_game(game.id);
        let card_item_before = store.get_card_item(game.id, 0, CardItemType::Common);
        assert(game_after.cash == game.cash - card_item_before.cost, 'wrong cash');

        let game_deck_after = GameDeckStore::get(world, game.id);
        assert(game_deck_after.len == game_deck_before.len + 1, 'wrong len_deck_cards');

        let deck_card = DeckCardStore::get(world, game.id, game_deck_after.len - 1);
        assert(deck_card.card_id == card_item_before.card_id, 'wrong card_id');

        let card_item_after = store.get_card_item(game.id, 0, CardItemType::Common);
        assert(card_item_after.purchased, 'wrong purchased');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_modifier_card() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_game_deck(world, game.id);

        // Set temp specials and poker hands empty
        let mut commons = array![].span();
        let modifiers_ids = array![SUIT_HEARTS_MODIFIER_ID].span();
        let special_ids = array![].span();
        let temp_specials = array![].span();
        let blister_packs = array![].span();
        let poker_hands = array![].span();

        mock_shop(ref store, game.id, commons, modifiers_ids, special_ids, temp_specials, blister_packs, poker_hands);

        let card_item_before = store.get_card_item(game.id, 0, CardItemType::Modifier);

        let game_deck_before = GameDeckStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.shop_system.buy_card_item(game.id, 0, CardItemType::Modifier);

        let game_after = store.get_game(game.id);
        assert(game_after.cash == game.cash - card_item_before.cost, 'wrong cash');

        let game_deck_after = GameDeckStore::get(world, game.id);
        assert(game_deck_after.len == game_deck_before.len + 1, 'wrong len_deck_cards');

        let deck_card = DeckCardStore::get(world, game.id, game_deck_after.len - 1);
        assert(deck_card.card_id == card_item_before.card_id, 'wrong card_id');

        let card_item_after = store.get_card_item(game.id, 0, CardItemType::Modifier);
        assert(card_item_after.purchased, 'wrong purchased');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_special_card() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_shop(
            ref store,
            game.id,
            commons: array![].span(),
            modifiers: array![].span(),
            specials: array![SPECIAL_MULTI_FOR_DIAMOND_ID].span(),
            temp_specials: array![].span(),
            blister_packs: array![].span(),
            poker_hands: array![].span()
        );

        let card_item_before = store.get_card_item(game.id, 0, CardItemType::Special);

        set_contract_address(PLAYER());
        systems.shop_system.buy_card_item(game.id, 0, CardItemType::Special);

        let game_after = store.get_game(game.id);
        assert(game_after.cash == game.cash - card_item_before.cost, 'wrong cash');
        assert(
            game_after.len_current_special_cards == game.len_current_special_cards + 1,
            'wrong len_current_special_cards'
        );

        let current_special_card = store.get_current_special_cards(game.id, game.len_current_special_cards);
        assert(current_special_card.effect_card_id == card_item_before.card_id, 'wrong card_id');

        let card_item_after = store.get_card_item(game.id, 0, CardItemType::Special);
        assert(card_item_after.purchased, 'wrong purchased');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_special_card_extra_help() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_shop(
            ref store,
            game.id,
            commons: array![].span(),
            modifiers: array![].span(),
            specials: array![SPECIAL_EXTRA_HELP_ID].span(),
            temp_specials: array![].span(),
            blister_packs: array![].span(),
            poker_hands: array![].span()
        );

        set_contract_address(PLAYER());
        systems.shop_system.buy_card_item(game.id, 0, CardItemType::Special);

        let game_after = store.get_game(game.id);
        assert(game_after.len_hand == 10, 'wrong len_hand');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_poker_hand_item() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        // Mock needed poker hands
        init_player_level_poker_hands(ref store, game.id, PokerHand::TwoPair, 1);

        mock_shop(
            ref store,
            game.id,
            commons: array![].span(),
            modifiers: array![].span(),
            specials: array![].span(),
            temp_specials: array![].span(),
            blister_packs: array![].span(),
            poker_hands: array![PokerHand::TwoPair].span()
        );

        let ph_item = store.get_poker_hand_item(game.id, 0);
        let level_poker_hand_before = store.get_player_level_poker_hand(game.id, ph_item.poker_hand);
        assert(level_poker_hand_before.level == 1, 'wrong level poker hand before');

        set_contract_address(PLAYER());
        systems.shop_system.buy_poker_hand_item(game.id, 0);

        let game_after = store.get_game(game.id);
        assert(game_after.cash == game.cash - ph_item.cost, 'wrong cash');

        let poker_hand_item_after = store.get_poker_hand_item(game.id, 0);
        assert(poker_hand_item_after.purchased, 'wrong purchased');

        let level_poker_hand_after = store.get_player_level_poker_hand(game.id, ph_item.poker_hand);
        assert(level_poker_hand_after.level == ph_item.level, 'wrong level poker hand after');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_when_poker_hands_are_leveled_up_then_dont_be_showed_on_shop() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_empty_shop(ref store, game.id);

        // Set all poker hands at level 20 (less 2), so the shop should show only 2 hands available
        let mut i = 0;
        loop {
            if i == poker_hands_all().len() - 2 {
                break;
            }
            let poker_hand: PokerHand = (*poker_hands_all().at(i)).try_into().unwrap();
            let mut poker_hand_level = store.get_player_level_poker_hand(game.id, poker_hand);
            poker_hand_level.level = 10;
            store.set_player_level_poker_hand(poker_hand_level);
            i += 1;
        };
        // Re-roll to use the update_items_shop() method
        set_contract_address(PLAYER());
        systems.shop_system.reroll(game.id);

        // Due to the order of the method, only the following hands should be available
        // This is because we have increased all but the last two poker hands.
        // POKER_HAND_HIGH_CARD,
        // POKER_HAND_FIVE_OF_A_KIND
        let high_card_item = store.get_poker_hand_item(game.id, 0);
        assert(high_card_item.level == 1, 'high_card should be avaiable');

        let five_of_a_kind_item = store.get_poker_hand_item(game.id, 1);
        assert(five_of_a_kind_item.level == 1, 'f_of_a_kind should be avaiable');

        let invalid_item = store.get_poker_hand_item(game.id, 2);
        assert(invalid_item.level == 0, 'this should not be avaiable');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_when_all_poker_hands_are_leveled_up_then_no_one_will_be_available() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_empty_shop(ref store, game.id);

        // Set all poker hands at level 20 (less 2), so the shop should show only 2 hands available
        let mut i = 0;
        loop {
            if i == poker_hands_all().len() {
                break;
            }
            let poker_hand: PokerHand = (*poker_hands_all().at(i)).try_into().unwrap();
            let mut poker_hand_level = store.get_player_level_poker_hand(game.id, poker_hand);
            poker_hand_level.level = 10;
            store.set_player_level_poker_hand(poker_hand_level);
            i += 1;
        };
        // Re-roll to use the update_items_shop() method
        set_contract_address(PLAYER());
        systems.shop_system.reroll(game.id);

        let invalid_item = store.get_poker_hand_item(game.id, 0);
        assert(invalid_item.level == 0, 'this should not be avaiable');
    }

    #[test]
    #[available_gas(30000000000000000)]
    #[should_panic(expected: ('Shop: maximum level reached', 'ENTRYPOINT_FAILED'))]
    fn test_shop_should_fail_when_buy_poker_hand_item_gt_level_10() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        // Mock needed poker hands
        init_player_level_poker_hands(ref store, game.id, PokerHand::TwoPair, 20);

        mock_shop(
            ref store,
            game.id,
            commons: array![].span(),
            modifiers: array![].span(),
            specials: array![].span(),
            temp_specials: array![].span(),
            blister_packs: array![].span(),
            poker_hands: array![PokerHand::TwoPair].span()
        );

        // level up poker hand to level 20
        let mut ph_item = store.get_poker_hand_item(game.id, 0);
        ph_item.level = 11;
        store.set_poker_hand_item(ph_item);

        set_contract_address(PLAYER());
        systems.shop_system.buy_poker_hand_item(game.id, 0);
    }


    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_when_player_has_hand_level_9() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        // Mock needed poker hands
        init_player_level_poker_hands(ref store, game.id, PokerHand::TwoPair, 9);

        mock_shop(
            ref store,
            game.id,
            commons: array![].span(),
            modifiers: array![].span(),
            specials: array![].span(),
            temp_specials: array![].span(),
            blister_packs: array![].span(),
            poker_hands: array![PokerHand::TwoPair].span()
        );

        // level up poker hand to level 20
        let mut ph_item = store.get_poker_hand_item(game.id, 0);
        ph_item.level = 10;
        store.set_poker_hand_item(ph_item);

        set_contract_address(PLAYER());
        systems.shop_system.buy_poker_hand_item(game.id, 0);
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_blister_pack_item() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        mock_shop(
            ref store,
            game.id,
            commons: array![].span(),
            modifiers: array![].span(),
            specials: array![].span(),
            temp_specials: array![].span(),
            blister_packs: array![BASIC_BLISTER_PACK].span(),
            poker_hands: array![].span()
        );

        let blister_pack_item_before = store.get_blister_pack_item(game.id, 0);

        set_contract_address(PLAYER());
        systems.shop_system.buy_blister_pack_item(game.id, 0);

        let game_after = store.get_game(game.id);
        assert(game_after.cash == game.cash - blister_pack_item_before.cost, 'wrong cash');

        let blister_pack_result = store.get_blister_pack_result(game.id);
        assert(!blister_pack_result.cards_picked, 'wrong cards_picked');
        assert(blister_pack_result.cards.len() == 5, 'wrong len cards');

        let blister_pack_item_after = store.get_blister_pack_item(game.id, 0);
        assert(blister_pack_item_after.purchased, 'wrong purchased');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_select_cards_from_blister() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::OPEN_BLISTER_PACK;
        store.set_game(game);

        mock_game_deck(world, game.id);

        let ACE_OF_HEARTS = CardTrait::new(Value::Ace, Suit::Hearts, 11);
        let SIX_OF_CLUBS = CardTrait::new(Value::Six, Suit::Clubs, 6);
        // Mock BlisterPackResult
        let cards = array![
            SUIT_HEARTS_MODIFIER_ID,
            SIX_OF_CLUBS.id,
            SPECIAL_MULTI_FOR_DIAMOND_ID,
            MULTI_MODIFIER_1_ID,
            ACE_OF_HEARTS.id,
        ]; // 2 commons - 2 modifiers - 1 special
        store.set_blister_pack_result(BlisterPackResult { game_id: game.id, cards_picked: false, cards: cards.span() });

        let game_deck_before = GameDeckStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.shop_system.select_cards_from_blister(game.id, array![4, 1, 3, 2, 0]);

        let game_after = store.get_game(game.id);
        assert(game_after.state == GameState::AT_SHOP, 'wrong GameState');

        let game_deck_after = GameDeckStore::get(world, game.id);
        assert(game_deck_after.len == game_deck_before.len + 4, 'wrong len_deck_cards');
        assert(
            game_after.len_current_special_cards == game.len_current_special_cards + 1,
            'wrong len_current_special_cards'
        );

        let blister_pack = store.get_blister_pack_result(game.id);
        assert(blister_pack.cards_picked == true, 'cards_picked should be true');

        // last common card must be `Six of Clubs` and `Ace of Hearts`
        let COMMON_PICKED_1 = DeckCardStore::get(world, game.id, game_deck_after.len - 4);
        assert(COMMON_PICKED_1.card_id == ACE_OF_HEARTS.id, 'wrong last common card 1');

        let COMMON_PICKED_2 = DeckCardStore::get(world, game.id, game_deck_after.len - 3);
        assert(COMMON_PICKED_2.card_id == SIX_OF_CLUBS.id, 'wrong last common card 2');

        // last modiifer must be `MULTI_MODIFIER_1` and `SUIT_HEARTS_MODIFIER`
        let MODIFIER_PICKED_1 = DeckCardStore::get(world, game.id, game_deck_after.len - 2);
        assert(MODIFIER_PICKED_1.card_id == MULTI_MODIFIER_1_ID, 'wrong modifier card 1');

        let MODIFIER_PICKED_2 = DeckCardStore::get(world, game.id, game_deck_after.len - 1);
        assert(MODIFIER_PICKED_2.card_id == SUIT_HEARTS_MODIFIER_ID, 'wrong modifier card 2');

        // last special must be `SPECIAL_MULTI_FOR_DIAMOND`
        let SPECIAL_PICKED = store.get_current_special_cards(game.id, game_after.len_current_special_cards - 1);
        assert(SPECIAL_PICKED.effect_card_id == SPECIAL_MULTI_FOR_DIAMOND_ID, 'wrong special card');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_shop_buy_slot_special_cards() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        game.cash = 5000;
        store.set_game(game);

        // Mock needed Slot Special Cards
        store.set_slot_special_cards_item(SlotSpecialCardsItem { game_id: game.id, cost: 300, purchased: false });

        assert(game.len_max_current_special_cards == 1, 'wrong max special cards1');

        set_contract_address(PLAYER());
        systems.shop_system.buy_slot_special_card_item(game.id);

        let game_after = store.get_game(game.id);
        assert(game_after.cash == game.cash - 300, 'wrong cash');
        assert(game_after.len_max_current_special_cards == 2, 'wrong max special cards2');
    }
}

mod test_shop_validations {
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::status::game::game::GameState;
    use jokers_of_neon::models::status::shop::shop::{Shop, CardItem, CardItemType};
    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::systems::shop_system::{shop_system, IShopSystemDispatcher, IShopSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{
        init_player_level_poker_hands, mock_game, mock_current_hand, mock_shop, mock_empty_shop
    };
    use jokers_of_neon::utils::shop::{round_to_nearest, get_poker_hand_item_cost};
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Shop: game not found', 'ENTRYPOINT_FAILED'))]
    fn test_game_not_found() {
        let (_, systems) = setup::spawn_game();
        let NON_EXISTENT_GAME_ID = 1;
        systems.shop_system.skip_shop(NON_EXISTENT_GAME_ID);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Shop: caller not owner', 'ENTRYPOINT_FAILED'))]
    fn test_caller_not_owner() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        store.set_game(game);

        let ANYONE = starknet::contract_address_const::<'ANYONE'>();
        set_contract_address(ANYONE);

        systems.shop_system.skip_shop(game.id);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Shop: game not at shop', 'ENTRYPOINT_FAILED'))]
    fn test_invalid_game_state() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        set_contract_address(PLAYER());
        systems.shop_system.skip_shop(game.id);
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_skip_shop_success() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        // Set game state in shop
        game.state = GameState::AT_SHOP;
        store.set_game(game);

        mock_empty_shop(ref store, game.id,);

        set_contract_address(PLAYER());
        systems.shop_system.skip_shop(game.id);

        let mut game_after = store.get_game(game.id);
        assert(game_after.state == GameState::IN_GAME, 'Wrong game state');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_round_to_nearest() {
        let mut result = round_to_nearest(100, 666);
        assert(result == 700, 'Wrong round');

        let mut result = round_to_nearest(100, 620);
        assert(result == 600, 'Wrong round');

        let mut result = round_to_nearest(100, 100);
        assert(result == 100, 'Wrong round');

        let mut result = round_to_nearest(100, 150);
        assert(result == 200, 'Wrong round');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_get_poker_hand_item_cost() {
        let mut result = get_poker_hand_item_cost(1);
        assert(result == 100, 'Wrong poker_hand cost 1');

        result = get_poker_hand_item_cost(2);
        assert(result == 150, 'Wrong poker_hand cost 2');

        result = get_poker_hand_item_cost(3);
        assert(result == 250, 'Wrong poker_hand cost 3');

        result = get_poker_hand_item_cost(4);
        assert(result == 350, 'Wrong poker_hand cost 4');

        result = get_poker_hand_item_cost(5);
        assert(result == 500, 'Wrong poker_hand cost 5');

        result = get_poker_hand_item_cost(6);
        assert(result == 750, 'Wrong poker_hand cost 6');

        result = get_poker_hand_item_cost(7);
        assert(result == 1150, 'Wrong poker_hand cost 7');
    }
}
