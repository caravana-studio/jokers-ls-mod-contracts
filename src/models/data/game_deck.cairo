use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_ls_mod::constants::card::{
    ACE_CLUBS_ID, ACE_DIAMONDS_ID, ACE_HEARTS_ID, ACE_SPADES_ID, JOKER_CARD, INVALID_CARD, OVERLORD_DECK, WARRIOR_DECK,
    traditional_cards_all
};
use jokers_ls_mod::constants::modifiers::{POINTS_MODIFIER_4_ID, MULTI_MODIFIER_4_ID};
use jokers_ls_mod::store::{Store, StoreTrait};

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
    fn init(ref store: Store, game_id: u32, deck_id: u8, extra_cards: Array<u32>) {
        // Traditional Deck
        let mut cards = traditional_cards_all();
        cards.append(JOKER_CARD);
        cards.append(JOKER_CARD);

        let mut extra_cards_span = extra_cards.span();
        loop {
            match extra_cards_span.pop_front() {
                Option::Some(extra_card) => { cards.append(*extra_card); },
                Option::None => { break; },
            }
        };

        store.create_deck(game_id, cards);
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

