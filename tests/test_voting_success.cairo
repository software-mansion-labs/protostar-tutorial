%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.voting import register_voters, voter_info, voting_state, vote

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local addresses: felt*) = alloc();
    let registered_voter = 111;
    assert addresses[0] = registered_voter;
    register_voters(1, addresses);
    %{ context.registered_voter = ids.registered_voter # Store registered voter in context %}

    return ();
}

@external
func test_vote_yes_success{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local registered_voter;
    %{
        start_prank(context.registered_voter)
        ids.registered_voter = context.registered_voter # Read registered voter from context to local variable
    %}
    vote(1);

    // Check voting state
    let (state) = voting_state.read();
    assert state.no_votes = 0;
    assert state.yes_votes = 1;

    // Check voter info
    let (voter) = voter_info.read(registered_voter);
    assert voter.allowed = 1;
    assert voter.voted = 1;
    return ();
}

@external
func test_vote_no_success{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local registered_voter;
    %{
        start_prank(context.registered_voter)
        ids.registered_voter = context.registered_voter # Read registered voter from context to local variable
    %}
    vote(0);

    // Check voting state
    let (state) = voting_state.read();
    assert state.no_votes = 1;
    assert state.yes_votes = 0;

    // Check voter info
    let (voter) = voter_info.read(registered_voter);
    assert voter.allowed = 1;
    assert voter.voted = 1;
    return ();
}
