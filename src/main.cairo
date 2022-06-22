%lang starknet
%builtins pedersen range_check
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)

from src.voting import register_voters
from src.getters import get_state

@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(addresses_len: felt, addresses : felt*):
    alloc_locals
    register_voters(addresses_len, addresses)
    return ()
end