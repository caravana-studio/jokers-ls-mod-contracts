use dojo::world::Resource::Contract;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use starknet::{ContractAddress, contract_address_const};

const MAINNET_CHAIN_ID: felt252 = 0x534e5f4d41494e;

fn get_adventurer_address(world: IWorldDispatcher, chain_id: felt252) -> ContractAddress {
    if chain_id == MAINNET_CHAIN_ID {
        ADVENTURER_ADDRESS_MAINNET()
    } else {
        let (_, erc721_system_address) = match world.resource(selector_from_tag!("jokers_of_neon-erc721_system")) {
            Contract((class_hash, contract_address)) => Option::Some((class_hash, contract_address)),
            _ => Option::None
        }.unwrap();
        erc721_system_address
    }
}

fn ADVENTURER_ADDRESS_MAINNET() -> ContractAddress {
    contract_address_const::<0x018108b32cea514a78ef1b0e4a0753e855cdf620bc0565202c02456f618c4dc4>()
}
