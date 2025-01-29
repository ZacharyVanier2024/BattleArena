local Players = game:GetService("Players")

type NetworkOwnershipModule = {
    setOwnership: (target: Model, attacker: Player, shouldFaceAttacker: boolean?) -> (),
    resetOwnership: (target: Model) -> (),
    isPlayerCharacter: (target: Model) -> boolean
}

local NetworkOwnership: NetworkOwnershipModule = {}

function NetworkOwnership.setOwnership(target: Model, attacker: Player, shouldFaceAttacker: boolean?)
    assert(typeof(target) == "Instance" and target:IsA("Model"), "target must be a Model")
    assert(typeof(attacker) == "Instance" and attacker:IsA("Player"), "attacker must be a Player")
    if shouldFaceAttacker ~= nil then
        assert(typeof(shouldFaceAttacker) == "boolean", "shouldFaceAttacker must be a boolean")
    end
    
    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart or not rootPart:IsA("BasePart") then return end
    
    rootPart:SetNetworkOwner(attacker)
end

function NetworkOwnership.resetOwnership(target: Model)
    assert(typeof(target) == "Instance" and target:IsA("Model"), "target must be a Model")
    
    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart or not rootPart:IsA("BasePart") then return end
    
    rootPart:SetNetworkOwner(nil)
end

function NetworkOwnership.isPlayerCharacter(target: Model): boolean
    assert(typeof(target) == "Instance" and target:IsA("Model"), "target must be a Model")
    
    return Players:GetPlayerFromCharacter(target) ~= nil
end

return NetworkOwnership