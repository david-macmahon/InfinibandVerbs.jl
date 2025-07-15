module InfinibandVerbs

export create_flow

# Include Clang-generated API wrappers
include("api.jl")

# Misc utility functions
include("utils.jl")

# High level create_flow function
include("flow.jl")

end # module InfinibandVerbs
