struct Context
    dev_name::String
    port_num::UInt8

    context::Ptr{ibv_context}
    pd::Ptr{ibv_pd}

    recv_comp_channel::Ptr{ibv_comp_channel}
    send_comp_channel::Ptr{ibv_comp_channel}

    recv_cq::Ptr{ibv_cq}
    send_cq::Ptr{ibv_cq}

    qp::Ptr{ibv_qp}

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

Create a `Context` object to use InfinibandVerbs on `port_num` of `dev_name`.

Create various InfinibandVerbs objects and return them in a `Context` instance.
Keyword arguments, described in the extended help, control various aspects of
the created objects.

This `Context` constructor creates the following libibverbs objects:

- `context::Ptr{ibv_context}` - Context
- `pd::Ptr{ibv_pd}` - Protection domain
- `recv_comp_channel::Ptr{ibv_comp_channel}` - Receive completion channel
- `send_comp_channel::Ptr{ibv_comp_channel}` - send completion channel
- `recv_cq::Ptr{ibv_cq}` - Receive completion queue
- `send_cq::Ptr{ibv_cq}` - Send completion queue
- `qp::Ptr{ibv_qp}` - Queue pair

Completion notifications on `send_cq` or `recv_cq` are not requested by this
constructor, but the caller may request them using [`req_notify_send_cq`](@ref)
or [`req_notify_recv_cq`](@ref) as desired.  Upon successful return, the
`Context`'s queue pair will be in the `IBV_QPS_INIT` state.

# Extended help

The following keyword arguments can be used to control various sizing aspects of
the created objects.  They default to 1 if not specified.  Set to -1 to use the
device's maximum supported value.  The actual QP values for the `max_...`
keyword arguments will be stored in the returned `Context` object.  These QP
values will be greater than or equal to the requested values.

- `force`: if true, allow `dev_name:port_num` to be inactive (default `false`)
- `send_cqe`, `recv_cqe`: Sizing for send/recev completion queues
- `max_send_wr`, `max_recv_wr`: Sizing for send/receive queues
- `max_send_sge`, `max_recv_sge`: max SGE for send/receive WR sg_lists

Completion notifications can be requested separately for send and receive
completion channels via `req_notify_send` and `rec_notify_recv`, both default to
`true`.  The `solicited_only` option of those notification requests can be
specified by `solicited_only_send` and `solicited_only_recv`, both default to
`false`.

- `req_notify_send`, `req_notify_recv`: request CQ notification
- `solicited_only_send`, `solicited_only_recv`: options for CQ notifications

Expert mode (change at your own risk)

- `comp_vector=0`: TODO make separate send/recv comp_vectors?
- `max_inline_data=0`
- `qp_type=IBV_QPT_RAW_PACKET`

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
            
        device_attr = Ref{ibv_device_attr}()
        errno = ibv_query_device(context, device_attr)
        errno == 0 || throw(SystemError("ibv_query_device", errno))

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
    req_notify_send && ibv_req_notify_cq(send_cq, solicited_only_send)
    req_notify_recv && ibv_req_notify_cq(recv_cq, solicited_only_recv)

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
        recv_comp_channel, send_comp_channel,
        recv_cq, send_cq,
        qp,
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
following symbols: `:reset`, `:init`, `:rtr`, `:rts`, :`sqd`.  Currently no
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
