using Clang.Generators
using rdma_core_jll
using GCCBootstrap_jll

cd(@__DIR__)

include_dir = normpath(rdma_core_jll.artifact_dir, "include")
infiniband_dir = joinpath(include_dir, "infiniband")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator_api.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(infiniband_dir, "verbs.h")]
#headers = [joinpath(infiniband_dir, header) for header in readdir(infiniband_dir) if endswith(header, ".h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)

# Run again for fcntl.h and poll.h to get constants for fcntl() and poll()
gcc_include_dir = normpath(GCCBootstrap_jll.artifact_dir, "./x86_64-linux-gnu/sysroot/usr/include/asm-generic")
headers = joinpath.(gcc_include_dir, ["fcntl.h", "poll.h"])
args = get_default_args()
options = load_options(joinpath(@__DIR__, "generator_poll.toml"))
ctx = create_context(headers, args, options)
build!(ctx)
