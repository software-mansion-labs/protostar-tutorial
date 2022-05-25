%lang starknet
%builtins pedersen range_check ecdsa
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)
from starkware.cairo.common.alloc import alloc

struct VoterInfo:
    # 1 yes/ 0 no
    member voted : felt
end

struct VotingState:
    member n_yes_votes : felt
    member n_no_votes : felt
end

@storage_var
func voter_info(user_address: felt) -> (res : VoterInfo):
end

@storage_var
func voting_state() -> (res : VoterInfo):
end


# @external
# func vote{
#     output_ptr : felt*,
#     pedersen_ptr : HashBuiltin*,
#     range_check_ptr,
#     ecdsa_ptr : SignatureBuiltin*,
# }(
#     vote : felt
# ) -> ():
#     alloc_locals
#     let ()
# end

func write_voters{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(addresses_len: felt, addresses : felt*):
    alloc_locals
    if addresses_len == 0:
        return()
    end
    
    local info : VoterInfo
    assert info.voted = 0
    # voter_info.write([addresses], info)

    write_voters(addresses_len - 1, addresses + 1)
    return ()
end


@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(addresses_len: felt, addresses : felt*):
    alloc_locals
    assert 1 = 1
    # write_voters(addresses_len, addresses)
    return ()
end
