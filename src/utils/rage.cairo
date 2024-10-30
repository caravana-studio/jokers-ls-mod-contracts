use jokers_of_neon::models::status::game::rage::RageRound;
use jokers_of_neon::utils::constants::is_rage_card;

/// Search if a specific rage card is active in the current round.
/// # Arguments
/// * `rage_round` - The RageRound model that represents the current state of rage round.
/// # Returns
/// * True if the rage card is active, otherwise false.
fn is_rage_card_active(rage_round: @RageRound, rage_card_id: u32) -> bool {
    let mut result = false;
    assert(is_rage_card(rage_card_id), 'Invalid rage card id');

    if *rage_round.is_active {
        let mut active_rages = (*rage_round.active_rage_ids).clone();
        result =
            loop {
                match active_rages.pop_front() {
                    Option::Some(active_rage_id) => { if *active_rage_id == rage_card_id {
                        break true;
                    } },
                    Option::None => { break false; }
                }
            };
    }
    result
}
