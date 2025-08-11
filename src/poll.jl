module Poll

struct pollfd
    fd::Cint
    events::Cshort
    revents::Cshort
end

const O_ACCMODE = 0x00000003

const O_RDONLY = 0x00000000

const O_WRONLY = 0x00000001

const O_RDWR = 0x00000002

const O_CREAT = 0x00000040

const O_EXCL = 0x00000080

const O_NOCTTY = 0x00000100

const O_TRUNC = 0x00000200

const O_APPEND = 0x00000400

const O_NONBLOCK = 0x00000800

const O_DSYNC = 0x00001000

const FASYNC = 0x00002000

const O_DIRECT = 0x00004000

const O_LARGEFILE = 0x00008000

const O_DIRECTORY = 0x00010000

const O_NOFOLLOW = 0x00020000

const O_NOATIME = 0x00040000

const O_CLOEXEC = 0x00080000

const __O_SYNC = 0x00100000

const O_SYNC = __O_SYNC | O_DSYNC

const O_PATH = 0x00200000

const __O_TMPFILE = 0x00400000

const O_TMPFILE = __O_TMPFILE | O_DIRECTORY

const O_TMPFILE_MASK = (__O_TMPFILE | O_DIRECTORY) | O_CREAT

const O_NDELAY = O_NONBLOCK

const F_DUPFD = 0

const F_GETFD = 1

const F_SETFD = 2

const F_GETFL = 3

const F_SETFL = 4

const F_GETLK = 5

const F_SETLK = 6

const F_SETLKW = 7

const F_SETOWN = 8

const F_GETOWN = 9

const F_SETSIG = 10

const F_GETSIG = 11

const F_GETLK64 = 12

const F_SETLK64 = 13

const F_SETLKW64 = 14

const F_SETOWN_EX = 15

const F_GETOWN_EX = 16

const F_GETOWNER_UIDS = 17

const F_OFD_GETLK = 36

const F_OFD_SETLK = 37

const F_OFD_SETLKW = 38

const F_OWNER_TID = 0

const F_OWNER_PID = 1

const F_OWNER_PGRP = 2

const FD_CLOEXEC = 1

const F_RDLCK = 0

const F_WRLCK = 1

const F_UNLCK = 2

const F_EXLCK = 4

const F_SHLCK = 8

const LOCK_SH = 1

const LOCK_EX = 2

const LOCK_NB = 4

const LOCK_UN = 8

const LOCK_MAND = 32

const LOCK_READ = 64

const LOCK_WRITE = 128

const LOCK_RW = 192

const F_LINUX_SPECIFIC_BASE = 1024

const POLLIN = 0x0001

const POLLPRI = 0x0002

const POLLOUT = 0x0004

const POLLERR = 0x0008

const POLLHUP = 0x0010

const POLLNVAL = 0x0020

const POLLRDNORM = 0x0040

const POLLRDBAND = 0x0080

const POLLWRNORM = 0x0100

const POLLWRBAND = 0x0200

const POLLMSG = 0x0400

const POLLREMOVE = 0x1000

const POLLRDHUP = 0x2000

const POLLFREE = 0x4000

const POLL_BUSY_LOOP = 0x8000

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


end # module
