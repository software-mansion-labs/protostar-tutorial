%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.voting import vote, register_voters

@external
func test_vote_no_permissions{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    %{ start_prank(4231421) %}
    %{ expect_revert("TRANSACTION_FAILED", "Address not allowed to vote") %}
    vote(0);
    return ();
}

@external
func test_vote_twice_failed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local addresses: felt*) = alloc();
    let registered_voter = 111;
    assert addresses[0] = registered_voter;
    register_voters(1, addresses);

    %{ stop_prank_callback = start_prank(ids.registered_voter) %}
    vote(0);
    %{ expect_revert(error_message="Address already voted") %}
    vote(0);
    return ();
}
