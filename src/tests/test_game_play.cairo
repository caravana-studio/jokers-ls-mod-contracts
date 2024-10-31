mod test_play_special_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::card::{
        SIX_CLUBS_ID, ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, NINE_DIAMONDS_ID, EIGHT_HEARTS_ID, QUEEN_CLUBS_ID,
        SEVEN_DIAMONDS_ID, FIVE_CLUBS_ID, KING_CLUBS_ID, SIX_HEARTS_ID, FOUR_CLUBS_ID, JACK_CLUBS_ID, JACK_HEARTS_ID,
        KING_DIAMONDS_ID, SEVEN_CLUBS_ID, SEVEN_HEARTS_ID, ACE_SPADES_ID
    };
    use jokers_of_neon::constants::modifiers::{SUIT_CLUB_MODIFIER_ID, MULTI_MODIFIER_1_ID};
    use jokers_of_neon::constants::specials::{
        SPECIAL_LUCKY_SEVEN_ID, SPECIAL_INCREASE_LEVEL_PAIR_ID, SPECIAL_MULTI_FOR_CLUB_ID, SPECIAL_MULTI_FOR_HEART_ID,
        SPECIAL_POINTS_FOR_FIGURES_ID, SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_MULTI_FOR_SPADE_ID, SPECIAL_NEON_BONUS_ID,
        SPECIAL_INITIAL_ADVANTAGE_ID, SPECIAL_MULTI_ACES_ID, SPECIAL_DEADLINE_ID, SPECIAL_ALL_CARDS_TO_HEARTS_ID,
        SPECIAL_LUCKY_HAND_ID
    };
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeck, DeckCard};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards, GameState};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use jokers_of_neon::tests::utils::{
        mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_special_cards,
    };
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_flush() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_ALL_CARDS_TO_HEARTS_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, QUEEN_CLUBS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

        // Flush - points: 35, multi: 4
        // points: 6 + 10 + 4 + 10 + 10
        // multi add: 0
        // player_score = 300
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 300, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_extra_points_figure() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_POINTS_FOR_FIGURES_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![
            SIX_CLUBS_ID,
            QUEEN_CLUBS_ID,
            FOUR_CLUBS_ID,
            JACK_HEARTS_ID,
            KING_DIAMONDS_ID,
            SUIT_CLUB_MODIFIER_ID,
            SUIT_CLUB_MODIFIER_ID,
            MULTI_MODIFIER_1_ID
        ];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 7, 100, 5, 6]);
        // Flush - points: 35, multi: 4
        // points: 6 + 10 + 4 + 10 + 10 + 50 * 3
        // multi add: 1
        // player_score = 1125
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 1125, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_multi_for_clubs() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_MULTI_FOR_CLUB_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, SIX_HEARTS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID,];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Pair - points: 10, multi: 2
        // points: 6 + 6
        // multi add: 2
        // player_score = 88
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 88, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_temporary_special_multi_for_clubs() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_MULTI_FOR_CLUB_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Modify the special card to make it temporary
        let mut special_multi_for_clubs = store.get_current_special_cards(game.id, 0);
        special_multi_for_clubs.is_temporary = true;
        special_multi_for_clubs.remaining = 1;
        store.set_current_special_cards(special_multi_for_clubs);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, SIX_CLUBS_ID, FOUR_CLUBS_ID, JACK_CLUBS_ID, KING_CLUBS_ID,];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

        let game_after = store.get_game(game.id);
        assert(game_after.len_current_special_cards.is_zero(), 'wrong len_current_special_cards');

        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 994, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_multi_for_all_suits() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![
            SPECIAL_MULTI_FOR_CLUB_ID,
            SPECIAL_MULTI_FOR_HEART_ID,
            SPECIAL_MULTI_FOR_DIAMOND_ID,
            SPECIAL_MULTI_FOR_SPADE_ID
        ];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![
            FIVE_CLUBS_ID, SIX_HEARTS_ID, SEVEN_DIAMONDS_ID, EIGHT_HEARTS_ID, NINE_DIAMONDS_ID,
        ];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Straight - points: 40, multi: 4
        // points: 5 + 6 + 7 + 8 + 9
        // multi add: 2 + 2 + 2 + 2 + 2
        // player_score = 1050
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 1050, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_multi_aces() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_MULTI_ACES_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2], array![100, 100, 100,]);
        // Three of a Kind - points: 30, multi: 5
        // points: 11 + 11 + 11
        // multi add: 3 + 3 + 3
        // player_score = 1134
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 1134, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_lucky_seven() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_LUCKY_SEVEN_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SEVEN_CLUBS_ID, SEVEN_HEARTS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID,];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Pair - points: 10, multi: 2
        // points: 7 + 7 + 77 + 77
        // multi add: 0
        // player_score = 356
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 356, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_deadline() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // let mut round = mock_round(ref store, @game, 300);

        // Set round last hand
        // round.hands = 1;
        // store.set_round(round);

        // Mock special card
        let special_cards_ids = array![SPECIAL_DEADLINE_ID, SPECIAL_INCREASE_LEVEL_PAIR_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1], array![100, 100]);
        // Pair - level 15 - points: 80, multi: 16
        // points: 11 + 11 + 10
        // multi add: 1
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 1632, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_initial_advantage() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock special card
        let special_cards_ids = array![SPECIAL_INITIAL_ADVANTAGE_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
        // Four of a Kind - points: 60, multi: 7
        // points: 11 + 11 + 11 + 11 + 100
        // multi add: 10
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 3468, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_lucky_hand() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Init modifiers cards
        let mut specials_ids = array![SPECIAL_LUCKY_HAND_ID];
        mock_special_cards(ref store, ref game, specials_ids);

        // Init and mock needed cards for the test
        let TWO_OF_DIAMONDS = CardTrait::new(Value::Two, Suit::Diamonds, 2);
        let THREE_OF_DIAMONDS = CardTrait::new(Value::Three, Suit::Diamonds, 3);
        let FOUR_OF_DIAMONDS = CardTrait::new(Value::Four, Suit::Diamonds, 4);
        let FIVE_OF_DIAMONDS = CardTrait::new(Value::Five, Suit::Diamonds, 5);
        let SIX_OF_DIAMONDS = CardTrait::new(Value::Six, Suit::Diamonds, 6);
        let mut game_cards_ids = array![
            TWO_OF_DIAMONDS.id, THREE_OF_DIAMONDS.id, FOUR_OF_DIAMONDS.id, FIVE_OF_DIAMONDS.id, SIX_OF_DIAMONDS.id
        ];
        mock_current_hand_cards_ids(ref store, game.id, game_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

        let game_after = store.get_game(game.id);

        // 2350 (defeating the round) + 250 (lucky hand)
        assert(game_after.cash == 2600, 'wrong game cash after');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_poker_hand_level_max() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Init and mock needed cards for the test
        let TWO_OF_DIAMONDS = CardTrait::new(Value::Two, Suit::Diamonds, 2);
        let THREE_OF_DIAMONDS = CardTrait::new(Value::Three, Suit::Diamonds, 3);
        let FOUR_OF_DIAMONDS = CardTrait::new(Value::Four, Suit::Diamonds, 4);
        let FIVE_OF_DIAMONDS = CardTrait::new(Value::Five, Suit::Diamonds, 5);
        let SIX_OF_DIAMONDS = CardTrait::new(Value::Six, Suit::Diamonds, 6);
        let mut game_cards_ids = array![
            TWO_OF_DIAMONDS.id, THREE_OF_DIAMONDS.id, FOUR_OF_DIAMONDS.id, FIVE_OF_DIAMONDS.id, SIX_OF_DIAMONDS.id
        ];
        mock_current_hand_cards_ids(ref store, game.id, game_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

        let game_after = store.get_game(game.id);

        // 2000 (defeating the round) + 250 (lucky hand)
        assert(game_after.cash == 2350, 'wrong game cash after');
    }
}

mod test_play_modifier_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::card::{
        JACK_CLUBS_ID, JACK_SPADES_ID, SIX_CLUBS_ID, QUEEN_CLUBS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID,
        KING_SPADES_ID, TWO_SPADES_ID, TWO_DIAMONDS_ID, TWO_CLUBS_ID, FOUR_DIAMONDS_ID, FOUR_HEARTS_ID
    };
    use jokers_of_neon::constants::modifiers::{
        SUIT_CLUB_MODIFIER_ID, MULTI_MODIFIER_1_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID, POINTS_MODIFIER_2_ID,
        MULTI_MODIFIER_3_ID,
    };
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeck};
    use jokers_of_neon::models::data::poker_hand::{PokerHand, LevelPokerHand};
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards, GameState};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };

    use jokers_of_neon::tests::utils::{mock_current_hand, mock_current_hand_cards_ids, mock_game};

    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_modifier_high_card() {
        let (world, systems) = setup::spawn_game();

        let mut store: Store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // let round = mock_round(ref store, @game, 300);

        // Init modifiers cards
        // let mut modifiers_ids = array![POINTS_MODIFIER_4, MULTI_MODIFIER_4].span();
        // init_modifiers_cards(ref store, game.id, ref modifiers_ids);

        // Mock hand
        let hand_cards_ids = array![KING_SPADES_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        // assert(round.player_score.is_zero(), 'wrong round_before player_score');
        assert(game.level == 1, 'wrong game_before level');
        assert(game.cash.is_zero(), 'wrong game_before cash');
        assert(game.state == GameState::IN_GAME, 'wrong game_before state');
        assert(game.player_score.is_zero(), 'wrong game_before player_score');

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0], array![1]);

        // let round = store.get_round(game.id);
        // assert(round.player_score == 115, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_modifier_one_pair() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock hand
        let hand_cards_ids = array![TWO_SPADES_ID, TWO_DIAMONDS_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1], array![2, 3]);

        // Pair - points: 10, multi: 2
        // points: 2 + 2 + 100
        // multi add: 10
        // player_score = 1368
        // let round = store.get_round(game.id);
        // assert(round.player_score == 1368, 'wrong round player_score');

        let game_after = store.get_game(game.id);
        assert(game_after.player_score == 1368, 'wrong game player_score');
        assert(game_after.cash == 2350, 'wrong game cash');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_two_pair() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock hand
        let hand_cards_ids = array![TWO_CLUBS_ID, TWO_SPADES_ID, FOUR_DIAMONDS_ID, FOUR_HEARTS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);

        // TwoPair - points: 20, multi: 3
        // points: 2 + 2 + 4 + 4 = 12
        // multi add: 0
        // player_score = 96
        // let round = store.get_round(game.id);
        // assert(round.player_score == 96, 'wrong round player_score');

        let game_after = store.get_game(game.id);
        assert(game_after.player_score == 0, 'wrong game_after player_score');
        assert(game_after.state == GameState::IN_GAME, 'wrong game_after state');
        assert(game_after.cash == 0, 'wrong game_after cash');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_modifier_flush() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock hand
        let hand_cards_ids = array![
            SIX_CLUBS_ID,
            QUEEN_CLUBS_ID,
            FOUR_CLUBS_ID,
            JACK_HEARTS_ID,
            KING_DIAMONDS_ID,
            SUIT_CLUB_MODIFIER_ID,
            SUIT_CLUB_MODIFIER_ID,
            MULTI_MODIFIER_1_ID
        ];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 7, 100, 5, 6]);
        // Flush - points: 35, multi: 4
        // points: 6 + 10 + 4 + 10 + 10
        // multi add: 1
        // player_score = 375
        // let round = store.get_round(game.id);
        // assert(round.player_score == 375, 'wrong round player_score');

        let game_after = store.get_game(game.id);
        assert(game_after.player_score == 375, 'wrong game_after player_score');
        assert(game_after.state == GameState::AT_SHOP, 'wrong game_after state');
        assert(game_after.cash == 2350, 'wrong game_after cash');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_two_modifiers() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock hand
        let hand_cards_ids = array![
            JACK_CLUBS_ID,
            JACK_SPADES_ID,
            POINTS_MODIFIER_4_ID,
            POINTS_MODIFIER_2_ID,
            MULTI_MODIFIER_3_ID,
            MULTI_MODIFIER_4_ID
        ];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1], array![5, 4]);

        // let round = store.get_round(game.id);
        // assert(round.player_score == 510, 'wrong round player_score');

        let game_after = store.get_game(game.id);
        assert(game_after.player_score == 510, 'wrong game_after player_score');
        assert(game_after.state == GameState::AT_SHOP, 'wrong game_after state');
        assert(game_after.cash == 2350, 'wrong game_after cash');
    }
}

mod test_rage_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_of_neon::constants::card::{
        ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID, SIX_CLUBS_ID, JOKER_CARD, FOUR_CLUBS_ID,
        JACK_HEARTS_ID, KING_DIAMONDS_ID
    };
    use jokers_of_neon::constants::specials::{SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_JOKER_BOOSTER_ID};
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeck};
    use jokers_of_neon::models::data::poker_hand::PokerHand;
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards, GameState};
    use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard};

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };

    use jokers_of_neon::tests::utils::{
        mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_special_cards, mock_rage_round
    };
    use jokers_of_neon::utils::constants::{
        RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_ZERO_WASTE, RAGE_CARD_SILENT_JOKERS
    };
    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_rage_card_silent_diamond() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock RageRound
        mock_rage_round(world, game.id, array![RAGE_CARD_SILENT_DIAMONDS]);

        // Mock hand
        let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
        // Four of a Kind - points: 60, multi: 7
        // points: 11 + 11 + 0 + 11
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 651, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_rage_card_silent_diamond_with_special() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock RageRound
        mock_rage_round(world, game.id, array![RAGE_CARD_SILENT_DIAMONDS]);

        // Mock special card
        let special_cards_ids = array![SPECIAL_MULTI_FOR_DIAMOND_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
        // Four of a Kind - points: 60, multi: 7
        // points: 11 + 11 + 0 + 11
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 651, 'wrong round player_score');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_rage_card_silent_jokers_with_special() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        // Mock RageRound
        mock_rage_round(world, game.id, array![RAGE_CARD_SILENT_JOKERS]);

        // Mock special card
        let special_cards_ids = array![SPECIAL_JOKER_BOOSTER_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, JOKER_CARD, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Pair - points: 10, multi: 2
        // points: 10
        // player_score = 40
        // let round_after = store.get_round(game.id);
        // assert(round_after.player_score == 40, 'wrong round player_score');
    }
// #[test]
// #[available_gas(30000000000000000)]
// fn test_play_rage_card_diminished_hold() {
//     let (world, systems) = setup::spawn_game();
//     let mut store = StoreTrait::new(world);
//     let mut game = mock_game(ref store, PLAYER());
//     mock_round(ref store, @game, 300);

//     // Mock RageRound
//     let len_hand_before = game.len_hand;
//     mock_rage_round(world, game.id, array![RAGE_CARD_DIMINISHED_HOLD]);

//     // Set game state in shop
//     game.state = GameState::AT_SHOP;
//     store.set_game(game);

//     set_contract_address(PLAYER());
//     systems.shop_system.skip_shop(game.id);

//     let game_after = store.get_game(game.id);
//     assert(game_after.len_hand == len_hand_before - 2, 'wrong game_after len_hand');
// }

// #[test]
// #[available_gas(30000000000000000)]
// fn test_play_rage_card_zero_waste() {
//     let (world, systems) = setup::spawn_game();
//     let mut store = StoreTrait::new(world);
//     let mut game = mock_game(ref store, PLAYER());
//     mock_round(ref store, @game, 300);

//     // Mock RageRound
//     mock_rage_round(world, game.id, array![RAGE_CARD_ZERO_WASTE]);

//     // Set game state in shop
//     game.state = GameState::AT_SHOP;
//     store.set_game(game);

//     set_contract_address(PLAYER());
//     systems.shop_system.skip_shop(game.id);

//     let round = store.get_round(game.id);
//     assert(round.discard == 0, 'wrong round discard');
// }
}

mod test_play_validations {
    use jokers_of_neon::constants::card::INVALID_CARD;
    use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
    use jokers_of_neon::models::data::poker_hand::PokerHand;

    use jokers_of_neon::models::status::game::game::{Game, GameState, DefaultGame};

    use jokers_of_neon::store::{Store, StoreTrait};

    use jokers_of_neon::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_of_neon::tests::setup::{setup, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait};
    use jokers_of_neon::tests::utils::{mock_current_hand_cards_ids, mock_game, mock_game_deck};
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
        systems.game_system.play(NON_EXISTENT_GAME_ID, array![0], array![0]);
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

        systems.game_system.play(game.id, array![0], array![0]);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: invalid card index len', 'ENTRYPOINT_FAILED'))]
    fn test_invalid_card_index() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![], array![]);
    }

    #[test]
    #[available_gas(30000000000000000)]
    #[should_panic(expected: ('Game: use an invalid card', 'ENTRYPOINT_FAILED'))]
    fn test_play_invalid_card() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        let cards_ids = array![INVALID_CARD];
        mock_current_hand_cards_ids(ref store, game.id, cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0], array![100]);
    }

    #[test]
    #[available_gas(30000000000000000)]
    #[should_panic(expected: ('Game: use an invalid card', 'ENTRYPOINT_FAILED'))]
    fn test_discard_invalid_card() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 300);

        let cards_ids = array![INVALID_CARD];
        mock_current_hand_cards_ids(ref store, game.id, cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.discard(game.id, array![0], array![100]);
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_when_current_deck_is_empty_should_return_invalid_cards() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 3000);

        let mut game_deck = mock_game_deck(world, game.id);
        game_deck.round_len = 0;
        GameDeckStore::set(@game_deck, world);

        let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
        let cards_ids = array![
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS
        ];
        mock_current_hand_cards_ids(ref store, game.id, cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1], array![100, 100]);

        // Validate that the quantity of invalid cards is 2
        let mut i = 0;
        let mut invalid_cards_count = 0;
        let HAND_LEN = 8;
        loop {
            if HAND_LEN == i {
                break;
            }
            let current_hand_card = store.get_current_hand_card(game.id, i);
            if current_hand_card.card_id == INVALID_CARD {
                invalid_cards_count += 1;
            }
            i += 1;
        };
        assert(invalid_cards_count == 2, 'wrong invalid cards quantity');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_when_current_deck_and_hand_are_empty_then_game_finish() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 3000);

        // Make sure that player doenst win with next hand
        // Set an empty current deck
        let mut game_deck = mock_game_deck(world, game.id);
        game_deck.round_len = 0;
        GameDeckStore::set(@game_deck, world);

        let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
        let cards_ids = array![
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD
        ];
        mock_current_hand_cards_ids(ref store, game.id, cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

        let game = store.get_game(game.id);
        assert(game.state == GameState::FINISHED, 'game should be finished');
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: game not found', 'ENTRYPOINT_FAILED'))]
    fn test_discard_game_not_found() {
        let (_, systems) = setup::spawn_game();
        let NON_EXISTENT_GAME_ID = 1;
        systems.game_system.discard(NON_EXISTENT_GAME_ID, array![0], array![0]);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: caller not owner', 'ENTRYPOINT_FAILED'))]
    fn test_discard_caller_not_owner() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());

        let ANYONE = starknet::contract_address_const::<'ANYONE'>();
        set_contract_address(ANYONE);

        systems.game_system.discard(game.id, array![0], array![0]);
    }

    #[test]
    #[available_gas(300000000000)]
    #[should_panic(expected: ('Game: is not IN_GAME', 'ENTRYPOINT_FAILED'))]
    fn test_discard_game_not_in_progress() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::FINISHED;
        store.set_game(game);

        set_contract_address(PLAYER());
        systems.game_system.discard(game.id, array![0], array![0]);
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_discard_when_current_deck_is_empty_and_have_invalid_cards() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 3000);

        let mut game_deck = mock_game_deck(world, game.id);
        game_deck.round_len = 0;
        GameDeckStore::set(@game_deck, world);

        let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
        let cards_ids = array![
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD
        ];
        mock_current_hand_cards_ids(ref store, game.id, cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.discard(game.id, array![0, 1], array![100, 100]);

        // Validate that the quantity of invalid cards is 7 (5 current invalid cards + 2 invalid for
        // discard)
        let mut i = 0;
        let mut invalid_cards_count = 0;
        let HAND_LEN = 8;
        loop {
            if HAND_LEN == i {
                break;
            }
            let current_hand_card = store.get_current_hand_card(game.id, i);
            if current_hand_card.card_id == INVALID_CARD {
                invalid_cards_count += 1;
            }
            i += 1;
        };
        assert(invalid_cards_count == 7, 'wrong invalid cards quantity');
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_discard_when_current_deck_and_hand_are_empty_then_game_finish() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let game = mock_game(ref store, PLAYER());
        // mock_round(ref store, @game, 3000);

        let mut game_deck = mock_game_deck(world, game.id);
        game_deck.round_len = 0;
        GameDeckStore::set(@game_deck, world);

        let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
        let cards_ids = array![
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            TWO_OF_HEARTS,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD,
            INVALID_CARD
        ];
        mock_current_hand_cards_ids(ref store, game.id, cards_ids);

        set_contract_address(PLAYER());
        systems.game_system.discard(game.id, array![0, 1, 2], array![100, 100, 100]);

        let game = store.get_game(game.id);
        assert(game.state == GameState::FINISHED, 'game should be finished');
    }
}
