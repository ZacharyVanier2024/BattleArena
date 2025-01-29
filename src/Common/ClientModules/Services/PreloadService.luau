local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Common = ReplicatedStorage:WaitForChild("Common")
local Assets = Common.Assets

local Trove = require(Common.ClientModules.OS.Trove)

export type PreloadService = {
    Init: () -> (() -> ()),
}

local PreloadService = {}

function PreloadService.Init(): (() -> ())
    local trove = Trove.new()
    local assetsToPreload = {}
    
    local function searchForAssets(folder: Instance)
        for _, item in folder:GetChildren() do
            if item:IsA("Animation") or item:IsA("Sound") then
                table.insert(assetsToPreload, item)
            elseif item:IsA("Folder") then
                searchForAssets(item)
            end
        end
    end
    
    searchForAssets(Assets)
    
    ContentProvider:PreloadAsync(assetsToPreload)
    
    return trove:WrapClean()
end

return PreloadService