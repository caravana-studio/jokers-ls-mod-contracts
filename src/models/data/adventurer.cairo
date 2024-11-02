use starknet::ContractAddress;

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct AdventurerConsumed {
    #[key]
    adventurer_id: u32,
    owner: ContractAddress,
    consumed: bool
}
