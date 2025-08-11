export fcntl_getflags
export fcntl_setflags
export fcntl_setnonblock
export pollin

"""
    fcntl_getfl(fd) -> flags

Get the flags for file descriptor `fd`.
"""
function fcntl_getflags(fd)
    flags = ccall(:fcntl, Cint, (Cint, Cint), fd, F_GETFL)
    flags == -1 && throw(SystemError("fcntl($fd, F_GETFL)", flags))
    flags
end

"""
    fcntl_setflags(fd, flags) -> nothing

Set the flags for file descriptor `fd` to `flags`.
"""
function fcntl_setflags(fd, flags)
    errno = flags = ccall(:fcntl, Cint, (Cint, Cint, Cint), fd, F_SETFL, flags)
    errno == -1 && throw(SystemError("fcntl($fd, F_SETFL, $flags)", errno))
    nothing
end

"""
    set_setnonblock(fd, nonblock::Bool=true) -> nothing

Set/clear the `O_NONBLOCK` flag on file descriptor `fd` according to `nonblock`.
"""
function fcntl_setnonblock(fd, nonblock::Bool=true)
    flags = fcntl_getflags(fd)
    flags = nonblock ? (flags | O_NONBLOCK) : (flags & (~O_NONBLOCK))
    fcntl_setflags(fd, flags)
end

"""
    pollin(fd, timeout_ms=-1)

Wait up to `timeout_ms` milleseconds for is data to be available on `fd`.

Wait "forever" if `timeout_ms < 0`.  Return immediately if `timeout_ms == 0`.
Return `true` if data is available, `false` for timeout and no data available.
Throws `SystemError` on error.
"""
function pollin(fd, timeout_ms=-1)
    pfd = Ref(pollfd(fd, POLLIN, 0))
    retval = ccall(:poll, Cint, (Ptr{pollfd}, Culong, Cint), pfd, 1, timeout_ms)
    retval == -1 && throw(SystemError("poll($fd, POLLIN, $timeout_ms)", errno))
    retval != 0
end
