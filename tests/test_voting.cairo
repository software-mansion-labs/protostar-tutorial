%lang starknet
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)
from starkware.cairo.common.alloc import alloc

from src.voting import write_voters, voting_state, voter_info


@external
func test_write_voters{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    let (local addresses: felt*) = alloc()
    assert [addresses] = 111
    assert [addresses + 1] = 222
    assert [addresses + 2] = 333

    write_voters(3, addresses)

    let (voter) = voter_info.read(111)
    assert voter.voted = 0
    return ()
end
