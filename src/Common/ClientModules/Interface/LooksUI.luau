--!strict

type ViewportSetup = {
    viewportFrame: ViewportFrame,
    character: Model,
    camera: Camera,
    connection: RBXScriptConnection?
}

type UpdateFunction = (viewportFrame: ViewportFrame, direction: number) -> string

local LooksUI = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonClient = ReplicatedStorage:WaitForChild("Common")
local Assets = CommonClient.Assets
local Settings = Assets.Settings
local CharacterCustomizer = Settings.CharacterCustomizer
local ClientModules = CommonClient.ClientModules
local Interface = ClientModules.Interface
local UITweens = require(ClientModules.Handlers.UITweens)

local Faces = require(CharacterCustomizer.Faces)
local Skins = require(CharacterCustomizer.Skins)
local Dyes = require(CharacterCustomizer.Dyes)
local Hairs = require(CharacterCustomizer.Hairs)
local HairMeshes = Assets.Hairs

local currentCategory, currentFaceIndex = "Default", 0
local currentSkinCategory, currentSkinIndex = "Default", 0
local currentHairCategory, currentHairIndex = "Default", 0
local currentDyeCategory, currentDyeIndex = "Default", 0

local function getCurrentCategoryItems<T>(items: {[string]: T}, category: string): T
    return items[category] or items.Default
end

local function getMaxIndex(items: {[number]: any}): number
    local maxIndex = 0
    for index in items do
        if type(index) == "number" and index > maxIndex then
            maxIndex = index
        end
    end
    return maxIndex
end

local function updateIndex(currentIndex: number, direction: number, maxIndex: number): number
    currentIndex = currentIndex + direction
    if currentIndex > maxIndex then
        return 0
    elseif currentIndex < 0 then
        return maxIndex
    end
    return currentIndex
end

local function updateFace(viewportFrame: ViewportFrame, direction: number): string
    local viewportCharacter = viewportFrame:FindFirstChildOfClass("Model")
    local localCharacter = Players.LocalPlayer.Character
    if not viewportCharacter then return "Face 0" end
    
    local categoryFaces = getCurrentCategoryItems(Faces, currentCategory)
    currentFaceIndex = updateIndex(currentFaceIndex, direction, getMaxIndex(categoryFaces))
    
    local function updateCharacterFace(character: Model)
        local head = character:FindFirstChild("Head")
        if not head then return end
        
        local face = head:FindFirstChild("face")
        if not face or not face:IsA("Decal") then return end
        
        if categoryFaces[currentFaceIndex] and categoryFaces[currentFaceIndex] ~= "" then
            face.Texture = categoryFaces[currentFaceIndex]
        end
    end
    
    updateCharacterFace(viewportCharacter)
    if localCharacter then updateCharacterFace(localCharacter) end
    
    return string.format("Face %d", currentFaceIndex)
end

local function updateSkin(viewportFrame: ViewportFrame, direction: number): string
    local viewportCharacter = viewportFrame:FindFirstChildOfClass("Model")
    local localCharacter = Players.LocalPlayer.Character
    if not viewportCharacter then return "Skin 0" end
    
    local categorySkins = getCurrentCategoryItems(Skins, currentSkinCategory)
    currentSkinIndex = updateIndex(currentSkinIndex, direction, getMaxIndex(categorySkins))
    
    local function updateCharacterSkin(character: Model)
        for _, part in character:GetChildren() do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if categorySkins[currentSkinIndex] then
                    part.Color = categorySkins[currentSkinIndex]
                end
            end
        end
    end
    
    updateCharacterSkin(viewportCharacter)
    if localCharacter then updateCharacterSkin(localCharacter) end
    
    return string.format("Skin %d", currentSkinIndex)
end

local function updateDye(viewportFrame: ViewportFrame, direction: number): string
    local viewportCharacter = viewportFrame:FindFirstChildOfClass("Model")
    local localCharacter = Players.LocalPlayer.Character
    if not viewportCharacter then return "Dye 0" end
    
    local categoryDyes = getCurrentCategoryItems(Dyes, currentDyeCategory)
    currentDyeIndex = updateIndex(currentDyeIndex, direction, getMaxIndex(categoryDyes))
    
    local function updateCharacterHairColor(character: Model)
        local head = character:FindFirstChild("Head")
        if not head then return end
        
        local hair = head:FindFirstChild("CharacterHair") :: BasePart?
        if hair and categoryDyes[currentDyeIndex] then
            hair.Color = categoryDyes[currentDyeIndex]
        end
    end
    
    updateCharacterHairColor(viewportCharacter)
    if localCharacter then updateCharacterHairColor(localCharacter) end
    
    return string.format("Dye %d", currentDyeIndex)
end

local function updateHair(viewportFrame: ViewportFrame, direction: number): string
    local viewportCharacter = viewportFrame:FindFirstChildOfClass("Model")
    local localCharacter = Players.LocalPlayer.Character
    if not viewportCharacter then return "Hair 0" end
    
    local categoryHairs = getCurrentCategoryItems(Hairs, currentHairCategory)
    if not categoryHairs then return "Hair 0" end
    
    currentHairIndex = updateIndex(currentHairIndex, direction, getMaxIndex(categoryHairs))
    
    local function updateCharacterHair(character: Model)
        local head = character:FindFirstChild("Head") :: BasePart?
        if not head then return end
        
        local existingHair = head:FindFirstChild("CharacterHair")
        if existingHair then existingHair:Destroy() end
        
        local hairSettings = categoryHairs[currentHairIndex]
        if not hairSettings then return end
        
        local hairMesh = HairMeshes:FindFirstChild(tostring(currentHairIndex))
        if not hairMesh or not hairMesh:IsA("BasePart") then return end
        
        local newHair = hairMesh:Clone()
        newHair.Name = "CharacterHair"
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = newHair
        weld.Parent = newHair
        
        newHair.CFrame = head.CFrame * (hairSettings.OFFSET and hairSettings.ROTATION and 
            hairSettings.OFFSET * hairSettings.ROTATION or CFrame.new())
        
        local categoryDyes = getCurrentCategoryItems(Dyes, currentDyeCategory)
        if categoryDyes and categoryDyes[currentDyeIndex] then
            newHair.Color = categoryDyes[currentDyeIndex]
        end
        
        newHair.Parent = head
    end
    
    updateCharacterHair(viewportCharacter)
    if localCharacter then updateCharacterHair(localCharacter) end
    
    return string.format("Hair %d", currentHairIndex)
end

local function setupViewportCharacter(viewportFrame: ViewportFrame, character: Model)
    if not viewportFrame or not character then return end
    
    local setup: ViewportSetup = {
        viewportFrame = viewportFrame,
        character = character,
        camera = Instance.new("Camera"),
        connection = nil
    }
    
    setup.viewportFrame:ClearAllChildren()
    setup.camera.FieldOfView = 30
    setup.viewportFrame.CurrentCamera = setup.camera
    
    setup.character.Archivable = true
    local viewportCharacter = setup.character:Clone()
    setup.character.Archivable = false
    viewportCharacter.Parent = setup.viewportFrame
    
    local humanoidRootPart = viewportCharacter:WaitForChild("HumanoidRootPart")
    local humanoid = viewportCharacter:WaitForChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    viewportCharacter:PivotTo(CFrame.new())
    
    for _, part in viewportCharacter:GetDescendants() do
        if part:IsA("BasePart") then part.Anchored = true end
    end
    
    local _, size = viewportCharacter:GetBoundingBox()
    local maxSize = math.max(size.X, size.Y, size.Z)
    local basePosition = Vector3.new(0, 2.5, 0)
    
    viewportCharacter:PivotTo(CFrame.new(basePosition))
    setup.camera.CFrame = CFrame.new(basePosition + Vector3.new(0, 0, maxSize * 2.5), basePosition)
    
    setup.viewportFrame.BackgroundTransparency = 1
    setup.viewportFrame.Size = UDim2.fromScale(1, 1)
    
    local rotationAngle = 0
    setup.connection = RunService.RenderStepped:Connect(function(deltaTime: number)
        if not setup.viewportFrame.Parent then
            setup.connection:Disconnect()
            return
        end
        rotationAngle += deltaTime * 0.5
        viewportCharacter:PivotTo(CFrame.Angles(0, rotationAngle, 0))
    end)
end

function LooksUI.Init()
    local player = Players.LocalPlayer
    if not player then return end
    
    local playerGui = player:WaitForChild("PlayerGui")
    local character = player.Character or player.CharacterAdded:Wait()
    local MainGUI = playerGui:WaitForChild("Main")
    local Canvas = MainGUI.Canvas
    local LooksFrame = Canvas.InventoryFrame.B_Frame.LooksFrame
    local ListFrame = LooksFrame.ListFrame
    local OptionsFrame = ListFrame.A_OptionFrame

    local frames = {
        Hair = OptionsFrame.A_HairFrame,
        Dye = OptionsFrame.B_DyeFrame,
        Face = OptionsFrame.C_FaceFrame,
        Skin = OptionsFrame.D_SkinFrame
    }
    
    local buttons = {}
    local labels = {}
    local updateFuncs: {[string]: UpdateFunction} = {
        Hair = updateHair,
        Dye = updateDye,
        Face = updateFace,
        Skin = updateSkin
    }
    
    for name, frame in frames do
        buttons[name] = {
            Left = frame.A_Frame.TextButton,
            Right = frame.C_Frame.TextButton
        }
        labels[name] = frame.B_InfoFrame.TextLabel
        labels[name].Text = string.format("%s 0", name)
    end

    local ViewportFrame = ListFrame.B_CharacterFrame.ViewportFrame
    
    if character then
        task.spawn(function()
            if not character.PrimaryPart then
                character:WaitForChild("HumanoidRootPart")
            end
            setupViewportCharacter(ViewportFrame, character)
            
            task.wait(0.1)
            for name, updateFunc in updateFuncs do
                labels[name].Text = updateFunc(ViewportFrame, 0)
            end
        end)
    end
    
    UITweens.InitButtonAnimations(LooksFrame)

    for name, btns in buttons do
        btns.Left.MouseButton1Click:Connect(function()
            labels[name].Text = updateFuncs[name](ViewportFrame, -1)
        end)
        btns.Right.MouseButton1Click:Connect(function()
            labels[name].Text = updateFuncs[name](ViewportFrame, 1)
        end)
    end

    player.CharacterAdded:Connect(function(newCharacter: Model)
        if not newCharacter then return end
        newCharacter:WaitForChild("HumanoidRootPart")
        setupViewportCharacter(ViewportFrame, newCharacter)
        
        task.wait(0.1)
        for name, updateFunc in updateFuncs do
            labels[name].Text = updateFunc(ViewportFrame, 0)
        end
    end)
end

return LooksUI