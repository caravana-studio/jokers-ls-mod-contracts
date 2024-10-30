use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::card::INVALID_CARD;
use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardStore};
use jokers_of_neon::models::status::round::round::Round;
use jokers_of_neon::utils::random::{Random, RandomImpl, RandomTrait};

const TWO_POW_160: u256 = 0x10000000000000000000000000000000000000000;
const TWO_POW_255: u256 = 0x8000000000000000000000000000000000000000000000000000000000000000;

#[generate_trait]
impl DeckCardImpl of DeckCardTrait {
    fn dealing(world: IWorldDispatcher, ref round: Round, cards_ids: Array<u32>) {
        let mut randomizer = RandomImpl::new(world);
        let mut game_deck = GameDeckStore::get(world, round.game_id);
        let mut random = randomizer.between_u256(TWO_POW_160, TWO_POW_255);

        _dealing(world, ref game_deck, cards_ids.len(), random, round.game_id, cards_ids);
        GameDeckStore::set(@game_deck, world);
    }
}

fn _dealing(
    world: IWorldDispatcher,
    ref game_deck: GameDeck,
    remaining_cards_to_deal: u32,
    random: u256,
    game_id: u32,
    cards_ids: Array<u32>
) {
    if remaining_cards_to_deal == 0 {
        return;
    } else {
        let (r, dealed_card) = if game_deck.round_len != 0 {
            let round_len_u256: u256 = game_deck.round_len.into();
            let (r, index) = integer::U256DivRem::div_rem(random, round_len_u256.try_into().unwrap());
            (r, game_deck.deal(world, index.try_into().unwrap()))
        } else {
            (0, INVALID_CARD)
        };
        let current_hand = CurrentHandCard {
            game_id, idx: (*cards_ids.at(remaining_cards_to_deal - 1)).into(), card_id: dealed_card
        };
        CurrentHandCardStore::set(@current_hand, world);
        emit!(world, (current_hand));
        _dealing(world, ref game_deck, remaining_cards_to_deal - 1, r, game_id, cards_ids)
    }
}
