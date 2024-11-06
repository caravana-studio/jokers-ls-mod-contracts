use jokers_of_neon::models::{
    status::{game::game::{Game, GameStore}, round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait}}
};

#[dojo::interface]
trait IPlayerSystem {
    fn get_player_current_hand(world: @IWorldDispatcher, game_id: u32) -> Array<CurrentHandCard>;
    fn get_game(world: @IWorldDispatcher, game_id: u32) -> Game;
}

#[dojo::contract]
mod player_system {
    use jokers_of_neon::{
        store::StoreTrait,
        models::{
            status::{game::game::{Game, GameStore}, round::current_hand_card::{CurrentHandCard, CurrentHandCardStore}}
        }
    };

    #[abi(embed_v0)]
    impl PokerHandSystem of super::IPlayerSystem<ContractState> {
        fn get_player_current_hand(world: @IWorldDispatcher, game_id: u32) -> Array<CurrentHandCard> {
            let mut current_hand = array![];
            let game = GameStore::get(world, game_id);

            let mut i = 0;
            loop {
                if i == game.len_hand {
                    break;
                }
                current_hand.append(CurrentHandCardStore::get(world, game_id, i));
                i += 1;
            };
            current_hand
        }

        fn get_game(world: @IWorldDispatcher, game_id: u32) -> Game {
            GameStore::get(world, game_id)
        }
    }
}
