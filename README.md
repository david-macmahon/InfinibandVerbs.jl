# InfinibandVerbs.jl

[Infiniband Verbs][] for [Julia][]

The `InfinibandVerbs.jl` package provides a [`Clang.jl`][]-generated module that
wraps the Infiniband Verbs API implemented in the [`libibverbs`][] library from
the [`rdma-core`][] project.  This package uses the `rdma-core` libraraies from
a pre-built Julia JLL package.  `rdma-core` packages for the host OS need not be
installed (in fact they are ignored), but an RDMA compatible network interface
card (NIC) is required.

## Current Status

Currently `InfinibandVerbs.jl` consists of little more than the
[`Clang.jl`][]-generated wrapper module `InfinibandVerbs.API`.  Not
surprisingly, it follows the C interface very closely.  Some sample scripts
showing basic usage are available in the `bin` directory.

## Future Plans

The plan is to develop a higher level API to provide a more Julia-like interface
to common operations.

[Infiniband Verbs]: https://en.wikipedia.org/wiki/InfiniBand#Software_interfaces
[Julia]: https://julialang.org/
[`Clang.jl`]: https://github.com/JuliaInterop/Clang.jl
[`libibverbs`]: https://github.com/linux-rdma/rdma-core/blob/master/Documentation/libibverbs.md
[`rdma-core`]: https://github.com/linux-rdma/rdma-core/
