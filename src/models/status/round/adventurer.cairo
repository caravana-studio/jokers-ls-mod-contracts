use core::num::traits::{Sqrt};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use jokers_of_neon::interfaces::erc721::{IERC721SystemDispatcher, IERC721SystemDispatcherTrait};
use jokers_of_neon::interfaces::loot_survivor::{ILootSurvivorSystemDispatcher, ILootSurvivorSystemDispatcherTrait};
use jokers_of_neon::models::data::adventurer::{AdventurerConsumed, AdventurerConsumedStore};
use jokers_of_neon::utils::adventurer::get_adventurer_address;
use starknet::{ContractAddress, get_caller_address, get_tx_info};

mod errors {
    const NOT_TOKEN_OWNER: felt252 = 'Not token owner';
    const ADVENTURER_CONSUMED: felt252 = 'Adventurer consumed';
}

#[generate_trait]
impl AdventurerImpl of AdventurerTrait {
    fn use_adventurer(world: IWorldDispatcher, adventurer_id: u32) {
        let adventurer_address = get_adventurer_address(world, get_tx_info().unbox().chain_id);

        let erc721_dispatcher = IERC721SystemDispatcher { contract_address: adventurer_address };
        let owner = erc721_dispatcher.owner_of(adventurer_id.into());
        assert(owner == get_caller_address(), errors::NOT_TOKEN_OWNER);

        let mut adventurer_consumed = AdventurerConsumedStore::get(world, adventurer_id);
        assert(!adventurer_consumed.consumed, errors::ADVENTURER_CONSUMED);

        //obtener el nivel y modificar el health
        let loot_survivor_dispatcher = ILootSurvivorSystemDispatcher { contract_address: adventurer_address };
        let adventurer = loot_survivor_dispatcher.get_adventurer(adventurer_id.into());
        let level = get_level_from_xp(adventurer.xp);

        adventurer_consumed.consumed = true;
        AdventurerConsumedStore::set(@adventurer_consumed, world);
    }
}

fn get_level_from_xp(xp: u16) -> u8 {
    if (xp == 0) {
        1
    } else {
        xp.sqrt()
    }
}
