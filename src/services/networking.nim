import asyncdispatch, net, asynchttpserver
import chronicles
import std/strutils

proc wsCallback(req: Request) {.async, gcSafe.} =
    if req.url.path == "/sync":
        notice("Recived sync request!")
    else:
        await req.respond(Http404, "NodePad route does not exist!")
        warn("Unimplemented route accessed!", errRoute = req.url.path)

proc startServer*(bindAddr: string) {.async.} =
    let parts = bindAddr.split(":", 1)
    if parts.len != 2:
        error("Invalid bind address format!", errBindAddr = bindAddr)
        return

    let host = parts[0]
    let port = Port(parseInt(parts[1]))

    let server = newAsyncHttpServer()

    info("Starting WS server!", bindOn = bindAddr)

    await server.serve(port, wsCallback, host)
