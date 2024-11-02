#[dojo::interface]
trait IERC721System {
    fn owner_of(ref world: IWorldDispatcher, token_id: u256) -> bool;
}

#[dojo::contract]
mod erc721_system {
    #[abi(embed_v0)]
    impl ERC721Impl of super::IERC721System<ContractState> {
        fn owner_of(ref world: IWorldDispatcher, token_id: u256) -> bool {
            true
        }
    }
}
