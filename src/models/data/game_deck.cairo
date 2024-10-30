use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::card::INVALID_CARD;

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct GameDeck {
    #[key]
    game_id: u32,
    len: u32,
    round_len: u32
}

#[derive(Copy, Drop, IntrospectPacked, Serde)]
#[dojo::model]
struct DeckCard {
    #[key]
    game_id: u32,
    #[key]
    index: u32,
    card_id: u32
}

#[generate_trait]
impl GameDeckImpl of IGameDeck {
    fn init(world: IWorldDispatcher, game_id: u32) {
        set!(
            world,
            (
                GameDeck { game_id, len: 54, round_len: 54 },
                DeckCard { game_id, index: 0, card_id: 0 },
                DeckCard { game_id, index: 1, card_id: 1 },
                DeckCard { game_id, index: 2, card_id: 2 },
                DeckCard { game_id, index: 3, card_id: 3 },
                DeckCard { game_id, index: 4, card_id: 4 },
                DeckCard { game_id, index: 5, card_id: 5 },
                DeckCard { game_id, index: 6, card_id: 6 },
                DeckCard { game_id, index: 7, card_id: 7 },
                DeckCard { game_id, index: 8, card_id: 8 },
                DeckCard { game_id, index: 9, card_id: 9 },
                DeckCard { game_id, index: 10, card_id: 10 },
                DeckCard { game_id, index: 11, card_id: 11 },
                DeckCard { game_id, index: 12, card_id: 12 },
                DeckCard { game_id, index: 13, card_id: 13 },
                DeckCard { game_id, index: 14, card_id: 14 },
                DeckCard { game_id, index: 15, card_id: 15 },
                DeckCard { game_id, index: 16, card_id: 16 },
                DeckCard { game_id, index: 17, card_id: 17 },
                DeckCard { game_id, index: 18, card_id: 18 },
                DeckCard { game_id, index: 19, card_id: 19 },
                DeckCard { game_id, index: 20, card_id: 20 },
                DeckCard { game_id, index: 21, card_id: 21 },
                DeckCard { game_id, index: 22, card_id: 22 },
                DeckCard { game_id, index: 23, card_id: 23 },
                DeckCard { game_id, index: 24, card_id: 24 },
                DeckCard { game_id, index: 25, card_id: 25 },
                DeckCard { game_id, index: 26, card_id: 26 },
                DeckCard { game_id, index: 27, card_id: 27 },
                DeckCard { game_id, index: 28, card_id: 28 },
                DeckCard { game_id, index: 29, card_id: 29 },
                DeckCard { game_id, index: 30, card_id: 30 },
                DeckCard { game_id, index: 31, card_id: 31 },
                DeckCard { game_id, index: 32, card_id: 32 },
                DeckCard { game_id, index: 33, card_id: 33 },
                DeckCard { game_id, index: 34, card_id: 34 },
                DeckCard { game_id, index: 35, card_id: 35 },
                DeckCard { game_id, index: 36, card_id: 36 },
                DeckCard { game_id, index: 37, card_id: 37 },
                DeckCard { game_id, index: 38, card_id: 38 },
                DeckCard { game_id, index: 39, card_id: 39 },
                DeckCard { game_id, index: 40, card_id: 40 },
                DeckCard { game_id, index: 41, card_id: 41 },
                DeckCard { game_id, index: 42, card_id: 42 },
                DeckCard { game_id, index: 43, card_id: 43 },
                DeckCard { game_id, index: 44, card_id: 44 },
                DeckCard { game_id, index: 45, card_id: 45 },
                DeckCard { game_id, index: 46, card_id: 46 },
                DeckCard { game_id, index: 47, card_id: 47 },
                DeckCard { game_id, index: 48, card_id: 48 },
                DeckCard { game_id, index: 49, card_id: 49 },
                DeckCard { game_id, index: 50, card_id: 50 },
                DeckCard { game_id, index: 51, card_id: 51 },
                DeckCard { game_id, index: 52, card_id: 52 },
                DeckCard { game_id, index: 53, card_id: 52 },
            )
        );
    }

    fn add(ref self: GameDeck, world: IWorldDispatcher, card_id: u32) {
        DeckCardStore::set(@DeckCard { game_id: self.game_id, index: self.len, card_id: card_id }, world);
        self.len += 1;
    }

    fn deal(ref self: GameDeck, world: IWorldDispatcher, index: u32) -> u32 {
        let temp_deck_card = DeckCardStore::get(world, self.game_id, index);
        let last_deck_card = DeckCardStore::get(world, self.game_id, self.round_len);

        set!(
            world,
            (
                DeckCard { game_id: self.game_id, index: temp_deck_card.index, card_id: last_deck_card.card_id },
                DeckCard { game_id: self.game_id, index: last_deck_card.index, card_id: temp_deck_card.card_id }
            )
        );

        self.round_len -= 1;
        temp_deck_card.card_id.into()
    }

    fn restore(ref self: GameDeck, world: IWorldDispatcher) {
        self.round_len = self.len;
        GameDeckStore::set(@self, world)
    }
}

