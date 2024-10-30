use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::configs::rage::RageRoundConfig;
use jokers_of_neon::models::data::blister_pack::BlisterPack;
use jokers_of_neon::models::data::card::{Card, CardTrait, Suit, Value, ValueEnumerableImpl};
use jokers_of_neon::models::data::effect_card::{Effect, EffectCard, TypeEffectCard};
use jokers_of_neon::models::data::game_deck::{GameDeckImpl, GameDeck, GameDeckStore};
use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};
use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards};
use jokers_of_neon::models::status::game::player::PlayerLevelPokerHand;
use jokers_of_neon::models::status::game::rage::{RageRound, RageRoundStore};
use jokers_of_neon::models::status::round::current_hand_card::CurrentHandCard;
use jokers_of_neon::models::status::round::round::Round;
use jokers_of_neon::models::status::shop::shop::{CardItem, CardItemType, PokerHandItem, BlisterPackItem};
use jokers_of_neon::store::{Store, StoreTrait};
use jokers_of_neon::utils::shop::Shop;
use starknet::ContractAddress;

fn mock_current_hand(
    ref store: Store, game_id: u32, value_cards: Array<Value>, suit_cards: Array<Suit>, effect_cards: Array<u32>
) {
    assert(value_cards.len() == suit_cards.len(), 'wrong len cards');
    assert(value_cards.len() + effect_cards.len() == 8, 'wrong total cards');

    let mut idx = 0;
    loop {
        if idx == value_cards.len() {
            break;
        }
        store
            .set_current_hand_card(
                CurrentHandCard {
                    game_id, idx, card_id: CardTrait::generate_id(*value_cards.at(idx), *suit_cards.at(idx))
                }
            );
        idx += 1;
    };

    let mut idy = 0;
    loop {
        if idy == effect_cards.len() {
            break;
        }
        let effect_card_id = *effect_cards.at(idy);
        store.set_current_hand_card(CurrentHandCard { game_id, idx, card_id: effect_card_id });
        idx += 1;
        idy += 1;
    }
}

fn mock_current_hand_cards_ids(ref store: Store, game_id: u32, cards_ids: Array<u32>,) {
    assert(cards_ids.len() <= 8, 'max cards exceeded');

    let mut idx = 0;
    loop {
        if idx == cards_ids.len() {
            break;
        }
        let card_id = *cards_ids.at(idx);
        store.set_current_hand_card(CurrentHandCard { game_id, idx, card_id });
        idx += 1;
    };
}

fn mock_special_cards(ref store: Store, ref game: Game, special_cards: Array<u32>) {
    game.len_current_special_cards = special_cards.len();
    store.set_game(game);

    let mut idx = 0;
    loop {
        if idx == special_cards.len() {
            break;
        }
        let effect_card_id = *special_cards.at(idx);

        store
            .set_current_special_cards(
                CurrentSpecialCards { game_id: game.id, idx, effect_card_id, is_temporary: false, remaining: 0 }
            );
        idx += 1;
    }
}

fn mock_game(ref store: Store, owner: ContractAddress) -> Game {
    let mut game: Game = Default::default();
    game.owner = owner;
    game.player_name = owner.into();
    store.set_game(game);

    game
}

fn mock_round(ref store: Store, game: @Game, level_score: u32) -> Round {
    let round = Round {
        game_id: *game.id, player_score: 0, level_score: level_score, hands: *game.max_hands, discard: *game.max_discard
    };
    store.set_round(round);
    round
}

fn mock_game_deck(world: IWorldDispatcher, game_id: u32) -> GameDeck {
    let game_deck = GameDeck { game_id, len: 54, round_len: 54 };
    GameDeckStore::set(@game_deck, world);
    game_deck
}


// - Prices
// Common: 100
// Modifiers: 500
// Temporary Specials: 750
// Specials: 1000
// Poker hands: 200
fn mock_shop(
    ref store: Store,
    game_id: u32,
    commons: Span<u32>,
    modifiers: Span<u32>,
    specials: Span<u32>,
    temp_specials: Span<u32>,
    blister_packs: Span<u32>,
    poker_hands: Span<PokerHand>
) -> Shop {
    let mut commons = commons;
    let mut modifiers = modifiers;
    let mut specials = specials;
    let mut temp_specials = temp_specials;
    let mut blister_packs = blister_packs;
    let mut poker_hands = poker_hands;

    let mut shop: Shop = Default::default();
    shop.game_id = game_id;
    store.set_shop(shop);

    let mut idx = 0;
    loop {
        match commons.pop_front() {
            Option::Some(common_id) => {
                store
                    .set_card_item(
                        CardItem {
                            game_id,
                            idx,
                            item_type: CardItemType::Common,
                            card_id: *common_id,
                            cost: 100,
                            purchased: false,
                            temporary: false
                        }
                    );
                idx += 1;
            },
            Option::None => { break; }
        };
    };

    idx = 0;
    loop {
        match modifiers.pop_front() {
            Option::Some(modifier_id) => {
                store
                    .set_card_item(
                        CardItem {
                            game_id,
                            idx,
                            item_type: CardItemType::Modifier,
                            card_id: *modifier_id,
                            cost: 500,
                            purchased: false,
                            temporary: false
                        }
                    );
                idx += 1;
            },
            Option::None => { break; }
        };
    };

    idx = 0;
    loop {
        match specials.pop_front() {
            Option::Some(special_id) => {
                store
                    .set_card_item(
                        CardItem {
                            game_id: game_id,
                            idx,
                            item_type: CardItemType::Special,
                            card_id: *special_id,
                            cost: 1000,
                            purchased: false,
                            temporary: false
                        }
                    );
                idx += 1;
            },
            Option::None => { break; }
        };
    };

    idx = 0;
    loop {
        match temp_specials.pop_front() {
            Option::Some(temp_special_id) => {
                store
                    .set_card_item(
                        CardItem {
                            game_id: game_id,
                            idx,
                            item_type: CardItemType::Special,
                            card_id: *temp_special_id,
                            cost: 1000,
                            purchased: false,
                            temporary: true
                        }
                    );
                idx += 1;
            },
            Option::None => { break; }
        };
    };

    idx = 0;
    loop {
        match blister_packs.pop_front() {
            Option::Some(blister_pack_id) => {
                store
                    .set_blister_pack_item(
                        BlisterPackItem {
                            game_id: game_id, idx, blister_pack_id: *blister_pack_id, cost: 1000, purchased: false,
                        }
                    );
                idx += 1;
            },
            Option::None => { break; }
        };
    };

    idx = 0;
    loop {
        match poker_hands.pop_front() {
            Option::Some(poker_hand) => {
                store
                    .set_poker_hand_item(
                        PokerHandItem { game_id, idx, poker_hand: *poker_hand, level: 1, cost: 200, purchased: false, }
                    );
                idx += 1;
            },
            Option::None => { break; }
        }
    };
    shop
}

fn mock_empty_shop(ref store: Store, game_id: u32) -> Shop {
    let mut shop: Shop = Default::default();
    shop.game_id = game_id;
    store.set_shop(shop);
    shop
}

fn init_player_level_poker_hands(ref store: Store, game_id: u32, hand: PokerHand, level: u32) {
    let level_u8: u8 = level.try_into().unwrap();
    match hand {
        PokerHand::RoyalFlush => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::RoyalFlush, level: level_u8 }
                );
        },
        PokerHand::StraightFlush => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::StraightFlush, level: level_u8 }
                );
        },
        PokerHand::FiveOfAKind => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::FiveOfAKind, level: level_u8 }
                );
        },
        PokerHand::FourOfAKind => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::FourOfAKind, level: level_u8 }
                );
        },
        PokerHand::FullHouse => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::FullHouse, level: level_u8 }
                );
        },
        PokerHand::Flush => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::Flush, level: level_u8 }
                );
        },
        PokerHand::Straight => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::Straight, level: level_u8, }
                );
        },
        PokerHand::ThreeOfAKind => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::ThreeOfAKind, level: level_u8 }
                );
        },
        PokerHand::TwoPair => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::TwoPair, level: level_u8 }
                );
        },
        PokerHand::OnePair => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::OnePair, level: level_u8 }
                );
        },
        PokerHand::HighCard => {
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand { game_id, poker_hand: PokerHand::HighCard, level: level_u8 }
                );
        },
        PokerHand::None => {}
    };
}

fn get_current_shop_common_card_items(ref store: Store, game_id: u32) -> Array<u32> {
    let shop = store.get_shop(game_id);
    let mut cards_on_shop = array![];
    let mut idx = 0;
    loop {
        if idx == shop.len_item_common_cards {
            break;
        }
        let card_item_found = store.get_card_item(game_id, idx, CardItemType::Common);
        cards_on_shop.append(card_item_found.card_id);
        idx += 1;
    };
    cards_on_shop
}

fn mock_rage_round(world: IWorldDispatcher, game_id: u32, active_rage_ids: Array<u32>) {
    RageRoundStore::set(
        @RageRound {
            game_id: game_id,
            is_active: true,
            current_probability: 100,
            active_rage_ids: active_rage_ids.span(),
            last_active_level: 1
        },
        world
    );
}
