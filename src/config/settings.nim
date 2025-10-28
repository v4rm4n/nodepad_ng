# config/settings.nim

import std/strformat
import os, chronicles
import helpers

const APP_PREFIX = "NODEPAD_"

# Types for sensitive fields
type
    RedactedString* = distinct string

# Masked string representation when converted or logged
proc `$`*(r: RedactedString): string =
    if r.string.len > 0:
        return "[REDACTED]"
    else:
        return "[EMPTY]"

# Allow safe access (explicit)
proc reveal*(r: RedactedString): string {.inline.} =
    ## Only use this if you *really* need the actual value.
    r.string

# Global app configuration
type
    AppConfig = object
        logLevel*: LogLevel
        mongoUrl*: RedactedString

let Config*: AppConfig = AppConfig(
    logLevel: getLogLevel(levelStr = getEnv(fmt"{APP_PREFIX}LOG_LEVEL")),
    mongoUrl: RedactedString(getEnvOrDefault(fmt"{APP_PREFIX}MONGO_URL",
            "localhost:27017"))
)
