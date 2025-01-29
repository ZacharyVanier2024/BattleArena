--!strict
type DummyHandler = {
    init: () -> (() -> ())
}

local DisableStatesDummiesHandler: DummyHandler = {}

local blacklistedStates: {string} = {
    "Ragdoll",
    "FallingDown", 
    "StrafingNoPhysics",
    "Swimming",
    "Seated",
    "Physics",
    "GettingUp",
}

local function setupDummy(dummy: Model): ()
    if not dummy then return end
    
    local humanoid = dummy:WaitForChild("Humanoid") :: Humanoid
    if not humanoid then return end
    
    humanoid.RequiresNeck = false
    humanoid.BreakJointsOnDeath = false
    
    for _, stateName in ipairs(blacklistedStates) do
        humanoid:SetStateEnabled(Enum.HumanoidStateType[stateName], false)
    end
    
    for _, accessory in ipairs(dummy:GetChildren()) do
        if not accessory:IsA("Accessory") then continue end
        
        local handle = accessory:FindFirstChild("Handle")
        if not handle then continue end
        
        handle.CanCollide = false
        handle.Massless = true
    end
end

function DisableStatesDummiesHandler.init(): () -> ()
    local world = workspace:WaitForChild("World")
    if not world then 
        return function() end 
    end
    
    local living = world:WaitForChild("Living") 
    if not living then 
        return function() end 
    end
    
    local npcs = living:WaitForChild("NPCs")
    if not npcs then 
        return function() end 
    end

    for _, dummy in ipairs(npcs:GetChildren()) do
        if dummy:IsA("Model") then
            setupDummy(dummy)
        end
    end

    npcs.ChildAdded:Connect(function(dummy: Instance)
        if dummy:IsA("Model") then
            setupDummy(dummy)
        end
    end)

    return function() end
end

return DisableStatesDummiesHandler