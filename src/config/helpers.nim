# config/helpers.nim

import os, strutils, chronicles

proc getLogLevel*(levelStr: string): LogLevel =
    try:
        return parseEnum[LogLevel](levelStr)
    except ValueError:
        return INFO

proc getEnvOrDefault*(key, default: string): string =
    let val = getEnv(key, "")
    if val.len > 0: val else: default
