local Players = game:GetService("Players")
local AttributeTypes = require(script.Parent.Parent.Types.AttributeTypes)
local Trove = require(script.Parent.Parent.OS.Trove)

local AttributesHandler = {}
local trove = Trove.new()

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

trove:Connect(player.CharacterAdded, function(newCharacter)
    character = newCharacter
end)

function AttributesHandler.setAttribute(attributeName: string, value: any)
    if not character then return end
    character:SetAttribute(attributeName, value)
end

function AttributesHandler.getAttribute(attributeName: string): any
    if not character then return nil end
    return character:GetAttribute(attributeName)
end

return AttributesHandler