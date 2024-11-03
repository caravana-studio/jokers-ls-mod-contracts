use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

#[dojo::interface]
trait IERC721System {
    fn owner_of(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
}
