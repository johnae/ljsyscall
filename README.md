# Linux system calls for LuaJIT

What? An FFI implementation of the Linux system calls for LuaJIT.

Why? Making a C library for everything you want to bind is a pain, so I thought I would see what you could do without, and I want to do some low level system stuff in Lua.

Linux only? Easy to port to other Unixes, you need to check the types and constants are correct, and remove anything that is not in your C library (that applies also to any non glibc library too), and test. Patches accepted.

Requirements: Needs git head of LuaJIT (or next release 2.0.0-beta8 when it is out).

## What is implemented?

Unfinished! Some syscalls missing, work in progress! Let me know if you need some that are not there.

No support for 64 bit file operations on a 32 bit system yet. 

### System calls (100)

open, close, creat, chdir, mkdir, rmdir, unlink, acct, chmod, link, umask, uname, gethostname, sethostname, getuid, geteuid, getpid, getppid, getgid, getegid, fork, execve, wait, waitpid, _exit, signal, gettimeofday, settimeofday, time, clock_getres, clock_gettime, clock_settime, sysinfo, read, write, pread, pwrite, lseek, send, sendto, sendmsg, recv, recvfrom, recvmsg, readv, writev, getsockopt, setsockopt, select, epoll_create, epoll_ctl, epoll_wait, sendfile, dup, fchdir, fsync, fdatasync, fcntl, fchmod, socket, socketpair, bind, listen, connect, accept, getsockname, getpeername, mmap, munmap, msync, mlock, munlock, mlockall, munlockall, mremap, madvise, pipe, access, getcwd, nanosleep, syscall, stat, fstat, lstat, ioctl, eventfd, truncate, ftruncate, pause, reboot, sync, shutdown, ksyslogctl, mount, umount,
nice, getpriority, setpriority, prctl, alarm, waitid

### Other functions

exit, inet_aton, inet_ntoa, inet_pton, inet_ntop

### Socket types

inet, inet6, unix, netlink (partial support, in progress)

### API

Basically what you expect, with the following notes. In general we explicitly return return parameters as it is more idiomatic.

All functions return two values, the return value, or true if there is not one other than success, then an error value. This makes it easy to write things like assert(fd:close()). The error type can be converted to a string message, or you can retrieve the errno, or test against a symbolic error name.

File descriptors are returned as a type not an integer. This is because they are garbage collected by default, ie if they go out of scope the file is closed. You can get the file descriptor using the fd field. To disable the garbage collection you can call fd:nogc(), in which case you need to close the descriptors by hand. They also have methods for operations that take an fd, like close, fsync, read. You can use this type where an fd is required, or a numeric fd, or a string like "stderr". 

As well as garbage collections of file descriptors, mmap regions are also unmapped if they go out of scope.

String conversions are not done automatically, you get a buffer back, you have to force a conversion. This is because interning strings is expensive if you do not need it. Nor are conversions from 64 bit values to Lua numbers, as that would be lossy (actually some are, need to make consistent). However if you do not supply a buffer for the return value, you will get a string from some functions. Again need to make more consistent.

Not yet supporting the 64 bit file operations for 32 bit architectures (lseek64 etc).

Constants should all be available, eg `L.SEEK_SET` etc. You can add to combine them. They are also available as strings, so "SEEK_SET" will be converted to S.SEEK_SET. You can miss off the "SEEK_" prefix, and they are not case sensitive, so you can just use `fd:lseek(offset, "set")` for more concise and readable use. If multiple flags are allowed, they can be comma separated for logical OR, such as `S.mmap(nil, size, "read", "private, anonymous", -1, 0)`.

You do not need to use the numbered versions of functions, eg dup can do dup2 or dup3 by adding more arguments

getcwd returns the result in a buffer if one is passed, or as a Lua string otherwise, ie if called with no parameters/

Standard convenience macros are also provided, eg S.major(dev) to extract a major number from a device number.

bind does not require a length for the address type length, as it can work this out dynamically.

uname returns a Lua table with the returned strings in it. Similarly getdents returns directory entries as a table. All functions that return multiple arguments return tables in general.

The test cases are good examples until I do better documentation!

### Issues

LuaJIT FFI cannot yet create callbacks. This causes issues in a few places, we cannot set a signal handler to be a Lua function, or use clone. This means some functions cannot yet usefully be implemented: sigaction (you can use signal just to set ignore, default behaviour), clone, getitimer/setitimer.

Some functions are returning raw structures, probably will change to return tables? waitid, stat, ...

Managing constants a lot of work, may divide into subtables

### Testing

The test script is quite comprehensive, though it does not test all the syscalls, as I assume they work, but it should stress the bindings. Tested on ARM, amd64, x86.

Initial testing on uclibc, works on my configuration, but uclibc warns that ABI can depend on compile options, so please test. I thought uclibc used kernel structures for eg stat, but they seem to use the glibc ones now, so more compatible. If there are more compatibility issues I may move towards using more syscalls directly, now we have the syscall function. Other C libraries may need more changes.



