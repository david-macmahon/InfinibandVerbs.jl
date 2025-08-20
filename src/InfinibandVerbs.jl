module InfinibandVerbs

# exports for context.jl functions
export Context, req_notify_send_cq, req_notify_recv_cq, get_qp_state,
        modify_qp_state, transition_qp_to_rts, transition_qp_to_rtr,
        wait_for_completion_event, wait_for_send_completion_event,
        wait_for_recv_completion_event, query_device, query_device_ex,
        query_port, hascapability

# exports for memory.jl functions
export reg_mr, create_sges, create_recv_wrs, create_send_wrs, post_wrs,
       link_wrs!, llength

# exports for flow.jl functions
export create_flow, destroy_flow

# exports for repostloop.jl functions
export repost_loop

# Include Clang-generated API wrappers
include("api.jl")
using .API

# Include Clang-generated fcntl/poll wrappers
include("poll.jl")
using .Poll

# Misc utility functions
include("utils.jl")

# Context
include("context.jl")

# Memory region functions
include("memory.jl")

# High level create_flow function
include("flow.jl")

# repost_loop and related functions
include("repostloop.jl")

end # module InfinibandVerbs
