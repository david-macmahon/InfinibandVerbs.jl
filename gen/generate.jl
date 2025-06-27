using Clang.Generators
using rdma_core_jll

cd(@__DIR__)

include_dir = normpath(rdma_core_jll.artifact_dir, "include")
infiniband_dir = joinpath(include_dir, "infiniband")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(infiniband_dir, "verbs.h")]
#headers = [joinpath(infiniband_dir, header) for header in readdir(infiniband_dir) if endswith(header, ".h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
