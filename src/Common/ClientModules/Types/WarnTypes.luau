local WarnTypes = {}
WarnTypes.__index = WarnTypes

function WarnTypes.new()
    local self = setmetatable({}, WarnTypes)
    self.warnTypes = {
        missingAnimationId = "⚠️ Missing animation ID.",
        incorrectAnimationId = "❌ Wrong animation ID or you did not spoof your animation.",
        unknownWarningType = "❓ Unknown warning type: ",
        missingHumanoid = "⚠️ Missing humanoid.",
        invalidAnimationTrack = "❌ Invalid animation track.",
        missingSoundId = "⚠️ Missing sound ID.",
        missingParent = "⚠️ Missing parent instance.",
        invalidSound = "❌ Invalid sound instance.",
    }
    return self
end

function WarnTypes:addWarnType(typeName: string, message: string)
    self.warnTypes[typeName] = message
end

function WarnTypes:warn(typeName: string)
    local message = self.warnTypes[typeName]
    local source = debug.info(2, "s")
    if message then
        warn(message .. " [Source: " .. source .. "]")
    else
        warn(self.warnTypes.unknownWarningType .. typeName .. " [Source: " .. source .. "]")
    end
end

return WarnTypes