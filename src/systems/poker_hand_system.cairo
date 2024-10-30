use jokers_of_neon::models::data::poker_hand::LevelPokerHand;

#[dojo::interface]
trait IPokerHandSystem {
    fn get_player_poker_hands(world: @IWorldDispatcher, game_id: u32) -> Array<LevelPokerHand>;
}

#[dojo::contract]
mod poker_hand_system {
    use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};
    use jokers_of_neon::store::StoreTrait;
    use jokers_of_neon::utils::constants::poker_hands_all;

    #[abi(embed_v0)]
    impl PokerHandSystem of super::IPokerHandSystem<ContractState> {
        fn get_player_poker_hands(world: @IWorldDispatcher, game_id: u32) -> Array<LevelPokerHand> {
            let mut store = StoreTrait::new(world);
            let mut poker_hands_span = poker_hands_all().span();
            let mut result = array![];
            loop {
                match poker_hands_span.pop_front() {
                    Option::Some(poker_hand) => {
                        result.append(store.get_level_poker_hand((*poker_hand).try_into().unwrap(), 1));
                    },
                    Option::None => { break; }
                };
            };
            result
        }
    }
}
