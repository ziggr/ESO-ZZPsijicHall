local ZZPsijicHall = _G["ZZPsijicHall"]
ZZPsijicHall.Log = {}
local Log = ZZPsijicHall.Log

function Log.Logger()
    if not Log.logger then
        Log.logger = LibDebugLogger.Create(ZZPsijicHall.name)
    end
    return Log.logger
end

function Log.LogOne(color, ...)
    if Log.log_to_chat then
        d("|c"..color..Log.name..": "..string.format(...).."|r")
    end
end

function Log.LogOneWarnError(color, ...)
    if Log.log_to_chat or Log.log_to_chat_warn_error then
        d("|c"..color..Log.name..": "..string.format(...).."|r")
    end
end

function Log.Debug(...)
    Log.LogOne("666666",...)
    Log.Logger():Debug(...)
end

function Log.Info(...)
    Log.LogOne("999999",...)
    Log.Logger():Info(...)
end

function Log.Warn(...)
    Log.LogOneWarnError("FF8800",...)
    Log.Logger():Warn(...)
end

function Log.Error(...)
    Log.LogOneWarnError("FF6666",...)
    Log.Logger():Error(...)
end
