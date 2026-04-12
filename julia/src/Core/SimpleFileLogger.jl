using Logging
using Dates
using Printf

struct SimpleFileLogger <: AbstractLogger
    io::IO
    minlevel::LogLevel
end

SimpleFileLogger(io::IO; minlevel=Logging.Debug) = SimpleFileLogger(io, minlevel)

Logging.min_enabled_level(logger::SimpleFileLogger) = logger.minlevel

Logging.shouldlog(logger::SimpleFileLogger, level, _module, group, id) =
    level ≥ logger.minlevel

function Logging.handle_message(logger::SimpleFileLogger,
    level, message, _module, group, id, file, line; kwargs...)

    ts = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")

    println(logger.io,
        @sprintf(
            "%s | %-5s | %-20s | %-15s:%-4d | %s",
            ts,
            string(level),
            string(_module),
            basename(string(file)),
            line,
            message
        )
    )

    flush(logger.io)
end