# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/logging, strformat
import cligen

# setup logging
const LOG_FILE = "nodepad_erros.log"
if not defined(release):
  let consoleLogger = newConsoleLogger(
    levelThreshold = lvlDebug,
    fmtStr = "$levelid $date|$time - $appname: "
    )
  let fileLogger = newFileLogger(
    filename = LOG_FILE,
    levelThreshold = lvlDebug,
    fmtStr = "$levelid $date|$time - $appname: "
    )
  addHandler(consoleLogger)
  addHandler(fileLogger)
else:
  let consoleLogger = newConsoleLogger(
    levelThreshold = lvlInfo,
    fmtStr = "$levelid $date|$time - $appname: "
    )
  let fileLogger = newFileLogger(
    filename = LOG_FILE,
    levelThreshold = lvlError,
    fmtStr = "$levelid $date|$time - $appname: "
    )
  addHandler(consoleLogger)
  addHandler(fileLogger)

proc runNodePad(bind_on: string, connect_to: int) = 
  info(fmt"NodePad is listening on: {bind_on}")
  info(fmt"NodePad connects to    : {connect_to}")

when isMainModule:
  # cligen.dispatch calls the 'runNodePad' proc using command-line arguments.
  cligen.dispatch(runNodePad)