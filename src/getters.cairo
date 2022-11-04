%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.voting import VotesCount, voting_state

@view
func get_state{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    state: VotesCount
) {
    let (state) = voting_state.read();
    return (state,);
}
