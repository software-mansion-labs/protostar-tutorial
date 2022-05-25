%lang starknet
%builtins pedersen range_check
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)
from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address

struct VoterInfo:
    # 1 yes / 0 no
    member voted : felt
    member voter_id : felt
end

struct VotingState:
    member n_yes_votes : felt
    member n_no_votes : felt
end

@storage_var
func voter_info(user_address: felt) -> (res : VoterInfo):
end

@storage_var
func voting_state() -> (res : VotingState):
end


@external
func vote{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    vote : felt
) -> ():
    alloc_locals
    let (caller) = get_caller_address()

    let (info) = voter_info.read(caller)
    let (state) = voting_state.read()

    with_attr error_message("Address not allowed to vote."):
        assert_not_zero(info.voter_id)
    end

    with_attr error_message("Address already voted."):
        assert info.voted = 0
    end 
    

    local new_info : VoterInfo
    assert new_info.voted = 1
    assert new_info.voter_id = info.voter_id
    voter_info.write(caller, new_info)

    local new_state : VotingState
    if vote == 0:
        assert new_state.n_no_votes = state.n_no_votes + 1
        assert new_state.n_yes_votes = state.n_yes_votes
    end
    if vote == 1:
        assert new_state.n_no_votes = state.n_no_votes
        assert new_state.n_yes_votes = state.n_yes_votes + 1
    end
    voting_state.write(new_state)
    return ()
end

@view
func get_state{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}() -> (state: VotingState):
    let (state) = voting_state.read()
    return (state)
end

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
    assert info.voter_id = addresses_len

    voter_info.write([addresses], info) 

    write_voters(addresses_len - 1, addresses + 1)
    return ()
end


