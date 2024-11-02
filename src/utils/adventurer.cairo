use starknet::{ContractAddress, contract_address_const};

const MAINNET_CHAIN_ID: felt252 = 0x534e5f4d41494e;

fn get_adventurer_address(chain_id: felt252) -> ContractAddress {
    if chain_id == MAINNET_CHAIN_ID {
        ADVENTURER_ADDRESS_MAINNET()
    } else {
        panic_with_felt252('Chain not supported')
    }
}

fn ADVENTURER_ADDRESS_MAINNET() -> ContractAddress {
    contract_address_const::<0x018108b32cea514a78ef1b0e4a0753e855cdf620bc0565202c02456f618c4dc4>()
}