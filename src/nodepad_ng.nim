# nodepad_ng.nim

import cligen, chronicles, asyncdispatch
import std/net

import config/settings
import services/networking
import utils/ip_checks

proc handleSigInt() {.noconv.} =
  stdout.write("\r\x1b[K")
  info("Shutting down gracefully (SIGINT)...")
  quit(0)

when defined(posix):
  setControlCHook(handleSigInt)

proc runNodePad(bind_on: string, connect_to: string) {.async.} =
  notice("Configuration loaded...", logLevel = Config.logLevel)

  var bindHost: string
  var bindPort: Port

  # Validate or die!
  try:
    (bindHost, bindPort) = validateIpv4Addr(bind_on)
  except ValueError as e:
    fatal("The supplied IPs are invalid!", errMsg = e.msg)
    quit(1)

  info("NodePad upstream", connectTo = connect_to)
  info("Mongo", mongo = reveal(Config.mongoUrl)) # just for testing

  asyncCheck startServer(bindHost, bindPort)

  # Steady-state loop
  while true:
    await sleepAsync(1000)

proc mainWrapper(bind_on: string, connect_to: string = "") =
  waitFor runNodePad(bind_on, connect_to)

when isMainModule:
  cligen.dispatch(mainWrapper)
