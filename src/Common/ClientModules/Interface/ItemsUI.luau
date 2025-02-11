local ItemsUI = {}

type OutfitData = {
    RARITY: string?,
    Items: {[string]: {
        BODY_PART: string,
        OFFSET: CFrame?,
        ROTATION: CFrame?
    }}
}

local Players = game:GetService("Players")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonClient = ReplicatedStorage:WaitForChild("Common")
local Outfits = require(CommonClient.Assets.Settings.CharacterCustomizer.Outfits)
local OutfitsWearing = CommonClient.Assets.Outfits
local RarityColors = require(CommonClient.Assets.Settings.CharacterCustomizer.Rarities)

local RARITY_COLORS: {[string]: Color3} = RarityColors

local function setupPreviewDummy(viewportFrame: ViewportFrame, previewDummy: Model): ()
    if not viewportFrame or not previewDummy then return end
    
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = viewportFrame
    
    local dummy = previewDummy:Clone()
    dummy.Parent = worldModel
    
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(4, 1, 4)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.CFrame = CFrame.new()
    platform.Parent = worldModel
    
    dummy:PivotTo(CFrame.new(0, platform.Size.Y/4, 0) * CFrame.Angles(0, math.rad(-90), 0))
    
    local camera = Instance.new("Camera")
    camera.FieldOfView = 15
    viewportFrame.CurrentCamera = camera
    
    local _, size = dummy:GetBoundingBox()
    local maxSize = math.max(size.X, size.Y, size.Z)
    camera.CFrame = CFrame.new(Vector3.new(0, 0, maxSize * 3.0), Vector3.new(0, 2.5, 0))
    
    local humanoid = dummy:WaitForChild("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        humanoid.AutoRotate = false
    end
end

local function createOutfitItem(template: Frame, outfitId: number, outfitData: OutfitData): Frame?
    if not template or not outfitId or not outfitData then return nil end
    
    local newItem = template:Clone()
    newItem.Name = tostring(outfitId)
    
    local viewportFrame = newItem.Frame.ViewportFrame
    local outfitFolder = OutfitsWearing:FindFirstChild(tostring(outfitId))
    if outfitFolder then
        local previewDummy = outfitFolder:FindFirstChild("PreviewDummy"):FindFirstChild("PreviewDummy")
        if previewDummy then
            setupPreviewDummy(viewportFrame, previewDummy)
        end
    end
    
    local rarity = outfitData.RARITY or "COMMON"
    newItem.BackgroundColor3 = RARITY_COLORS[rarity]
    
    local equipButton = newItem
    if equipButton then
        equipButton.MouseButton1Click:Connect(function()
            local outfitFolder = OutfitsWearing:FindFirstChild(tostring(outfitId))
            if not outfitFolder then return end
            
            local itemsFolder = outfitFolder:FindFirstChild("Items")
            local character = Players.LocalPlayer.Character
            if not (itemsFolder and character) then return end
            
            local existingOutfit = character:FindFirstChild("Outfit")
            if existingOutfit then
                existingOutfit:Destroy()
            end
            
            local newOutfitFolder = Instance.new("Folder")
            newOutfitFolder.Name = "Outfit"
            newOutfitFolder.Parent = character
            
            for itemName, itemData in outfitData.Items do
                local item = itemsFolder:FindFirstChild(itemName)
                if not item then continue end
                
                local clone = item:Clone()
                clone.Name = itemName
                
                if clone:IsA("MeshPart") or clone:IsA("Part") then
                    clone.Anchored = false
                    clone.CanCollide = false
                    clone.CanTouch = false
                    clone.CanQuery = false
                end
                
                for _, part in clone:GetDescendants() do
                    if part:IsA("MeshPart") or part:IsA("Part") then
                        part.Anchored = false
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                    end
                end
                
                local bodyPart = character:FindFirstChild(itemData.BODY_PART)
                if not bodyPart then continue end
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = bodyPart
                weld.Part1 = clone:IsA("Model") and clone.PrimaryPart or clone
                weld.Parent = clone
                
                clone.CFrame = bodyPart.CFrame * 
                    (itemData.OFFSET or CFrame.new()) * 
                    (itemData.ROTATION or CFrame.new())
                clone.Parent = newOutfitFolder
            end
        end)
    end
    
    return newItem
end

function ItemsUI.Init(): ()
    local player = Players.LocalPlayer
    if not player then return end
    
    local playerGui = player:WaitForChild("PlayerGui")
    local Canvas = playerGui:WaitForChild("Main").Canvas
    local InventoryFrame = Canvas.InventoryFrame
    local ItemsFrame = InventoryFrame.B_Frame.ItemsFrame
    local ListFrame = ItemsFrame.ListFrame
    local ScrollingFrame = ListFrame.C_ItemsFrame.ScrollingFrame
    local ItemTemplate = ScrollingFrame.A_TemplateItem
    
    ItemTemplate.Visible = false
    
    for outfitId, outfitData in Outfits do
        local newItem = createOutfitItem(ItemTemplate, outfitId, outfitData)
        if newItem then
            newItem.Parent = ScrollingFrame
            newItem.Visible = true
        end
    end
end

local function CreateBasicOutfit(rarity: string, name: string)
    return {
        Items = {
            ["Hat"] = {
                OFFSET = CFrame.new(0, 0.25, 0.1),
                ROTATION = CFrame.Angles(0, 0, 0),
                BODY_PART = "Head"
            },
            ["ShirtLowerTorso"] = {
                OFFSET = CFrame.new(),
                ROTATION = CFrame.Angles(0, math.rad(90), 0),
                BODY_PART = "LowerTorso"
            },
            ["ShirtUpperTorso"] = {
                OFFSET = CFrame.new(),
                ROTATION = CFrame.Angles(0, math.rad(90), 0),
                BODY_PART = "UpperTorso"
            },
            ["ShortLeft"] = {
                OFFSET = CFrame.new(0, -0.079, 0),
                ROTATION = CFrame.new(),
                BODY_PART = "LeftUpperLeg"
            },
            ["ShortRight"] = {
                OFFSET = CFrame.new(0, -0.079, 0),
                ROTATION = CFrame.new(),
                BODY_PART = "RightUpperLeg"
            },
            ["UnderUpperTorso"] = {
                OFFSET = CFrame.new(0, 0.5, -0.45),
                ROTATION = CFrame.Angles(0, math.rad(90), 0),
                BODY_PART = "UpperTorso"
            }
        },
        RARITY = rarity,
        NAME = name
    }
end

local function CreateArmorOutfit(rarity: string, name: string)
    return {
        Items = {
            ["Cape"] = {
                OFFSET = CFrame.new(0, -0.869, 0.585),
                ROTATION = CFrame.Angles(0, math.rad(-90), 0),
                BODY_PART = "UpperTorso"
            },
            -- ... other armor pieces
        },
        RARITY = rarity,
        NAME = name
    }
end

-- Create outfits using templates
local Outfits = {
    [1] = CreateBasicOutfit("COMMON", "Basic Outfit 1"),
    [2] = CreateBasicOutfit("COMMON", "Basic Outfit 2"),
    [3] = CreateArmorOutfit("DIVINE", "Divine Armor Set"),
    -- ... etc
}

return ItemsUI