# Memory region functions

"""
    reg_mr(ctx, buf; access=IBV_ACCESS_LOCAL_WRITE) -> Ptr{ibv_mr}

Register the memory region starting at `pointer(obj)` spanning `sizeof(obj)`
bytes with access mode given by `access`.  By default, local read and local
write access are enabled.  Local read is always enabled.  To disable local
write, pass `0` for `access`.  This function throws an exception if the
registration fails, otherwise a valid (non-`C_NULL`) `Ptr{ibv_mr}` is returned.
"""
function reg_mr(ctx, buf; access=IBV_ACCESS_LOCAL_WRITE)
    mr = ibv_reg_mr(ctx.pd, pointer(buf), sizeof(buf), access)
    mr == C_NULL && throw(SystemError("ibv_reg_mr"))
    mr
end

"""
    get_lkey(mr::Ptr{ibv_mr}) -> lkey

Get the `lkey` value of memory region `mr`.
"""
function get_lkey(mr::Ptr{ibv_mr})
    mr == C_NULL && throw(ArgumentError("invalid memory region"))
    unsafe_load(mr).lkey
end

"""
    create_sges(bufs, lkeys, num_wr[, npad]) -> Matrix{ibv_sge}

Return a `Matrix{ibv_sge}` of size `(length(bufs), num_wr)`.

Each column of the returned Matrix is an SG list initialized to point to the
first `num_wr` packets of `bufs`.  Both `bufs` and `lkeys` must be Vectors of
the same length.  The elements of `bufs` are Arrays that must be sized for the
same number of packets and `num_wr` must not exceed this number.  The elements
of `lkeys` must be the `lkey` values corresponding to the registered memory
regions for `bufs`.

The Arrays in `bufs` may include a number of padding bytes along their first
dimension to improve alignment of the packet data.  The number of padding bytes
may be specified by passing `npad`.  `npad` may be a single `Int` to apply the
same value to all `bufs` Arrays or a `Vector{Int}` to specify values for all the
`bufs` Array.  The default value of `npad` is `0` (i.e. no padding).  The
value(s) of `npad` will be subtracted from the number of bytes in the first
dimensions of the `bufs` Array.
"""
function create_sges(
    bufs::AbstractVector{<:AbstractArray},
    lkeys::AbstractVector{<:Integer},
    num_wr::Integer,
    npad::Union{Integer, Vector{<:Integer}}=0
)::Matrix{ibv_sge}
    # Reshape bufs to matrices
    bufmats = reshape.(bufs, size.(bufs, 1), :)

    # Ensure all bufs have the same number of packets
    nupkts = unique(size.(bufmats, 2))
    if length(nupkts) != 1
        throw(ArgumentError("all bufs must hold the same number of packets (got $nupkts)"))
    end
    npkts = nupkts[1]

    # num_wr must be <= npkts
    if num_wr > npkts
        throw(ArgumentError("num_wr ($num_wr) cannot exceed number of packets ($npkt)"))
    end

    # Use broadcasting to create Matrix{ibv_sge}
    ibv_sge.(
        # Pointers
        pointer.(view.(bufmats,1,:), permutedims(1:num_wr)),
        # Lengths
        (size.(bufmats, 1) .* sizeof.(eltype.(bufmats))) .- npad,
        # LKeys
        lkeys
    )
end

"""
    create_recv_wrs(ctx::Context, bufs, num_wr[, npad]; post=false) -> recv_wrs, sges, mrs
    create_recv_wrs(mrs, bufs, num_wr[, npad]) -> recv_wrs, sges

Return `num_wr` `ibv_recv_wr` work requests (WRs) and their associated
scatter-gather (SG) lists.

`bufs` and `mrs`, if given, must be Vectors.  If the form with `ctx::Context` is
called, the memory region(s) of `bufs` will be registered before calling the
`mrs` form and the resulting MRs will be returned in addition to the WRs and SG
lists.  If memory regions `mrs` are given, their `lkey` values will be used when
populating the SG lists so `mrs` must correspond to `bufs`.  All of the Arrays
in `bufs` must hold the same number of packets (i.e. packet fragments).  See the
doc string for [`create_sges`](@ref) for details about the `npad` parameter.

The `Context` form also accepts keyword argument `post` (default `false`).  If
`post` is `true`, the work requests will be posted and the `Context`'s QP will
be transitioned to a "ready-to-receive" (RTR) compatible state.
"""
function create_recv_wrs(
    mrs::AbstractVector{Ptr{ibv_mr}},
    bufs::AbstractVector{<:AbstractArray},
    num_wr::Integer,
    npad::Union{Integer, Vector{<:Integer}}=0
)
    # Create and initialize SGEs
    sges = create_sges(bufs, get_lkey.(mrs), num_wr, npad)
    sgheads = view(sges, 1, :)

    # Create and initialize recv WRs
    numsge = length(bufs)
    recv_wrs = Vector{ibv_recv_wr}(undef, num_wr)
    for wr_id = 1:num_wr-1
        pnext = pointer(recv_wrs, wr_id+1)
        psge = pointer(sgheads, wr_id)
        recv_wrs[wr_id] = ibv_recv_wr(
            wr_id,  # wr_id::UInt64
            pnext,  # next::Ptr{ibv_recv_wr}
            psge,   # sge_list::Ptr{ibv_sge}
            numsge  # num_sge::Int32
        )
    end
    # Initialize last element
    psge = pointer(sgheads, num_wr)
    recv_wrs[num_wr] = ibv_recv_wr(
        num_wr, # wr_id::UInt64
        C_NULL, # next::Ptr{ibv_recv_wr}
        psge,   # sge_list::Ptr{ibv_sge}
        numsge  # num_sge::Int32
    )

    recv_wrs, sges
end

function create_recv_wrs(
    ctx::Context,
    bufs::AbstractVector{<:AbstractArray},
    num_wr::Integer,
    npad::Union{Integer, Vector{<:Integer}}=0;
    post=false
)
    mrs = reg_mr.(Ref(ctx), bufs)
    recv_wrs, sges = create_recv_wrs(mrs, bufs, num_wr, npad)
    post && post_wrs(ctx, pointer(recv_wrs); modify_qp=true)
    recv_wrs, sges, mrs
end

"""
    create_send_wrs(ctx::Context, bufs, num_wr[, npad]; offload=false, post=false) -> send_wrs, sges, mrs
    create_send_wrs(mrs, bufs, num_wr[, npad]) -> send_wrs, sges

Return `num_wr` `ibv_send_wr` work requests (WRs) and their associated
scatter-gather (SG) lists.

`bufs` and `mrs`, if given, must be Vectors.  If the form with `ctx::Context` is
called, the memory region(s) of `bufs` will be registered before calling the
`mrs` form and the resulting MRs will be returned in addition to the WRs and SG
lists.  If memory regions `mrs` are given, their `lkey` values will be used when
populating the SG lists so `mrs` must correspond to `bufs`.  All of the Arrays
in `bufs` must hold the same number of packets (i.e. packet fragments).  See the
doc string for [`create_sges`](@ref) for details about the `npad` parameter.

The `Context` form also accepts keyword arguments `offload` and `post`, both of
which default to `false`.  If `offload` is `true` the WRs will be setup to
offload the IP checksum calculation to the NIC.  You can use `hascapability` to
check whether your device supports this.  See the man page of `ibv_post_send`
for more details.  If `post` is `true`, the `Context`'s QP will be transitioned
to the "ready-to-send" (RTS) state and the work requests will be posted.
"""
function create_send_wrs(
    mrs::AbstractVector{Ptr{ibv_mr}},
    bufs::AbstractVector{<:AbstractArray},
    num_wr::Integer,
    npad::Union{Integer, Vector{<:Integer}}=0;
    offload=false
)
    # Create and initialize SGEs
    sges = create_sges(bufs, get_lkey.(mrs), num_wr, npad)
    sgheads = view(sges, 1, :)

    # Create and initialize send WRs
    num_sge = length(bufs)
    send_wrs = Vector{ibv_send_wr}(undef, num_wr)

    opcode = IBV_WR_SEND
    send_flags = offload ? IBV_SEND_IP_CSUM : 0
    for wr_id = 1:num_wr-1
        next = pointer(send_wrs, wr_id+1)
        sg_list = pointer(sgheads, wr_id)
        send_wrs[wr_id] = ibv_send_wr(;
            wr_id,   # wr_id::UInt64
            next,    # next::Ptr{ibv_recv_wr}
            sg_list, # sg_list::Ptr{ibv_sge}
            num_sge, # num_sge::Int32
            opcode,
            send_flags
        )
    end
    # Initialize last element
    wr_id = num_wr
    next = C_NULL
    sg_list = pointer(sgheads, num_wr)
    send_wrs[num_wr] = ibv_send_wr(;
        wr_id,   # wr_id::UInt64
        next,    # next::Ptr{ibv_recv_wr}
        sg_list, # sge_list::Ptr{ibv_sge}
        num_sge, # num_sge::Int32
        opcode,
        send_flags
    )

    send_wrs, sges
end

function create_send_wrs(
    ctx::Context,
    bufs::AbstractVector{<:AbstractArray},
    num_wr::Integer,
    npad::Union{Integer, Vector{<:Integer}}=0;
    offload=false,
    post=false
)
    mrs = reg_mr.(Ref(ctx), bufs)
    send_wrs, sges = create_send_wrs(mrs, bufs, num_wr, npad; offload)
    post && post_wrs(ctx, pointer(send_wrs); modify_qp=true)
    send_wrs, sges, mrs
end

"""
    post_wrs(ctx::Context, wr::Ptr; modify_qp=false) -> nothing
    post_wrs(ctx::Context, wrs::Vector, idx=1; modify_qp=false) -> nothing

Post linked WRs to the `Context`'s QP.

`wr` may be a `Ptr{ibv_send_wr}`/`Ptr{ibv_recv_wr}` or
`Vector{ibv_send_wr}`/`Vector{ibv_recv_wr}`.  Passing a `Vector` will only post
the WRs that are part of the linked list headed by the WR `wrs[idx]` of the
Vector, which may not be the same as `wrs[idx:end]`.  Throws a `SystemError` if
the underlying library call fails, otherwise returns `nothing`.

If `modify_qp` is `true`, the Context's QP will be transitioned appropriately
for the work request type:

- For `ibv_recv_wr`, the QP will be transitioned to a "ready-to-receive"
  compatible state _after_ posting the WRs.

- For `ibv_send_wr`, the QP will be transitioned to the "ready-to-send" state
  _before_ posting the WRs.
"""
function post_wrs(ctx::Context, send_wr::Ptr{ibv_send_wr}; modify_qp=false)
    # If modify_qp is true, transition QP to RTS state
    modify_qp && transition_qp_to_rts(ctx)

    wr_bad = Ref{Ptr{ibv_send_wr}}(C_NULL)
    errno = ibv_post_send(ctx.qp, send_wr, wr_bad)
    errno == 0 || throw(SystemErrer("ibv_post_send [wr_id=$(wr_bad[][].wr_id)]", errno))
    nothing
end

function post_wrs(ctx::Context, recv_wr::Ptr{ibv_recv_wr}; modify_qp=false)
    wr_bad = Ref{Ptr{ibv_recv_wr}}(C_NULL)
    errno = ibv_post_recv(ctx.qp, recv_wr, wr_bad)
    errno == 0 || throw(SystemError("ibv_post_recv [wr_id=$(wr_bad[][].wr_id)]", errno))

    # If modify_qp is true, transition qp to RTR-compatible state
    modify_qp && transition_qp_to_rtr(ctx)
    nothing
end

function post_wrs(ctx::Context,
    wrs::Vector{<:Union{ibv_send_wr,ibv_recv_wr}}, idx=1;
    modify_qp=false
)
    post_wrs(ctx, pointer(wrs, idx); modify_qp)
end

"""
    link_wrs!(wrs, n=length(wrs))

Link the first `n`, default all) work requests in `wrs`.  `n < 1` does nothing.
`n >= length(wrs)` links all work requests in `wrs`.  Returns `wrs`.
"""
function link_wrs!(
    wrs::AbstractVector{<:Union{ibv_send_wr,ibv_recv_wr}},
    n=length(wrs)
)
    n < 1 && return wrs
    n = min(n, length(wrs))

    # Update the `next` pointer of all but the last work request
    for wr_id = 1:n-1
        pnext = pointer(wrs, wr_id+1)
        pointer(wrs, wr_id).next  = pnext
    end
    # Null terminate the linked list
    pointer(wrs, n).next = C_NULL

    wrs
end

"""
    link_wrs!(wrs, wcs, num_wc)

Link work requests in `wrs` identified by work completions `wcs[1:num_wc]`.

`num_wc < 1` does nothing.  `num_wc >= length(wcs)` links work requests
identified by all work completiond in `wcs`.
Throws an exception if `num_wcs > length(wrs)`.  Returns `wrs`.
"""
function link_wrs!(
    wrs::AbstractVector{<:Union{ibv_send_wr,ibv_recv_wr}},
    wcs::AbstractVector{ibv_wc},
    num_wc
)
    num_wc < 1 && return wrs
    num_wc = min(num_wc, length(wcs))
    num_wc > length(wrs) && error("more WCs than WRs ($num_wc > $(length(wrs)))")

    # Update the `next` pointer of the WRs identified by the first `num_wc-1`
    # WCs
    wr_id = wcs[1].wr_id
    for i = 1:num_wc-1
        wr_id_next = wcs[i+1].wr_id
        pnext = pointer(wrs, wr_id_next)
        pointer(wrs, wr_id).next  = pnext
        wr_id = wr_id_next
    end
    # Null terminate the linked list
    pointer(wrs, wr_id).next = C_NULL

    wrs
end

"""
    llength(ptr::Ptr{ibv_sge}) -> Int
    llength(ptr::Ptr{ibv_recv_wr}) -> Int
    llength(ptr::Ptr{ibv_send_wr}) -> Int

Return the length of a linked list of work requests (WRs) or scatter/gather
elemenets (SGEs) headed by the item pointed to by `ptr`.
"""
function llength(ptr::Ptr{T}, n=0) where {T<:Union{ibv_recv_wr,ibv_send_wr,ibv_sge}}
    ptr == C_NULL ? n : llength(ptr.next[], n+1)
end

"""
    llength(sges::AbstractArray{Ptr{ibv_sge}}, i=1) -> Int
    llength(wrs::AbstractArray{Ptr{ibv_recv_wr}}, i=1) -> Int
    llength(wrs::AbstractArray{Ptr{ibv_send_wr}}, i=1) -> Int

Return the length of a linked list of work requests (WRs) or scatter/gather
elemenets (SGEs) starting with the first (or `i`-th) element in the given Array.
"""
function llength(items::AbstractArray{T}, i=1) where {T<:Union{ibv_recv_wr,ibv_send_wr,ibv_sge}}
    llength(pointer(items, i))
end
