%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

// State
struct VotesCount {
    yes_votes: felt,
    no_votes: felt,
}

@storage_var
func voting_state() -> (res: VotesCount) {
}

struct VoterInfo {
    voted: felt,
    allowed: felt,
}

@storage_var
func voter_info(user_address: felt) -> (res: VoterInfo) {
}

func register_voters{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addresses_len: felt, addresses: felt*
) {
    // No voters left
    if (addresses_len == 0) {
        return ();
    }

    let v_info = VoterInfo(voted=0, allowed=1);
    voter_info.write(addresses[addresses_len - 1], v_info);

    // Go to the next voter
    return register_voters(addresses_len - 1, addresses);
}

func assert_allowed_to_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    info: VoterInfo
) {
    // We check if caller is allowed to vote
    with_attr error_message("Address not allowed to vote.") {
        assert_not_zero(info.allowed);
    }

    return ();
}

func assert_did_not_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    info: VoterInfo
) {
    // We check if caller hasn't already voted
    with_attr error_message("Address already voted.") {
        assert info.voted = 0;
    }
    return ();
}

@external
func vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(vote: felt) -> () {
    alloc_locals;
    let (caller) = get_caller_address();
    let (info) = voter_info.read(caller);

    assert_allowed_to_vote(info);
    assert_did_not_vote(info);

    // Set voted flag to true
    let new_info = VoterInfo(voted=1, allowed=1);
    voter_info.write(caller, new_info);

    let (state) = voting_state.read();
    // Add positive/negative vote
    local new_state: VotesCount;
    if (vote == 0) {
        assert new_state.no_votes = state.no_votes + 1;
        assert new_state.yes_votes = state.yes_votes;
    }
    if (vote == 1) {
        assert new_state.no_votes = state.no_votes;
        assert new_state.yes_votes = state.yes_votes + 1;
    }
    voting_state.write(new_state);
    return ();
}
