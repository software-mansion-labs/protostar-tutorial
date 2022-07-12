%lang starknet
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    SignatureBuiltin,
)
from starkware.cairo.common.alloc import alloc
from src.voting import VotesCount

@contract_interface
namespace VotingContract:
    func vote(vote : felt):
    end

    func get_state() -> (state: VotesCount):
    end
end

@external
func test_voting{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals
    # Deploy the contract
    local voting_contract_address
    %{ ids.voting_contract_address = deploy_contract('./src/main.cairo', {"addresses": [111, 222, 333]}).contract_address %}

    # Let everybody vote
    %{ stop_prank_callback = start_prank(111, target_contract_address=ids.voting_contract_address) %}
    VotingContract.vote(voting_contract_address, 1)
    %{ stop_prank_callback() %}

    %{ stop_prank_callback = start_prank(222, target_contract_address=ids.voting_contract_address) %}
    VotingContract.vote(voting_contract_address, 1)
    %{ stop_prank_callback() %}

    %{ stop_prank_callback = start_prank(333, target_contract_address=ids.voting_contract_address) %}
    VotingContract.vote(voting_contract_address, 0)
    %{ stop_prank_callback() %}

    # Check results as a third party
    %{ stop_prank_callback = start_prank(444, target_contract_address=ids.voting_contract_address) %}
    let (state) = VotingContract.get_state(voting_contract_address)
    assert state.no_votes = 1
    assert state.yes_votes = 2
    return ()
end
