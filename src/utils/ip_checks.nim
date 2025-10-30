import std/[net, strutils, strformat]

proc validateIpv4Addr*(address: string): (string, Port) =
    # Blank string check
    if address.len == 0:
        raise newException(ValueError, fmt"Address string cannot be empty! {address}")

    # Structure validation
    let parts = address.split(":")
    if parts.len != 2:
        raise newException(ValueError, "Invalid address format!, Must be host:port")

    let host = parts[0]
    let portStr = parts[1]

    # Port validation
    try:
        let port = parseInt(portStr)

        if port < 1 or port > 65_535:
            raise newException(ValueError,
                    fmt"Port number out of range (1-65535): {port}")

        (host, Port(port))
    except ValueError as e:
        raise newException(ValueError, fmt"Invalid port '{portStr}': {e.msg}")
