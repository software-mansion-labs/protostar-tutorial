%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.voting import register_voters, voter_info

@external
func test_register_voters{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local addresses: felt*) = alloc();
    assert addresses[0] = 111;
    assert addresses[1] = 222;
    assert addresses[2] = 333;
    register_voters(3, addresses);

    // Check registered voters
    let (voter) = voter_info.read(111);
    assert voter.allowed = 1;

    let (voter) = voter_info.read(222);
    assert voter.allowed = 1;

    let (voter) = voter_info.read(333);
    assert voter.allowed = 1;

    // Check example non-registered voter
    let (voter) = voter_info.read(4231421);
    assert voter.allowed = 0;
    return ();
}
