use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
use jokers_of_neon::models::data::adventurer::{
    AdventurerConsumed, AdventurerConsumedStore
};
use jokers_of_neon::utils::adventurer::get_adventurer_address;
use starknet::{ContractAddress, get_caller_address, get_tx_info};

mod errors {
    const NOT_TOKEN_OWNER: felt252 = 'Not token owner';
    const ADVENTURER_CONSUMED: felt252 = 'Adventurer consumed';
}

#[generate_trait]
impl AdventurerImpl of AdventurerTrait {

    fn use_adventurer(world: IWorldDispatcher, adventurer_id: u32) {
        assert_adventurer_ownership(adventurer_id);
        let mut adventurer_consumed = AdventurerConsumedStore::get(world, adventurer_id);
        assert(!adventurer_consumed.consumed, errors::ADVENTURER_CONSUMED);
        adventurer_consumed.consumed = true;
        AdventurerConsumedStore::set(@adventurer_consumed, world);
    }
}

fn assert_adventurer_ownership(token_id: u32) {
    let owner = get_owner_of_adventurer(token_id);
    assert(owner == get_caller_address(), errors::NOT_TOKEN_OWNER);
}

fn get_owner_of_adventurer(token_id: u32) -> ContractAddress {
    let adventurer_address = get_adventurer_address(get_tx_info().unbox().chain_id);
    let erc721_dispatcher = IERC721Dispatcher { contract_address: adventurer_address };
    erc721_dispatcher.owner_of(token_id.into())
}

// fn _get_adventurer(self: @ContractState, token_id: u32) -> Adventurer {
//     let adventurer_address = utils::ADVENTURER_ADDRESS_MAINNET();
//     let game_dispatcher = IGameDispatcher { contract_address: adventurer_address };

//     let adventurer = game_dispatcher.get_adventurer(token_id.into());
//     let adventurer_meta = game_dispatcher.get_adventurer_meta(token_id.into());

//     Adventurer {
//         level: Self::_get_level_from_xp(adventurer.xp),
//         health: adventurer.health,
//         rank_at_death: adventurer_meta.rank_at_death,
//     }
// }