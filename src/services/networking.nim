import asyncdispatch, net, asynchttpserver, ws
import chronicles

proc wsCallback(req: Request) {.async, gcsafe.} =
    # Scope peer list within callback to avoid gcsafe issues
    var connections = newSeq[WebSocket]()
    if req.url.path == "/sync":
        info("DBG", dbg = req)
        try:
            var ws = await newWebSocket(req)
            connections.add ws

            while ws.readyState == Open:
                let packet = await ws.receiveStrPacket()

                info("WS string packet", wsStringPacket = packet)

                # Flooding + split horizon logic
                for peer in connections:
                    if peer != ws and peer.readyState == Open:
                        asyncCheck peer.send(packet)
        except WebSocketError, IOError:
            warn("Socket closed!")
        except Exception as e:
            error("Unknown wsCallback error: ", errMsg = e.msg)
        # finally:
        #     if ws != nil and connections.contains(ws):
        #         let idx = connections.find(ws)
        #         if idx > -1:
        #             connections.delete(idx)
        #             info("Peer removed!", peerCount = connections.len)
    else:
        await req.respond(Http404, "NodePad route does not exist!")
        warn("Unimplemented route accessed!", errRoute = req.url.path)

proc startServer*(bindHost: string, bindPort: Port) {.async.} =
    let server = newAsyncHttpServer()

    info("Starting WS server....", bindHost = bindHost, bindPort = bindPort)

    await server.serve(bindPort, wsCallback, bindHost)
