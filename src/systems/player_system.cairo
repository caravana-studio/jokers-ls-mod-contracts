use jokers_of_neon::{
    models::{
        data::{beast::{GameModeBeast, Beast, PlayerBeast}, challenge::{Challenge, ChallengePlayer}, reward::Reward,},
        status::{game::game::Game, shop::shop::BlisterPackResult, round::current_hand_card::CurrentHandCard}
    }
};

#[dojo::interface]
trait IPlayerSystem {
    fn get_game(world: @IWorldDispatcher, game_id: u32) -> Game;
    fn get_player_current_hand(world: @IWorldDispatcher, game_id: u32) -> Array<CurrentHandCard>;
    fn get_game_mode_beast(world: @IWorldDispatcher, game_id: u32) -> GameModeBeast;
    fn get_beast(world: @IWorldDispatcher, game_id: u32) -> Beast;
    fn get_player_beast(world: @IWorldDispatcher, game_id: u32) -> PlayerBeast;
    fn get_challenge(world: @IWorldDispatcher, game_id: u32) -> Challenge;
    fn get_challenge_player(world: @IWorldDispatcher, game_id: u32) -> ChallengePlayer;
    fn get_reward(world: @IWorldDispatcher, game_id: u32) -> Reward;
    fn get_blister_pack_result(world: @IWorldDispatcher, game_id: u32) -> BlisterPackResult;
}

#[dojo::contract]
mod player_system {
    use jokers_of_neon::{
        models::{
            data::{
                beast::{Beast, BeastStore, GameModeBeast, GameModeBeastStore, PlayerBeast, PlayerBeastStore},
                challenge::{Challenge, ChallengeStore, ChallengePlayer, ChallengePlayerStore},
                reward::{Reward, RewardStore},
            },
            status::{
                game::game::{Game, GameStore}, shop::shop::{BlisterPackResult, BlisterPackResultStore},
                round::current_hand_card::{CurrentHandCard, CurrentHandCardStore}
            }
        }
    };

    #[abi(embed_v0)]
    impl PokerHandSystem of super::IPlayerSystem<ContractState> {
        fn get_game(world: @IWorldDispatcher, game_id: u32) -> Game {
            GameStore::get(world, game_id)
        }

        fn get_player_current_hand(world: @IWorldDispatcher, game_id: u32) -> Array<CurrentHandCard> {
            let mut current_hand = array![];
            let game = GameStore::get(world, game_id);

            let mut i = 0;
            loop {
                if i == game.len_hand {
                    break;
                }
                current_hand.append(CurrentHandCardStore::get(world, game_id, i));
                i += 1;
            };
            current_hand
        }

        fn get_beast(world: @IWorldDispatcher, game_id: u32) -> Beast {
            BeastStore::get(world, game_id)
        }

        fn get_player_beast(world: @IWorldDispatcher, game_id: u32) -> PlayerBeast {
            PlayerBeastStore::get(world, game_id)
        }

        fn get_game_mode_beast(world: @IWorldDispatcher, game_id: u32) -> GameModeBeast {
            GameModeBeastStore::get(world, game_id)
        }

        fn get_challenge(world: @IWorldDispatcher, game_id: u32) -> Challenge {
            ChallengeStore::get(world, game_id)
        }

        fn get_challenge_player(world: @IWorldDispatcher, game_id: u32) -> ChallengePlayer {
            ChallengePlayerStore::get(world, game_id)
        }

        fn get_reward(world: @IWorldDispatcher, game_id: u32) -> Reward {
            RewardStore::get(world, game_id)
        }

        fn get_blister_pack_result(world: @IWorldDispatcher, game_id: u32) -> BlisterPackResult {
            BlisterPackResultStore::get(world, game_id)
        }
    }
}
