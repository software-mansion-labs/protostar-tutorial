%lang starknet
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)
from starkware.cairo.common.alloc import alloc

from src.voting import write_voters, voting_state, voter_info, vote


@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(addresses_len: felt, addresses : felt*):
    alloc_locals
    write_voters(addresses_len, addresses)
    return ()
end
