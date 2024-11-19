use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_ls_mod::constants::{
    card::INVALID_CARD,
    challenge::{
        CHALLENGE_ROYAL_FLUSH, CHALLENGE_STRAIGHT_FLUSH, CHALLENGE_FIVE_OF_A_KIND, CHALLENGE_FOUR_OF_A_KIND,
        CHALLENGE_FULL_HOUSE, CHALLENGE_FLUSH, CHALLENGE_STRAIGHT, CHALLENGE_THREE_OF_A_KIND, CHALLENGE_DOUBLE_PAIR,
        CHALLENGE_PAIR, CHALLENGE_HIGH_CARD, CHALLENGE_HEARTS, CHALLENGE_CLUBS, CHALLENGE_DIAMONDS, CHALLENGE_SPADES,
        CHALLENGE_TWO, CHALLENGE_THREE, CHALLENGE_FOUR, CHALLENGE_FIVE, CHALLENGE_SIX, CHALLENGE_SEVEN, CHALLENGE_EIGHT,
        CHALLENGE_NINE, CHALLENGE_TEN, CHALLENGE_JACK, CHALLENGE_QUEEN, CHALLENGE_KING, CHALLENGE_ACE, CHALLENGE_JOKER,
        CHALLENGE_500_POINTS, CHALLENGE_1000_POINTS, CHALLENGE_2000_POINTS, CHALLENGE_5000_POINTS, challenges_all
    },
    specials::SPECIAL_ALL_CARDS_TO_HEARTS_ID,
};

use jokers_ls_mod::{
    models::{
        data::{
            challenge::{Challenge, ChallengeStore, ChallengePlayer, ChallengePlayerStore}, card::{Card, Suit, Value},
            game_deck::{GameDeckStore, GameDeckImpl},
            events::{
                ChallengeCompleted, ItemChallengeCompleted, PlayGameOverEvent, ModifierCardSuitEvent,
                SpecialModifierSuitEvent, ObstacleAttack, ObstacleHandScore, PlayerScore
            },
            poker_hand::PokerHand, reward::RewardTrait
        },
        status::{
            game::game::{Game, GameState, GameSubState, GameStore},
            round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait}
        },
    },
    store::{Store, StoreTrait},
    utils::{
        game::{play as calculate_hand_score}, calculate_hand::calculate_hand, random::{Random, RandomImpl, RandomTrait}
    }
};
use starknet::get_caller_address;

mod errors {
    const STATE_NOT_IN_GAME: felt252 = 'State not IN_GAME';
    const SUBSTATE_NOT_OBSTACLE: felt252 = 'Substate not OBSTACLE';
    const USE_INVALID_CARD: felt252 = 'Use an invalid card';
    const ARRAY_REPEATED_ELEMENTS: felt252 = 'Array has repeated elements';
    const OUT_OF_PLAYS: felt252 = 'Out of plays';
    const OUT_OF_DISCARDS: felt252 = 'Out of discards';
}

#[generate_trait]
impl ChallengeImpl of ChallengeTrait {
    fn create(world: IWorldDispatcher, ref store: Store, game_id: u32) {
        let mut game = store.get_game(game_id);

        let mut challenge = ChallengeStore::get(world, game_id);

        challenge
            .active_ids =
                if game.level <= 5 {
                    _generate_random_challenges(world, 2, challenges_all(), array![]).span()
                } else {
                    _generate_random_challenges(world, 3, challenges_all(), array![]).span()
                };
        ChallengeStore::set(@challenge, world);
        emit!(world, (challenge));

        let challenge_player = ChallengePlayer { game_id, discards: game.max_discard, plays: game.max_hands };
        ChallengePlayerStore::set(@challenge_player, world);
        emit!(world, (challenge_player));

        let mut game_deck = GameDeckStore::get(world, game_id);
        game_deck.restore(world);
        CurrentHandCardTrait::create(world, game);
    }

    fn play(world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
        let mut game = GameStore::get(world, game_id);
        assert(game.state == GameState::IN_GAME, errors::STATE_NOT_IN_GAME);
        assert(game.substate == GameSubState::OBSTACLE, errors::SUBSTATE_NOT_OBSTACLE);

        let mut challenge_player = ChallengePlayerStore::get(world, game_id);
        assert(challenge_player.plays > 0, errors::OUT_OF_PLAYS);

        let mut store = StoreTrait::new(world);
        let mut current_special_cards_index = _current_special_cards(ref store, @game);
        let (mut cards, _, _) = _get_cards(
            world, ref store, game.id, @cards_index, @modifiers_index, ref current_special_cards_index
        );
        let (result_hand, mut hit_cards) = calculate_hand(@cards, ref current_special_cards_index);
        let hand_score = calculate_hand_score(world, ref game, @cards_index, @modifiers_index);

        emit!(world, (ObstacleHandScore { player: get_caller_address(), hand_score }));

        let mut challenge = ChallengeStore::get(world, game_id);
        _resolve_challenges(world, ref challenge, result_hand, ref hit_cards, @cards, hand_score);
        ChallengeStore::set(@challenge, world);

        if Self::is_completed(world, game_id) {
            emit!(world, ChallengeCompleted { player: game.owner, player_name: game.player_name, game_id });
            game.player_score += challenge.active_ids.len() * 100;
            game.obstacles_cleared += 1;
            game.substate = GameSubState::CREATE_REWARD;
            RewardTrait::challenge(world, game_id);

            GameStore::set(@game, world);
        } else {
            challenge_player.plays -= 1;
            ChallengePlayerStore::set(@challenge_player, world);
            emit!(world, (challenge_player));
            ChallengePlayerStore::set(@challenge_player, world);
            if challenge_player.plays.is_zero() {
                let challenge_attack = 5 * game.level;
                game
                    .current_player_hp =
                        if game.current_player_hp <= challenge_attack {
                            0
                        } else {
                            game.current_player_hp - challenge_attack
                        };

                if game.current_player_hp.is_zero() {
                    let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
                    emit!(world, (play_game_over_event));

                    emit!(
                        world,
                        (PlayerScore {
                            player: game.owner,
                            player_name: game.player_name,
                            player_score: game.player_score,
                            player_level: game.player_level,
                            obstacles_cleared: game.obstacles_cleared,
                            beasts_defeated: game.beasts_defeated
                        })
                    );

                    game.state = GameState::FINISHED;
                    return;
                }

                emit!(world, ObstacleAttack { player: game.owner, attack: challenge_attack });
                game.substate = GameSubState::UNPASSED_OBSTACLE;
                GameStore::set(@game, world);
                return;
            }

            let mut cards = array![];
            let mut idx = 0;
            loop {
                if idx == cards_index.len() {
                    break;
                }
                cards.append(*cards_index.at(idx));
                idx += 1;
            };

            idx = 0;
            loop {
                if idx == modifiers_index.len() {
                    break;
                }
                let card_index = *modifiers_index.at(idx);
                if card_index != 100 {
                    cards.append(card_index);
                }
                idx += 1;
            };

            CurrentHandCardTrait::refresh(world, game_id, cards);

            let game_deck = GameDeckStore::get(world, game_id);
            if game_deck.round_len.is_zero() && _player_has_empty_hand(ref store, @game) {
                let challenge_attack = 5 * game.level;
                game
                    .current_player_hp =
                        if game.current_player_hp <= challenge_attack {
                            0
                        } else {
                            game.current_player_hp - challenge_attack
                        };

                if game.current_player_hp.is_zero() {
                    let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
                    emit!(world, (play_game_over_event));

                    emit!(
                        world,
                        (PlayerScore {
                            player: game.owner,
                            player_name: game.player_name,
                            player_score: game.player_score,
                            player_level: game.player_level,
                            obstacles_cleared: game.obstacles_cleared,
                            beasts_defeated: game.beasts_defeated
                        })
                    );

                    game.state = GameState::FINISHED;
                    return;
                }

                emit!(world, ObstacleAttack { player: game.owner, attack: challenge_attack });
                game.substate = GameSubState::UNPASSED_OBSTACLE;
                GameStore::set(@game, world);
                return;
            }
        }
    }

    fn discard(world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
        let mut game = GameStore::get(world, game_id);
        assert(game.state == GameState::IN_GAME, errors::STATE_NOT_IN_GAME);
        assert(game.substate == GameSubState::OBSTACLE, errors::SUBSTATE_NOT_OBSTACLE);

        let mut challenge_player = ChallengePlayerStore::get(world, game_id);
        assert(challenge_player.discards > 0, errors::OUT_OF_DISCARDS);

        let mut store = StoreTrait::new(world);
        let mut cards = array![];
        let mut idx = 0;
        loop {
            if idx == cards_index.len() {
                break;
            }
            let current_hand_card = store.get_current_hand_card(game_id, *cards_index.at(idx));
            assert(current_hand_card.card_id != INVALID_CARD, errors::USE_INVALID_CARD);

            cards.append(*cards_index.at(idx));
            idx += 1;
        };

        idx = 0;
        loop {
            if idx == modifiers_index.len() {
                break;
            }
            let card_index = *modifiers_index.at(idx);
            if card_index != 100 {
                cards.append(card_index);
            }
            idx += 1;
        };
        CurrentHandCardTrait::refresh(world, game_id, cards);

        challenge_player.discards -= 1;
        emit!(world, (challenge_player));
        ChallengePlayerStore::set(@challenge_player, world);

        let game_deck = GameDeckStore::get(world, game_id);
        if game_deck.round_len.is_zero() && _player_has_empty_hand(ref store, @game) {
            let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
            emit!(world, (play_game_over_event));

            emit!(
                world,
                (PlayerScore {
                    player: game.owner,
                    player_name: game.player_name,
                    player_score: game.player_score,
                    player_level: game.player_level,
                    obstacles_cleared: game.obstacles_cleared,
                    beasts_defeated: game.beasts_defeated
                })
            );

            game.state = GameState::FINISHED;
            store.set_game(game);
        }
    }

    fn is_completed(world: IWorldDispatcher, game_id: u32) -> bool {
        let mut active_challenges_ids = ChallengeStore::get(world, game_id).active_ids;
        let mut is_completed = true;
        loop {
            match active_challenges_ids.pop_front() {
                Option::Some(challenge) => {
                    let (_, completed) = *challenge;
                    is_completed = is_completed && completed;
                },
                Option::None => { break; }
            }
        };
        is_completed
    }
}

fn _resolve_challenges(
    world: IWorldDispatcher,
    ref challenge: Challenge,
    result_hand: PokerHand,
    ref hit_cards: Felt252Dict<bool>,
    cards: @Array<Card>,
    hand_score: u32,
) {
    match result_hand {
        PokerHand::RoyalFlush => _complete(world, ref challenge, CHALLENGE_ROYAL_FLUSH),
        PokerHand::StraightFlush => _complete(world, ref challenge, CHALLENGE_STRAIGHT_FLUSH),
        PokerHand::FiveOfAKind => _complete(world, ref challenge, CHALLENGE_FIVE_OF_A_KIND),
        PokerHand::FourOfAKind => _complete(world, ref challenge, CHALLENGE_FOUR_OF_A_KIND),
        PokerHand::FullHouse => _complete(world, ref challenge, CHALLENGE_FULL_HOUSE),
        PokerHand::Straight => _complete(world, ref challenge, CHALLENGE_STRAIGHT),
        PokerHand::Flush => _complete(world, ref challenge, CHALLENGE_FLUSH),
        PokerHand::ThreeOfAKind => _complete(world, ref challenge, CHALLENGE_THREE_OF_A_KIND),
        PokerHand::TwoPair => _complete(world, ref challenge, CHALLENGE_DOUBLE_PAIR),
        PokerHand::OnePair => _complete(world, ref challenge, CHALLENGE_PAIR),
        PokerHand::HighCard => _complete(world, ref challenge, CHALLENGE_HIGH_CARD),
        PokerHand::None => (),
    };

    if hand_score >= 5000 {
        _complete(world, ref challenge, CHALLENGE_5000_POINTS);
    }
    if hand_score >= 2000 {
        _complete(world, ref challenge, CHALLENGE_2000_POINTS);
    }
    if hand_score >= 1000 {
        _complete(world, ref challenge, CHALLENGE_1000_POINTS);
    }
    if hand_score >= 500 {
        _complete(world, ref challenge, CHALLENGE_500_POINTS);
    }

    let mut idx = 0;
    loop {
        if idx == cards.len() {
            break;
        }

        let hit = hit_cards.get(idx.into());
        if hit {
            let card = *cards.at(idx);
            match card.value {
                Value::Two => { _complete(world, ref challenge, CHALLENGE_TWO); },
                Value::Three => { _complete(world, ref challenge, CHALLENGE_THREE); },
                Value::Four => { _complete(world, ref challenge, CHALLENGE_FOUR); },
                Value::Five => { _complete(world, ref challenge, CHALLENGE_FIVE); },
                Value::Six => { _complete(world, ref challenge, CHALLENGE_SIX); },
                Value::Seven => { _complete(world, ref challenge, CHALLENGE_SEVEN); },
                Value::Eight => { _complete(world, ref challenge, CHALLENGE_EIGHT); },
                Value::Nine => { _complete(world, ref challenge, CHALLENGE_NINE); },
                Value::Ten => { _complete(world, ref challenge, CHALLENGE_TEN); },
                Value::Jack => { _complete(world, ref challenge, CHALLENGE_JACK); },
                Value::Queen => { _complete(world, ref challenge, CHALLENGE_QUEEN); },
                Value::King => { _complete(world, ref challenge, CHALLENGE_KING); },
                Value::Ace => { _complete(world, ref challenge, CHALLENGE_ACE); },
                Value::Joker => { _complete(world, ref challenge, CHALLENGE_JOKER); },
                Value::NeonJoker => { _complete(world, ref challenge, CHALLENGE_JOKER); },
                Value::None => {},
            };

            match card.suit {
                Suit::Clubs => { _complete(world, ref challenge, CHALLENGE_CLUBS); },
                Suit::Hearts => { _complete(world, ref challenge, CHALLENGE_HEARTS); },
                Suit::Spades => { _complete(world, ref challenge, CHALLENGE_SPADES); },
                Suit::Diamonds => { _complete(world, ref challenge, CHALLENGE_DIAMONDS); },
                Suit::Joker => { _complete(world, ref challenge, CHALLENGE_JOKER); },
                Suit::None => {},
            };
        }
        idx += 1;
    };
}

fn _complete(world: IWorldDispatcher, ref challenge: Challenge, _challenge_id: u32) {
    let mut remaining_challenges = array![];
    loop {
        match challenge.active_ids.pop_front() {
            Option::Some(challenge_pop) => {
                let (challenge_id, completed) = *challenge_pop;
                if challenge_id == _challenge_id && !completed {
                    remaining_challenges.append((challenge_id, true));
                    emit!(world, ItemChallengeCompleted { game_id: challenge.game_id, challenge_id: challenge_id });
                } else {
                    remaining_challenges.append((challenge_id, completed));
                }
            },
            Option::None => { break; },
        }
    };
    challenge.active_ids = remaining_challenges.span();
}

fn _player_has_empty_hand(ref store: Store, game: @Game) -> bool {
    let mut i = 0;
    loop {
        if game.len_hand == @i {
            break true;
        }
        let deck_card = store.get_current_hand_card(*game.id, i);
        if deck_card.card_id != INVALID_CARD {
            break false;
        }
        i += 1;
    }
}

fn _current_special_cards(ref store: Store, game: @Game) -> Felt252Dict<Nullable<u32>> {
    let mut current_special_cards_index: Felt252Dict<Nullable<u32>> = Default::default();
    let mut idx = 0;
    loop {
        if idx == *game.len_current_special_cards {
            break;
        }
        let current_special_card = store.get_current_special_cards(*game.id, idx);
        current_special_cards_index.insert(current_special_card.effect_card_id.into(), NullableTrait::new(idx));
        idx += 1;
    };
    current_special_cards_index
}

fn _get_cards(
    world: IWorldDispatcher,
    ref store: Store,
    game_id: u32,
    cards_index: @Array<u32>,
    modifiers_index: @Array<u32>,
    ref current_special_cards_index: Felt252Dict<Nullable<u32>>
) -> (Array<Card>, Array<u32>, Array<u32>) {
    assert(!_has_repeated(cards_index), errors::ARRAY_REPEATED_ELEMENTS);
    let mut cards = array![];
    let mut effect_id_cards_1 = array![];
    let mut effect_id_cards_2 = array![];
    let mut idx = 0;
    loop {
        if idx == cards_index.len() {
            break;
        }

        let current_hand_card = store.get_current_hand_card(game_id, *cards_index.at(idx));
        assert(current_hand_card.card_id != INVALID_CARD, errors::USE_INVALID_CARD);

        let mut card = store.get_card(current_hand_card.card_id);

        let modifier_1_index = *modifiers_index.at(idx);
        if modifier_1_index != 100 { // TODO: Invalid
            let current_hand_modifier_card = store.get_current_hand_card(game_id, modifier_1_index);
            let effect_card = store.get_effect_card(current_hand_modifier_card.card_id);
            effect_id_cards_1.append(effect_card.effect_id);
            let effect = store.get_effect(effect_card.effect_id);
            if effect.suit != Suit::None && card.suit != Suit::Joker {
                card.suit = effect.suit;
                emit!(
                    world,
                    ModifierCardSuitEvent {
                        player: get_caller_address(),
                        game_id,
                        modifier_card_idx: *modifiers_index.at(idx),
                        current_hand_card_idx: *cards_index.at(idx),
                        suit: card.suit
                    }
                );
            }
        } else {
            effect_id_cards_1.append(100);
        }

        if !(current_special_cards_index.get(SPECIAL_ALL_CARDS_TO_HEARTS_ID.into()).is_null()) {
            if card.suit != Suit::Joker {
                card.suit = Suit::Hearts;
                emit!(
                    world,
                    SpecialModifierSuitEvent {
                        player: get_caller_address(),
                        game_id,
                        current_special_card_idx: current_special_cards_index
                            .get(SPECIAL_ALL_CARDS_TO_HEARTS_ID.into())
                            .deref(),
                        current_hand_card_idx: *cards_index.at(idx),
                        suit: card.suit
                    }
                );
            }
        }

        cards.append(card);
        idx += 1;
    };
    (cards, effect_id_cards_1, effect_id_cards_2)
}

fn _has_repeated(array: @Array<u32>) -> bool {
    let mut founded: Felt252Dict<bool> = Default::default();
    let mut span = array.span();
    loop {
        match span.pop_front() {
            Option::Some(e) => {
                let repeated = founded.get((*e).into());
                if repeated {
                    break true;
                }
                founded.insert((*e).into(), true);
            },
            Option::None => { break false; }
        };
    }
}


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

fn _generate_random_challenges(
    world: IWorldDispatcher, size: u32, values: Array<u32>, exclude: Array<u32>
) -> Array<(u32, bool)> {
    let mut elements: Array<(u32, bool)> = ArrayTrait::new();
    let mut randomizer = RandomImpl::new(world);

    assert(size <= values.len(), 'error size unique values');
    loop {
        if elements.len() == size {
            break;
        }
        let new_elem = *values.at(randomizer.between::<u32>(0, values.len() - 1));
        if item_in_array(@exclude, new_elem) || item_in_array(@elements, (new_elem, false)) {
            continue;
        }
        elements.append((new_elem, false));
    };
    elements
}
