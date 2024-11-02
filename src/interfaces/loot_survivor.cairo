use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Drop, Copy, Serde)]
struct Adventurer {
    xp: u16
}

#[dojo::interface]
trait ILootSurvivorSystem {
    fn get_adventurer(world: @IWorldDispatcher, adventurer_id: felt252) -> Adventurer;
}
