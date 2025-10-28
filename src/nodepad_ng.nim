# nodepad_ng.nim

import cligen, chronicles

import config/settings

proc runNodePad(bind_on: string, connect_to: string, ) =
  notice("Configuration loaded!", logLevel = Config.logLevel)
  info("NodePad bind", bindOn = bind_on)
  info("NodePad upstream", connectTo = connect_to)
  info("Mongo", mongo = reveal(Config.mongoUrl))

when isMainModule:
  cligen.dispatch(runNodePad)
