--types for NetBSD sysctl, incomplete at present

local require = require

local c = require "syscall.netbsd.constants"

return {
  [c.CTL.KERN] = {
    [c.KERN.OSTYPE]    = "string",
    [c.KERN.OSRELEASE] = "string",
    [c.KERN.OSREV]     = "int",
    [c.KERN.VERSION]   = "string",
    [c.KERN.MAXVNODES] = "int",
    [c.KERN.MAXPROC]   = "int",
    [c.KERN.MAXFILES]  = "int",
    [c.KERN.ARGMAX]    = "int",
    [c.KERN.SECURELVL] = "int",
    [c.KERN.HOSTNAME]  = "string",
    [c.KERN.HOSTID]    = "int",
-- some missing
    [c.KERN.DOMAINNAME] = "string",
    [c.KERN.RAWPARTITION] = "int",
  }
}
