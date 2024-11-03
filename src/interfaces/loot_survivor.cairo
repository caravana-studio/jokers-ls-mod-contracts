use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
#[derive(Drop, Copy, PartialEq, Serde)]
struct Item { // 21 storage bits
    id: u8, // 7 bits
    xp: u16, // 9 bits
}

#[derive(Drop, Copy, Serde, PartialEq)]
struct Equipment { // 128 bits
    weapon: Item,
    chest: Item,
    head: Item,
    waist: Item, // 16 bits per item
    foot: Item,
    hand: Item,
    neck: Item,
    ring: Item,
}

#[derive(Drop, Copy, Serde, PartialEq)]
struct Stats { // 30 bits total
    strength: u8,
    dexterity: u8,
    vitality: u8, // 5 bits per stat
    intelligence: u8,
    wisdom: u8,
    charisma: u8,
    luck: u8 // dynamically generated, not stored.
}

#[derive(Drop, Copy, Serde)]
struct Adventurer {
    health: u16, // 10 bits
    xp: u16, // 15 bits
    gold: u16, // 9 bits
    beast_health: u16, // 10 bits
    stat_upgrades_available: u8, // 4 bits
    stats: Stats, // 30 bits
    equipment: Equipment, // 128 bits
    battle_action_count: u8, // 8 bits
    mutated: bool, // not packed
    awaiting_item_specials: bool, // not packed
}

#[dojo::interface]
trait ILootSurvivorSystem {
    fn get_adventurer(world: @IWorldDispatcher, adventurer_id: felt252) -> Adventurer;
}
