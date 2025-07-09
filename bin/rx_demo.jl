using InfinibandVerbs.API

# Get device list
num_devices = Ref{Cint}(0)
dev_list = ibv_get_device_list(num_devices)
if dev_list == C_NULL
    error("failed to get IB devices list")
end
if num_devices[] == 0
    error("no devices found")
end

# Load first device from list
devidx = 1
dev = unsafe_load(dev_list, devidx)

# Open device
ctx = ibv_open_device(dev)

# Create protection domain (aka PD)
pd = ibv_alloc_pd(ctx)

# Create receive completion channel
recv_cc = ibv_create_comp_channel(ctx)
# TODO Make recv_cc non-blocking with fcntl or ioctl???
recv_cc_fd = RawFD(unsafe_load(recv_cc).fd)

# Create recieve completion queue
cqe = 1 # Number of completion queue entries (minimum)
comp_vector = 0
send_cq = ibv_create_cq(ctx, cqe, C_NULL, C_NULL, comp_vector)
recv_cq = ibv_create_cq(ctx, cqe, C_NULL, recv_cc, comp_vector)

# Request notifications before any receive completion can be created.
# (false == do NOT restrict to solicited-only completions for receive)
ibv_req_notify_cq(recv_cq, false)

# Create queue pair (aka QP, starts in RESET state)
qpinitattr = Ref(ibv_qp_init_attr(
    ctx,                # .qp_context
    send_cq,            # .send_cq
    recv_cq,            # .recv_cq
    C_NULL,             # .srq
    ibv_qp_cap(         # .cap
        5,              # .cap.max_send_wr
        5,              # .cap.max_recv_wr
        1,              # .cap.max_send_sge
        1,              # .cap.max_recv_sge
        0),             # .cap.max_inline_data
    IBV_QPT_RAW_PACKET, # .qp_type
    true                # .sq_sig_all
))

qp = ibv_create_qp(pd, qpinitattr)
qp == C_NULL && throw(SystemError("ibv_create_qp"))
@info "successfully created QP"

# Transition QP to INIT state
qp_state = IBV_QPS_INIT
port_num = 1 # NIC port (1 or 2 for dual port NIC)
qp_attr = ibv_qp_attr(; qp_state, port_num)
ibv_modify_qp(qp, qp_attr, IBV_QP_STATE|IBV_QP_PORT)

# Create packet receive buffer for 10 packets of up to 9000 bytes each.
# recv_buf is a Matrix with mtu rows and num_pkt columns.  Each of the num_pkt
# columns has space for up to mtu bytes of a single packet.
mtu = 9000
num_pkt = 10
recv_buf = zeros(UInt8, mtu, num_pkt)

# Register packet receive buffer
mr = ibv_reg_mr(pd, pointer(recv_buf), sizeof(recv_buf), IBV_ACCESS_LOCAL_WRITE)
mr == C_NULL && throw(SystemError("ibv_reg_mr"))
lkey = unsafe_load(mr).lkey

# Create sniffer flow
sniffer_flow_attr = Ref(ibv_flow_attr(
    0,                     # comp_mask
    IBV_FLOW_ATTR_SNIFFER, # type
    sizeof(ibv_flow_attr), # size
    0,                     # priority
    0,                     # num_of_specs
    port_num,              # port
    0                      # flags
))
sniffer_flow = ibv_create_flow(qp, sniffer_flow_attr)

# Initialize work requests and scatter/gather fields
#
# Use two WRs for demo purposes, each with one sge
# NB: Real-world apps should use many WRs (and therefore many SGEs)!

# Helper function to make ibv_sge instances pointing to columns of recv_buf.
# The return value is a Vector of sges.
function new_sge(recv_buf::Matrix{T}, col::Integer, lkey::UInt32)::Vector{ibv_sge} where T
    colsz = size(recv_buf, 1) * sizeof(eltype(recv_buf))
    [
        ibv_sge(pointer(recv_buf, (col-1) * colsz + 1), colsz, lkey)
    ]
end

# sges is a Vector{Vector{ibv_sge}}, i.e. a Vector of Vectors of ibv_sge.  The
# "outer" Vector has num_wr members that correspond one-to-one with WRs.  Each
# inner Vector has num_sge members.
num_wr = 2
num_sge = 1
sges = new_sge.(Ref(recv_buf), 1:num_wr, lkey)
recv_wrs = Vector{ibv_recv_wr}(undef, num_wr)
# WRs are stored in a Vector and their wr_id is their index in the Vector.
for wr_id = eachindex(recv_wrs)
    pnext = (wr_id == lastindex(recv_wrs)) ? C_NULL : pointer(recv_wrs, wr_id+1)
    psge = pointer(sges[wr_id])
    recv_wrs[wr_id] = ibv_recv_wr(
        wr_id,  # wr_id::UInt64
        pnext,  # next::Ptr{ibv_recv_wr}
        psge,   # sge_list::Ptr{ibv_sge}
        num_sge # num_sge::Int32
    )
end

# Post recv_wr work requests!
wr_bad = Ref{Ptr{ibv_recv_wr}}(C_NULL)
ibv_post_recv(qp, pointer(recv_wrs), wr_bad)

# Counters to track WR postings.  These are incremented/decremented in unison so
# they could probably be consolidated into one variable.
num_posted = 2 # Number of posted WRs
num_topost = num_pkt - num_posted # Number of WRs still to post

# Transition qp to ready-to-receive (RTR) state
qp_state = IBV_QPS_RTR
qp_attr = ibv_qp_attr(; qp_state)
ibv_modify_qp(qp, qp_attr, IBV_QP_STATE)

#=
# For non-blocking polling of completion channel's fd
struct PollFD
    fd::Cint
    events::Cshort
    revents::Cshort
end

pfd = Ref(PollFD(unsafe_load(recv_cc).fd, 1, 0))
@time ccall(:poll, Cint, (Ptr{PollFD}, Culong, Cint), pfd, 1, 10000)
=#

# Blocking call that waits for a work completion event
function wait_for_completion_event(cc::Ptr{ibv_comp_channel},
    ev_cq = Ref{Ptr{ibv_cq}}(C_NULL),
    ev_cq_ctx = Ref{Ptr{Nothing}}(C_NULL)
)
    # Wait for the completion event
    if ibv_get_cq_event(cc, ev_cq, ev_cq_ctx) != 0
        throw(SystemError("ibv_get_cq_event"))
    end
    # Ack the CQ event TODO: amortize this over N events???
    ibv_ack_cq_events(ev_cq[], 1);

    # Request notification upon the next completion event
    if ibv_req_notify_cq(ev_cq[], false) != 0
        throw(SystemError("ibv_req_notify_cq"))
    end
end

function update_addr!(sglist::AbstractVector{ibv_sge}, sgeidx, addr)
    unsafe_store!(Ptr{UInt64}(pointer(sglist, sgeidx)), addr)
end

function update_next!(wrlist::AbstractVector{ibv_recv_wr}, wr_id, ptr_next::Ptr{ibv_recv_wr})
    unsafe_store!(Ptr{Ptr{ibv_recv_wr}}(pointer(wrlist, wr_id)+8), ptr_next)
end

# Receive packets loop

# NB: Real-world apps should use many WRs and many WCs!
wcs = Vector{ibv_wc}(undef, 2)
pktlengths = zeros(UInt32, num_pkt)
num_rx = 0
ev_cq = Ref{Ptr{ibv_cq}}(C_NULL)
ev_cq_ctx = Ref{Ptr{Nothing}}(C_NULL)
while num_rx < num_pkt
    global num_rx, num_posted, num_topost

    @info "waiting for completion event"
    @time wait_for_completion_event(recv_cc, ev_cq, ev_cq_ctx)

    # Poll recv_cq for work completions
    num_wc = ibv_poll_cq(recv_cq, length(wcs), wcs)
    num_wc < 0 && throw(SystemError("ibv_poll_wc"))
    if num_wc == 0
        continue
    end

    # For each work completion
    for wcidx = 1:num_wc
        # Save length (use 0 if WC has non-success status)
        pktlengths[num_rx+wcidx] = (wcs[wcidx].status == IBV_WC_SUCCESS) ?
            wcs[wcidx].byte_len : 0

        # Log packet reception for demo
        wr_id = wcs[wcidx].wr_id
        @info "received packet $(num_rx+wcidx) length=$(pktlengths[num_rx+wcidx]) for wr_id=$wr_id"
    end

    # Increment num_rx
    num_rx += num_wc

    # Repost WRs as needed (we only receive num_pkt packets)
    num_repost = min(num_wc, num_topost)
    if num_repost > 0
        # Link first num_repost-1 WRs from WC for re-posting
        for wcidx = 1:num_repost-1
            wr_id = wcs[wcidx].wr_id
            wr_id_next = wcs[wcidx+1].wr_id
            ptr_next = pointer(recv_wrs, wr_id_next)
            update_next!(recv_wrs, wr_id, ptr_next)
        end
        # Null terminate last (i.e. num_repost'th) WR in linked list
        update_next!(recv_wrs, wcs[num_repost].wr_id, Ptr{ibv_recv_wr}(C_NULL))

        # Update SGEs for num_repost WRs
        for wcidx = 1:num_repost
            wr_id = wcs[wcidx].wr_id
            # Reset WR's SGEs to point to next slot in the receive buffer
            # This demo only has one SGE per WR
            newaddr = pointer(recv_buf, (num_posted+wcidx-1)*size(recv_buf, 1) + 1)
            update_addr!(sges[wr_id], 1, newaddr)
        end

        # Repost work requests from this wc
        ibv_post_recv(qp, pointer(recv_wrs, wcs[1].wr_id), wr_bad)
        num_posted += num_repost
        num_topost -= num_repost
    end
end
