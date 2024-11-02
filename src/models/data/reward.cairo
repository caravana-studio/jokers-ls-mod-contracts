use jokers_of_neon::constants::reward::{REWARD_HP_POTION, REWARD_BLISTER_PACK, REWARD_SPECIAL_CARDS};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Reward {
    #[key]
    game_id: u32,
    rewards_ids: Span<u32>
}

#[derive(Serde, Copy, Drop, IntrospectPacked, PartialEq)]
enum RewardType {
    HP_POTION,
    BLISTER_PACK,
    SPECIAL_CARDS,
    NONE
}

impl u32IntoRewardType of Into<u32, RewardType> {
    fn into(self: u32) -> RewardType {
        if self == REWARD_HP_POTION {
            RewardType::HP_POTION
        } else if self == REWARD_BLISTER_PACK {
            RewardType::BLISTER_PACK
        } else if self == REWARD_SPECIAL_CARDS {
            RewardType::SPECIAL_CARDS
        } else {
            RewardType::NONE
        }
    }
}
