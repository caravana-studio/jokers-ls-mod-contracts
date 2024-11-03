use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_ls_mod::constants::card::{JOKER_CARD, NEON_JOKER_CARD};
use jokers_ls_mod::constants::specials::{SPECIAL_HAND_THIEF_ID, SPECIAL_EXTRA_HELP_ID};
use jokers_ls_mod::models::data::game_deck::{GameDeckStore, GameDeckImpl};
use jokers_ls_mod::models::status::game::game::{Game, CurrentSpecialCards, CurrentSpecialCardsStore, GameState};
use jokers_ls_mod::store::{Store, StoreTrait};
use jokers_ls_mod::utils::constants::{is_special_card, is_modifier_card};
use jokers_ls_mod::utils::random::{Random, RandomImpl, RandomTrait};
use jokers_ls_mod::utils::shop::{get_current_special_cards, item_in_array};

fn open_blister_pack(world: IWorldDispatcher, ref store: Store, game: Game, blister_pack_id: u32) -> Span<u32> {
    let mut ret = array![];
    let mut blister_pack = store.get_blister_pack(blister_pack_id);
    let mut count_cards = 0;

    let mut guaranteed_cards = array![].span();
    let mut cards = array![];
    let mut probs = array![];
    let mut idx = 0;
    loop {
        if idx == blister_pack.cards.len() {
            break;
        }
        if idx == 0 {
            guaranteed_cards = *blister_pack.cards.at(idx);
        } else {
            cards.append(*blister_pack.cards.at(idx));
            probs.append(*blister_pack.probs.at(idx));
        }
        idx += 1;
    };

    loop {
        match guaranteed_cards.pop_front() {
            Option::Some(card_id) => {
                ret.append(*card_id);
                count_cards += 1;
            },
            Option::None => { break; }
        }
    };

    let mut randomizer = RandomImpl::new(world);
    if count_cards < blister_pack.size {
        loop {
            if count_cards == blister_pack.size {
                break;
            }
            let number_random = randomizer.between::<u32>(0, 100);
            let index_content = get_index_content(probs.span(), number_random);
            let cards_temp = *cards.at(index_content);
            let card_id_random = *cards_temp.at(randomizer.between::<u32>(0, cards_temp.len() - 1));
            if is_special_card(card_id_random) {
                let current_special_cards = get_current_special_cards(ref store, @game);
                if item_in_array(@ret, card_id_random) || item_in_array(@current_special_cards, card_id_random) {
                    continue;
                }
            }
            ret.append(card_id_random);
            count_cards += 1;
        }
    }
    ret.span()
}

fn select_cards_from_blister(
    world: IWorldDispatcher, ref game: Game, cards_result: Span<u32>, cards_index: Array<u32>
) {
    let mut idx = 0;
    loop {
        if idx == cards_index.len() {
            break;
        }
        let card_id = *cards_result.at(*cards_index.at(idx));
        if is_special_card(card_id) {
            assert(game.len_current_special_cards + 1 <= game.len_max_current_special_cards, 'special cards full');

            if card_id == SPECIAL_HAND_THIEF_ID {
                game.max_hands += 1;
                game.max_discard += 1;
            }
            if card_id == SPECIAL_EXTRA_HELP_ID {
                game.len_hand += 2;
            }

            let current_special_cards = CurrentSpecialCards {
                game_id: game.id,
                idx: game.len_current_special_cards,
                effect_card_id: card_id,
                is_temporary: false,
                remaining: 0
            };
            CurrentSpecialCardsStore::set(@current_special_cards, world);

            game.len_current_special_cards += 1;
        } else if is_modifier_card(card_id) {
            let mut game_deck = GameDeckStore::get(world, game.id);
            game_deck.add(world, card_id);
            GameDeckStore::set(@game_deck, world);
        } else {
            let mut game_deck = GameDeckStore::get(world, game.id);
            game_deck.add(world, card_id);
            GameDeckStore::set(@game_deck, world);

            // check joker
            if card_id == JOKER_CARD || card_id == NEON_JOKER_CARD {
                game.current_jokers += 1;
            }
        }
        idx += 1;
    };
}

fn get_index_content(probs: Span<u32>, number_random: u32) -> u32 {
    let mut probs = probs;
    let mut acum = 0;
    let mut idx = 0;
    loop {
        match probs.pop_front() {
            Option::Some(prob) => {
                acum += *prob;

                if number_random < acum {
                    break idx;
                }
                idx += 1;
            },
            Option::None => { break 0; }
        }
    }
}
