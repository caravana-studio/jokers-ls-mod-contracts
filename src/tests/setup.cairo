mod setup {
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use jokers_ls_mod::models::data::beast::{game_mode_beast, beast, player_beast};
    use jokers_ls_mod::models::data::challenge::{challenge, challenge_player};
    use jokers_ls_mod::models::data::game_deck::{game_deck, deck_card};
    use jokers_ls_mod::models::status::game::game::{game, current_special_cards};
    use jokers_ls_mod::models::status::game::rage::rage_round;
    use jokers_ls_mod::models::status::round::current_hand_card::current_hand_card;

    use jokers_ls_mod::models::status::shop::shop::{card_item, blister_pack_item, blister_pack_result};
    use jokers_ls_mod::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use jokers_ls_mod::systems::rage_system::{rage_system, IRageSystemDispatcher, IRageSystemDispatcherTrait};
    use starknet::ContractAddress;
    use starknet::testing::set_contract_address;

    fn OWNER() -> ContractAddress {
        starknet::contract_address_const::<0x0>()
    }

    #[starknet::interface]
    trait IDojoInit<ContractState> {
        fn dojo_init(self: @ContractState);
    }

    #[derive(Drop)]
    struct Systems {
        game_system: IGameSystemDispatcher,
        rage_system: IRageSystemDispatcher,
    }

    fn spawn_game() -> (IWorldDispatcher, Systems) {
        let mut models = array![
            challenge::TEST_CLASS_HASH,
            challenge_player::TEST_CLASS_HASH,
            game::TEST_CLASS_HASH,
            current_special_cards::TEST_CLASS_HASH,
            current_hand_card::TEST_CLASS_HASH,
            game_deck::TEST_CLASS_HASH,
            deck_card::TEST_CLASS_HASH,
            card_item::TEST_CLASS_HASH,
            blister_pack_item::TEST_CLASS_HASH,
            blister_pack_result::TEST_CLASS_HASH,
            rage_round::TEST_CLASS_HASH,
            game_mode_beast::TEST_CLASS_HASH,
            beast::TEST_CLASS_HASH,
            player_beast::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(array!["jokers_ls_mod"].span(), models.span());
        let systems = Systems {
            game_system: IGameSystemDispatcher {
                contract_address: world
                    .deploy_contract('game_system', game_system::TEST_CLASS_HASH.try_into().unwrap(),)
            },
            rage_system: IRageSystemDispatcher {
                contract_address: world
                    .deploy_contract('rage_system', rage_system::TEST_CLASS_HASH.try_into().unwrap(),)
            },
        };

        world.grant_writer(dojo::utils::bytearray_hash(@"jokers_ls_mod"), systems.game_system.contract_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"jokers_ls_mod"), systems.rage_system.contract_address);
        set_contract_address(OWNER());
        (world, systems)
    }
}
