# nodepad_ng.nim

import cligen, chronicles, asyncdispatch, ws, asynchttpserver
import std/net

import config/settings
import services/networking
import utils/ip_checks

var die = false

proc handleSigInt() {.noconv.} =
  stdout.write("\r\x1b[K")
  info("Shutting down gracefully (SIGINT)...")
  die = true

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

  var state = await startServer(bindHost, bindPort)

  # Steady-state loop
  while not die:
    await sleepAsync(1000)

  info("Sending close frames...")

  for peer in state.connections:
    if peer.readyState == Open:
      try:
        peer.close()
      except:
        # Ignore errors (socket may already be closed)
        info("Exception during peer.close() (can be ignored).")

  # Give the async loop time to send the packets
  await sleepAsync(100)

  state.server.close() # This is synchronous

  try:
    await state.future
  except OSError as e:
    if "Bad file descriptor" in e.msg:
      info("Server task shut down cleanly!")
    else:
      # This was a *different* OS error, which is bad
      raise e # Re-raise the unexpected error

  notice("Main routine ended!")

proc mainWrapper(bind_on: string, connect_to: string = "") =
  waitFor runNodePad(bind_on, connect_to)

when isMainModule:
  cligen.dispatch(mainWrapper)
