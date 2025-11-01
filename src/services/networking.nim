# services/networking.nim

import chronicles, asyncdispatch, net, asynchttpserver, ws

type ServerState* = ref object
  server*: AsyncHttpServer
  connections*: seq[WebSocket]
  future*: Future[void]

proc startServer*(bindHost: string, bindPort: Port): Future[
    ServerState] {.async.} =
  # Use a closure pattern for gcsafe

  var state = ServerState(
    server: newAsyncHttpServer(),
    connections: newSeq[WebSocket]()
  )

  proc wsCallback(req: Request) {.async, gcsafe.} =
    if req.url.path == "/sync":

      var ws: WebSocket = nil

      try:
        ws = await newWebSocket(req)
        # Update connections list
        state.connections.add ws
        info("Peer connected!", peerWs = ws, peerCount = state.connections.len)
        while ws.readyState == Open:
          let packet = await ws.receiveStrPacket()

          info("WS string packet", peerWs = ws, wsStringPacket = packet)

          # Flooding + split horizon logic
          for peer in state.connections:
            if peer != ws and peer.readyState == Open:
              asyncCheck peer.send(packet)
      except WebSocketError, IOError:
        warn("Socket closed!")
      except Exception as e:
        error("Unknown wsCallback error: ", errMsg = e.msg)
      finally:
        if (ws != nil) and (state.connections.contains(ws)):
          let idx = state.connections.find(ws)
          if idx > -1:
            state.connections.delete(idx)
            info("Peer disconnected!", peerWsKey = ws.key,
                peerCount = state.connections.len)
    else:
      await req.respond(Http404, "NodePad route does not exist!")
      warn("Unimplemented route accessed!", errRoute = req.url.path)

  info("Starting WS server....", bindHost = bindHost, bindPort = bindPort)

  state.future = state.server.serve(bindPort, wsCallback, bindHost)

  return state
