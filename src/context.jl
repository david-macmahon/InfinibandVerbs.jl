struct Context
    dev_name::String
    port_num::UInt8

    context::Ptr{ibv_context}
    pd::Ptr{ibv_pd}

    send_comp_channel::Ptr{ibv_comp_channel}
    recv_comp_channel::Ptr{ibv_comp_channel}

    recv_cq::Ptr{ibv_cq}
    send_cq::Ptr{ibv_cq}

    qp::Ptr{ibv_qp}

    send_cge::UInt32
    recv_cge::UInt32
    max_send_wr::UInt32
    max_recv_wr::UInt32
    max_send_sge::UInt32
    max_recv_sge::UInt32
    max_inline_data::UInt32

    send_wcs::Vector{ibv_wc}
    recv_wcs::Vector{ibv_wc}
end

"""
    Context(dev_name, port_num; <kwargs>)

Create a `Context` object to use Infiniband Verbs on `port_num` of `dev_name`.

Keyword arguments, described in the extended help, control various aspects of
the created objects.  Their default values request minimal resources, but
non-trivial applications will need to request more resources depending on the
application's needs.  Upon successful return, the `Context`'s queue pair will be
in the `IBV_QPS_INIT` state.

# Extended help

The `Context` structure manages the following fields (so you don't have to):

| Field name | Type                             | Description
|:-----------|:---------------------------------|:-----------
| `context`  | `Ptr{ibv_context}`               | Context from C library
| `pd`       | `Ptr{ibv_pd}`                    | Protection domain
| `send_comp_channel` | `Ptr{ibv_comp_channel}` | Send completion channel
| `recv_comp_channel` | `Ptr{ibv_comp_channel}` | Receive completion channel
| `send_cq`  | `Ptr{ibv_cq}`                    | Send completion queue
| `recv_cq`  | `Ptr{ibv_cq}`                    | Receive completion queue
| `qp`       | `Ptr{ibv_qp}`                    | Queue pair
| `send_wcs` | `Vector{ibv_wc}`                 | Send work completions
| `recv_wcs` | `Vector{ibv_wc}`                 | Recv work completions

The following fields of the `Context` structure hold sizing information:

| Field name        | Type     | Description
|:------------------|:---------|:-----------
| `send_cqe`        | `UInt32` | Number of send completion queue events
| `recv_cqe`        | `UInt32` | Number of recv completion queue events
| `max_send_wr`     | `UInt32` | Max number of posted send work requests
| `max_recv_wr`     | `UInt32` | Max number of posted recv work requests
| `max_send_sge`    | `UInt32` | Max number of SGEs per send work request
| `max_recv_sge`    | `UInt32` | Max number of SGEs per recv work request
| (!) `max_inline_data` | `UInt32` | Maximum amount of inline data

The `Context` constructor supports the following keyword arguments:

| Keyword argument      | Default | Description
|:----------------------|:-------:|:-----------
| `force`               | `false` | Allow `dev_name:port_num` to be inactive
| (-) `send_cqe`        | `1`     | Number of events for send completion queue
| (-) `recv_cqe`        | `1`     | Number of events for recv completion queue
| (-) `max_send_wr`     | `1`     | Maximum number of send work requests
| (-) `max_recv_wr`     | `1`     | Maximum number of recv work requests
| (-) `max_send_sge`    | `1`     | Maximum number of SGEs for send WR sg_lists
| (-) `max_recv_sge`    | `1`     | Maximum number of SGEs for recv WR sg_lists
| `req_notify_send`     | `true`  | Request send CQ notifications
| `req_notify_recv`     | `true`  | Request recv CQ notifications
| `solicited_only_send` | `false` | `solicited_only` for send CQ notifications
| `solicited_only_recv` | `false` | `solicited_only` for recv CQ notifications
| (!) `comp_vector`     | `0`     | Completion queue `comp_vector`
| (!) `max_inline_data` | `0`     | Maximum inline data for QP
| (!) `qp_type`         | `IBV_QPT_RAW_PACKET` | QP type

!!! info

    Keyword arguments marked with (-) can be passed as `-1` to use the device's
    maximum supported value, which can be retrieved from the `Context` field of
    the same name once constructed.  The actual values will be greater than or
    equal to the requested values.

!!! warning

    Fields and keyword arguments marked with (!) are for expert use.  Use and/or
    change at your own risk.
"""
function Context(dev_name, port_num; force=false,
    send_cqe=1, recv_cqe=1, # sizing for send/recv completion queues
    max_send_wr=1, max_recv_wr=1, # sizing for send/recv queues
    max_send_sge=1, max_recv_sge=1, # sizing for SGE for send/recv WR sg_lists
    req_notify_send=true, req_notify_recv=true,
    solicited_only_send=false, solicited_only_recv=false,
    # Below here is best left unchanged
    comp_vector=0, # TODO make separate send/recv comp_vectors?
    max_inline_data=0,
    qp_type=IBV_QPT_RAW_PACKET
)
    # Open device
    context = open_device_by_name(dev_name, force ? nothing : port_num)

    # Query device if any sizing parameters are given as -1
    if send_cqe == -1 || recv_cqe == -1 ||
            max_send_wr  == -1 || max_recv_wr  == -1 ||
            max_send_sge == -1 || max_recv_sge == -1
            
        # Query device attributes
        device_attr = query_device(context)

        # In practice, using max_cqe directly fails with "Cannot allocate
        # memory" error.  Using max_cqe÷sizeof(Ptr) works.  Using
        # max_cqe÷sizeof(Ptr)+1 fails.  Maybe it was just a bug/feature of the
        # hardware/driver used in development?  Maybe we should just set
        # send_cqe/recv_cqe to `max_qp_wr` instead?
        send_cqe == -1 && (send_cqe = device_attr[].max_cqe÷sizeof(Ptr))
        recv_cqe == -1 && (recv_cqe = device_attr[].max_cqe÷sizeof(Ptr))
        max_send_wr == -1 && (max_send_wr = device_attr[].max_qp_wr)
        max_recv_wr == -1 && (max_recv_wr = device_attr[].max_qp_wr)
        max_send_sge == -1 && (max_send_sge = device_attr[].max_sge)
        max_recv_sge == -1 && (max_recv_sge = device_attr[].max_sge)
    end

    # Create protection domain (aka PD)
    pd = ibv_alloc_pd(context)
    pd == C_NULL && throw(SystemError("ibv_alloc_pd"))

    # Create send/receive completion channels
    send_comp_channel = ibv_create_comp_channel(context)
    send_comp_channel == C_NULL && throw(SystemError("ibv_create_comp_channel [send]"))
    fcntl_setnonblock(send_comp_channel)

    recv_comp_channel = ibv_create_comp_channel(context)
    recv_comp_channel == C_NULL && throw(SystemError("ibv_create_comp_channel [recv]"))
    fcntl_setnonblock(recv_comp_channel)

    # Create send/receive completion queues
    send_cq = ibv_create_cq(context, send_cqe, C_NULL, send_comp_channel, comp_vector)
    send_cq == C_NULL && throw(SystemError("ibv_create_cq [send]"))
    recv_cq = ibv_create_cq(context, recv_cqe, C_NULL, recv_comp_channel, comp_vector)
    recv_cq == C_NULL && throw(SystemError("ibv_create_cq [recv]"))

    # Request notifications on the completion queues as desired
    if req_notify_send
        errno = ibv_req_notify_cq(send_cq, solicited_only_send)
        errno == 0 || throw(SystemError("ibv_req_notify_cq [send]", errno))
    end
    if req_notify_recv
        errno = ibv_req_notify_cq(recv_cq, solicited_only_recv)
        errno == 0 || throw(SystemError("ibv_req_notify_cq [recv]", errno))
    end

    # Create queue pair (aka QP, starts in RESET state)
    qpinitattr = Ref(ibv_qp_init_attr(
        context,              # .qp_context
        send_cq,              # .send_cq
        recv_cq,              # .recv_cq
        C_NULL,               # .srq
        ibv_qp_cap(           # .cap
            max_send_wr,      # .cap.max_send_wr
            max_recv_wr,      # .cap.max_recv_wr
            max_send_sge,     # .cap.max_send_sge
            max_recv_sge,     # .cap.max_recv_sge
            max_inline_data), # .cap.max_inline_data
        qp_type,              # .qp_type
        true                  # .sq_sig_all
    ))

    qp = ibv_create_qp(pd, qpinitattr)
    qp == C_NULL && throw(SystemError("ibv_create_qp"))

    # Allocate send/recv work completions
    send_wcs = Vector{ibv_wc}(undef, send_cqe)
    fill!(reinterpret(UInt8, send_wcs), 0)
    recv_wcs = Vector{ibv_wc}(undef, recv_cqe)
    fill!(reinterpret(UInt8, recv_wcs), 0)

    # Transition QP to INIT state
    qp_state = IBV_QPS_INIT
    qp_attr = Ref(ibv_qp_attr(; qp_state, port_num))
    errno = ibv_modify_qp(qp, qp_attr, IBV_QP_STATE|IBV_QP_PORT)
    errno == 0 || throw(SystemError("ibv_modify_qp", errno))

     Context(dev_name, port_num, context, pd,
        send_comp_channel, recv_comp_channel,
        send_cq, recv_cq,
        qp,
        send_cqe, recv_cqe,
        qpinitattr[].cap.max_send_wr, qpinitattr[].cap.max_recv_wr,
        qpinitattr[].cap.max_send_sge, qpinitattr[].cap.max_recv_sge,
        qpinitattr[].cap.max_inline_data,
        send_wcs, recv_wcs
    )
end

function Base.show(io::IO, ctx::Context)
    compact = get(io, :compact, false)
    print(io, "Context(", ctx.dev_name, ":", ctx.port_num,
        ", ", compact ? "" : "max WRxSGE send/recv ",
        ctx.max_send_wr, "x", ctx.max_send_sge,
        "/", ctx.max_recv_wr, "x", ctx.max_recv_sge,
        ")"
    )
end

"""
    open_device_by_name(dev_name[, port_num]) -> Ptr{ibv_context}

Open device `dev_name` and return `Ptr{ibv_context}`.

If `port_num` is given (and not `nothing`), query that port on device `dev_name`
and throw an exception if the port is inactive (i.e. not "up").
"""
function open_device_by_name(dev_name, _::Nothing=nothing)
    num_devices = Ref{Cint}(0)
    dev_list = ibv_get_device_list(num_devices)
    if dev_list == C_NULL
        throw(SystemError("Failed to get devices list"))
    end
    if num_devices[] == 0
        error("no devices found")
    end

    context = Ptr{ibv_context}(C_NULL)

    for i = 1:num_devices[]
        dev = unsafe_load(dev_list, i)
        name = ibv_get_device_name(dev)|>unsafe_string
        if name == dev_name
            context = ibv_open_device(dev)
            break
        end
    end

    # Free device list resources
    ibv_free_device_list(dev_list)

    context == C_NULL && error("device $dev_name not found")

    context
end

function open_device_by_name(dev_name, port_num)
    context = open_device_by_name(dev_name)
    port_attr = Ref{ibv_port_attr}()
    errno = ibv_query_port(context, port_num, port_attr)
    errno == 0 || throw(SystemErrer("ibv_query_port"))
    if port_attr[].state != IBV_PORT_ACTIVE
        ibv_close_device(context)
        msg = "device $dev_name port $port_num is not active"
        throw(InvalidStateException(msg, Symbol(port_attr[].state)))
    end
    context
end

function Poll.fcntl_setnonblock(comp_channel::Ptr{ibv_comp_channel})
    fd = unsafe_load(comp_channel.fd)
    fcntl_setnonblock(fd)
end

function Poll.pollin(comp_channel::Ptr{ibv_comp_channel}, timeout_ms=-1)
    fd = unsafe_load(comp_channel.fd)
    pollin(fd, timeout_ms)
end

"""
    req_notify_send_cq(ctx::Context, solicited_only=false) -> 0 or errno
    req_notify_recv_cq(ctx::Context, solicited_only=false) -> 0 or errno

Request a completion notification on the send or receive completion queue
associated with `ctx`.  These functions are typically called from performance
critical code so error checking/handling is left to the discretion of the
caller.
"""
function req_notify_send_cq(ctx::Context, solicited_only=false)
    ibv_req_notify_cq(ctx.send_cq, solicited_only)
end,
function req_notify_recv_cq(ctx::Context, solicited_only=false)
    ibv_req_notify_cq(ctx.recv_cq, solicited_only)
end

"""
    get_qp_state(ctx::Context) -> QP state

Return the state of the Context's QP as an `ibv_qp_state` enum.
"""
function get_qp_state(ctx::Context)
    GC.@preserve ctx unsafe_load(ctx.qp.state)
end

# TODO Document QP state transitions as shown here
# https://www.rdmamojo.com/2012/05/05/qp-state-machine/
"""
    modify_qp_state(ctx, qp_state) -> QP state

Attempt to modify the state of `ctx`'s QP to `qp_state`.

The `qp_state` parameter may be an `ibv_qp_state` enum value or one of the
following symbols: `:reset`, `:init`, `:rtr`, `:rts`, `:sqd`.  Currently no
checking is performed to verify that the current QP state allows a transition to
the given `qp_state`.  A `SystemError` will be thrown if an error occurs,
otherwise the actual state of the QP is returned (which should equal
`qp_state`).
"""
function modify_qp_state(ctx::Context, qp_state::ibv_qp_state)
    qp_attr = Ref(ibv_qp_attr(; qp_state))
    errno = ibv_modify_qp(ctx.qp, qp_attr, IBV_QP_STATE)
    errno == 0 || throw(SystemError("ibv_modify_qp [$qp_state]", errno))
    get_qp_state(ctx)
end

function modify_qp_state(ctx::Context, qp_state_sym)
    qp_state = qp_state_sym == :reset ? IBV_QPS_RESET :
               qp_state_sym == :init  ? IBV_QPS_INIT  :
               qp_state_sym == :rtr   ? IBV_QPS_RTR   :
               qp_state_sym == :rts   ? IBV_QPS_RTS   :
               qp_state_sym == :sqd   ? IBV_QPS_SQD   :
               error("unsupported QP state: :$qp_state_sym")
    modify_qp_state(ctx, qp_state)
end

"""
    transition_qp_to_rtr(ctx::Context)

Transitions the Context's QP from its current state to a "ready-to-receive"
compatible state.

The QP can be in any state and this function will perform legal state
transitions to get to a "ready-to-receive" (RTR) compatible state.  The final
state of the QP is returned.
"""
function transition_qp_to_rtr(ctx::Context)
    qp_state = get_qp_state(ctx)
    if qp_state == IBV_QPS_ERR
        qp_state = modify_qp_state(ctx, IBV_QPS_RESET)
    end
    if qp_state == IBV_QPS_RESET
        qp_state = modify_qp_state(ctx, IBV_QPS_INIT)
    end
    if qp_state == IBV_QPS_INIT
        qp_state = modify_qp_state(ctx, IBV_QPS_RTR)
    end
    # Any other non-RTR state is also valid, so we're done!
    get_qp_state(ctx)
end

"""
    transition_qp_to_rts(ctx::Context)

Transitions the Context's QP from its current state to the "ready-to-send"
state.

The QP can be in any state and this function will perform legal state
transitions to get to the "ready-to-send" (RTS) compatible state.  The final
state of the QP is returned.
"""
function transition_qp_to_rts(ctx::Context)
    qp_state = get_qp_state(ctx)
    if qp_state != IBV_QPS_RTS
        transition_qp_to_rtr(ctx)
        modify_qp_state(ctx, IBV_QPS_RTS)
    end
    get_qp_state(ctx)
end

"""
    wait_for_completion_event(comp_channel::Ptr{ibv_comp_channel}[, timeout_ms=-1], solicited_only=false) -> CQ
    wait_for_recv_completion_event(ctx::Context, timeout_ms=-1], solicited_only=false) -> CQ
    wait_for_send_completion_event(ctx::Context, timeout_ms=-1], solicited_only=false) -> CQ

Blocking call that waits for a work completion event on `comp_channel`.

After getting a completion event another notification is requested using the
provided `solicited_only` value.  Returns the CQ that generated the completion
event or `nothing` if a timeout occurs after `timeout_ms` milliseconds
(`timeout_ms < 0` means wait "forever").
"""
function wait_for_completion_event(comp_channel::Ptr{ibv_comp_channel}, timeout_ms::Signed=-1, solicited_only=false)
    # Wait for the completion event
    ready = pollin(comp_channel, timeout_ms)
    ready || return nothing

    ev_cq = Ref{Ptr{ibv_cq}}(C_NULL)
    ev_cq_ctx = Ref{Ptr{Nothing}}(C_NULL)
    status = ibv_get_cq_event(comp_channel, ev_cq, ev_cq_ctx)
    # EAGAIN should "never" happen since pollin waited above; treat as timeout
    status != 0 && Libc.errno() == Libc.EAGAIN && return nothing
    # Throw on all other errors
    status != 0 && throw(SystemError("ibv_get_cq_event")) # Is libc's errno valid here?

    # Ack the CQ event
    # TODO: amortize this over N events???
    ibv_ack_cq_events(ev_cq[], 1)

    # Request notification of the next completion event
    errno = ibv_req_notify_cq(ev_cq[], solicited_only)
    errno == 0 || throw(SystemError("ibv_req_notify_cq", errno))

    # Currently, Context does not support a user-defined CQ "context" pointer,
    # so ev_cq_ctx will always be C_NULL so don't bother returning it.
    ev_cq[]#, ev_cq_ctx[]
end

function wait_for_completion_event(comp_channel::Ptr{ibv_comp_channel}, solicited_only::Bool)
    wait_for_completion_event(comp_channel, -1, solicited_only)
end

function wait_for_send_completion_event(ctx::Context, timeout_ms::Signed=-1, solicited_only=false)
    wait_for_completion_event(ctx.send_comp_channel, timeout_ms, solicited_only)
end

function wait_for_send_completion_event(ctx::Context, solicited_only::Bool)
    wait_for_completion_event(ctx.send_comp_channel, -1, solicited_only)
end

function wait_for_recv_completion_event(ctx::Context, timeout_ms::Signed=-1, solicited_only=false)
    wait_for_completion_event(ctx.recv_comp_channel, timeout_ms, solicited_only)
end

function wait_for_recv_completion_event(ctx::Context, solicited_only::Bool)
    wait_for_completion_event(ctx.recv_comp_channel, -1, solicited_only)
end

"""
    query_device(ctx::Context) -> ibv_device_attr

Return attributes of the Context's device.

Call `ibv_query_device` and return an `ibv_device_attr` (or throw `SystemError`
on error).
"""
function query_device(ctx::Context)
    dev_attr_ref = Ref{ibv_device_attr}()
    errno = ibv_query_device(ctx.context, dev_attr_ref)
    errno == 0 || throw(SystemError("ibv_query_device", errno))
    dev_attr_ref[]
end

"""
    query_device_ex(ctx::Context) -> ibv_device_attr_ex

Return extended attributes of the Context's device.

Call `ibv_query_device_ex` and return an `ibv_device_attr_ex` (or throw
`SystemError` on error).
"""
function query_device_ex(ctx::Context)
    dev_attr_ex_ref = Ref{ibv_device_attr_ex}()
    errno = ibv_query_device_ex(ctx.context, C_NULL, dev_attr_ex_ref)
    errno == 0 || throw(SystemError("ibv_query_device_ex", errno))
    dev_attr_ex_ref[]
end

"""
    query_port(ctx::Context) -> ibv_port_attr

Return attributes of the Context's port.

Call `ibv_query_port` and return an `ibv_port_attr` (or throw `SystemError` on
error).
"""
function query_port(ctx::Context)
    port_attr_ref = Ref{ibv_port_attr}()
    errno = ibv_query_port(ctx.context, ctx.port_num, port_attr_ref)
    errno == 0 || throw(SystemError("ibv_query_port", errno))
    port_attr_ref[]
end

"""
    hascapability(ctx::Context, cap)

Return `true` if the device corresponding to `ctx` has capability `cap`.

`cap` may be any one (and only one) of the `ibv_device_cap_flags` or
`ibv_raw_packet_caps` flags.

# Extended help

| `ibv_device_cap_flags`             |
|:-----------------------------------|
| `IBV_DEVICE_RESIZE_MAX_WR`         |
| `IBV_DEVICE_BAD_PKEY_CNTR`         |
| `IBV_DEVICE_BAD_QKEY_CNTR`         |
| `IBV_DEVICE_RAW_MULTI`             |
| `IBV_DEVICE_AUTO_PATH_MIG`         |
| `IBV_DEVICE_CHANGE_PHY_PORT`       |
| `IBV_DEVICE_UD_AV_PORT_ENFORCE`    |
| `IBV_DEVICE_CURR_QP_STATE_MOD`     |
| `IBV_DEVICE_SHUTDOWN_PORT`         |
| `IBV_DEVICE_INIT_TYPE`             |
| `IBV_DEVICE_PORT_ACTIVE_EVENT`     |
| `IBV_DEVICE_SYS_IMAGE_GUID`        |
| `IBV_DEVICE_RC_RNR_NAK_GEN`        |
| `IBV_DEVICE_SRQ_RESIZE`            |
| `IBV_DEVICE_N_NOTIFY_CQ`           |
| `IBV_DEVICE_MEM_WINDOW`            |
| `IBV_DEVICE_UD_IP_CSUM`            |
| `IBV_DEVICE_XRC`                   |
| `IBV_DEVICE_MEM_MGT_EXTENSIONS`    |
| `IBV_DEVICE_MEM_WINDOW_TYPE_2A`    |
| `IBV_DEVICE_MEM_WINDOW_TYPE_2B`    |
| `IBV_DEVICE_RC_IP_CSUM`            |
| `IBV_DEVICE_RAW_IP_CSUM`           |
| `IBV_DEVICE_MANAGED_FLOW_STEERING` |

| `ibv_raw_packet_caps`                |
|:-------------------------------------|
| `IBV_RAW_PACKET_CAP_CVLAN_STRIPPING` |
| `IBV_RAW_PACKET_CAP_SCATTER_FCS`     |
| `IBV_RAW_PACKET_CAP_IP_CSUM`         |
| `IBV_RAW_PACKET_CAP_DELAY_DROP`      |
"""
function hascapability(ctx::Context, devcap::ibv_device_cap_flags)::Bool
    dev_attr = query_device(ctx)
    (dev_attr.device_cap_flags & devcap) == devcap
end

function hascapability(ctx::Context, rawcap::ibv_raw_packet_caps)::Bool
    dev_attr_ex = query_device_ex(ctx)
    (dev_attr_ex.raw_packet_caps & rawcap) == rawcap
end
