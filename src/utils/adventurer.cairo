use dojo::world::Resource::Contract;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use starknet::{ContractAddress, contract_address_const};

const MAINNET_CHAIN_ID: felt252 = 0x534e5f4d41494e;

fn is_mainnet(chain_id: felt252) -> bool {
    chain_id == MAINNET_CHAIN_ID
}

fn ADVENTURER_ADDRESS_MAINNET() -> ContractAddress {
    contract_address_const::<0x018108b32cea514a78ef1b0e4a0753e855cdf620bc0565202c02456f618c4dc4>()
}

fn NFT_ADDRESS_MAINNET() -> ContractAddress {
    contract_address_const::<0x07268fcf96383f8691b91ba758cc8fefe0844146f0557909345b841fb1de042f>()
}
