use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::models::status::game::game::Game;
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::utils::constants::is_special_card;
use jokers_of_neon::utils::random::{Random, RandomImpl, RandomTrait};

fn item_in_array<
    T,
    impl TPartialEq: core::traits::PartialEq<T>,
    impl TCopy: core::traits::Copy<T>,
    impl TDrop: core::traits::Drop<T>,
>(
    array: @Array<T>, item: T
) -> bool {
    let mut array_span = array.span();
    let result = loop {
        match array_span.pop_front() {
            Option::Some(seen_elem) => { if *seen_elem == item {
                break true;
            } },
            Option::None => { break false; }
        };
    };
    result
}

fn generate_unique_random_values(
    world: IWorldDispatcher, size: u32, values: Array<u32>, exclude: Array<u32>
) -> Array<u32> {
    let mut elements: Array<u32> = ArrayTrait::new();
    let mut randomizer = RandomImpl::new(world);

    assert(size <= values.len(), 'error size unique values');
    loop {
        if elements.len() == size {
            break;
        }
        let new_elem = *values.at(randomizer.between::<u32>(0, values.len() - 1));
        if item_in_array(@exclude, new_elem) || item_in_array(@elements, new_elem) {
            continue;
        }
        elements.append(new_elem);
    };
    elements
}

fn get_current_special_cards(ref store: Store, game: @Game) -> Array<u32> {
    let mut current_special_cards = array![];
    let mut idx = 0;
    loop {
        if idx == *game.len_current_special_cards {
            break;
        }
        let current_special_card = store.get_current_special_cards(*game.id, idx);
        current_special_cards.append(current_special_card.effect_card_id);
        idx += 1;
    };
    current_special_cards
}
