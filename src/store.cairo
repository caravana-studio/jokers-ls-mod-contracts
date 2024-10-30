use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::configs::{
    rage::RageRoundConfig, slot_special_cards::SlotSpecialCardsConfig, earning_cash::EarningCashConfig
};
use jokers_of_neon::constants::card::{
    NEON_TWO_CLUBS_ID, NEON_TWO_CLUBS, TWO_CLUBS_ID, TWO_CLUBS, NEON_THREE_CLUBS_ID, NEON_THREE_CLUBS, THREE_CLUBS_ID,
    THREE_CLUBS, NEON_FOUR_CLUBS_ID, NEON_FOUR_CLUBS, FOUR_CLUBS_ID, FOUR_CLUBS, NEON_FIVE_CLUBS_ID, NEON_FIVE_CLUBS,
    FIVE_CLUBS_ID, FIVE_CLUBS, NEON_SIX_CLUBS_ID, NEON_SIX_CLUBS, SIX_CLUBS_ID, SIX_CLUBS, NEON_SEVEN_CLUBS_ID,
    NEON_SEVEN_CLUBS, SEVEN_CLUBS_ID, SEVEN_CLUBS, NEON_EIGHT_CLUBS_ID, NEON_EIGHT_CLUBS, EIGHT_CLUBS_ID, EIGHT_CLUBS,
    NEON_NINE_CLUBS_ID, NEON_NINE_CLUBS, NINE_CLUBS_ID, NINE_CLUBS, NEON_TEN_CLUBS_ID, NEON_TEN_CLUBS, TEN_CLUBS_ID,
    TEN_CLUBS, NEON_JACK_CLUBS_ID, NEON_JACK_CLUBS, JACK_CLUBS_ID, JACK_CLUBS, NEON_QUEEN_CLUBS_ID, NEON_QUEEN_CLUBS,
    QUEEN_CLUBS_ID, QUEEN_CLUBS, NEON_KING_CLUBS_ID, NEON_KING_CLUBS, KING_CLUBS_ID, KING_CLUBS, NEON_ACE_CLUBS_ID,
    NEON_ACE_CLUBS, ACE_CLUBS_ID, ACE_CLUBS, NEON_TWO_DIAMONDS_ID, NEON_TWO_DIAMONDS, TWO_DIAMONDS_ID, TWO_DIAMONDS,
    NEON_THREE_DIAMONDS_ID, NEON_THREE_DIAMONDS, THREE_DIAMONDS_ID, THREE_DIAMONDS, NEON_FOUR_DIAMONDS_ID,
    NEON_FOUR_DIAMONDS, FOUR_DIAMONDS_ID, FOUR_DIAMONDS, NEON_FIVE_DIAMONDS_ID, NEON_FIVE_DIAMONDS, FIVE_DIAMONDS_ID,
    FIVE_DIAMONDS, NEON_SIX_DIAMONDS_ID, NEON_SIX_DIAMONDS, SIX_DIAMONDS_ID, SIX_DIAMONDS, NEON_SEVEN_DIAMONDS_ID,
    NEON_SEVEN_DIAMONDS, SEVEN_DIAMONDS_ID, SEVEN_DIAMONDS, NEON_EIGHT_DIAMONDS_ID, NEON_EIGHT_DIAMONDS,
    EIGHT_DIAMONDS_ID, EIGHT_DIAMONDS, NEON_NINE_DIAMONDS_ID, NEON_NINE_DIAMONDS, NINE_DIAMONDS_ID, NINE_DIAMONDS,
    NEON_TEN_DIAMONDS_ID, NEON_TEN_DIAMONDS, TEN_DIAMONDS_ID, TEN_DIAMONDS, NEON_JACK_DIAMONDS_ID, NEON_JACK_DIAMONDS,
    JACK_DIAMONDS_ID, JACK_DIAMONDS, NEON_QUEEN_DIAMONDS_ID, NEON_QUEEN_DIAMONDS, QUEEN_DIAMONDS_ID, QUEEN_DIAMONDS,
    NEON_KING_DIAMONDS_ID, NEON_KING_DIAMONDS, KING_DIAMONDS_ID, KING_DIAMONDS, NEON_ACE_DIAMONDS_ID, NEON_ACE_DIAMONDS,
    ACE_DIAMONDS_ID, ACE_DIAMONDS, NEON_TWO_HEARTS_ID, NEON_TWO_HEARTS, TWO_HEARTS_ID, TWO_HEARTS, NEON_THREE_HEARTS_ID,
    NEON_THREE_HEARTS, THREE_HEARTS_ID, THREE_HEARTS, NEON_FOUR_HEARTS_ID, NEON_FOUR_HEARTS, FOUR_HEARTS_ID,
    FOUR_HEARTS, NEON_FIVE_HEARTS_ID, NEON_FIVE_HEARTS, FIVE_HEARTS_ID, FIVE_HEARTS, NEON_SIX_HEARTS_ID,
    NEON_SIX_HEARTS, SIX_HEARTS_ID, SIX_HEARTS, NEON_SEVEN_HEARTS_ID, NEON_SEVEN_HEARTS, SEVEN_HEARTS_ID, SEVEN_HEARTS,
    NEON_EIGHT_HEARTS_ID, NEON_EIGHT_HEARTS, EIGHT_HEARTS_ID, EIGHT_HEARTS, NEON_NINE_HEARTS_ID, NEON_NINE_HEARTS,
    NINE_HEARTS_ID, NINE_HEARTS, NEON_TEN_HEARTS_ID, NEON_TEN_HEARTS, TEN_HEARTS_ID, TEN_HEARTS, NEON_JACK_HEARTS_ID,
    NEON_JACK_HEARTS, JACK_HEARTS_ID, JACK_HEARTS, NEON_QUEEN_HEARTS_ID, NEON_QUEEN_HEARTS, QUEEN_HEARTS_ID,
    QUEEN_HEARTS, NEON_KING_HEARTS_ID, NEON_KING_HEARTS, KING_HEARTS_ID, KING_HEARTS, NEON_ACE_HEARTS_ID,
    NEON_ACE_HEARTS, ACE_HEARTS_ID, ACE_HEARTS, NEON_TWO_SPADES_ID, NEON_TWO_SPADES, TWO_SPADES_ID, TWO_SPADES,
    NEON_THREE_SPADES_ID, NEON_THREE_SPADES, THREE_SPADES_ID, THREE_SPADES, NEON_FOUR_SPADES_ID, NEON_FOUR_SPADES,
    FOUR_SPADES_ID, FOUR_SPADES, NEON_FIVE_SPADES_ID, NEON_FIVE_SPADES, FIVE_SPADES_ID, FIVE_SPADES, NEON_SIX_SPADES_ID,
    NEON_SIX_SPADES, SIX_SPADES_ID, SIX_SPADES, NEON_SEVEN_SPADES_ID, NEON_SEVEN_SPADES, SEVEN_SPADES_ID, SEVEN_SPADES,
    NEON_EIGHT_SPADES_ID, NEON_EIGHT_SPADES, EIGHT_SPADES_ID, EIGHT_SPADES, NEON_NINE_SPADES_ID, NEON_NINE_SPADES,
    NINE_SPADES_ID, NINE_SPADES, NEON_TEN_SPADES_ID, NEON_TEN_SPADES, TEN_SPADES_ID, TEN_SPADES, NEON_JACK_SPADES_ID,
    NEON_JACK_SPADES, JACK_SPADES_ID, JACK_SPADES, NEON_QUEEN_SPADES_ID, NEON_QUEEN_SPADES, QUEEN_SPADES_ID,
    QUEEN_SPADES, NEON_KING_SPADES_ID, NEON_KING_SPADES, KING_SPADES_ID, KING_SPADES, NEON_ACE_SPADES_ID,
    NEON_ACE_SPADES, ACE_SPADES_ID, ACE_SPADES, JOKER_CARD, NEON_JOKER_CARD, INVALID_CARD,
};
use jokers_of_neon::constants::effect::{
    SPECIAL_MULTI_FOR_HEARTS_EFFECT_ID, SPECIAL_MULTI_FOR_HEARTS_EFFECT, SPECIAL_MULTI_FOR_DIAMONDS_EFFECT_ID,
    SPECIAL_MULTI_FOR_DIAMONDS_EFFECT, SPECIAL_MULTI_FOR_CLUBS_EFFECT_ID, SPECIAL_MULTI_FOR_CLUBS_EFFECT,
    SPECIAL_MULTI_FOR_SPADES_EFFECT_ID, SPECIAL_MULTI_FOR_SPADES_EFFECT, SPECIAL_INCREASE_LEVEL_PAIR_EFFECT_ID,
    SPECIAL_INCREASE_LEVEL_PAIR_EFFECT, SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT_ID,
    SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT, SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT_ID,
    SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT, SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT_ID, SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT,
    SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT_ID, SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT,
    SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT_ID, SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT, SPECIAL_JOKER_BOOSTER_EFFECT_ID,
    SPECIAL_JOKER_BOOSTER_EFFECT, SPECIAL_MODIFIER_BOOSTER_EFFECT_ID, SPECIAL_MODIFIER_BOOSTER_EFFECT,
    SPECIAL_POINTS_FOR_FIGURES_EFFECT_ID, SPECIAL_POINTS_FOR_FIGURES_EFFECT, SPECIAL_MULTI_ACES_EFFECT_ID,
    SPECIAL_MULTI_ACES_EFFECT, SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT_ID, SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT,
    SPECIAL_HAND_THIEF_EFFECT_ID, SPECIAL_HAND_THIEF_EFFECT, POINTS_MODIFIER_1_EFFECT_ID, POINTS_MODIFIER_1_EFFECT,
    POINTS_MODIFIER_2_EFFECT_ID, POINTS_MODIFIER_2_EFFECT, POINTS_MODIFIER_3_EFFECT_ID, POINTS_MODIFIER_3_EFFECT,
    POINTS_MODIFIER_4_EFFECT_ID, POINTS_MODIFIER_4_EFFECT, MULTI_MODIFIER_1_EFFECT_ID, MULTI_MODIFIER_1_EFFECT,
    MULTI_MODIFIER_2_EFFECT_ID, MULTI_MODIFIER_2_EFFECT, MULTI_MODIFIER_3_EFFECT_ID, MULTI_MODIFIER_3_EFFECT,
    MULTI_MODIFIER_4_EFFECT_ID, MULTI_MODIFIER_4_EFFECT, SUIT_CLUBS_MODIFIER_EFFECT_ID, SUIT_CLUBS_MODIFIER_EFFECT,
    SUIT_DIAMONDS_MODIFIER_EFFECT_ID, SUIT_DIAMONDS_MODIFIER_EFFECT, SUIT_HEARTS_MODIFIER_EFFECT_ID,
    SUIT_HEARTS_MODIFIER_EFFECT, SUIT_SPADES_MODIFIER_EFFECT_ID, SUIT_SPADES_MODIFIER_EFFECT,
    SPECIAL_LUCKY_SEVEN_EFFECT_ID, SPECIAL_LUCKY_SEVEN_EFFECT, SPECIAL_NEON_BONUS_EFFECT_ID, SPECIAL_NEON_BONUS_EFFECT,
    SPECIAL_DEADLINE_EFFECT_ID, SPECIAL_DEADLINE_EFFECT, SPECIAL_INITIAL_ADVANTAGE_EFFECT_ID,
    SPECIAL_INITIAL_ADVANTAGE_EFFECT, EMPTY_EFFECT
};

use jokers_of_neon::constants::modifiers::{
    POINTS_MODIFIER_1_ID, POINTS_MODIFIER_1, POINTS_MODIFIER_2_ID, POINTS_MODIFIER_2, POINTS_MODIFIER_3_ID,
    POINTS_MODIFIER_3, POINTS_MODIFIER_4_ID, POINTS_MODIFIER_4, MULTI_MODIFIER_1_ID, MULTI_MODIFIER_1,
    MULTI_MODIFIER_2_ID, MULTI_MODIFIER_2, MULTI_MODIFIER_3_ID, MULTI_MODIFIER_3, MULTI_MODIFIER_4_ID, MULTI_MODIFIER_4,
    SUIT_CLUB_MODIFIER_ID, SUIT_CLUB_MODIFIER, SUIT_DIAMONDS_MODIFIER_ID, SUIT_DIAMONDS_MODIFIER,
    SUIT_HEARTS_MODIFIER_ID, SUIT_HEARTS_MODIFIER, SUIT_SPADES_MODIFIER_ID, SUIT_SPADES_MODIFIER,
};
use jokers_of_neon::constants::packs::{
    BASIC_BLISTER_PACK, ADVANCED_BLISTER_PACK, JOKER_BLISTER_PACK, SPECIALS_BLISTER_PACK, MODIFIER_BLISTER_PACK,
    FIGURES_BLISTER_PACK, DECEITFUL_JOKER_BLISTER_PACK, LOVERS_BLISTER_PACK, SPECIAL_BET_BLISTER_PACK,
    EMPTY_BLISTER_PACK, BASIC_BLISTER_PACK_ID, ADVANCED_BLISTER_PACK_ID, JOKER_BLISTER_PACK_ID,
    SPECIALS_BLISTER_PACK_ID, MODIFIER_BLISTER_PACK_ID, FIGURES_BLISTER_PACK_ID, DECEITFUL_JOKER_BLISTER_PACK_ID,
    LOVERS_BLISTER_PACK_ID, SPECIAL_BET_BLISTER_PACK_ID,
};
use jokers_of_neon::constants::playhand::{
    ROYAL_FLUSH, STRAIGHT_FLUSH, FIVE_OF_A_KIND, FOUR_OF_A_KIND, FULL_HOUSE, FLUSH, STRAIGHT, THREE_OF_A_KIND, TWO_PAIR,
    ONE_PAIR, HIGH_CARD, NONE
};
use jokers_of_neon::constants::specials::{
    SPECIAL_MULTI_FOR_HEART_ID, SPECIAL_MULTI_FOR_HEART, SPECIAL_MULTI_FOR_CLUB_ID, SPECIAL_MULTI_FOR_CLUB,
    SPECIAL_MULTI_FOR_DIAMOND_ID, SPECIAL_MULTI_FOR_DIAMOND, SPECIAL_MULTI_FOR_SPADE_ID, SPECIAL_MULTI_FOR_SPADE,
    SPECIAL_INCREASE_LEVEL_PAIR_ID, SPECIAL_INCREASE_LEVEL_PAIR, SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID,
    SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR, SPECIAL_INCREASE_LEVEL_STRAIGHT_ID, SPECIAL_INCREASE_LEVEL_STRAIGHT,
    SPECIAL_INCREASE_LEVEL_FLUSH_ID, SPECIAL_INCREASE_LEVEL_FLUSH, SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID,
    SPECIAL_STRAIGHT_WITH_FOUR_CARDS, SPECIAL_FLUSH_WITH_FOUR_CARDS_ID, SPECIAL_FLUSH_WITH_FOUR_CARDS,
    SPECIAL_JOKER_BOOSTER_ID, SPECIAL_JOKER_BOOSTER, SPECIAL_MODIFIER_BOOSTER_ID, SPECIAL_MODIFIER_BOOSTER,
    SPECIAL_POINTS_FOR_FIGURES_ID, SPECIAL_POINTS_FOR_FIGURES, SPECIAL_MULTI_ACES_ID, SPECIAL_MULTI_ACES,
    SPECIAL_ALL_CARDS_TO_HEARTS_ID, SPECIAL_ALL_CARDS_TO_HEARTS, SPECIAL_HAND_THIEF_ID, SPECIAL_HAND_THIEF,
    SPECIAL_EXTRA_HELP_ID, SPECIAL_EXTRA_HELP, SPECIAL_LUCKY_SEVEN_ID, SPECIAL_LUCKY_SEVEN, SPECIAL_NEON_BONUS_ID,
    SPECIAL_NEON_BONUS, SPECIAL_DEADLINE_ID, SPECIAL_DEADLINE, SPECIAL_INITIAL_ADVANTAGE_ID, SPECIAL_INITIAL_ADVANTAGE,
    INVALID_EFFECT_CARD, SPECIAL_LUCKY_HAND_ID, SPECIAL_LUCKY_HAND
};
use jokers_of_neon::models::data::blister_pack::BlisterPack;
use jokers_of_neon::models::data::card::{Card, Suit, Value, SuitEnumerableImpl, ValueEnumerableImpl,};
use jokers_of_neon::models::data::effect_card::{EffectCard, Effect};
use jokers_of_neon::models::data::events::{PokerHandEvent, CreateGameEvent, CardScoreEvent};
use jokers_of_neon::models::data::poker_hand::{LevelPokerHand, PokerHand};

use jokers_of_neon::models::status::game::game::{Game, CurrentSpecialCards};
use jokers_of_neon::models::status::game::player::PlayerLevelPokerHand;
use jokers_of_neon::models::status::round::current_hand_card::{CurrentHandCard, CurrentHandCardTrait};
use jokers_of_neon::models::status::round::deck_card::{DeckCardTrait};
use jokers_of_neon::models::status::round::round::Round;

use jokers_of_neon::models::status::shop::shop::{
    Shop, CardItem, CardItemType, PokerHandItem, BlisterPackItem, BlisterPackResult, SlotSpecialCardsItem
};
use starknet::ContractAddress;

#[derive(Drop)]
struct Store {
    world: IWorldDispatcher
}

#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    fn get_rage_config(ref self: Store) -> RageRoundConfig {
        Default::default()
    }

    fn get_slot_special_cards_config(ref self: Store) -> SlotSpecialCardsConfig {
        Default::default()
    }

    fn get_card(ref self: Store, id: u32) -> Card {
        if id <= 51 {
            get_traditional_card(id)
        } else if id == JOKER_CARD {
            Card { id: JOKER_CARD, suit: Suit::Joker, value: Value::Joker, points: 100, multi_add: 1 }
        } else if id == NEON_JOKER_CARD {
            Card { id: NEON_JOKER_CARD, suit: Suit::Joker, value: Value::NeonJoker, points: 500, multi_add: 3 }
        } else {
            get_neon_card(id)
        }
    }

    fn get_effect_card(ref self: Store, id: u32) -> EffectCard {
        if id == SPECIAL_MULTI_FOR_HEART_ID {
            SPECIAL_MULTI_FOR_HEART()
        } else if id == SPECIAL_MULTI_FOR_CLUB_ID {
            SPECIAL_MULTI_FOR_CLUB()
        } else if id == SPECIAL_MULTI_FOR_DIAMOND_ID {
            SPECIAL_MULTI_FOR_DIAMOND()
        } else if id == SPECIAL_MULTI_FOR_SPADE_ID {
            SPECIAL_MULTI_FOR_SPADE()
        } else if id == SPECIAL_INCREASE_LEVEL_PAIR_ID {
            SPECIAL_INCREASE_LEVEL_PAIR()
        } else if id == SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_ID {
            SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR()
        } else if id == SPECIAL_INCREASE_LEVEL_STRAIGHT_ID {
            SPECIAL_INCREASE_LEVEL_STRAIGHT()
        } else if id == SPECIAL_INCREASE_LEVEL_FLUSH_ID {
            SPECIAL_INCREASE_LEVEL_FLUSH()
        } else if id == SPECIAL_STRAIGHT_WITH_FOUR_CARDS_ID {
            SPECIAL_STRAIGHT_WITH_FOUR_CARDS()
        } else if id == SPECIAL_FLUSH_WITH_FOUR_CARDS_ID {
            SPECIAL_FLUSH_WITH_FOUR_CARDS()
        } else if id == SPECIAL_JOKER_BOOSTER_ID {
            SPECIAL_JOKER_BOOSTER()
        } else if id == SPECIAL_MODIFIER_BOOSTER_ID {
            SPECIAL_MODIFIER_BOOSTER()
        } else if id == SPECIAL_POINTS_FOR_FIGURES_ID {
            SPECIAL_POINTS_FOR_FIGURES()
        } else if id == SPECIAL_MULTI_ACES_ID {
            SPECIAL_MULTI_ACES()
        } else if id == SPECIAL_ALL_CARDS_TO_HEARTS_ID {
            SPECIAL_ALL_CARDS_TO_HEARTS()
        } else if id == SPECIAL_HAND_THIEF_ID {
            SPECIAL_HAND_THIEF()
        } else if id == SPECIAL_EXTRA_HELP_ID {
            SPECIAL_EXTRA_HELP()
        } else if id == SPECIAL_LUCKY_SEVEN_ID {
            SPECIAL_LUCKY_SEVEN()
        } else if id == SPECIAL_NEON_BONUS_ID {
            SPECIAL_NEON_BONUS()
        } else if id == SPECIAL_DEADLINE_ID {
            SPECIAL_DEADLINE()
        } else if id == SPECIAL_INITIAL_ADVANTAGE_ID {
            SPECIAL_INITIAL_ADVANTAGE()
        } else if id == SPECIAL_LUCKY_HAND_ID {
            SPECIAL_LUCKY_HAND()
        } else if id == POINTS_MODIFIER_1_ID {
            POINTS_MODIFIER_1()
        } else if id == POINTS_MODIFIER_2_ID {
            POINTS_MODIFIER_2()
        } else if id == POINTS_MODIFIER_3_ID {
            POINTS_MODIFIER_3()
        } else if id == POINTS_MODIFIER_4_ID {
            POINTS_MODIFIER_4()
        } else if id == MULTI_MODIFIER_1_ID {
            MULTI_MODIFIER_1()
        } else if id == MULTI_MODIFIER_2_ID {
            MULTI_MODIFIER_2()
        } else if id == MULTI_MODIFIER_3_ID {
            MULTI_MODIFIER_3()
        } else if id == MULTI_MODIFIER_4_ID {
            MULTI_MODIFIER_4()
        } else if id == SUIT_CLUB_MODIFIER_ID {
            SUIT_CLUB_MODIFIER()
        } else if id == SUIT_DIAMONDS_MODIFIER_ID {
            SUIT_DIAMONDS_MODIFIER()
        } else if id == SUIT_HEARTS_MODIFIER_ID {
            SUIT_HEARTS_MODIFIER()
        } else if id == SUIT_SPADES_MODIFIER_ID {
            SUIT_SPADES_MODIFIER()
        } else {
            INVALID_EFFECT_CARD()
        }
    }

    fn get_effect(ref self: Store, effect_id: u32) -> Effect {
        if effect_id == SPECIAL_MULTI_FOR_HEARTS_EFFECT_ID {
            SPECIAL_MULTI_FOR_HEARTS_EFFECT()
        } else if effect_id == SPECIAL_MULTI_FOR_DIAMONDS_EFFECT_ID {
            SPECIAL_MULTI_FOR_DIAMONDS_EFFECT()
        } else if effect_id == SPECIAL_MULTI_FOR_CLUBS_EFFECT_ID {
            SPECIAL_MULTI_FOR_CLUBS_EFFECT()
        } else if effect_id == SPECIAL_MULTI_FOR_SPADES_EFFECT_ID {
            SPECIAL_MULTI_FOR_SPADES_EFFECT()
        } else if effect_id == SPECIAL_INCREASE_LEVEL_PAIR_EFFECT_ID {
            SPECIAL_INCREASE_LEVEL_PAIR_EFFECT()
        } else if effect_id == SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT_ID {
            SPECIAL_INCREASE_LEVEL_DOUBLE_PAIR_EFFECT()
        } else if effect_id == SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT_ID {
            SPECIAL_INCREASE_LEVEL_STRAIGHT_EFFECT()
        } else if effect_id == SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT_ID {
            SPECIAL_INCREASE_LEVEL_FLUSH_EFFECT()
        } else if effect_id == SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT_ID {
            SPECIAL_STRAIGHT_WITH_FOUR_CARDS_EFFECT()
        } else if effect_id == SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT_ID {
            SPECIAL_FLUSH_WITH_FOUR_CARDS_EFFECT()
        } else if effect_id == SPECIAL_JOKER_BOOSTER_EFFECT_ID {
            SPECIAL_JOKER_BOOSTER_EFFECT()
        } else if effect_id == SPECIAL_MODIFIER_BOOSTER_EFFECT_ID {
            SPECIAL_MODIFIER_BOOSTER_EFFECT()
        } else if effect_id == SPECIAL_POINTS_FOR_FIGURES_EFFECT_ID {
            SPECIAL_POINTS_FOR_FIGURES_EFFECT()
        } else if effect_id == SPECIAL_MULTI_ACES_EFFECT_ID {
            SPECIAL_MULTI_ACES_EFFECT()
        } else if effect_id == SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT_ID {
            SPECIAL_ALL_CARDS_TO_HEARTS_EFFECT()
        } else if effect_id == SPECIAL_HAND_THIEF_EFFECT_ID {
            SPECIAL_HAND_THIEF_EFFECT()
        } else if effect_id == POINTS_MODIFIER_1_EFFECT_ID {
            POINTS_MODIFIER_1_EFFECT()
        } else if effect_id == POINTS_MODIFIER_2_EFFECT_ID {
            POINTS_MODIFIER_2_EFFECT()
        } else if effect_id == POINTS_MODIFIER_3_EFFECT_ID {
            POINTS_MODIFIER_3_EFFECT()
        } else if effect_id == POINTS_MODIFIER_4_EFFECT_ID {
            POINTS_MODIFIER_4_EFFECT()
        } else if effect_id == MULTI_MODIFIER_1_EFFECT_ID {
            MULTI_MODIFIER_1_EFFECT()
        } else if effect_id == MULTI_MODIFIER_2_EFFECT_ID {
            MULTI_MODIFIER_2_EFFECT()
        } else if effect_id == MULTI_MODIFIER_3_EFFECT_ID {
            MULTI_MODIFIER_3_EFFECT()
        } else if effect_id == MULTI_MODIFIER_4_EFFECT_ID {
            MULTI_MODIFIER_4_EFFECT()
        } else if effect_id == SUIT_CLUBS_MODIFIER_EFFECT_ID {
            SUIT_CLUBS_MODIFIER_EFFECT()
        } else if effect_id == SUIT_DIAMONDS_MODIFIER_EFFECT_ID {
            SUIT_DIAMONDS_MODIFIER_EFFECT()
        } else if effect_id == SUIT_HEARTS_MODIFIER_EFFECT_ID {
            SUIT_HEARTS_MODIFIER_EFFECT()
        } else if effect_id == SUIT_SPADES_MODIFIER_EFFECT_ID {
            SUIT_SPADES_MODIFIER_EFFECT()
        } else if effect_id == SPECIAL_LUCKY_SEVEN_EFFECT_ID {
            SPECIAL_LUCKY_SEVEN_EFFECT()
        } else if effect_id == SPECIAL_NEON_BONUS_EFFECT_ID {
            SPECIAL_NEON_BONUS_EFFECT()
        } else if effect_id == SPECIAL_DEADLINE_EFFECT_ID {
            SPECIAL_DEADLINE_EFFECT()
        } else if effect_id == SPECIAL_INITIAL_ADVANTAGE_EFFECT_ID {
            SPECIAL_INITIAL_ADVANTAGE_EFFECT()
        } else {
            EMPTY_EFFECT()
        }
    }

    fn get_level_poker_hand(ref self: Store, poker_hand: PokerHand, level: u8) -> LevelPokerHand {
        match poker_hand {
            PokerHand::RoyalFlush => ROYAL_FLUSH(level),
            PokerHand::StraightFlush => STRAIGHT_FLUSH(level),
            PokerHand::FiveOfAKind => FIVE_OF_A_KIND(level),
            PokerHand::FourOfAKind => FOUR_OF_A_KIND(level),
            PokerHand::FullHouse => FULL_HOUSE(level),
            PokerHand::Straight => STRAIGHT(level),
            PokerHand::Flush => FLUSH(level),
            PokerHand::ThreeOfAKind => THREE_OF_A_KIND(level),
            PokerHand::TwoPair => TWO_PAIR(level),
            PokerHand::OnePair => ONE_PAIR(level),
            PokerHand::HighCard => HIGH_CARD(level),
            PokerHand::None => NONE()
        }
    }

    fn get_game(ref self: Store, id: u32) -> Game {
        get!(self.world, id, (Game))
    }

    fn set_game(ref self: Store, game: Game) {
        set!(self.world, (game));
    }

    fn get_current_special_cards(ref self: Store, game_id: u32, idx: u32) -> CurrentSpecialCards {
        get!(self.world, (game_id, idx), (CurrentSpecialCards))
    }

    fn set_current_special_cards(ref self: Store, current_special_cards: CurrentSpecialCards) {
        set!(self.world, (current_special_cards));
    }

    fn get_player_level_poker_hand(ref self: Store, game_id: u32, poker_hand: PokerHand) -> PlayerLevelPokerHand {
        get!(self.world, (game_id, poker_hand), (PlayerLevelPokerHand))
    }

    fn set_player_level_poker_hand(ref self: Store, player_level_poker_hand: PlayerLevelPokerHand) {
        set!(self.world, (player_level_poker_hand));
    }

    fn get_current_hand_card(ref self: Store, game_id: u32, idx: u32) -> CurrentHandCard {
        get!(self.world, (game_id, idx), (CurrentHandCard))
    }

    fn set_current_hand_card(ref self: Store, current_hand_card: CurrentHandCard) {
        set!(self.world, (current_hand_card));
    }

    fn get_round(ref self: Store, game_id: u32) -> Round {
        get!(self.world, (game_id), (Round))
    }

    fn set_round(ref self: Store, round: Round) {
        set!(self.world, (round));
    }

    fn get_shop(ref self: Store, game_id: u32) -> Shop {
        get!(self.world, (game_id), (Shop))
    }

    fn set_shop(ref self: Store, shop: Shop) {
        set!(self.world, (shop));
    }

    fn get_card_item(ref self: Store, game_id: u32, idx: u32, item_type: CardItemType) -> CardItem {
        get!(self.world, (game_id, idx, item_type), (CardItem))
    }

    fn set_card_item(ref self: Store, card_item: CardItem) {
        set!(self.world, (card_item))
    }

    fn get_config_earning_cash(ref self: Store) -> EarningCashConfig {
        Default::default()
    }

    fn get_poker_hand_item(ref self: Store, game_id: u32, idx: u32) -> PokerHandItem {
        get!(self.world, (game_id, idx), (PokerHandItem))
    }

    fn set_poker_hand_item(ref self: Store, poker_hand_item: PokerHandItem) {
        set!(self.world, (poker_hand_item));
    }

    fn get_slot_special_cards_item(ref self: Store, game_id: u32) -> SlotSpecialCardsItem {
        get!(self.world, (game_id), (SlotSpecialCardsItem))
    }

    fn set_slot_special_cards_item(ref self: Store, slot_special_cards_item: SlotSpecialCardsItem) {
        set!(self.world, (slot_special_cards_item))
    }

    fn get_blister_pack(ref self: Store, id: u32) -> BlisterPack {
        if id == BASIC_BLISTER_PACK_ID {
            BASIC_BLISTER_PACK()
        } else if id == ADVANCED_BLISTER_PACK_ID {
            ADVANCED_BLISTER_PACK()
        } else if id == JOKER_BLISTER_PACK_ID {
            JOKER_BLISTER_PACK()
        } else if id == SPECIALS_BLISTER_PACK_ID {
            SPECIALS_BLISTER_PACK()
        } else if id == MODIFIER_BLISTER_PACK_ID {
            MODIFIER_BLISTER_PACK()
        } else if id == FIGURES_BLISTER_PACK_ID {
            FIGURES_BLISTER_PACK()
        } else if id == DECEITFUL_JOKER_BLISTER_PACK_ID {
            DECEITFUL_JOKER_BLISTER_PACK()
        } else if id == LOVERS_BLISTER_PACK_ID {
            LOVERS_BLISTER_PACK()
        } else if id == SPECIAL_BET_BLISTER_PACK_ID {
            SPECIAL_BET_BLISTER_PACK()
        } else {
            EMPTY_BLISTER_PACK()
        }
    }

    fn get_blister_pack_item(ref self: Store, game_id: u32, idx: u32) -> BlisterPackItem {
        get!(self.world, (game_id, idx), (BlisterPackItem))
    }

    fn set_blister_pack_item(ref self: Store, blister_pack_item: BlisterPackItem) {
        set!(self.world, (blister_pack_item));
    }

    fn get_blister_pack_result(ref self: Store, game_id: u32) -> BlisterPackResult {
        get!(self.world, (game_id), (BlisterPackResult))
    }

    fn set_blister_pack_result(ref self: Store, blister_pack_result: BlisterPackResult) {
        set!(self.world, (blister_pack_result));
    }
}

fn get_traditional_card(id: u32) -> Card {
    if id == TWO_CLUBS_ID {
        TWO_CLUBS()
    } else if id == THREE_CLUBS_ID {
        THREE_CLUBS()
    } else if id == FOUR_CLUBS_ID {
        FOUR_CLUBS()
    } else if id == FIVE_CLUBS_ID {
        FIVE_CLUBS()
    } else if id == SIX_CLUBS_ID {
        SIX_CLUBS()
    } else if id == SEVEN_CLUBS_ID {
        SEVEN_CLUBS()
    } else if id == EIGHT_CLUBS_ID {
        EIGHT_CLUBS()
    } else if id == NINE_CLUBS_ID {
        NINE_CLUBS()
    } else if id == TEN_CLUBS_ID {
        TEN_CLUBS()
    } else if id == JACK_CLUBS_ID {
        JACK_CLUBS()
    } else if id == QUEEN_CLUBS_ID {
        QUEEN_CLUBS()
    } else if id == KING_CLUBS_ID {
        KING_CLUBS()
    } else if id == ACE_CLUBS_ID {
        ACE_CLUBS()
    } else if id == TWO_DIAMONDS_ID {
        TWO_DIAMONDS()
    } else if id == THREE_DIAMONDS_ID {
        THREE_DIAMONDS()
    } else if id == FOUR_DIAMONDS_ID {
        FOUR_DIAMONDS()
    } else if id == FIVE_DIAMONDS_ID {
        FIVE_DIAMONDS()
    } else if id == SIX_DIAMONDS_ID {
        SIX_DIAMONDS()
    } else if id == SEVEN_DIAMONDS_ID {
        SEVEN_DIAMONDS()
    } else if id == EIGHT_DIAMONDS_ID {
        EIGHT_DIAMONDS()
    } else if id == NINE_DIAMONDS_ID {
        NINE_DIAMONDS()
    } else if id == TEN_DIAMONDS_ID {
        TEN_DIAMONDS()
    } else if id == JACK_DIAMONDS_ID {
        JACK_DIAMONDS()
    } else if id == QUEEN_DIAMONDS_ID {
        QUEEN_DIAMONDS()
    } else if id == KING_DIAMONDS_ID {
        KING_DIAMONDS()
    } else if id == ACE_DIAMONDS_ID {
        ACE_DIAMONDS()
    } else if id == TWO_HEARTS_ID {
        TWO_HEARTS()
    } else if id == THREE_HEARTS_ID {
        THREE_HEARTS()
    } else if id == FOUR_HEARTS_ID {
        FOUR_HEARTS()
    } else if id == FIVE_HEARTS_ID {
        FIVE_HEARTS()
    } else if id == SIX_HEARTS_ID {
        SIX_HEARTS()
    } else if id == SEVEN_HEARTS_ID {
        SEVEN_HEARTS()
    } else if id == EIGHT_HEARTS_ID {
        EIGHT_HEARTS()
    } else if id == NINE_HEARTS_ID {
        NINE_HEARTS()
    } else if id == TEN_HEARTS_ID {
        TEN_HEARTS()
    } else if id == JACK_HEARTS_ID {
        JACK_HEARTS()
    } else if id == QUEEN_HEARTS_ID {
        QUEEN_HEARTS()
    } else if id == KING_HEARTS_ID {
        KING_HEARTS()
    } else if id == ACE_HEARTS_ID {
        ACE_HEARTS()
    } else if id == TWO_SPADES_ID {
        TWO_SPADES()
    } else if id == THREE_SPADES_ID {
        THREE_SPADES()
    } else if id == FOUR_SPADES_ID {
        FOUR_SPADES()
    } else if id == FIVE_SPADES_ID {
        FIVE_SPADES()
    } else if id == SIX_SPADES_ID {
        SIX_SPADES()
    } else if id == SEVEN_SPADES_ID {
        SEVEN_SPADES()
    } else if id == EIGHT_SPADES_ID {
        EIGHT_SPADES()
    } else if id == NINE_SPADES_ID {
        NINE_SPADES()
    } else if id == TEN_SPADES_ID {
        TEN_SPADES()
    } else if id == JACK_SPADES_ID {
        JACK_SPADES()
    } else if id == QUEEN_SPADES_ID {
        QUEEN_SPADES()
    } else if id == KING_SPADES_ID {
        KING_SPADES()
    } else if id == ACE_SPADES_ID {
        ACE_SPADES()
    } else {
        Card { id: INVALID_CARD, suit: Suit::None, value: Value::None, points: 0, multi_add: 0 }
    }
}

fn get_neon_card(id: u32) -> Card {
    if id == NEON_TWO_CLUBS_ID {
        NEON_TWO_CLUBS()
    } else if id == NEON_THREE_CLUBS_ID {
        NEON_THREE_CLUBS()
    } else if id == NEON_FOUR_CLUBS_ID {
        NEON_FOUR_CLUBS()
    } else if id == NEON_FIVE_CLUBS_ID {
        NEON_FIVE_CLUBS()
    } else if id == NEON_SIX_CLUBS_ID {
        NEON_SIX_CLUBS()
    } else if id == NEON_SEVEN_CLUBS_ID {
        NEON_SEVEN_CLUBS()
    } else if id == NEON_EIGHT_CLUBS_ID {
        NEON_EIGHT_CLUBS()
    } else if id == NEON_NINE_CLUBS_ID {
        NEON_NINE_CLUBS()
    } else if id == NEON_TEN_CLUBS_ID {
        NEON_TEN_CLUBS()
    } else if id == NEON_JACK_CLUBS_ID {
        NEON_JACK_CLUBS()
    } else if id == NEON_QUEEN_CLUBS_ID {
        NEON_QUEEN_CLUBS()
    } else if id == NEON_KING_CLUBS_ID {
        NEON_KING_CLUBS()
    } else if id == NEON_ACE_CLUBS_ID {
        NEON_ACE_CLUBS()
    } else if id == NEON_TWO_DIAMONDS_ID {
        NEON_TWO_DIAMONDS()
    } else if id == NEON_THREE_DIAMONDS_ID {
        NEON_THREE_DIAMONDS()
    } else if id == NEON_FOUR_DIAMONDS_ID {
        NEON_FOUR_DIAMONDS()
    } else if id == NEON_FIVE_DIAMONDS_ID {
        NEON_FIVE_DIAMONDS()
    } else if id == NEON_SIX_DIAMONDS_ID {
        NEON_SIX_DIAMONDS()
    } else if id == NEON_SEVEN_DIAMONDS_ID {
        NEON_SEVEN_DIAMONDS()
    } else if id == NEON_EIGHT_DIAMONDS_ID {
        NEON_EIGHT_DIAMONDS()
    } else if id == NEON_NINE_DIAMONDS_ID {
        NEON_NINE_DIAMONDS()
    } else if id == NEON_TEN_DIAMONDS_ID {
        NEON_TEN_DIAMONDS()
    } else if id == NEON_JACK_DIAMONDS_ID {
        NEON_JACK_DIAMONDS()
    } else if id == NEON_QUEEN_DIAMONDS_ID {
        NEON_QUEEN_DIAMONDS()
    } else if id == NEON_KING_DIAMONDS_ID {
        NEON_KING_DIAMONDS()
    } else if id == NEON_ACE_DIAMONDS_ID {
        NEON_ACE_DIAMONDS()
    } else if id == NEON_TWO_HEARTS_ID {
        NEON_TWO_HEARTS()
    } else if id == NEON_THREE_HEARTS_ID {
        NEON_THREE_HEARTS()
    } else if id == NEON_FOUR_HEARTS_ID {
        NEON_FOUR_HEARTS()
    } else if id == NEON_FIVE_HEARTS_ID {
        NEON_FIVE_HEARTS()
    } else if id == NEON_SIX_HEARTS_ID {
        NEON_SIX_HEARTS()
    } else if id == NEON_SEVEN_HEARTS_ID {
        NEON_SEVEN_HEARTS()
    } else if id == NEON_EIGHT_HEARTS_ID {
        NEON_EIGHT_HEARTS()
    } else if id == NEON_NINE_HEARTS_ID {
        NEON_NINE_HEARTS()
    } else if id == NEON_TEN_HEARTS_ID {
        NEON_TEN_HEARTS()
    } else if id == NEON_JACK_HEARTS_ID {
        NEON_JACK_HEARTS()
    } else if id == NEON_QUEEN_HEARTS_ID {
        NEON_QUEEN_HEARTS()
    } else if id == NEON_KING_HEARTS_ID {
        NEON_KING_HEARTS()
    } else if id == NEON_ACE_HEARTS_ID {
        NEON_ACE_HEARTS()
    } else if id == NEON_TWO_SPADES_ID {
        NEON_TWO_SPADES()
    } else if id == NEON_THREE_SPADES_ID {
        NEON_THREE_SPADES()
    } else if id == NEON_FOUR_SPADES_ID {
        NEON_FOUR_SPADES()
    } else if id == NEON_FIVE_SPADES_ID {
        NEON_FIVE_SPADES()
    } else if id == NEON_SIX_SPADES_ID {
        NEON_SIX_SPADES()
    } else if id == NEON_SEVEN_SPADES_ID {
        NEON_SEVEN_SPADES()
    } else if id == NEON_EIGHT_SPADES_ID {
        NEON_EIGHT_SPADES()
    } else if id == NEON_NINE_SPADES_ID {
        NEON_NINE_SPADES()
    } else if id == NEON_TEN_SPADES_ID {
        NEON_TEN_SPADES()
    } else if id == NEON_JACK_SPADES_ID {
        NEON_JACK_SPADES()
    } else if id == NEON_QUEEN_SPADES_ID {
        NEON_QUEEN_SPADES()
    } else if id == NEON_KING_SPADES_ID {
        NEON_KING_SPADES()
    } else if id == NEON_ACE_SPADES_ID {
        NEON_ACE_SPADES()
    } else {
        Card { id: INVALID_CARD, suit: Suit::None, value: Value::None, points: 0, multi_add: 0 }
    }
}
