-- mips specific constants

local require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string, math = 
require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string, math

local h = require "syscall.helpers"

local octal = h.octal

local abi = require "syscall.abi"

local arch = {}

arch.syscall = {
  zeropad = true,
}

-- these are different for different ABIs TODO add the rest

assert(abi.mipsabi == "o32", "FIXME: syscalls only defined for o32 MIPS ABI")

arch.SYS = {
  syscall               = 4000,
  exit                  = 4001,
  fork                  = 4002,
  read                  = 4003,
  write                 = 4004,
  open                  = 4005,
  close                 = 4006,
  waitpid               = 4007,
  creat                 = 4008,
  link                  = 4009,
  unlink                = 4010,
  execve                = 4011,
  chdir                 = 4012,
  time                  = 4013,
  mknod                 = 4014,
  chmod                 = 4015,
  lchown                = 4016,
  ["break"]             = 4017,
  unused18              = 4018,
  lseek                 = 4019,
  getpid                = 4020,
  mount                 = 4021,
  umount                = 4022,
  setuid                = 4023,
  getuid                = 4024,
  stime                 = 4025,
  ptrace                = 4026,
  alarm                 = 4027,
  unused28              = 4028,
  pause                 = 4029,
  utime                 = 4030,
  stty                  = 4031,
  gtty                  = 4032,
  access                = 4033,
  nice                  = 4034,
  ftime                 = 4035,
  sync                  = 4036,
  kill                  = 4037,
  rename                = 4038,
  mkdir                 = 4039,
  rmdir                 = 4040,
  dup                   = 4041,
  pipe                  = 4042,
  times                 = 4043,
  prof                  = 4044,
  brk                   = 4045,
  setgid                = 4046,
  getgid                = 4047,
  signal                = 4048,
  geteuid               = 4049,
  getegid               = 4050,
  acct                  = 4051,
  umount2               = 4052,
  lock                  = 4053,
  ioctl                 = 4054,
  fcntl                 = 4055,
  mpx                   = 4056,
  setpgid               = 4057,
  ulimit                = 4058,
  unused59              = 4059,
  umask                 = 4060,
  chroot                = 4061,
  ustat                 = 4062,
  dup2                  = 4063,
  getppid               = 4064,
  getpgrp               = 4065,
  setsid                = 4066,
  sigaction             = 4067,
  sgetmask              = 4068,
  ssetmask              = 4069,
  setreuid              = 4070,
  setregid              = 4071,
  sigsuspend            = 4072,
  sigpending            = 4073,
  sethostname           = 4074,
  setrlimit             = 4075,
  getrlimit             = 4076,
  getrusage             = 4077,
  gettimeofday          = 4078,
  settimeofday          = 4079,
  getgroups             = 4080,
  setgroups             = 4081,
  reserved82            = 4082,
  symlink               = 4083,
  unused84              = 4084,
  readlink              = 4085,
  uselib                = 4086,
  swapon                = 4087,
  reboot                = 4088,
  readdir               = 4089,
  mmap                  = 4090,
  munmap                = 4091,
  truncate              = 4092,
  ftruncate             = 4093,
  fchmod                = 4094,
  fchown                = 4095,
  getpriority           = 4096,
  setpriority           = 4097,
  profil                = 4098,
  statfs                = 4099,
  fstatfs               = 4100,
  ioperm                = 4101,
  socketcall            = 4102,
  syslog                = 4103,
  setitimer             = 4104,
  getitimer             = 4105,
  stat                  = 4106,
  lstat                 = 4107,
  fstat                 = 4108,
  unused109             = 4109,
  iopl                  = 4110,
  vhangup               = 4111,
  idle                  = 4112,
  vm86                  = 4113,
  wait4                 = 4114,
  swapoff               = 4115,
  sysinfo               = 4116,
  ipc                   = 4117,
  fsync                 = 4118,
  sigreturn             = 4119,
  clone                 = 4120,
  setdomainname         = 4121,
  uname                 = 4122,
  modify_ldt            = 4123,
  adjtimex              = 4124,
  mprotect              = 4125,
  sigprocmask           = 4126,
  create_module         = 4127,
  init_module           = 4128,
  delete_module         = 4129,
  get_kernel_syms       = 4130,
  quotactl              = 4131,
  getpgid               = 4132,
  fchdir                = 4133,
  bdflush               = 4134,
  sysfs                 = 4135,
  personality           = 4136,
  afs_syscall           = 4137,
  setfsuid              = 4138,
  setfsgid              = 4139,
  _llseek               = 4140,
  getdents              = 4141,
  select                = 4142,
  flock                 = 4143,
  msync                 = 4144,
  readv                 = 4145,
  writev                = 4146,
  cacheflush            = 4147,
  cachectl              = 4148,
  sysmips               = 4149,
  unused150             = 4150,
  getsid                = 4151,
  fdatasync             = 4152,
  _sysctl               = 4153,
  mlock                 = 4154,
  munlock               = 4155,
  mlockall              = 4156,
  munlockall            = 4157,
  sched_setparam        = 4158,
  sched_getparam        = 4159,
  sched_setscheduler    = 4160,
  sched_getscheduler    = 4161,
  sched_yield           = 4162,
  sched_get_priority_max= 4163,
  sched_get_priority_min= 4164,
  sched_rr_get_interval = 4165,
  nanosleep             = 4166,
  mremap                = 4167,
  accept                = 4168,
  bind                  = 4169,
  connect               = 4170,
  getpeername           = 4171,
  getsockname           = 4172,
  getsockopt            = 4173,
  listen                = 4174,
  recv                  = 4175,
  recvfrom              = 4176,
  recvmsg               = 4177,
  send                  = 4178,
  sendmsg               = 4179,
  sendto                = 4180,
  setsockopt            = 4181,
  shutdown              = 4182,
  socket                = 4183,
  socketpair            = 4184,
  setresuid             = 4185,
  getresuid             = 4186,
  query_module          = 4187,
  poll                  = 4188,
  nfsservctl            = 4189,
  setresgid             = 4190,
  getresgid             = 4191,
  prctl                 = 4192,
  rt_sigreturn          = 4193,
  rt_sigaction          = 4194,
  rt_sigprocmask        = 4195,
  rt_sigpending         = 4196,
  rt_sigtimedwait       = 4197,
  rt_sigqueueinfo       = 4198,
  rt_sigsuspend         = 4199,
  pread64               = 4200,
  pwrite64              = 4201,
  chown                 = 4202,
  getcwd                = 4203,
  capget                = 4204,
  capset                = 4205,
  sigaltstack           = 4206,
  sendfile              = 4207,
  getpmsg               = 4208,
  putpmsg               = 4209,
  mmap2                 = 4210,
  truncate64            = 4211,
  ftruncate64           = 4212,
  stat64                = 4213,
  lstat64               = 4214,
  fstat64               = 4215,
  pivot_root            = 4216,
  mincore               = 4217,
  madvise               = 4218,
  getdents64            = 4219,
  fcntl64               = 4220,
  reserved221           = 4221,
  gettid                = 4222,
  readahead             = 4223,
  setxattr              = 4224,
  lsetxattr             = 4225,
  fsetxattr             = 4226,
  getxattr              = 4227,
  lgetxattr             = 4228,
  fgetxattr             = 4229,
  listxattr             = 4230,
  llistxattr            = 4231,
  flistxattr            = 4232,
  removexattr           = 4233,
  lremovexattr          = 4234,
  fremovexattr          = 4235,
  tkill                 = 4236,
  sendfile64            = 4237,
  futex                 = 4238,
  sched_setaffinity     = 4239,
  sched_getaffinity     = 4240,
  io_setup              = 4241,
  io_destroy            = 4242,
  io_getevents          = 4243,
  io_submit             = 4244,
  io_cancel             = 4245,
  exit_group            = 4246,
  lookup_dcookie        = 4247,
  epoll_create          = 4248,
  epoll_ctl             = 4249,
  epoll_wait            = 4250,
  remap_file_pages      = 4251,
  set_tid_address       = 4252,
  restart_syscall       = 4253,
  fadvise64             = 4254,
  statfs64              = 4255,
  fstatfs64             = 4256,
  timer_create          = 4257,
  timer_settime         = 4258,
  timer_gettime         = 4259,
  timer_getoverrun      = 4260,
  timer_delete          = 4261,
  clock_settime         = 4262,
  clock_gettime         = 4263,
  clock_getres          = 4264,
  clock_nanosleep       = 4265,
  tgkill                = 4266,
  utimes                = 4267,
  mbind                 = 4268,
  get_mempolicy         = 4269,
  set_mempolicy         = 4270,
  mq_open               = 4271,
  mq_unlink             = 4272,
  mq_timedsend          = 4273,
  mq_timedreceive       = 4274,
  mq_notify             = 4275,
  mq_getsetattr         = 4276,
  vserver               = 4277,
  waitid                = 4278,
  add_key               = 4280,
  request_key           = 4281,
  keyctl                = 4282,
  set_thread_area       = 4283,
  inotify_init          = 4284,
  inotify_add_watch     = 4285,
  inotify_rm_watch      = 4286,
  migrate_pages         = 4287,
  openat                = 4288,
  mkdirat               = 4289,
  mknodat               = 4290,
  fchownat              = 4291,
  futimesat             = 4292,
  fstatat64             = 4293,
  unlinkat              = 4294,
  renameat              = 4295,
  linkat                = 4296,
  symlinkat             = 4297,
  readlinkat            = 4298,
  fchmodat              = 4299,
  faccessat             = 4300,
  pselect6              = 4301,
  ppoll                 = 4302,
  unshare               = 4303,
  splice                = 4304,
  sync_file_range       = 4305,
  tee                   = 4306,
  vmsplice              = 4307,
  move_pages            = 4308,
  set_robust_list       = 4309,
  get_robust_list       = 4310,
  kexec_load            = 4311,
  getcpu                = 4312,
  epoll_pwait           = 4313,
  ioprio_set            = 4314,
  ioprio_get            = 4315,
  utimensat             = 4316,
  signalfd              = 4317,
  timerfd               = 4318,
  eventfd               = 4319,
  fallocate             = 4320,
  timerfd_create        = 4321,
  timerfd_gettime       = 4322,
  timerfd_settime       = 4323,
  signalfd4             = 4324,
  eventfd2              = 4325,
  epoll_create1         = 4326,
  dup3                  = 4327,
  pipe2                 = 4328,
  inotify_init1         = 4329,
  preadv                = 4330,
  pwritev               = 4331,
  rt_tgsigqueueinfo     = 4332,
  perf_event_open       = 4333,
  accept4               = 4334,
  recvmmsg              = 4335,
  fanotify_init         = 4336,
  fanotify_mark         = 4337,
  prlimit64             = 4338,
  name_to_handle_at     = 4339,
  open_by_handle_at     = 4340,
  clock_adjtime         = 4341,
  syncfs                = 4342,
  sendmmsg              = 4343,
  setns                 = 4344,
  process_vm_readv      = 4345,
  process_vm_writev     = 4346,
}

arch.SIG = {
  HUP = 1,
  INT = 2,
  QUIT = 3,
  ILL = 4,
  TRAP = 5,
  ABRT = 6,
  EMT = 7,
  FPE = 8,
  KILL = 9,
  BUS = 10,
  SEGV = 11,
  SYS = 12,
  PIPE = 13,
  ALRM = 14,
  TERM = 15,
  USR1 = 16,
  USR2 = 17,
  CHLD = 18,
  PWR = 19,
  WINCH = 20,
  URG = 21,
  IO = 22,
  STOP = 23,
  TSTP = 24,
  CONT = 25,
  TTIN = 26,
  TTOU = 27,
  VTALRM = 28,
  PROF = 29,
  XCPU = 30,
  XFSZ = 31,
}

arch.MAP = {
  SHARED     = 0x001,
  PRIVATE    = 0x002,
  TYPE       = 0x00f,
  FIXED      = 0x010,
  NORESERVE  = 0x0400,
  ANONYMOUS  = 0x0800,
  GROWSDOWN  = 0x1000,
  DENYWRITE  = 0x2000,
  EXECUTABLE = 0x4000,
  LOCKED     = 0x8000,
  POPULATE   = 0x10000,
  NONBLOCK   = 0x20000,
  STACK      = 0x40000,
  HUGETLB    = 0x80000,
}

local __O_SYNC = 0x4000

arch.O = {
  APPEND   = 0x0008,
  DSYNC    = 0x0010,
  NONBLOCK = 0x0080,
  CREAT    = 0x0100,
  TRUNC    = 0x0200,
  EXCL     = 0x0400,
  NOCTTY   = 0x0800,
  LARGEFILE= 0x2000,
  DIRECT   = 0x8000,
}

arch.O_SYNC = __O_SYNC + arch.O.DSYNC -- compatibility, see notes in header, we do not expose __O_SYNC TODO check if this is best way

arch.E = {
  PERM          =  1,
  NOENT         =  2,
  SRCH          =  3,
  INTR          =  4,
  IO            =  5,
  NXIO          =  6,
  ["2BIG"]      =  7,
  NOEXEC        =  8,
  BADF          =  9,
  CHILD         = 10,
  AGAIN         = 11,
  NOMEM         = 12,
  ACCES         = 13,
  FAULT         = 14,
  NOTBLK        = 15,
  BUSY          = 16,
  EXIST         = 17,
  XDEV          = 18,
  NODEV         = 19,
  NOTDIR        = 20,
  ISDIR         = 21,
  INVAL         = 22,
  NFILE         = 23,
  MFILE         = 24,
  NOTTY         = 25,
  TXTBSY        = 26,
  FBIG          = 27,
  NOSPC         = 28,
  SPIPE         = 29,
  ROFS          = 30,
  MLINK         = 31,
  PIPE          = 32,
  DOM           = 33,
  RANGE         = 34,
  NOMSG         = 35,
  IDRM          = 36,
  CHRNG         = 37,
  L2NSYNC       = 38,
  L3HLT         = 39,
  L3RST         = 40,
  LNRNG         = 41,
  UNATCH        = 42,
  NOCSI         = 43,
  L2HLT         = 44,
  DEADLK        = 45,
  NOLCK         = 46,
  BADE          = 50,
  BADR          = 51,
  XFULL         = 52,
  NOANO         = 53,
  BADRQC        = 54,
  BADSLT        = 55,
  DEADLOCK      = 56,
  BFONT         = 59,
  NOSTR         = 60,
  NODATA        = 61,
  TIME          = 62,
  NOSR          = 63,
  NONET         = 64,
  NOPKG         = 65,
  REMOTE        = 66,
  NOLINK        = 67,
  ADV           = 68,
  SRMNT         = 69,
  COMM          = 70,
  PROTO         = 71,
  DOTDOT        = 73,
  MULTIHOP      = 74,
  BADMSG        = 77,
  NAMETOOLONG   = 78,
  OVERFLOW      = 79,
  NOTUNIQ       = 80,
  BADFD         = 81,
  REMCHG        = 82,
  LIBACC        = 83,
  LIBBAD        = 84,
  LIBSCN        = 85,
  LIBMAX        = 86,
  LIBEXEC       = 87,
  ILSEQ         = 88,
  NOSYS         = 89,
  LOOP          = 90,
  RESTART       = 91,
  STRPIPE       = 92,
  NOTEMPTY      = 93,
  USERS         = 94,
  NOTSOCK       = 95,
  DESTADDRREQ   = 96,
  MSGSIZE       = 97,
  PROTOTYPE     = 98,
  NOPROTOOPT    = 99,
  PROTONOSUPPORT= 120,
  SOCKTNOSUPPORT= 121,
  OPNOTSUPP     = 122,
  PFNOSUPPORT   = 123,
  AFNOSUPPORT   = 124,
  ADDRINUSE     = 125,
  ADDRNOTAVAIL  = 126,
  NETDOWN       = 127,
  NETUNREACH    = 128,
  NETRESET      = 129,
  CONNABORTED   = 130,
  CONNRESET     = 131,
  NOBUFS        = 132,
  ISCONN        = 133,
  NOTCONN       = 134,
  UCLEAN        = 135,
  NOTNAM        = 137,
  NAVAIL        = 138,
  ISNAM         = 139,
  REMOTEIO      = 140,
  INIT          = 141,
  REMDEV        = 142,
  SHUTDOWN      = 143,
  TOOMANYREFS   = 144,
  TIMEDOUT      = 145,
  CONNREFUSED   = 146,
  HOSTDOWN      = 147,
  HOSTUNREACH   = 148,
  ALREADY       = 149,
  INPROGRESS    = 150,
  STALE         = 151,
  CANCELED      = 158,
  NOMEDIUM      = 159,
  MEDIUMTYPE    = 160,
  NOKEY         = 161,
  KEYEXPIRED    = 162,
  KEYREVOKED    = 163,
  KEYREJECTED   = 164,
  OWNERDEAD     = 165,
  NOTRECOVERABLE= 166,
  RFKILL        = 167,
  HWPOISON      = 168,
  DQUOT         = 1133,
}

arch.SFD = {
  CLOEXEC  = octal "02000000",
  NONBLOCK = octal "00000200",
}

arch.IN_INIT = {
  CLOEXEC  = octal("02000000"),
  NONBLOCK = octal("00000200"),
}

arch.SA = {
  ONSTACK     = 0x08000000,
  RESETHAND   = 0x80000000,
  RESTART     = 0x10000000,
  SIGINFO     = 0x00000008,
  NODEFER     = 0x40000000,
  NOCLDWAIT   = 0x00010000,
  NOCLDSTOP   = 0x00000001,
}

arch.SIGPM = {
  BLOCK     = 1,
  UNBLOCK   = 2,
  SETMASK   = 3,
}

return arch

