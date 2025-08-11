module InfinibandVerbs

# exports for context.jl functions
export Context, req_notify_send_cq, req_notify_recv_cq, get_qp_state,
        modify_qp_state, transition_qp_to_rts, transition_qp_to_rtr,
        wait_for_completion_event, wait_for_send_completion_event,
        wait_for_recv_completion_event, query_device, query_port
# exports for memory.jl functions
export reg_mr, create_recv_wrs, create_sges, post_wrs, llength
# exports for flow.jl functions
export create_flow, destroy_flow

# Include Clang-generated API wrappers
include("api.jl")
using .API

# Misc utility functions
include("utils.jl")

# Context
include("context.jl")

# Memory region functions
include("memory.jl")

# High level create_flow function
include("flow.jl")

# Receive loop function
include("recvloop.jl")

end # module InfinibandVerbs
