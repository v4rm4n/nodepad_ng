# nodepad_ng.nim

import cligen, chronicles, asyncdispatch

import config/settings
import services/networking

proc runNodePad(bind_on: string, connect_to: string, ) {.async.} =
  notice("Configuration loaded!", logLevel = Config.logLevel)
  info("NodePad bind", bindOn = bind_on)
  info("NodePad upstream", connectTo = connect_to)
  info("Mongo", mongo = reveal(Config.mongoUrl)) # just for testing

  asyncCheck startServer(bind_on)

  while true:
    # info("loop entered!")
    await sleepAsync(1000)

  fatal("loop exited!")

proc mainWrapper(bind_on: string, connect_to: string = "") =
  waitFor runNodePad(bind_on, connect_to)

when isMainModule:
  cligen.dispatch(mainWrapper)
