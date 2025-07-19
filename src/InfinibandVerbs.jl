module InfinibandVerbs

export Context, req_notify_send_cq, req_notify_recv_cq
export create_flow

# Include Clang-generated API wrappers
include("api.jl")
using .API

# Misc utility functions
include("utils.jl")

# Context
include("context.jl")

# High level create_flow function
include("flow.jl")

end # module InfinibandVerbs
