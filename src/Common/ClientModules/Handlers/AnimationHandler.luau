local Trove = require(script.Parent.Parent.OS.Trove)
local WarnTypes = require(script.Parent.Parent.Types.WarnTypes)

type AnimationHandler = {
    character: Model,
    animations: {AnimationTrack},
    humanoid: Humanoid,
    trove: Trove.Trove,
    new: (character: Model) -> AnimationHandler,
    loadAndPlayAnimation: (self: AnimationHandler, animationId: string, loop: boolean?, priority: Enum.AnimationPriority?, duration: number?, speed: number?) -> AnimationTrack?,
    stopAllAnimations: (self: AnimationHandler) -> (),
    destroy: (self: AnimationHandler) -> (),
    init: (self: AnimationHandler) -> boolean
}

local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler

function AnimationHandler.new(character: Model): AnimationHandler
    local self = setmetatable({}, AnimationHandler)
    self.character = character
    self.animations = {}
    self.humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid
    self.trove = Trove.new()
    return self
end

function AnimationHandler:loadAndPlayAnimation(animationId: string, loop: boolean?, priority: Enum.AnimationPriority?, duration: number?, speed: number?): AnimationTrack?
    local warnTypes = WarnTypes.new()

    if not self.humanoid then
        warnTypes:warn("missingHumanoid")
        return nil
    end

    if not animationId or animationId == "" then
        warnTypes:warn("missingAnimationId")
        return nil
    end

    local success, animationTrack = pcall(function()
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        return self.humanoid:LoadAnimation(animation)
    end)

    if not success or not animationTrack then
        warnTypes:warn("incorrectAnimationId")
        return nil
    end

    animationTrack.Looped = loop or false
    if priority then
        animationTrack.Priority = priority
    end
    animationTrack:Play()
    
    if speed then
        animationTrack:AdjustSpeed(speed)
    end
    
    if duration then
        task.delay(duration, function()
            if animationTrack.IsPlaying then
                animationTrack:Stop()
            end
        end)
    end
    
    self.trove:Add(animationTrack)
    table.insert(self.animations, animationTrack)

    return animationTrack
end

function AnimationHandler:stopAllAnimations(): ()
    for _, animationTrack in ipairs(self.animations) do
        animationTrack:Stop()
    end
end

function AnimationHandler:destroy(): ()
    self:stopAllAnimations()
    self.trove:Clean()
    self.animations = {}
end

return AnimationHandler