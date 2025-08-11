"""
    recv_loop(cb, ctx::Context, recv_wrs, timeout_ms, cb_args...)

Run a loop that processes work completions from `ctx.recv_cq` and reposts WRs.

The `cb` argument is a user supplied callback function described in detail
below.  `ctx` is a `Context` struct.  `recv_wrs` is a `Vector{ibv_recv_wr}`
containing all the work requests being used.  `cb_args...` are user supplied
arguments that will be passed to the user supplied callback function.  Typically
`cb_args` will include the packet receive buffers (or some other means of
getting packet (fragment) buffers) and a `Ref{Int}` for accumulating the number
of packets posted (useful when finding the next location in the recv_bufs to
use), but the caller is free to decide how to make use of `cb_args...`.

The user supplied callback function `cb` is called for every work completion
event that has a non-zero number of work completions.  It is also called if no
work completions are received for `timeout_ms` milliseconds.  The callback
function is passed the following arguments:

    cb(wcs, num_wc, recv_wrs, cb_args...)

- `wcs`: A `Vector{ibv_wc}` containing work completions (WCs)
- `num_wc`: Number of valid entries in `wcs` (i.e. `wcs[1:num_wc]` are valid).
  If the callback function is called after a timeout, `num_wc` will be `0`.
- `recv_wrs`: The same `recv_wrs` passed to `recv_loop`
- `cb_args...`: The same `cb_args...` parameters that were passed to
  `recv_loop` (the callback function may specify the individual extra arguments
  by name rather than splatting `cb_args`)

!!! warning

    This function can block waiting for packets.  It should be run in a separate
    `Task` from the main `Task` so that it will not interfere with the
    Julia scheduler.  Usually this would be done using `Threads.@spawn`.  For
    example:

        recvtask = Threads.@spawn recv_loop(cb, ctx, wrs, timeout, user1, user2)

# Extended help

The main purpose of the callback function is to update the SG lists of the
completed work requests (WRs) with pointers to the next available packet
(fragment) receive buffer location(s).  The callback function should return the
number of work requests for `recv_loop` to repost.  Returning `0` from the
callback will keep `recv_loop` running but no WRs will be reposted.  Returning a
negative value will cause `recv_loop` to return (i.e. end).  When `num_wc` is
`0` (i.e. after a timeout), the callback should return a value less than `0` to
end the loop or `0` to keep waiting for packets.

For streaming applications that run "forever", the callback function should
update the SG lists of the WRs for all `num_wc` WCs and return `num_wc`.

Applications that want to receive exactly `N` packets should pass `N` as part of
`cb_args...` as well as two `Ref{Int}` parameters so the callback function can
accumulate the number of packets posted and the number of packets done/received.
As the number of packets posted approaches `N` the callback may return a number
less than than `num_wc`.  Such applications should also pay attention to the
number of done/received packets and return a negative value when it equals `N`
(or exceeds `N`, but that should never happen if exactly `N` WRs are posted).
"""
function recv_loop(cb, ctx::Context, recv_wrs, timeout_ms, cb_args...)
    npkts_repost = 0
    wcs = ctx.recv_wcs
    while npkts_repost >= 0
        # Poll recv_cq for work completions (WCs)
        num_wc = ibv_poll_cq(ctx.recv_cq, length(wcs), wcs)

        # If no work completions are available, wait for a completion event and
        # try again
        if num_wc == 0
            # Wait for completion event
            # Returns cq for event or nothing on timeout
            cq = wait_for_completion_event(ctx.recv_comp_channel, timeout_ms)
            # Poll recv_cq for work completions (WCs) if cq is not nothing
            if isnothing(cq)
                num_wc = 0
            else
                num_wc = ibv_poll_cq(ctx.recv_cq, length(wcs), wcs)
                # If we got an event, but no work completions, re-loop
                num_wc == 0 && continue
            end
        end

        # Throw on error
        num_wc < 0 && throw(SystemError("ibv_poll_wc"))

        # Call the user callback.  Passing 0 for num_wc indicates a timeout
        npkts_repost = cb(wcs, num_wc, recv_wrs, cb_args...)

        # Check for various special cases
        npkts_repost  < 0 && break    # Done!
        npkts_repost == 0 && continue # Not done, but no more to post
        # The user callback should have returned 0 if num_wc==0, but we double
        # check num_wc here just in case.
        num_wc == 0 && continue

        # Limit npkts_repost to no more than num_wc.  Should never happen
        # unless user callback has a bug.
        npkts_repost = clamp(npkts_repost, 1, num_wc)

        # Link first npkts_repost-1 WRs from WCs for re-posting
        for wcidx = 1:num_wc-1
            wr_id = wcs[wcidx].wr_id
            wr_id_next = wcs[wcidx+1].wr_id
            ptr_next = pointer(recv_wrs, wr_id_next)
            pointer(recv_wrs, wr_id).next = ptr_next
        end
        # Null terminate WR linked list at npkts_repost point
        pointer(recv_wrs, wcs[npkts_repost].wr_id).next = C_NULL

        # Repost WRs
        post_wrs(ctx, recv_wrs, wcs[1].wr_id)
    end
end
