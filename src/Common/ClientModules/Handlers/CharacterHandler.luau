local Players = game:GetService("Players")
local Trove = require(script.Parent.Parent.OS.Trove)

export type CharacterData = {
    character: Model,
    humanoid: Humanoid,
    rootPart: BasePart,
}

export type CharacterHandler = {
    onCharacterAdded: (callback: (data: CharacterData) -> ()) -> (),
    getCurrentCharacter: () -> CharacterData?,
    init: () -> (() -> ()),
}

local CharacterHandler = {}
CharacterHandler.__index = CharacterHandler

local player = Players.LocalPlayer
local currentCharacter: CharacterData?
local callbacks: {(data: CharacterData) -> ()} = {}
local trove = Trove.new()

local function handleCharacter(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    local rootPart = char:WaitForChild("HumanoidRootPart")

    currentCharacter = {
        character = char,
        humanoid = humanoid,
        rootPart = rootPart,
    }

    for _, callback in callbacks do
        task.spawn(callback, currentCharacter)
    end
end

function CharacterHandler.onCharacterAdded(callback: (data: CharacterData) -> ())
    table.insert(callbacks, callback)
    if currentCharacter then
        task.spawn(callback, currentCharacter)
    end
end

function CharacterHandler.getCurrentCharacter(): CharacterData?
    return currentCharacter
end

function CharacterHandler.init(): (() -> ())
    if player.Character then
        handleCharacter(player.Character)
    end

    local connection = player.CharacterAdded:Connect(handleCharacter)
    trove:Add(connection)

    return function()
        trove:Destroy()
        currentCharacter = nil
        table.clear(callbacks)
    end
end

return CharacterHandler