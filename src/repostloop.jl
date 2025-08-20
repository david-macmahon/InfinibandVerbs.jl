"""
    repost_loop(callback, ctx::Context, wrs, timeout_ms, callback_args...)

Run a loop that processes work completions and reposts work requests.

The `callback` argument is a user supplied callback function described in detail
below.  `ctx` is a `Context` struct.  `wrs` is a `Vector{ibv_recv_wr}` or
`Vector{ibv_send_wr}` containing all the work requests being used.
`callback_args...` are user supplied arguments that will be passed to the user
supplied callback function.  Typically `callback_args` will include the packet
buffers (or some other means of getting packet (fragment) buffers) and a
`Ref{Int}` for accumulating the number of packets posted (useful when finding
the next location in the packet buffers to use), but the caller is free to
decide how to make use of `callback_args...`.

The user supplied callback function `callback` is called for every work
completion event that has a non-zero number of work completions.  It is also
called if no work completions are received for `timeout_ms` milliseconds.  The
callback function is passed the following arguments:

    callback(wcs, num_wc, wrs, callback_args...)

- `wcs`: A `Vector{ibv_wc}` containing work completions (WCs)
- `num_wc`: Number of valid entries in `wcs` (i.e. `wcs[1:num_wc]` are valid).
  If the callback function is called after a timeout, `num_wc` will be `0`.
- `wrs`: The same `recv_wrs` or `send_wrs` passed to `repost_loop`
- `callback_args...`: The same `callback_args...` parameters that were passed to
  `repost_loop` (the callback function may specify the individual extra
  arguments by name rather than splatting `callback_args`)

!!! warning

    This function can block waiting for work completion events.  It should be
    run in a separate thread from the main Julia thread so that it will not
    interfere with the Julia scheduler.  Usually this will be done using
    `Threads.@spawn`.  For example (using `repost_loop` to receive):

        recvtask = Threads.@spawn repost_loop(recv_callback, ctx, recv_wrs, timeout, user1, user2)

    Note that `Threads.@spawn` does not create new threads.  To use multiple
    threads, Julia must be started with more than one thread (e.g.
    `julia -t 4`).  Additional threads cannot be created after startup.

# Extended help

The main purpose of the callback function is to update the SG lists of the
completed work requests (WRs) with pointers to the next available packet
(fragment) buffer location(s).  The callback function should return the number
of work requests for `repost_loop` to repost.  Returning `0` from the callback
will keep `repost_loop` running but no WRs will be reposted.  Returning a
negative value will cause `repost_loop` to return (i.e. end).  When `num_wc` is
`0` (i.e. after a timeout), the callback should return a value less than `0` to
end the loop or `0` to keep waiting for more work completions (i.e. packets).

For streaming applications that run "forever", the callback function should
update the SG lists of the WRs for all `num_wc` WCs and return `num_wc`.

Applications that want to process exactly `N` WRs should pass `N` as part of
`callback_args...` as well as two `Ref{Int}` parameters so the callback function
can accumulate the number of WRs posted and the number of WRs done/processed.
As the number of WRs posted approaches `N` the callback may return a number less
than than `num_wc`.  Such applications should also pay attention to the number
of done/processed WRs and return a negative value when it equals `N` (or exceeds
`N`, but that should never happen if exactly `N` WRs are posted).
"""
function repost_loop(callback, ctx::Context, wrs, timeout_ms, callback_args...)
    npkts_repost = 0
    while npkts_repost >= 0
        npkts_repost, wcs, num_wc = _repost_loop_body(
            callback, ctx, wrs, timeout_ms, callback_args...
        )

        # Check for various special cases
        npkts_repost  < 0 && break    # Done!
        npkts_repost == 0 && continue # Not done, but no more to post
        # The user callback should have returned 0 if num_wc==0, but we double
        # check num_wc here just in case.
        num_wc == 0 && continue

        # Limit npkts_repost to no more than num_wc.  Should never happen
        # unless user callback has a bug.
        npkts_repost = clamp(npkts_repost, 1, num_wc)

        # Link npkts_repost WRs from WCs for re-posting
        link_wrs!(wrs, wcs, npkts_repost)

        # Repost WRs
        post_wrs(ctx, wrs, wcs[1].wr_id)
    end
end

function _repost_loop_body(cb, ctx::Context, wrs::AbstractVector{<:ibv_send_wr}, timeout_ms, cb_args...)
    _repost_loop_body(cb, ctx.send_cq, ctx.send_comp_channel, ctx.send_wcs, wrs, timeout_ms, cb_args...)
end

function _repost_loop_body(cb, ctx::Context, wrs::AbstractVector{<:ibv_recv_wr}, timeout_ms, cb_args...)
    _repost_loop_body(cb, ctx.recv_cq, ctx.recv_comp_channel, ctx.recv_wcs, wrs, timeout_ms, cb_args...)
end

# Returns (npkts_repost, wcs, num_wc)
function _repost_loop_body(callback, cq::Ptr{ibv_cq}, cc, wcs, wrs, timeout_ms, cb_args...)
    # Poll cq for work completions (WCs)
    num_wc = ibv_poll_cq(cq, length(wcs), wcs)

    # If no work completions are available, wait for a completion event and
    # try again
    if num_wc == 0
        # wait_for_completion_event returns cq for event or nothing on timeout
        cq = wait_for_completion_event(cc, timeout_ms)
        # Poll cq for work completions (WCs) if cq is not nothing
        if isnothing(cq)
            num_wc = 0
        else
            num_wc = ibv_poll_cq(cq, length(wcs), wcs)
            # If we got an event (no timeout), but no work completions, re-loop
            num_wc == 0 && return (0, wcs, 0)
        end
    end

    # Throw on error
    num_wc < 0 && throw(SystemError("ibv_poll_wc"))

    # Call the user callback.  Passing 0 for num_wc indicates a timeout
    npkts_repost = callback(wcs, num_wc, wrs, cb_args...)

    npkts_repost, wcs, num_wc
end
