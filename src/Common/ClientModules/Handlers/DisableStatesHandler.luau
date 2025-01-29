local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateHandler = {}

local blacklistedStates = {
    "Ragdoll",
    "FallingDown", 
    "StrafingNoPhysics",
    "Swimming",
    "Seated",
    "Physics",
    "GettingUp",
}

local function onCharacterAdded(character: Model)
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    
    humanoid.RequiresNeck = false
    humanoid.BreakJointsOnDeath = false
    
    for _, stateName in ipairs(blacklistedStates) do
        humanoid:SetStateEnabled(Enum.HumanoidStateType[stateName], false)
    end
    
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                handle.CanCollide = false
                handle.Massless = true
            end
        end
    end
end

function StateHandler.init()
    local player = Players.LocalPlayer
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    return function()
        -- Cleanup function
    end
end

return StateHandler
