use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::models::status::shop::shop::CardItemType;

#[dojo::interface]
trait IShopSystem {
    fn skip_shop(ref world: IWorldDispatcher, game_id: u32);
    fn buy_card_item(ref world: IWorldDispatcher, game_id: u32, item_id: u32, card_item_type: CardItemType);
    fn buy_poker_hand_item(ref world: IWorldDispatcher, game_id: u32, item_id: u32);
    fn buy_blister_pack_item(ref world: IWorldDispatcher, game_id: u32, blister_pack_item_id: u32);
    fn select_cards_from_blister(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>);
    fn buy_slot_special_card_item(ref world: IWorldDispatcher, game_id: u32);
    fn reroll(ref world: IWorldDispatcher, game_id: u32);
}

mod errors {
    const GAME_NOT_FOUND: felt252 = 'Shop: game not found';
    const CALLER_NOT_OWNER: felt252 = 'Shop: caller not owner';
    const GAME_NOT_AT_SHOP: felt252 = 'Shop: game not at shop';
    const ITEM_PURCHASED: felt252 = 'Shop: item purchased';
    const INSUFFICIENT_BALANCE: felt252 = 'Shop: insufficient balance';
    const ITEM_NOT_FOUND: felt252 = 'Shop: item not found';
    const REROLL_ALREADY_EXECUTED: felt252 = 'Shop: reroll already executed';
    const POKER_HAND_MAX_LEVEL_REACHED: felt252 = 'Shop: maximum level reached';
    const INVALID_CARD_INDEX_LEN: felt252 = 'Shop: invalid card index len';
    const GAME_NOT_OPEN_BLISTER_PACK: felt252 = 'Shop: is not OPEN_BLISTER_PACK';
}

#[dojo::contract]
mod shop_system {
    use jokers_of_neon::constants::card::{JOKER_CARD, NEON_JOKER_CARD};
    use jokers_of_neon::constants::specials::{SPECIAL_HAND_THIEF_ID, SPECIAL_EXTRA_HELP_ID};
    use jokers_of_neon::models::data::events::{BuyCardEvent, BuyPokerHandEvent, BuyBlisterPackEvent, BuyRerollEvent};
    use jokers_of_neon::models::data::game_deck::{GameDeckStore, GameDeckImpl};
    use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards, GameState};
    use jokers_of_neon::models::status::game::player::PlayerLevelPokerHand;
    use jokers_of_neon::models::status::shop::shop::{CardItemType, BlisterPackResult};
    use jokers_of_neon::store::{Store, StoreTrait};
    use jokers_of_neon::utils::constants::{
        RAGE_CARD_DIMINISHED_HOLD, RAGE_CARD_ZERO_WASTE, is_special_card, is_modifier_card
    };
    use jokers_of_neon::utils::round::create_round;
    use jokers_of_neon::utils::shop::{update_items_shop, open_blister_pack};
    use starknet::get_caller_address;
    use super::{IShopSystem, errors};

    #[abi(embed_v0)]
    impl ShopImpl of IShopSystem<ContractState> {
        fn skip_shop(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::AT_SHOP, errors::GAME_NOT_AT_SHOP);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            game.state = GameState::IN_GAME;
            game.level += 1;
            store.set_game(game);

            let mut shop = store.get_shop(game_id);
            shop.reroll_executed = false;
            if shop.reroll_cost <= 1000 {
                shop.reroll_cost += 100;
            }
            store.set_shop(shop);

            create_round(world, game);
            update_items_shop(world, game);
        }

        fn buy_card_item(ref world: IWorldDispatcher, game_id: u32, item_id: u32, card_item_type: CardItemType) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::AT_SHOP, errors::GAME_NOT_AT_SHOP);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            // TODO: validar item_id

            let mut card_item = store.get_card_item(game_id, item_id, card_item_type);

            assert(!card_item.purchased, errors::ITEM_PURCHASED);
            assert(game.cash >= card_item.cost, errors::INSUFFICIENT_BALANCE);

            game.cash -= card_item.cost;
            card_item.purchased = true;

            match card_item_type {
                CardItemType::Common => {
                    let mut game_deck = GameDeckStore::get(world, game_id);
                    game_deck.add(world, card_item.card_id);
                    GameDeckStore::set(@game_deck, world);

                    // check joker
                    if card_item.card_id == JOKER_CARD || card_item.card_id == NEON_JOKER_CARD {
                        game.current_jokers += 1;
                    }
                },
                CardItemType::Modifier => {
                    let mut game_deck = GameDeckStore::get(world, game_id);
                    game_deck.add(world, card_item.card_id);
                    GameDeckStore::set(@game_deck, world);
                },
                CardItemType::Special => {
                    assert(
                        game.len_current_special_cards + 1 <= game.len_max_current_special_cards, 'special cards full'
                    );

                    if card_item.card_id == SPECIAL_HAND_THIEF_ID {
                        game.max_hands += 1;
                        game.max_discard += 1;
                    }
                    if card_item.card_id == SPECIAL_EXTRA_HELP_ID {
                        game.len_hand += 2;
                    }

                    if card_item.temporary {
                        store
                            .set_current_special_cards(
                                CurrentSpecialCards {
                                    game_id,
                                    idx: game.len_current_special_cards,
                                    effect_card_id: card_item.card_id,
                                    is_temporary: true,
                                    remaining: 3 // TODO:
                                }
                            );
                    } else {
                        store
                            .set_current_special_cards(
                                CurrentSpecialCards {
                                    game_id,
                                    idx: game.len_current_special_cards,
                                    effect_card_id: card_item.card_id,
                                    is_temporary: false,
                                    remaining: 0
                                }
                            );
                    }
                    game.len_current_special_cards += 1;
                },
                CardItemType::None => { // TODO: lanzar error
                },
            }
            store.set_game(game);
            store.set_card_item(card_item);
            // Track BuyCardEvent
            emit!(
                world,
                (BuyCardEvent {
                    game_id,
                    level: game.level,
                    idx: card_item.idx,
                    item_type: card_item.item_type,
                    card_id: card_item.card_id,
                    temporary: card_item.temporary
                })
            );
        }

        fn buy_poker_hand_item(ref world: IWorldDispatcher, game_id: u32, item_id: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::AT_SHOP, errors::GAME_NOT_AT_SHOP);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            let mut poker_hand_item = store.get_poker_hand_item(game_id, item_id);
            assert(poker_hand_item.level.is_non_zero(), errors::ITEM_NOT_FOUND);
            assert(!poker_hand_item.purchased, errors::ITEM_PURCHASED);
            assert(game.cash >= poker_hand_item.cost, errors::INSUFFICIENT_BALANCE);

            game.cash -= poker_hand_item.cost;
            poker_hand_item.purchased = true;

            let player_level_poker_hand = store.get_player_level_poker_hand(game_id, poker_hand_item.poker_hand);
            assert(player_level_poker_hand.level < 10, errors::POKER_HAND_MAX_LEVEL_REACHED);
            store
                .set_player_level_poker_hand(
                    PlayerLevelPokerHand {
                        game_id: game_id, poker_hand: poker_hand_item.poker_hand, level: poker_hand_item.level,
                    }
                );
            store.set_game(game);
            store.set_poker_hand_item(poker_hand_item);

            // Track BuyPokerHand
            emit!(
                world,
                (BuyPokerHandEvent {
                    game_id,
                    level: game.level,
                    idx: poker_hand_item.idx,
                    poker_hand: poker_hand_item.poker_hand,
                    level_hand: poker_hand_item.level
                })
            );
        }

        fn buy_blister_pack_item(ref world: IWorldDispatcher, game_id: u32, blister_pack_item_id: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::AT_SHOP, errors::GAME_NOT_AT_SHOP);

            let mut blister_pack_item = store.get_blister_pack_item(game_id, blister_pack_item_id);
            assert(blister_pack_item.blister_pack_id.is_non_zero(), errors::ITEM_NOT_FOUND);
            assert(!blister_pack_item.purchased, errors::ITEM_PURCHASED);
            assert(game.cash >= blister_pack_item.cost, errors::INSUFFICIENT_BALANCE);

            game.cash -= blister_pack_item.cost;
            game.state = GameState::OPEN_BLISTER_PACK;
            blister_pack_item.purchased = true;

            let cards = open_blister_pack(world, ref store, game, blister_pack_item.blister_pack_id);
            store.set_blister_pack_result(BlisterPackResult { game_id, cards_picked: false, cards });

            store.set_game(game);
            store.set_blister_pack_item(blister_pack_item);

            // Track BuyBlisterPackEvent
            emit!(
                world,
                (BuyBlisterPackEvent {
                    game_id,
                    level: game.level,
                    idx: blister_pack_item.idx,
                    blister_pack_id: blister_pack_item.blister_pack_id
                })
            );
        }

        fn select_cards_from_blister(ref world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            // Check that the game exists (if the game has no owner means it does not exists)
            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);

            // Check that the owner of the game is the caller
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            // Check that the status of the game
            assert(game.state == GameState::OPEN_BLISTER_PACK, errors::GAME_NOT_OPEN_BLISTER_PACK);

            let blister_pack_result = store.get_blister_pack_result(game.id);
            assert(cards_index.len() <= blister_pack_result.cards.len(), errors::INVALID_CARD_INDEX_LEN);

            let mut idx = 0;
            loop {
                if idx == cards_index.len() {
                    break;
                }
                let card_id = *blister_pack_result.cards.at(*cards_index.at(idx));
                if is_special_card(card_id) {
                    assert(
                        game.len_current_special_cards + 1 <= game.len_max_current_special_cards, 'special cards full'
                    );

                    if card_id == SPECIAL_HAND_THIEF_ID {
                        game.max_hands += 1;
                        game.max_discard += 1;
                    }
                    if card_id == SPECIAL_EXTRA_HELP_ID {
                        game.len_hand += 2;
                    }

                    store
                        .set_current_special_cards(
                            CurrentSpecialCards {
                                game_id,
                                idx: game.len_current_special_cards,
                                effect_card_id: card_id,
                                is_temporary: false,
                                remaining: 0
                            }
                        );

                    game.len_current_special_cards += 1;
                } else if is_modifier_card(card_id) {
                    let mut game_deck = GameDeckStore::get(world, game_id);
                    game_deck.add(world, card_id);
                    GameDeckStore::set(@game_deck, world);
                } else {
                    let mut game_deck = GameDeckStore::get(world, game_id);
                    game_deck.add(world, card_id);
                    GameDeckStore::set(@game_deck, world);

                    // check joker
                    if card_id == JOKER_CARD || card_id == NEON_JOKER_CARD {
                        game.current_jokers += 1;
                    }
                }
                idx += 1;
            };

            let mut blister_pack_result = store.get_blister_pack_result(game.id);
            blister_pack_result.cards_picked = true;
            store.set_blister_pack_result(blister_pack_result);

            game.state = GameState::AT_SHOP;
            store.set_game(game);
        }

        fn buy_slot_special_card_item(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::AT_SHOP, errors::GAME_NOT_AT_SHOP);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);

            let mut slot_special_cards_item = store.get_slot_special_cards_item(game_id);

            assert(!slot_special_cards_item.purchased, errors::ITEM_PURCHASED);
            assert(game.cash >= slot_special_cards_item.cost, errors::INSUFFICIENT_BALANCE);

            game.cash -= slot_special_cards_item.cost;
            game.len_max_current_special_cards += 1;

            slot_special_cards_item.purchased = true;

            store.set_game(game);
            store.set_slot_special_cards_item(slot_special_cards_item);
        }

        fn reroll(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);
            let mut game = store.get_game(game_id);

            assert(game.owner.is_non_zero(), errors::GAME_NOT_FOUND);
            assert(game.owner == get_caller_address(), errors::CALLER_NOT_OWNER);
            assert(game.state == GameState::AT_SHOP, errors::GAME_NOT_AT_SHOP);

            let mut shop = store.get_shop(game_id);
            assert(shop.reroll_executed == false, errors::REROLL_ALREADY_EXECUTED);
            assert(game.cash >= shop.reroll_cost, errors::INSUFFICIENT_BALANCE);

            game.cash -= shop.reroll_cost;
            shop.reroll_executed = true;
            update_items_shop(world, game);
            store.set_game(game);
            store.set_shop(shop);

            // Track Reroll
            emit!(
                world,
                (BuyRerollEvent { game_id, level: game.level, reroll_cost: shop.reroll_cost, reroll_executed: true, })
            );
        }
    }
}
