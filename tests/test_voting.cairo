%lang starknet
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)
from starkware.cairo.common.alloc import alloc

from src.voting import write_voters, voting_state, voter_info, vote


@external
func test_write_voters{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    let (local addresses: felt*) = alloc()
    assert addresses[0] = 111
    assert addresses[1] = 222
    assert addresses[2] = 333

    write_voters(3, addresses)

    let (voter) = voter_info.read(111)
    assert voter.voter_id = 3

    let (voter) = voter_info.read(222)
    assert voter.voter_id = 2

    let (voter) = voter_info.read(333)
    assert voter.voter_id = 1 

    let (voter) = voter_info.read(4231421)
    assert voter.voter_id = 0
    return ()
end

@external
func test_vote_yes_success{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    let (local addresses: felt*) = alloc()
    assert addresses[0] = 111

    write_voters(1, addresses)

    %{ stop_prank_callback = start_prank(111) %}

    vote(1)

    let (state) = voting_state.read()
    assert state.n_no_votes = 0
    assert state.n_yes_votes = 1

    let (voter) = voter_info.read(111)
    assert voter.voter_id = 1
    assert voter.voted = 1
    return ()
end


@external
func test_vote_no_success{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    let (local addresses: felt*) = alloc()
    assert addresses[0] = 111

    write_voters(1, addresses)

    %{ stop_prank_callback = start_prank(111) %}

    vote(0)

    let (state) = voting_state.read()
    assert state.n_no_votes = 1
    assert state.n_yes_votes = 0

    let (voter) = voter_info.read(111)
    assert voter.voter_id = 1
    assert voter.voted = 1
    return ()
end

@external
func test_vote_no_permissions{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    let (local addresses: felt*) = alloc()
    assert addresses[0] = 111

    write_voters(1, addresses)

    %{ stop_prank_callback = start_prank(4231421) %}
    
    %{ expect_revert("TRANSACTION_FAILED", "Address not allowed to vote")%}
    vote(0)
    return ()
end

@external
func test_vote_twice_failed{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    let (local addresses: felt*) = alloc()
    assert addresses[0] = 111

    write_voters(1, addresses)

    %{ stop_prank_callback = start_prank(111) %}
    vote(0)

    %{ expect_revert("TRANSACTION_FAILED", "Address already voted")%}
    vote(0)
    return ()
end
