mod test_play_beast_special_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::constants::card::{
        SIX_CLUBS_ID, ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, NINE_DIAMONDS_ID, EIGHT_HEARTS_ID, QUEEN_CLUBS_ID,
        SEVEN_DIAMONDS_ID, FIVE_CLUBS_ID, KING_CLUBS_ID, SIX_HEARTS_ID, FOUR_CLUBS_ID, JACK_CLUBS_ID, JACK_HEARTS_ID,
        KING_DIAMONDS_ID, SEVEN_CLUBS_ID, SEVEN_HEARTS_ID, ACE_SPADES_ID, QUEEN_HEARTS_ID
    };
    use jokers_ls_mod::constants::modifiers::MULTI_MODIFIER_4_ID;
    use jokers_ls_mod::constants::specials::{
        SPECIAL_LUCKY_SEVEN_ID, SPECIAL_INCREASE_LEVEL_PAIR_ID, SPECIAL_MULTI_FOR_CLUB_ID, SPECIAL_MULTI_FOR_HEART_ID,
        SPECIAL_POINTS_FOR_FIGURES_ID, SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_MULTI_FOR_SPADE_ID, SPECIAL_NEON_BONUS_ID,
        SPECIAL_INITIAL_ADVANTAGE_ID, SPECIAL_MULTI_ACES_ID, SPECIAL_DEADLINE_ID, SPECIAL_ALL_CARDS_TO_HEARTS_ID,
        SPECIAL_LUCKY_HAND_ID
    };
    use jokers_ls_mod::models::data::beast::{
        GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore
    };
    use jokers_ls_mod::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_ls_mod::models::data::game_deck::{GameDeck, DeckCard};
    use jokers_ls_mod::models::data::poker_hand::PokerHand;
    use jokers_ls_mod::models::status::game::game::{Game, CurrentSpecialCards, GameState, GameSubState};
    use jokers_ls_mod::models::status::round::current_hand_card::{CurrentHandCard};
    use jokers_ls_mod::store::{Store, StoreTrait};

    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_ls_mod::tests::setup::{setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait};
    use jokers_ls_mod::tests::utils::{
        mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_special_cards, mock_level_best
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
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock special card
        let special_cards_ids = array![SPECIAL_ALL_CARDS_TO_HEARTS_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, QUEEN_CLUBS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let beast_before = BeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Flush - points: 35, multi: 4
        // points: 6 + 10 + 4 + 10 + 10
        // multi add: 0
        // player_score = 300

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health == beast_before.current_health - 300, 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_extra_points_figure() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock special card
        let special_cards_ids = array![SPECIAL_POINTS_FOR_FIGURES_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![QUEEN_CLUBS_ID, QUEEN_HEARTS_ID, MULTI_MODIFIER_4_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1], array![100, 2]);
        // Pair - points: 10, multi: 2
        // points: 10 + 10 + 50 * 2
        // multi add: 10
        // player_score = 1560

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health.is_zero(), 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_multi_for_clubs() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock special card
        let special_cards_ids = array![SPECIAL_MULTI_FOR_CLUB_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SIX_CLUBS_ID, SIX_HEARTS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID,];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let beast_before = BeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Pair - points: 10, multi: 2
        // points: 6 + 6
        // multi add: 2
        // player_score = 88

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health == beast_before.current_health - 88, 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_multi_for_all_suits() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

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

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Straight - points: 40, multi: 4
        // points: 5 + 6 + 7 + 8 + 9
        // multi add: 2 + 2 + 2 + 2 + 2
        // player_score = 1050

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health.is_zero(), 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_multi_aces() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock special card
        let special_cards_ids = array![SPECIAL_MULTI_ACES_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2], array![100, 100, 100,]);
        // Three of a Kind - points: 30, multi: 5
        // points: 11 + 11 + 11
        // multi add: 3 + 3 + 3
        // player_score = 1134

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health.is_zero(), 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_special_lucky_seven() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock special card
        let special_cards_ids = array![SPECIAL_LUCKY_SEVEN_ID];
        mock_special_cards(ref store, ref game, special_cards_ids);

        // Mock hand
        let hand_cards_ids = array![SEVEN_CLUBS_ID, SEVEN_HEARTS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID,];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
        // Pair - points: 10, multi: 2
        // points: 7 + 7 + 77 + 77
        // multi add: 0
        // player_score = 356

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health.is_zero(), 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }
    // #[test]
// #[available_gas(30000000000000000)]
// fn test_play_special_initial_advantage() {
//     let (world, systems) = setup::spawn_game();
//     let mut store = StoreTrait::new(world);
//     let mut game = mock_game(ref store, PLAYER());
//     mock_round(ref store, @game, 300);

    //     // Mock special card
//     let special_cards_ids = array![SPECIAL_INITIAL_ADVANTAGE_ID];
//     mock_special_cards(ref store, ref game, special_cards_ids);

    //     // Mock hand
//     let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID];
//     mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

    //     set_contract_address(PLAYER());
//     systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
//     // Four of a Kind - points: 60, multi: 7
//     // points: 11 + 11 + 11 + 11 + 100
//     // multi add: 10
//     let round_after = store.get_round(game.id);
//     assert(round_after.player_score == 3468, 'wrong round player_score');
// }
}

mod test_play_beast_modifier_cards {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::constants::card::{
        JACK_CLUBS_ID, JACK_SPADES_ID, SIX_CLUBS_ID, QUEEN_CLUBS_ID, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID,
        KING_SPADES_ID, TWO_SPADES_ID, TWO_DIAMONDS_ID, TWO_CLUBS_ID, FOUR_DIAMONDS_ID, FOUR_HEARTS_ID
    };
    use jokers_ls_mod::constants::modifiers::{
        MULTI_MODIFIER_1_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID, POINTS_MODIFIER_2_ID, MULTI_MODIFIER_3_ID,
    };
    use jokers_ls_mod::models::data::beast::{
        GameModeBeast, GameModeBeastStore, Beast, BeastStore, PlayerBeast, PlayerBeastStore
    };
    use jokers_ls_mod::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
    use jokers_ls_mod::models::data::game_deck::{GameDeck};
    use jokers_ls_mod::models::data::poker_hand::{PokerHand, LevelPokerHand};
    use jokers_ls_mod::models::status::game::game::{Game, CurrentSpecialCards, GameState, GameSubState};
    use jokers_ls_mod::models::status::round::current_hand_card::{CurrentHandCard};
    use jokers_ls_mod::store::{Store, StoreTrait};

    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_ls_mod::tests::setup::{setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait};

    use jokers_ls_mod::tests::utils::{mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_level_best};

    use starknet::testing::set_contract_address;

    fn PLAYER() -> starknet::ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_modifier_high_card() {
        let (world, systems) = setup::spawn_game();

        let mut store: Store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());
        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock hand
        let hand_cards_ids = array![KING_SPADES_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let beast_before = BeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0], array![1]);

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health == beast_before.current_health - 115, 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_modifier_one_pair() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock hand
        let hand_cards_ids = array![TWO_SPADES_ID, TWO_DIAMONDS_ID, POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1], array![2, 3]);
        // Pair - points: 10, multi: 2
        // points: 2 + 2 + 100
        // multi add: 10
        // player_score = 1368

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health.is_zero(), 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }

    #[test]
    #[available_gas(30000000000000000)]
    fn test_play_two_pair() {
        let (world, systems) = setup::spawn_game();
        let mut store = StoreTrait::new(world);
        let mut game = mock_game(ref store, PLAYER());

        game.state = GameState::IN_GAME;
        game.substate = GameSubState::BEAST;
        store.set_game(game);

        mock_level_best(world, game.id);

        // Mock hand
        let hand_cards_ids = array![TWO_CLUBS_ID, TWO_SPADES_ID, FOUR_DIAMONDS_ID, FOUR_HEARTS_ID];
        mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

        let game_mode_beast = GameModeBeastStore::get(world, game.id);
        let beast_before = BeastStore::get(world, game.id);
        let player_beast_before = PlayerBeastStore::get(world, game.id);

        set_contract_address(PLAYER());
        systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
        // TwoPair - points: 20, multi: 3
        // points: 2 + 2 + 4 + 4 = 12
        // multi add: 0
        // player_score = 96

        let beast_after = BeastStore::get(world, game.id);
        assert(beast_after.current_health == beast_before.current_health - 96, 'wrong beast health');

        let player_beast_after = PlayerBeastStore::get(world, game.id);
        assert(
            player_beast_after.energy == player_beast_before.energy - game_mode_beast.cost_play, 'wrong player energy'
        );
    }
}
// mod test_rage_cards {
//     use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
//     use jokers_ls_mod::constants::card::{
//         ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID, SIX_CLUBS_ID, JOKER_CARD, FOUR_CLUBS_ID,
//         JACK_HEARTS_ID, KING_DIAMONDS_ID
//     };
//     use jokers_ls_mod::constants::specials::{SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_JOKER_BOOSTER_ID};
//     use jokers_ls_mod::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
//     use jokers_ls_mod::models::data::game_deck::{GameDeck};
//     use jokers_ls_mod::models::data::poker_hand::PokerHand;
//     use jokers_ls_mod::models::status::game::game::{Game, CurrentSpecialCards, GameState};
//     use jokers_ls_mod::models::status::round::current_hand_card::{CurrentHandCard};
//     use jokers_ls_mod::models::status::round::round::{Round};

//     use jokers_ls_mod::store::{Store, StoreTrait};

//     use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
//     use jokers_ls_mod::tests::setup::{
//         setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
//     };

//     use jokers_ls_mod::tests::utils::{
//         mock_current_hand, mock_current_hand_cards_ids, mock_game, mock_round, mock_special_cards, mock_rage_round
//     };
//     use jokers_ls_mod::utils::constants::{
//         RAGE_CARD_SILENT_DIAMONDS, RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_ZERO_WASTE, RAGE_CARD_SILENT_JOKERS
//     };
//     use starknet::testing::set_contract_address;

//     fn PLAYER() -> starknet::ContractAddress {
//         starknet::contract_address_const::<'PLAYER'>()
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_play_rage_card_silent_diamond() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let mut game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 300);

//         // Mock RageRound
//         mock_rage_round(world, game.id, array![RAGE_CARD_SILENT_DIAMONDS]);

//         // Mock hand
//         let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID];
//         mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
//         // Four of a Kind - points: 60, multi: 7
//         // points: 11 + 11 + 0 + 11
//         let round_after = store.get_round(game.id);
//         assert(round_after.player_score == 651, 'wrong round player_score');
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_play_rage_card_silent_diamond_with_special() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let mut game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 300);

//         // Mock RageRound
//         mock_rage_round(world, game.id, array![RAGE_CARD_SILENT_DIAMONDS]);

//         // Mock special card
//         let special_cards_ids = array![SPECIAL_MULTI_FOR_DIAMOND_ID];
//         mock_special_cards(ref store, ref game, special_cards_ids);

//         // Mock hand
//         let hand_cards_ids = array![ACE_CLUBS_ID, ACE_HEARTS_ID, ACE_DIAMONDS_ID, ACE_SPADES_ID];
//         mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![0, 1, 2, 3], array![100, 100, 100, 100]);
//         // Four of a Kind - points: 60, multi: 7
//         // points: 11 + 11 + 0 + 11
//         let round_after = store.get_round(game.id);
//         assert(round_after.player_score == 651, 'wrong round player_score');
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_play_rage_card_silent_jokers_with_special() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let mut game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 300);

//         // Mock RageRound
//         mock_rage_round(world, game.id, array![RAGE_CARD_SILENT_JOKERS]);

//         // Mock special card
//         let special_cards_ids = array![SPECIAL_JOKER_BOOSTER_ID];
//         mock_special_cards(ref store, ref game, special_cards_ids);

//         // Mock hand
//         let hand_cards_ids = array![SIX_CLUBS_ID, JOKER_CARD, FOUR_CLUBS_ID, JACK_HEARTS_ID, KING_DIAMONDS_ID];
//         mock_current_hand_cards_ids(ref store, game.id, hand_cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);
//         // Pair - points: 10, multi: 2
//         // points: 10
//         // player_score = 40
//         let round_after = store.get_round(game.id);
//         assert(round_after.player_score == 40, 'wrong round player_score');
//     }
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
// }

// mod test_play_validations {
//     use jokers_ls_mod::constants::card::INVALID_CARD;
//     use jokers_ls_mod::models::data::card::{Card, CardTrait, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl};
//     use jokers_ls_mod::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
//     use jokers_ls_mod::models::data::poker_hand::PokerHand;

//     use jokers_ls_mod::models::status::game::game::{Game, GameState, DefaultGame};
//     use jokers_ls_mod::models::status::round::round::Round;

//     use jokers_ls_mod::store::{Store, StoreTrait};

//     use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
//     use jokers_ls_mod::tests::setup::{setup, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait};
//     use jokers_ls_mod::tests::utils::{mock_current_hand_cards_ids, mock_game, mock_game_deck};
//     use starknet::testing::set_contract_address;

//     fn PLAYER() -> starknet::ContractAddress {
//         starknet::contract_address_const::<'PLAYER'>()
//     }

//     #[test]
//     #[available_gas(300000000000)]
//     #[should_panic(expected: ('Game: game not found', 'ENTRYPOINT_FAILED'))]
//     fn test_game_not_found() {
//         let (_, systems) = setup::spawn_game();
//         let NON_EXISTENT_GAME_ID = 1;
//         systems.game_system.play(NON_EXISTENT_GAME_ID, array![0], array![0]);
//     }

//     #[test]
//     #[available_gas(300000000000)]
//     #[should_panic(expected: ('Game: caller not owner', 'ENTRYPOINT_FAILED'))]
//     fn test_caller_not_owner() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());

//         let ANYONE = starknet::contract_address_const::<'ANYONE'>();
//         set_contract_address(ANYONE);

//         systems.game_system.play(game.id, array![0], array![0]);
//     }

//     #[test]
//     #[available_gas(300000000000)]
//     #[should_panic(expected: ('Game: invalid card index len', 'ENTRYPOINT_FAILED'))]
//     fn test_invalid_card_index() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![], array![]);
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     #[should_panic(expected: ('Game: use an invalid card', 'ENTRYPOINT_FAILED'))]
//     fn test_play_invalid_card() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 300);

//         let cards_ids = array![INVALID_CARD];
//         mock_current_hand_cards_ids(ref store, game.id, cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![0], array![100]);
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     #[should_panic(expected: ('Game: use an invalid card', 'ENTRYPOINT_FAILED'))]
//     fn test_discard_invalid_card() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 300);

//         let cards_ids = array![INVALID_CARD];
//         mock_current_hand_cards_ids(ref store, game.id, cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.discard(game.id, array![0], array![100]);
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_play_when_current_deck_is_empty_should_return_invalid_cards() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 3000);

//         let mut game_deck = mock_game_deck(world, game.id);
//         game_deck.round_len = 0;
//         GameDeckStore::set(@game_deck, world);

//         let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
//         let cards_ids = array![
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS
//         ];
//         mock_current_hand_cards_ids(ref store, game.id, cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![0, 1], array![100, 100]);

//         // Validate that the quantity of invalid cards is 2
//         let mut i = 0;
//         let mut invalid_cards_count = 0;
//         let HAND_LEN = 8;
//         loop {
//             if HAND_LEN == i {
//                 break;
//             }
//             let current_hand_card = store.get_current_hand_card(game.id, i);
//             if current_hand_card.card_id == INVALID_CARD {
//                 invalid_cards_count += 1;
//             }
//             i += 1;
//         };
//         assert(invalid_cards_count == 2, 'wrong invalid cards quantity');
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_play_when_current_deck_and_hand_are_empty_then_game_finish() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 3000);

//         // Make sure that player doenst win with next hand
//         // Set an empty current deck
//         let mut game_deck = mock_game_deck(world, game.id);
//         game_deck.round_len = 0;
//         GameDeckStore::set(@game_deck, world);

//         let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
//         let cards_ids = array![
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD
//         ];
//         mock_current_hand_cards_ids(ref store, game.id, cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.play(game.id, array![0, 1, 2, 3, 4], array![100, 100, 100, 100, 100]);

//         let game = store.get_game(game.id);
//         assert(game.state == GameState::FINISHED, 'game should be finished');
//     }

//     #[test]
//     #[available_gas(300000000000)]
//     #[should_panic(expected: ('Game: game not found', 'ENTRYPOINT_FAILED'))]
//     fn test_discard_game_not_found() {
//         let (_, systems) = setup::spawn_game();
//         let NON_EXISTENT_GAME_ID = 1;
//         systems.game_system.discard(NON_EXISTENT_GAME_ID, array![0], array![0]);
//     }

//     #[test]
//     #[available_gas(300000000000)]
//     #[should_panic(expected: ('Game: caller not owner', 'ENTRYPOINT_FAILED'))]
//     fn test_discard_caller_not_owner() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());

//         let ANYONE = starknet::contract_address_const::<'ANYONE'>();
//         set_contract_address(ANYONE);

//         systems.game_system.discard(game.id, array![0], array![0]);
//     }

//     #[test]
//     #[available_gas(300000000000)]
//     #[should_panic(expected: ('Game: is not IN_GAME', 'ENTRYPOINT_FAILED'))]
//     fn test_discard_game_not_in_progress() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let mut game = mock_game(ref store, PLAYER());
//         game.state = GameState::FINISHED;
//         store.set_game(game);

//         set_contract_address(PLAYER());
//         systems.game_system.discard(game.id, array![0], array![0]);
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_discard_when_current_deck_is_empty_and_have_invalid_cards() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 3000);

//         let mut game_deck = mock_game_deck(world, game.id);
//         game_deck.round_len = 0;
//         GameDeckStore::set(@game_deck, world);

//         let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
//         let cards_ids = array![
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD
//         ];
//         mock_current_hand_cards_ids(ref store, game.id, cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.discard(game.id, array![0, 1], array![100, 100]);

//         // Validate that the quantity of invalid cards is 7 (5 current invalid cards + 2 invalid for
//         // discard)
//         let mut i = 0;
//         let mut invalid_cards_count = 0;
//         let HAND_LEN = 8;
//         loop {
//             if HAND_LEN == i {
//                 break;
//             }
//             let current_hand_card = store.get_current_hand_card(game.id, i);
//             if current_hand_card.card_id == INVALID_CARD {
//                 invalid_cards_count += 1;
//             }
//             i += 1;
//         };
//         assert(invalid_cards_count == 7, 'wrong invalid cards quantity');
//     }

//     #[test]
//     #[available_gas(30000000000000000)]
//     fn test_discard_when_current_deck_and_hand_are_empty_then_game_finish() {
//         let (world, systems) = setup::spawn_game();
//         let mut store = StoreTrait::new(world);
//         let game = mock_game(ref store, PLAYER());
//         mock_round(ref store, @game, 3000);

//         let mut game_deck = mock_game_deck(world, game.id);
//         game_deck.round_len = 0;
//         GameDeckStore::set(@game_deck, world);

//         let TWO_OF_HEARTS = CardTrait::generate_id(Value::Two, Suit::Hearts);
//         let cards_ids = array![
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             TWO_OF_HEARTS,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD,
//             INVALID_CARD
//         ];
//         mock_current_hand_cards_ids(ref store, game.id, cards_ids);

//         set_contract_address(PLAYER());
//         systems.game_system.discard(game.id, array![0, 1, 2], array![100, 100, 100]);

//         let game = store.get_game(game.id);
//         assert(game.state == GameState::FINISHED, 'game should be finished');
//     }
// }


