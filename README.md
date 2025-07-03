# InfinibandVerbs.jl

[Infiniband Verbs][] for [Julia][]

The `InfinibandVerbs.jl` package provides a [`Clang.jl`][]-generated module that
wraps the Infiniband Verbs API implemented in the [`libibverbs`][] library from
the [`rdma-core`][] project.  This package uses the `rdma-core` libraries from
a pre-built Julia JLL package.  `rdma-core` packages for the host OS need not be
installed (in fact they are ignored), but an RDMA compatible network interface
card (NIC) is required.

The underlying `rdma-core` libraries are only available for Linux, so
`InfinibandVerbs.jl` is likewise only available for Linux.

## Current Status

Currently `InfinibandVerbs.jl` consists of little more than the
[`Clang.jl`][]-generated wrapper module `InfinibandVerbs.API`.  Not
surprisingly, it follows the C interface very closely.  Some sample scripts
showing basic usage are available in the `bin` directory.

Some files are included under the `contrib` directory to facilitate the use of
`RAW_PACKET` queue pairs (QPs).  See below for more information.

## Future Plans

The plan is to develop a higher level API to provide a more Julia-like interface
to common operations.

## Notes on CAP_NET_RAW capability

Linux provides finely grained [capabilities][] that can be used to delegate
specific privileges to processes/threads.  One such capability, known as
`CAP_NET_RAW`, is required to create a `RAW_PACKET` type queue
pair (QP).  A Julia process that creates a `RAW_PACKET` QP must have this
capability.  If you are not using `RAW_PACKET` QPs then this section does not
apply.

A Julia process can be started with the `CAP_NET_RAW` capability in several
different ways, but some of them are not so amenable to all situations.  For
example, setting `CAP_NET_RAW` as a file level capability on the `julia`
executable file does not work if it is accessed via NFS.  Using `libpam-cap` to
enable capabilities for certain user's PAM sessions can work for local logins,
but does not work for SSH logins authenticated via pubkey authentication (at
least not on Ubuntu 24) unless they `su` to themselves, which defeats the
password-less login feature.  A more versatile way is to use `sudo` to run
`capsh`, but setting up `sudo` to allow that with no password required can be
tricky and setting up VS Code to run Julia as `sudo capsh ... julia ...` can be
inconvenient as well.

The author has opted to simplify this latter approach by writing a wrapper
script called `ibv_julia`.  This wrapper script uses `capsh` to add the
`CAP_NET_RAW` capability and then launch Julia (NB: as the calling user, NOT
`root`) with the same command line arguments that were passed to `ibv_julia`.
If not running as `root` already, the wrapper script will re-execute itself
using `sudo`.  Setting up `sudo` to allow this with no password is fairly
straightforward.  If this all sounds complicated (it is), don't worry!  Example
wrapper scripts and configuration files are provided to make it easy and fun.

A sample `ibv_julia` wrapper script is provided in `contrib/bin/ibv_julia` and a
sample `sudoers.d` "drop-in" file that allows members of the `sudo` group to run
`ibv_julia` without a password is provided in `contrib/etc/sudoers.d/ibv_julia`.
Be sure to tailor the contents of these file as appropriate for your system,
specifically the path to `ibv_julia` in the `sudoers.d` drop-in file!

As a final reminder, the `ibv_julia` wrapper script and `sudoers.d` drop-in file
are only needed to create queue pairs (QPs) having the `RAW_PACKET` type.  It is
not needed for other QP types nor for utility scripts that simply query device
parameters.

### Testing

After setting this up, you can test whether it works by trying to create a
`RAW_PACKET` QP, but for a more diagnostic approach you can run the `setpriv -d`
Linux command from the `ibv_julia` session.  If you see `net_raw` in both the
`Inheritable` and `Ambient` capabilities lines then the Julia process has the
requisite capabilities to use `RAW_PACKET` QPs.  If `net_raw` is not present on
both lines, then trying to create a `RAW_PACKET` QP will result in an `EPERM`
"Operation not permitted" error and the low level interface will return a NULL
QP equal to `C_NULL`.  Users of the low level interface are encouraged to
`throw(SystemError("ibv_create_qp"))` if the return value from `ibv_create_qp`
is `==` to `C_NULL`.

Here is an example showing the output of `setpriv -d` for a working setup:

```
julia> run(`setpriv -d`)
[...]
Inheritable capabilities: net_raw
Ambient capabilities: net_raw
[...]
```

### Creating `RAW_PACKET` QPs from within VS Code

If you are using `InfinibandVerbs.jl` from within VS Code and its Julia
extension (highly recommended) and you want to create `RAW_PACKET` QPs, you will
almost certainly need to run Julia via the `ibv_julia` wrapper script as
described above.  This is most conveniently done by specifying the path to
`ibv_julia` in the "Julia: Executable Path" setting.  The "Workspace" level is
probably the most appropriate level at which to modify this setting rather than
the "User" or "Remote" level.

### Creating `RAW_PACKET` QPs with `Distributed.jl`

If using `RAW_PACKET` QPs on remote workers launched via `Distributed.jl`, you
will also need to:

1. Ensure the `ibv_julia` wrapper script is available on the remote hosts
2. Ensure that workers run as a user that can `sudo` the wrapper script without
   a password
3. Use the `exename` keyword argument of `addprocs` to specify the `ibv_julia`
   wrapper script so that the worker processes will have the `CAP_NET_RAW`
   capability

[Infiniband Verbs]: https://en.wikipedia.org/wiki/InfiniBand#Software_interfaces
[Julia]: https://julialang.org/
[`Clang.jl`]: https://github.com/JuliaInterop/Clang.jl
[`libibverbs`]: https://github.com/linux-rdma/rdma-core/blob/master/Documentation/libibverbs.md
[`rdma-core`]: https://github.com/linux-rdma/rdma-core/
[capabilities]: https://sites.google.com/site/fullycapable/
