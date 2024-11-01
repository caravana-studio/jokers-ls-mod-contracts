use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::{
    card::INVALID_CARD,
    challenge::{
        CHALLENGE_ROYAL_FLUSH, CHALLENGE_STRAIGHT_FLUSH, CHALLENGE_FIVE_OF_A_KIND, CHALLENGE_FOUR_OF_A_KIND,
        CHALLENGE_FULL_HOUSE, CHALLENGE_FLUSH, CHALLENGE_STRAIGHT, CHALLENGE_THREE_OF_A_KIND, CHALLENGE_DOUBLE_PAIR,
        CHALLENGE_PAIR, CHALLENGE_HIGH_CARD, CHALLENGE_HEARTS, CHALLENGE_CLUBS, CHALLENGE_DIAMONDS, CHALLENGE_SPADES,
        CHALLENGE_ONE, CHALLENGE_TWO, CHALLENGE_THREE, CHALLENGE_FOUR, CHALLENGE_FIVE, CHALLENGE_SIX, CHALLENGE_SEVEN,
        CHALLENGE_EIGHT, CHALLENGE_NINE, CHALLENGE_TEN, CHALLENGE_JACK, CHALLENGE_QUEEN, CHALLENGE_KING, CHALLENGE_ACE,
        CHALLENGE_JOKER, CHALLENGE_500_POINTS, CHALLENGE_1000_POINTS, CHALLENGE_2000_POINTS, CHALLENGE_5000_POINTS,
        challenges_all
    },
    specials::SPECIAL_ALL_CARDS_TO_HEARTS_ID,
};

use jokers_of_neon::{
    models::{
        data::{
            challenge::{Challenge, ChallengeStore, ChallengePlayer, ChallengePlayerStore}, card::{Card, Suit, Value},
            game_deck::{GameDeckStore, GameDeckImpl},
            events::{ChallengeCompleted, PlayGameOverEvent, ModifierCardSuitEvent, SpecialModifierSuitEvent},
            poker_hand::PokerHand
        },
        status::{
            game::game::{Game, GameState, GameSubState, GameStore},
            round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait}
        },
    },
    store::{Store, StoreTrait},
    utils::{game::{play as calculate_hand_score}, shop::generate_unique_random_values, calculate_hand::calculate_hand}
};
use starknet::get_caller_address;

mod errors {
    const STATE_NOT_IN_GAME: felt252 = 'State not IN_GAME';
    const SUBSTATE_NOT_OBSTACLE: felt252 = 'Substate not OBSTACLE';
    const USE_INVALID_CARD: felt252 = 'Use an invalid card';
    const ARRAY_REPEATED_ELEMENTS: felt252 = 'Array has repeated elements';
}

#[generate_trait]
impl ChallengeImpl of ChallengeTrait {
    fn create(world: IWorldDispatcher, ref store: Store, game_id: u32) {
        let mut game = store.get_game(game_id);

        let mut challenge = ChallengeStore::get(world, game_id);
        challenge.active_ids = generate_unique_random_values(world, 3, challenges_all(), array![]).span();
        ChallengeStore::set(@challenge, world);
        emit!(world, (challenge));

        let challenge_player = ChallengePlayer { game_id, discards: 5, plays: 5 };
        ChallengePlayerStore::set(@challenge_player, world);

        let mut game_deck = GameDeckStore::get(world, game_id);
        game_deck.restore(world);
        CurrentHandCardTrait::create(world, game);
    }

    fn play(world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
        let mut game = GameStore::get(world, game_id);
        assert(game.state == GameState::IN_GAME, errors::STATE_NOT_IN_GAME);
        assert(game.substate == GameSubState::OBSTACLE, errors::SUBSTATE_NOT_OBSTACLE);

        let mut store = StoreTrait::new(world);
        let mut current_special_cards_index = _current_special_cards(ref store, @game);
        let (mut cards, _, _) = _get_cards(
            world, ref store, game.id, @cards_index, @modifiers_index, ref current_special_cards_index
        );
        let (result_hand, mut hit_cards) = calculate_hand(@cards, ref current_special_cards_index);
        let hand_score = calculate_hand_score(world, ref game, @cards_index, @modifiers_index);

        let mut challenge = ChallengeStore::get(world, game_id);
        _resolve_challenges(ref challenge, result_hand, ref hit_cards, @cards, hand_score);
        ChallengeStore::set(@challenge, world);

        if Self::is_completed(@world, game_id) {
            emit!(world, ChallengeCompleted { player: game.owner, player_name: game.player_name, game_id })
        } else {
            let mut challenge_player = ChallengePlayerStore::get(world, game_id);
            challenge_player.plays -= 1;
            emit!(world, (challenge_player));
            ChallengePlayerStore::set(@challenge_player, world);
        }

        CurrentHandCardTrait::refresh(world, game_id, cards_index);

        let game_deck = GameDeckStore::get(world, game_id);
        if game_deck.round_len.is_zero() && _player_has_empty_hand(ref store, @game) {
            let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
            emit!(world, (play_game_over_event));
            game.state = GameState::FINISHED;
            GameStore::set(@game, world);
        }
    }

    fn discard(world: IWorldDispatcher, game_id: u32, cards_index: Array<u32>, modifiers_index: Array<u32>) {
        let mut game = GameStore::get(world, game_id);
        assert(game.state == GameState::IN_GAME, errors::STATE_NOT_IN_GAME);
        assert(game.substate == GameSubState::OBSTACLE, errors::SUBSTATE_NOT_OBSTACLE);

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

        let mut challenge_player = ChallengePlayerStore::get(world, game_id);
        challenge_player.discards -= 1;
        emit!(world, (challenge_player));
        ChallengePlayerStore::set(@challenge_player, world);

        let game_deck = GameDeckStore::get(world, game_id);
        if game_deck.round_len.is_zero() && _player_has_empty_hand(ref store, @game) {
            let play_game_over_event = PlayGameOverEvent { player: get_caller_address(), game_id: game.id };
            emit!(world, (play_game_over_event));
            game.state = GameState::FINISHED;
            store.set_game(game);
        }
    }

    fn is_completed(world: @IWorldDispatcher, game_id: u32) -> bool {
        ChallengeStore::get(*world, game_id).active_ids.is_empty()
    }
}

fn _resolve_challenges(
    ref challenge: Challenge,
    result_hand: PokerHand,
    ref hit_cards: Felt252Dict<bool>,
    cards: @Array<Card>,
    hand_score: u32,
) {
    match result_hand {
        PokerHand::RoyalFlush => _complete(ref challenge, CHALLENGE_ROYAL_FLUSH),
        PokerHand::StraightFlush => _complete(ref challenge, CHALLENGE_STRAIGHT_FLUSH),
        PokerHand::FiveOfAKind => _complete(ref challenge, CHALLENGE_FIVE_OF_A_KIND),
        PokerHand::FourOfAKind => _complete(ref challenge, CHALLENGE_FOUR_OF_A_KIND),
        PokerHand::FullHouse => _complete(ref challenge, CHALLENGE_FULL_HOUSE),
        PokerHand::Straight => _complete(ref challenge, CHALLENGE_STRAIGHT),
        PokerHand::Flush => _complete(ref challenge, CHALLENGE_FLUSH),
        PokerHand::ThreeOfAKind => _complete(ref challenge, CHALLENGE_THREE_OF_A_KIND),
        PokerHand::TwoPair => _complete(ref challenge, CHALLENGE_DOUBLE_PAIR),
        PokerHand::OnePair => _complete(ref challenge, CHALLENGE_PAIR),
        PokerHand::HighCard => _complete(ref challenge, CHALLENGE_HIGH_CARD),
        PokerHand::None => (),
    };

    if hand_score >= 5000 {
        _complete(ref challenge, CHALLENGE_5000_POINTS);
    }
    if hand_score >= 2000 {
        _complete(ref challenge, CHALLENGE_2000_POINTS);
    }
    if hand_score >= 1000 {
        _complete(ref challenge, CHALLENGE_1000_POINTS);
    }
    if hand_score >= 500 {
        _complete(ref challenge, CHALLENGE_500_POINTS);
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
                Value::Two => { _complete(ref challenge, CHALLENGE_TWO); },
                Value::Three => { _complete(ref challenge, CHALLENGE_THREE); },
                Value::Four => { _complete(ref challenge, CHALLENGE_FOUR); },
                Value::Five => { _complete(ref challenge, CHALLENGE_FIVE); },
                Value::Six => { _complete(ref challenge, CHALLENGE_SIX); },
                Value::Seven => { _complete(ref challenge, CHALLENGE_SEVEN); },
                Value::Eight => { _complete(ref challenge, CHALLENGE_EIGHT); },
                Value::Nine => { _complete(ref challenge, CHALLENGE_NINE); },
                Value::Ten => { _complete(ref challenge, CHALLENGE_TEN); },
                Value::Jack => { _complete(ref challenge, CHALLENGE_JACK); },
                Value::Queen => { _complete(ref challenge, CHALLENGE_QUEEN); },
                Value::King => { _complete(ref challenge, CHALLENGE_KING); },
                Value::Ace => { _complete(ref challenge, CHALLENGE_ACE); },
                Value::Joker => { _complete(ref challenge, CHALLENGE_JOKER); },
                Value::NeonJoker => { _complete(ref challenge, CHALLENGE_JOKER); },
                Value::None => {},
            };

            match card.suit {
                Suit::Clubs => { _complete(ref challenge, CHALLENGE_CLUBS); },
                Suit::Hearts => { _complete(ref challenge, CHALLENGE_HEARTS); },
                Suit::Spades => { _complete(ref challenge, CHALLENGE_SPADES); },
                Suit::Diamonds => { _complete(ref challenge, CHALLENGE_DIAMONDS); },
                Suit::Joker => {},
                Suit::None => {},
            };
        }
        idx += 1;
    };
}

fn _complete(ref challenge: Challenge, challenge_id: u32) {
    let mut remaining_challenges = array![];
    loop {
        match challenge.active_ids.pop_front() {
            Option::Some(challenge) => { if *challenge != challenge_id {
                remaining_challenges.append(*challenge);
            } },
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
