use jokers_of_neon::utils::round::calculate_level_score;

#[test]
#[available_gas(300000000000)]
fn test_calculate_level_score_two_level() {
    let level_score = calculate_level_score(level: 2);
    assert(level_score == 600, 'error level_score');
}

#[test]
#[available_gas(300000000000)]
fn test_calculate_level_score_ten_level() {
    let level_score = calculate_level_score(level: 10);
    assert(level_score == 5400, 'error level_score');
}

#[test]
#[available_gas(300000000000)]
fn test_calculate_level_score_twenty_level() {
    let level_score = calculate_level_score(level: 20);
    assert(level_score == 17400, 'error level_score');
}

#[test]
#[available_gas(300000000000)]
fn test_calculate_level_score_twenty_five_level() {
    let level_score = calculate_level_score(level: 25);
    assert(level_score == 32400, 'error level_score');
}

#[test]
#[available_gas(300000000000)]
fn test_calculate_level_score_thirty_level() {
    let level_score = calculate_level_score(level: 30);
    assert(level_score == 67400, 'error level_score');
}
