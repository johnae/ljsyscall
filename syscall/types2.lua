-- choose correct types for OS

-- these are either simple ffi types or ffi metatypes for the kernel types
-- plus some Lua metatables for types that cannot be sensibly done as Lua types eg arrays, integers

-- note that some types will be overridden, eg default fd type will have metamethods added

local function init(abi, errors, c)

local ffi = require "ffi"
local bit = require "bit"

local h = require "syscall.helpers"

local ntohl, ntohl, ntohs, htons = h.ntohl, h.ntohl, h.ntohs, h.htons
local split, trim = h.split, h.trim

local C = ffi.C -- for inet_pton, TODO due to be replaced with Lua
ffi.cdef[[
int inet_pton(int af, const char *src, void *dst);
]]

local types = {}

local t, pt, s, ctypes = {}, {}, {}, {} -- types, pointer types and sizes tables
types.t, types.pt, types.s, types.ctypes = t, pt, s, ctypes

local mt = {} -- metatables
local meth = {}

--helpers
local function mktype(tp, x) if ffi.istype(tp, x) then return x else return tp(x) end end

local function ptt(tp)
  local ptp = ffi.typeof(tp .. " *")
  return function(x) return ffi.cast(ptp, x) end
end

local function addtype(name, tp, mt)
  if mt then t[name] = ffi.metatype(tp, mt) else t[name] = ffi.typeof(tp) end
  ctypes[tp] = t[name]
  pt[name] = ptt(tp)
  s[name] = ffi.sizeof(t[name])
end

-- for variables length types, ie those with arrays
local function addtype_var(name, tp, mt)
  t[name] = ffi.metatype(tp, mt)
  pt[name] = ptt(tp)
end

local function lenfn(tp) return ffi.sizeof(tp) end

local lenmt = {__len = lenfn}

-- generic for __new TODO use more
local function newfn(tp, tab)
  local num = {}
  if tab then for i = 1, #tab do num[i] = tab[i] end end -- numeric index initialisers TODO remove these as may vary by OS
  local obj = ffi.new(tp, num)
  -- these are split out so __newindex is called, not just initialisers luajit understands
  for k, v in pairs(tab or {}) do if type(k) == "string" then obj[k] = v end end -- set string indexes
  return obj
end

-- makes code tidier
local function istype(tp, x)
  if ffi.istype(tp, x) then return x else return false end
end

-- generic types

local voidp = ffi.typeof("void *")

pt.void = function(x)
  return ffi.cast(voidp, x)
end

local addtypes = {
  char = "char",
  uchar = "unsigned char",
  int = "int",
  uint = "unsigned int",
  int16 = "int16_t",
  uint16 = "uint16_t",
  int32 = "int32_t",
  uint32 = "uint32_t",
  int64 = "int64_t",
  uint64 = "uint64_t",
  long = "long",
  ulong = "unsigned long",
  uintptr = "uintptr_t",
  intptr = "intptr_t",
  size = "size_t",
  ssize = "ssize_t",
  mode = "mode_t",
  dev = "dev_t",
  off = "off_t",
  uid = "uid_t",
  gid = "gid_t",
  pid = "pid_t",
  in_port = "in_port_t",
  sa_family = "sa_family_t",
  socklen = "socklen_t",
  id = "id_t",
  daddr = "daddr_t",
  time = "time_t",
  blksize = "blksize_t",
  blkcnt = "blkcnt_t",
  clock = "clock_t",
  nlink = "nlink_t",
  ino = "ino_t",
}

local addstructs = {
  iovec = "struct iovec",
  msghdr = "struct msghdr",
}

for k, v in pairs(addtypes) do addtype(k, v) end
for k, v in pairs(addstructs) do addtype(k, v, lenmt) end

t.ints = ffi.typeof("int[?]")
t.buffer = ffi.typeof("char[?]") -- TODO rename as chars?

local function singleton(tp)
  return ffi.typeof("$[1]", tp)
end

t.int1 = singleton(t.int)
t.uint1 = singleton(t.uint)
t.int16_1 = singleton(t.int16)
t.uint16_1 = singleton(t.uint16)
t.int32_1 = singleton(t.int32)
t.uint32_1 = singleton(t.uint32)
t.int64_1 = singleton(t.int64)
t.uint64_1 = singleton(t.uint64)
t.socklen1 = singleton(t.socklen)
t.off1 = singleton(t.off)
t.uid1 = singleton(t.uid)
t.gid1 = singleton(t.gid)

t.char2 = ffi.typeof("char[2]")
t.int2 = ffi.typeof("int[2]")
t.uint2 = ffi.typeof("unsigned int[2]")

-- still need sizes for these, for ioctls
s.uint2 = ffi.sizeof(t.uint2)

-- 64 to 32 bit conversions via unions TODO use meth not object?
if abi.le then
mt.i6432 = {
  __index = {
    to32 = function(u) return u.i32[1], u.i32[0] end,
  }
}
else
mt.i6432 = {
  __index = {
    to32 = function(u) return u.i32[0], u.i32[1] end,
  }
}
end

t.i6432 = ffi.metatype("union {int64_t i64; int32_t i32[2];}", mt.i6432)
t.u6432 = ffi.metatype("union {uint64_t i64; uint32_t i32[2];}", mt.i6432)

local errsyms = {} -- reverse lookup
for k, v in pairs(c.E) do
  errsyms[v] = k
end

t.error = ffi.metatype("struct {int errno;}", {
  __tostring = function(e) return errors[e.errno] end,
  __index = function(t, k)
    if k == 'sym' then return errsyms[t.errno] end
    if k == 'lsym' then return errsyms[t.errno]:lower() end
    if c.E[k] then return c.E[k] == t.errno end
  end,
  __new = function(tp, errno)
    if not errno then errno = ffi.errno() end
    return ffi.new(tp, errno)
  end,
})

-- TODO add generic address type that works out which to take? basically inet_name, except without netmask

-- convert strings to inet addresses and the reverse
local function inet_ntop(af, src)
  af = c.AF[af] -- TODO do not need, in fact could split into two functions if no need to export.
  if af == c.AF.INET then
    local b = pt.uchar(src)
    return b[0] .. "." .. b[1] .. "." .. b[2] .. "." .. b[3]
  end
  if af ~= c.AF.INET6 then return end
  local a = src.s6_addr
  local parts = {256*a[0] + a[1], 256*a[2] + a[3],   256*a[4] + a[5],   256*a[6] + a[7],
                 256*a[8] + a[9], 256*a[10] + a[11], 256*a[12] + a[13], 256*a[14] + a[15]}

  for i = 1, #parts do parts[i] = string.format("%x", parts[i]) end

  local start, max = 0, 0
  for i = 1, #parts do
    if parts[i] == "0" then
      local count = 0
      for j = i, #parts do
        if parts[j] == "0" then count = count + 1 else break end
      end
      if count > max then max, start = count, i end
    end
  end

  if max > 2 then
    parts[start] = ""
    if start == 1 or start + max == 9 then parts[start] = ":" end
    if start == 1 and start + max == 9 then parts[start] = "::" end 
    for i = 1, max - 1 do table.remove(parts, start + 1) end
  end

  return table.concat(parts, ":")
end

local function inet_pton(af, src, addr)
  af = c.AF[af]
  addr = addr or t.addrtype[af]()
  if af == c.AF.INET then
    local ip4 = split("%.", src)
    if #ip4 ~= 4 then return nil end
    addr = addr or t.in_addr()
    addr.s_addr = ip4[4] * 0x1000000 + ip4[3] * 0x10000 + ip4[2] * 0x100 + ip4[1]
    return addr
  end
-- TODO ipv6 implementation
  local ret = C.inet_pton(af, src, addr) -- TODO redo in pure Lua
  if ret == -1 then return nil, t.error() end
  if ret == 0 then return nil end -- maybe return string
  return addr
end

addtype("in_addr", "struct in_addr", {
  __tostring = function(a) return inet_ntop(c.AF.INET, a) end,
  __new = function(tp, s)
    local addr = ffi.new(tp)
    if s then
      if ffi.istype(tp, s) then
        addr.s_addr = s.s_addr
      else
        addr = inet_pton(c.AF.INET, s, addr)
        if not addr then return nil end
      end
    end
    return addr
  end,
  __len = lenfn,
})

addtype("in6_addr", "struct in6_addr", {
  __tostring = function(a) return inet_ntop(c.AF.INET6, a) end,
  __new = function(tp, s)
    local addr = ffi.new(tp)
    if s then addr = inet_pton(c.AF.INET6, s, addr) end
    return addr
  end,
  __len = lenfn,
})

t.addrtype = {
  [c.AF.INET] = t.in_addr,
  [c.AF.INET6] = t.in6_addr,
}

mt.iovecs = {
  __index = function(io, k)
    return io.iov[k - 1]
  end,
  __newindex = function(io, k, v)
    v = istype(t.iovec, v) or t.iovec(v)
    ffi.copy(io.iov[k - 1], v, s.iovec)
  end,
  __len = function(io) return io.count end,
  __new = function(tp, is)
    if type(is) == 'number' then return ffi.new(tp, is, is) end
    local count = #is
    local iov = ffi.new(tp, count, count)
    for n = 1, count do
      local i = is[n]
      if type(i) == 'string' then
        local buf = t.buffer(#i)
        ffi.copy(buf, i, #i)
        iov[n].iov_base = buf
        iov[n].iov_len = #i
      elseif type(i) == 'number' then
        iov[n].iov_base = t.buffer(i)
        iov[n].iov_len = i
      elseif ffi.istype(t.iovec, i) then
        ffi.copy(iov[n], i, s.iovec)
      elseif type(i) == 'cdata' then -- eg buffer or other structure
        iov[n].iov_base = i
        iov[n].iov_len = ffi.sizeof(i)
      else -- eg table
        iov[n] = i
      end
    end
    return iov
  end
}

addtype_var("iovecs", "struct { int count; struct iovec iov[?];}", mt.iovecs)

meth.sockaddr = {
  index = {
    family = function(sa) return sa.sa_family end,
  }
}

addtype("sockaddr", "struct sockaddr", {
  __index = function(sa, k) if meth.sockaddr.index[k] then return meth.sockaddr.index[k](sa) end end,
  __len = function(tp) return s.sockaddr end,
})

meth.sockaddr_storage = {
  index = {
    family = function(sa) return sa.ss_family end,
  },
  newindex = {
    family = function(sa, v) sa.ss_family = c.AF[v] end,
  }
}

-- cast socket address to actual type based on family, defined later
local samap_pt = {}

-- experiment, see if we can use this as generic type, to avoid allocations.
addtype("sockaddr_storage", "struct sockaddr_storage", {
  __index = function(sa, k)
    if meth.sockaddr_storage.index[k] then return meth.sockaddr_storage.index[k](sa) end
    local st = samap_pt[sa.ss_family]
    if st then
      local cs = st(sa)
      return cs[k]
    end
  end,
  __newindex = function(sa, k, v)
    if meth.sockaddr_storage.newindex[k] then
      meth.sockaddr_storage.newindex[k](sa, v)
      return
    end
    local st = samap_pt[sa.ss_family]
    if st then
      local cs = st(sa)
      cs[k] = v
    end
  end,
  __new = function(tp, init)
    local ss = ffi.new(tp)
    local family
    if init and init.family then family = c.AF[init.family] end
    local st
    if family then
      st = samap_pt[family]
      ss.ss_family = family
      init.family = nil
    end
    if st then
      local cs = st(ss)
      for k, v in pairs(init) do
        cs[k] = v
      end
    end
    return ss
  end,
  -- netbsd likes to see the correct size when it gets a sockaddr; Linux was ok with a longer one
  __len = function(sa)
    if samap_pt[sa.family] then
      local cs = samap_pt[sa.family](sa)
      return #cs
    else
      return s.sockaddr_storage
    end
  end,
})

meth.sockaddr_in = {
  index = {
    family = function(sa) return sa.sin_family end,
    port = function(sa) return ntohs(sa.sin_port) end,
    addr = function(sa) return sa.sin_addr end,
  },
  newindex = {
    family = function(sa, v) sa.sin_family = v end,
    port = function(sa, v) sa.sin_port = htons(v) end,
    addr = function(sa, v) sa.sin_addr = v end,
  }
}

addtype("sockaddr_in", "struct sockaddr_in", {
  __index = function(sa, k) if meth.sockaddr_in.index[k] then return meth.sockaddr_in.index[k](sa) end end,
  __newindex = function(sa, k, v) if meth.sockaddr_in.newindex[k] then meth.sockaddr_in.newindex[k](sa, v) end end,
  __new = function(tp, port, addr)
    local tab
    if type(port) == "table" then
      tab = port
    else
      tab = {family = c.AF.INET, port = port, addr = addr}
    end
    tab.addr = mktype(t.in_addr, tab.addr)
    if not tab.addr then return nil end
    return newfn(tp, tab)
  end,
  __len = function(tp) return s.sockaddr_in end,
})

meth.sockaddr_in6 = {
  index = {
    family = function(sa) return sa.sin6_family end,
    port = function(sa) return ntohs(sa.sin6_port) end,
    addr = function(sa) return sa.sin6_addr end,
  },
  newindex = {
    family = function(sa, v) sa.sin6_family = v end,
    port = function(sa, v) sa.sin6_port = htons(v) end,
    addr = function(sa, v) sa.sin6_addr = v end,
    flowinfo = function(sa, v) sa.sin6_flowinfo = v end,
    scope_id = function(sa, v) sa.sin6_scope_id = v end,
  }
}

addtype("sockaddr_in6", "struct sockaddr_in6", {
  __index = function(sa, k) if meth.sockaddr_in6.index[k] then return meth.sockaddr_in6.index[k](sa) end end,
  __newindex = function(sa, k, v) if meth.sockaddr_in6.newindex[k] then meth.sockaddr_in6.newindex[k](sa, v) end end,
  __new = function(tp, port, addr, flowinfo, scope_id) -- reordered initialisers.
    local tab
    if type(port) == "table" then
      tab = port
    else
      tab = {family = c.AF.INET6, port = port, addr = addr, flowinfo = flowinfo, scope_id = scope_id}
    end
    tab.addr = mktype(t.in6_addr, tab.addr)
    if not tab.addr then return nil end
    return newfn(tp, tab)
  end,
  __len = function(tp) return s.sockaddr_in6 end,
})

meth.timespec = {
  index = {
    time = function(tv) return tonumber(tv.tv_sec) + tonumber(tv.tv_nsec) / 1000000000 end,
    sec = function(tv) return tonumber(tv.tv_sec) end,
    nsec = function(tv) return tonumber(tv.tv_nsec) end,
  },
  newindex = {
    time = function(tv, v)
      local i, f = math.modf(v)
      tv.tv_sec, tv.tv_nsec = i, math.floor(f * 1000000000)
    end,
    sec = function(tv, v) tv.tv_sec = v end,
    nsec = function(tv, v) tv.tv_nsec = v end,
  }
}

addtype("timespec", "struct timespec", {
  __index = function(tv, k) if meth.timespec.index[k] then return meth.timespec.index[k](tv) end end,
  __newindex = function(tv, k, v) if meth.timespec.newindex[k] then meth.timespec.newindex[k](tv, v) end end,
  __new = function(tp, v)
    if not v then v = {0, 0} end
    if type(v) ~= "number" then return ffi.new(tp, v) end
    local ts = ffi.new(tp)
    ts.time = v
    return ts
  end,
  __len = lenfn,
})

addtype_var("groups", "struct {int count; gid_t list[?];}", {
  __index = function(g, k)
    return g.list[k - 1]
  end,
  __newindex = function(g, k, v)
    g.list[k - 1] = v
  end,
  __new = function(tp, gs)
    if type(gs) == 'number' then return ffi.new(tp, gs, gs) end
    return ffi.new(tp, #gs, #gs, gs)
  end,
  __len = function(g) return g.count end,
})

-- signal set handlers TODO replace with metatypes
local function sigismember(set, sig)
  local d = bit.rshift(sig - 1, 5) -- always 32 bits
  return bit.band(set.val[d], bit.lshift(1, (sig - 1) % 32)) ~= 0
end

local function sigemptyset(set)
  for i = 0, s.sigset / 4 - 1 do
    if set.val[i] ~= 0 then return false end
  end
  return true
end

local function sigaddset(set, sig)
  set = t.sigset(set)
  local d = bit.rshift(sig - 1, 5)
  set.val[d] = bit.bor(set.val[d], bit.lshift(1, (sig - 1) % 32))
  return set
end

local function sigdelset(set, sig)
  set = t.sigset(set)
  local d = bit.rshift(sig - 1, 5)
  set.val[d] = bit.band(set.val[d], bit.bnot(bit.lshift(1, (sig - 1) % 32)))
  return set
end

local function sigaddsets(set, sigs) -- allow multiple
  if type(sigs) ~= "string" then return sigaddset(set, sigs) end
  set = t.sigset(set)
  local a = split(",", sigs)
  for i, v in ipairs(a) do
    local s = trim(v)
    local sig = c.SIG[s]
    if not sig then error("invalid signal: " .. v) end -- don't use this format if you don't want exceptions, better than silent ignore
    sigaddset(set, sig)
  end
  return set
end

local function sigdelsets(set, sigs) -- allow multiple
  if type(sigs) ~= "string" then return sigdelset(set, sigs) end
  set = t.sigset(set)
  local a = split(",", sigs)
  for i, v in ipairs(a) do
    local s = trim(v)
    local sig = c.SIG[s]
    if not sig then error("invalid signal: " .. v) end -- don't use this format if you don't want exceptions, better than silent ignore
    sigdelset(set, sig)
  end
  return set
end

addtype("sigset", "sigset_t", {
  __index = function(set, k)
    if k == 'add' then return sigaddsets end
    if k == 'del' then return sigdelsets end
    if k == 'isemptyset' then return sigemptyset(set) end
    local sig = c.SIG[k]
    if sig then return sigismember(set, sig) end
  end,
  __new = function(tp, str)
    if ffi.istype(tp, str) then return str end
    if not str then return ffi.new(tp) end
    local f = ffi.new(tp)
    local a = split(",", str)
    for i, v in ipairs(a) do
      local st = trim(v)
      local sig = c.SIG[st]
      if not sig then error("invalid signal: " .. v) end -- don't use this format if you don't want exceptions, better than silent ignore
      local d = bit.rshift(sig - 1, 5) -- always 32 bits
      f.val[d] = bit.bor(f.val[d], bit.lshift(1, (sig - 1) % 32))
    end
    return f
  end,
  __len = lenfn,
})

-- sigaction
t.sa_sigaction = ffi.typeof("void (*)(int, siginfo_t *, void *)")
s.sa_sigaction = ffi.sizeof(t.sa_sigaction)

meth.sigaction = {
  index = {
    handler = function(sa) return sa.sa_handler end,
    sigaction = function(sa) return sa.sa_sigaction end,
    mask = function(sa) return sa.sa_mask end,
    flags = function(sa) return tonumber(sa.sa_flags) end,
  },
  newindex = {
    handler = function(sa, v)
      if type(v) == "string" then v = pt.void(c.SIGACT[v]) end
      if type(v) == "number" then v = pt.void(v) end
      if type(v) == "function" then v = ffi.cast(t.sighandler, v) end -- note doing this will leak resource, use carefully
      sa.sa_handler.sa_handler = v
    end,
    sigaction = function(sa, v)
      if type(v) == "string" then v = pt.void(c.SIGACT[v]) end
      if type(v) == "number" then v = pt.void(v) end
      if type(v) == "function" then v = ffi.cast(t.sa_sigaction, v) end -- note doing this will leak resource, use carefully
      sa.sa_handler.sa_sigaction = v
    end,
    mask = function(sa, v)
      if not ffi.istype(t.sigset, v) then v = t.sigset(v) end
      sa.sa_mask = v
    end,
    flags = function(sa, v) sa.sa_flags = c.SA[v] end,
  },
}

mt.sigaction = {
  __index = function(sa, k) if meth.sigaction.index[k] then return meth.sigaction.index[k](sa) end end,
  __newindex = function(sa, k, v) if meth.sigaction.newindex[k] then meth.sigaction.newindex[k](sa, v) end end,
  __new = function(tp, tab)
    local sa = ffi.new(tp)
    if tab then for k, v in pairs(tab) do sa[k] = v end end
    if tab and tab.sigaction then sa.sa_flags = bit.bor(sa.flags, c.SA.SIGINFO) end -- this flag must be set if sigaction set
    return sa
  end,
  __len = lenfn,
}

addtype("sigaction", "struct sigaction", mt.sigaction)

-- include OS specific types
local hh = {ptt = ptt, addtype = addtype, addtype_var = addtype_var, lenfn = lenfn, lenmt = lenmt, newfn = newfn, istype = istype}

types = require("syscall." .. abi.os .. ".types")(types, hh)

-- this is declared above
samap_pt = {
  [c.AF.UNIX] = pt.sockaddr_un,
  [c.AF.INET] = pt.sockaddr_in,
  [c.AF.INET6] = pt.sockaddr_in6,
}
if c.AF.NETLINK then samap_pt[c.AF.NETLINK] = pt.sockaddr_nl end

if c.AF.PACKET then samap_pt[c.AF.PACKET] = pt.sockaddr_ll end

return types

end

return {init = init}
