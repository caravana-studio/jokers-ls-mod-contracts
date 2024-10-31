use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::models::status::game::game::Game;
use jokers_of_neon::models::status::round::deck_card::DeckCardTrait;
use jokers_of_neon::store::{Store, StoreTrait};

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
#[dojo::event]
struct CurrentHandCard {
    #[key]
    game_id: u32,
    #[key]
    idx: u32,
    card_id: u32
}

#[generate_trait]
impl CurrentHandCardImpl of CurrentHandCardTrait {
    fn create(world: IWorldDispatcher, game: Game) {
        // TODO: upgrade this solution
        let cards_indexes = if game.len_hand == 10 {
            array![0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        } else {
            array![0, 1, 2, 3, 4, 5, 6, 7]
        };
        DeckCardTrait::dealing(world, game.id, cards_indexes);
    }

    fn refresh(world: IWorldDispatcher, game_id: u32, cards_indexes: Array<u32>) {
        DeckCardTrait::dealing(world, game_id, cards_indexes);
    }
}
