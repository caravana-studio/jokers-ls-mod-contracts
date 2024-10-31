use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::challenge::{
    CHALLENGE_ROYAL_FLUSH, CHALLENGE_STRAIGHT_FLUSH, CHALLENGE_FIVE_OF_A_KIND, CHALLENGE_FOUR_OF_A_KIND,
    CHALLENGE_FULL_HOUSE, CHALLENGE_FLUSH, CHALLENGE_STRAIGHT, CHALLENGE_THREE_OF_A_KIND, CHALLENGE_DOUBLE_PAIR,
    CHALLENGE_PAIR, CHALLENGE_HIGH_CARD, CHALLENGE_HEARTS, CHALLENGE_CLUBS, CHALLENGE_DIAMONDS, CHALLENGE_SPADES,
    CHALLENGE_ONE, CHALLENGE_TWO, CHALLENGE_THREE, CHALLENGE_FOUR, CHALLENGE_FIVE, CHALLENGE_SIX, CHALLENGE_SEVEN,
    CHALLENGE_EIGHT, CHALLENGE_NINE, CHALLENGE_TEN, CHALLENGE_JACK, CHALLENGE_QUEEN, CHALLENGE_KING, CHALLENGE_ACE,
    CHALLENGE_JOKER, challenges_all
};
use jokers_of_neon::models::{
    data::{
        challenge::{Challenge, ChallengeStore, ChallengePlayerStore}, card::{Card, Suit, Value},
        events::ChallengeCompleted, poker_hand::PokerHand
    },
    status::{game::game::{GameStore, GameState, GameSubState}}
};
use jokers_of_neon::utils::{shop::generate_unique_random_values, calculate_hand::calculate_hand};

#[generate_trait]
impl ChallengeImpl of ChallengeTrait {
    fn calculate(ref world: IWorldDispatcher, game_id: u32) {
        let mut challenge = ChallengeStore::get(world, game_id);
        challenge.active_ids = generate_unique_random_values(world, 3, challenges_all(), array![]).span();
        ChallengeStore::set(@challenge, world);
    }

    fn is_completed(world: @IWorldDispatcher, game_id: u32) -> bool {
        ChallengeStore::get(*world, game_id).active_ids.is_empty()
    }

    fn play(
        world: IWorldDispatcher,
        game_id: u32,
        cards: @Array<Card>,
        ref current_special_cards_index: Felt252Dict<Nullable<u32>>
    ) {
        let game = GameStore::get(world, game_id);
        assert(game.state == GameState::IN_GAME, 'Game not in progress');
        assert(game.substate == GameSubState::OBSTACLE, 'Game not in obstacle');
        let mut challenge_player = ChallengePlayerStore::get(world, game_id);
        assert(challenge_player.plays.is_non_zero(), 'You dont have more plays');

        let mut challenge = ChallengeStore::get(world, game_id);
        let (result_hand, mut hit_cards) = calculate_hand(cards, ref current_special_cards_index);
        Self::_resolve_challenges(ref challenge, result_hand, ref hit_cards, cards);
        ChallengeStore::set(@challenge, world);

        if Self::is_completed(@world, game_id) {
            emit!(world, ChallengeCompleted { player: game.owner, player_name: game.player_name, game_id })
        } else {
            challenge_player.plays -= 1;
            ChallengePlayerStore::set(@challenge_player, world);
        // if 0 then emit event
        }
    }

    fn _resolve_challenges(
        ref challenge: Challenge, result_hand: PokerHand, ref hit_cards: Felt252Dict<bool>, cards: @Array<Card>
    ) {
        match result_hand {
            PokerHand::RoyalFlush => Self::_complete(ref challenge, CHALLENGE_ROYAL_FLUSH),
            PokerHand::StraightFlush => Self::_complete(ref challenge, CHALLENGE_STRAIGHT_FLUSH),
            PokerHand::FiveOfAKind => Self::_complete(ref challenge, CHALLENGE_FIVE_OF_A_KIND),
            PokerHand::FourOfAKind => Self::_complete(ref challenge, CHALLENGE_FOUR_OF_A_KIND),
            PokerHand::FullHouse => Self::_complete(ref challenge, CHALLENGE_FULL_HOUSE),
            PokerHand::Straight => Self::_complete(ref challenge, CHALLENGE_STRAIGHT),
            PokerHand::Flush => Self::_complete(ref challenge, CHALLENGE_FLUSH),
            PokerHand::ThreeOfAKind => Self::_complete(ref challenge, CHALLENGE_THREE_OF_A_KIND),
            PokerHand::TwoPair => Self::_complete(ref challenge, CHALLENGE_DOUBLE_PAIR),
            PokerHand::OnePair => Self::_complete(ref challenge, CHALLENGE_PAIR),
            PokerHand::HighCard => Self::_complete(ref challenge, CHALLENGE_HIGH_CARD),
            PokerHand::None => (),
        };

        let mut idx = 0;
        loop {
            if idx == cards.len() {
                break;
            }

            let hit = hit_cards.get(idx.into());
            if hit {
                let card = *cards.at(idx);
                match card.value {
                    Value::Two => { Self::_complete(ref challenge, CHALLENGE_TWO); },
                    Value::Three => { Self::_complete(ref challenge, CHALLENGE_THREE); },
                    Value::Four => { Self::_complete(ref challenge, CHALLENGE_FOUR); },
                    Value::Five => { Self::_complete(ref challenge, CHALLENGE_FIVE); },
                    Value::Six => { Self::_complete(ref challenge, CHALLENGE_SIX); },
                    Value::Seven => { Self::_complete(ref challenge, CHALLENGE_SEVEN); },
                    Value::Eight => { Self::_complete(ref challenge, CHALLENGE_EIGHT); },
                    Value::Nine => { Self::_complete(ref challenge, CHALLENGE_NINE); },
                    Value::Ten => { Self::_complete(ref challenge, CHALLENGE_TEN); },
                    Value::Jack => { Self::_complete(ref challenge, CHALLENGE_JACK); },
                    Value::Queen => { Self::_complete(ref challenge, CHALLENGE_QUEEN); },
                    Value::King => { Self::_complete(ref challenge, CHALLENGE_KING); },
                    Value::Ace => { Self::_complete(ref challenge, CHALLENGE_ACE); },
                    Value::Joker => { Self::_complete(ref challenge, CHALLENGE_JOKER); },
                    Value::NeonJoker => { Self::_complete(ref challenge, CHALLENGE_JOKER); },
                    Value::None => {},
                };

                match card.suit {
                    Suit::Clubs => { Self::_complete(ref challenge, CHALLENGE_CLUBS); },
                    Suit::Hearts => { Self::_complete(ref challenge, CHALLENGE_HEARTS); },
                    Suit::Spades => { Self::_complete(ref challenge, CHALLENGE_SPADES); },
                    Suit::Diamonds => { Self::_complete(ref challenge, CHALLENGE_DIAMONDS); },
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
                Option::Some(challenge) => {
                    if *challenge != challenge_id {
                        remaining_challenges.append(*challenge);
                    }
                },
                Option::None => { break; },
            }
        };
        challenge.active_ids = remaining_challenges.span();
    }
}
