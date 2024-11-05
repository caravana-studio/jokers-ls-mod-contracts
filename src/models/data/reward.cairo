use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};
use jokers_of_neon::constants::reward::{REWARD_HP_POTION, REWARD_BLISTER_PACK, REWARD_SPECIAL_CARDS};

#[derive(Copy, Drop, Serde)]
#[dojo::event]
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
#[generate_trait]
impl RewardImpl of RewardTrait {
    fn challenge(world: IWorldDispatcher, game_id: u32) {
        let reward = Reward { game_id, rewards_ids: array![REWARD_HP_POTION, REWARD_BLISTER_PACK].span() };
        RewardStore::set(@reward, world);
        emit!(world, (reward))
    }

    fn beast(world: IWorldDispatcher, game_id: u32) {
        let reward = Reward { game_id, rewards_ids: array![REWARD_HP_POTION, REWARD_SPECIAL_CARDS].span() };
        RewardStore::set(@reward, world);
        emit!(world, (reward))
    }
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
