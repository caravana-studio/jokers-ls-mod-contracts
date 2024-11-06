use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::models::data::beast::BeastStats;
use starknet::ContractAddress;

#[dojo::interface]
trait IERC721System {
    fn owner_of(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
    fn safe_mint(ref world: IWorldDispatcher, recipient: ContractAddress, beast_stats: BeastStats);
    fn get_owner(world: @IWorldDispatcher, beast_stats: BeastStats) -> ContractAddress;
}
