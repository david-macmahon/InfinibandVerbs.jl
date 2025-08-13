# The rx_demo_high_level.jl script is similar to the low-evel rx_demo.jl, but as
# the name implies it uses the high level API of InfinibandVerbs.jl instead.

using InfinibandVerbs
using InfinibandVerbs.API: IBV_WC_SUCCESS

# Device/port to use
dev_name = "mlx5_0"
port_num = 1

# Use two work requests (WRs) for demo purposes, each with one scatter/gather
# element (SGE).  NB: Real-world apps should use many WRs.
num_wr = 2
num_sge = 1

#---
# Create InfinibandVerbs.Context

ctx = Context(dev_name, port_num;
    recv_cqe=num_wr,
    max_recv_wr=num_wr,
    max_recv_sge=num_sge
)

#---
# Create packet receive buffers

# Create packet receive buffer for 10 packets of up to 9000 bytes each.
# recv_buf is a Matrix with mtu rows and num_pkt columns.  Each of the num_pkt
# columns has space for up to mtu bytes of a single packet.
mtu = 9000
npkts_max = 10
recv_buf = zeros(UInt8, mtu, npkts_max);

#---
# Register packet receive buffers and create (and post) num_wr receive WRs.

recv_wrs, _sges, _mrs = create_recv_wrs(ctx, [recv_buf], num_wr; post=true);

#---
# Define our recv_loop callback function

# Process work completions for all posted WRs.  For this demo we will be
# determining how many WRs to re-post (up to a total of num_pkt WRs) and
# updating their SGEs to point to the next packet location is `recv_heads`.
function recv_loop_callback(wcs, num_wc, recv_wrs, # Required parameters
    # User args follow
    runloop::Ref{Bool},     # Ref{Bool} that callback uses to stop
    recv_heads,             # A view of packet "heads", i.e. `@view recv_buf[1,:]
    npkts_posted::Ref{Int}, # Ref for counting number of packets/WRs posted
    npkts_done::Ref{Int},   # Ref for counting number of packets/WRs done
    npkts_max::Int,         # Total number of packets to receive
    pktlengths::AbstractVector{<:Integer} # place to store packet lengths
)
    # Keep running?
    runloop[] || return -1

    # Report each work completion (not normally done in recv_loop_callback!)
    for wcidx = 1:num_wc
        pktidx = npkts_done[] + wcidx
        # Save length (use 0 if WC has non-success status)
        pktlengths[pktidx] = (wcs[wcidx].status == IBV_WC_SUCCESS) ? wcs[wcidx].byte_len : 0

        # Log packet reception for demo
        wr_id = wcs[wcidx].wr_id
        @info "received packet $(pktidx) length=$(pktlengths[pktidx]) for wr_id=$wr_id"
    end

    # Accumulate these num_wc packets (i.e. WCs) into npkts_done
    npkts_done[] += num_wc

    # If this is the last batch of WCs, we're done!
    npkts_done[] >= npkts_max && return -1

    # Not done, figure out how many WRs to repost.  We only post a total of
    # npkts_max WRs and right now we can't repost more than num_wc WRs.
    num_repost = min(num_wc, npkts_max-npkts_posted[])

    # If we're going to repost WRs, update their SGEs to point to the starting
    # locations of the next packets in recv_buf.
    if num_repost > 0
        # Update SGEs for num_repost WRs
        for wcidx = 1:num_repost
            # Update WR's SGEs to point to next location in the receive buffer
            # This demo only has one SGE per WR
            wr_id = wcs[wcidx].wr_id
            newaddr = pointer(recv_heads, npkts_posted[]+wcidx)
            @info "setting addr for wr_id $wr_id to slot $(npkts_posted[]+wcidx) ($(repr(newaddr)))"
            recv_wrs[wr_id].sg_list[1].addr = newaddr
        end

        # Accumulate these reposted packets into npks_reposted
        npkts_posted[] += num_repost
    end

    return num_repost
end

#---
# Create sniffer flow

sniffer_flow = create_flow(ctx; flow_type=:sniffer)

#---
# Run recv_loop

timeout_ms = 2000
runloop = Ref(true)
recv_heads = @view recv_buf[1,:]
npkts_posted = Ref(num_wr)
npkts_done = Ref(0)
pktlengths = zeros(Int, npkts_max)

recvtask = Threads.@spawn InfinibandVerbs.recv_loop(
    # required args
    $recv_loop_callback, # user callback function
    $ctx,                # our Context struct
    $recv_wrs,           # our Vector of recv WRs
    $timeout_ms,         # Timeout value (periodic, not absolute)
    # user callback args (cb_args) follow
    $runloop,      # Ref{Bool} that callback uses to stop
    $recv_heads,   # A view of packet "heads", i.e. `@view recv_buf[1,:]
    $npkts_posted, # Ref for counting number of packets/WRs posted
    $npkts_done,   # Ref for counting number of packets/WRs done
    $npkts_max,    # Total number of packets to receive
    $pktlengths    # place to store packet lengths
)

#--- 
# Wait for recvtask to finish

wait(recvtask)

#---
# Destroy flow

destroy_flow(sniffer_flow)
