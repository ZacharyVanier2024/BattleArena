--!strict

type ViewportSetup = {
    viewportFrame: ViewportFrame,
    character: Model,
    camera: Camera,
    connection: RBXScriptConnection?
}

type UpdateFunction = (viewportFrame: ViewportFrame, direction: number) -> string

type CategoryItems<T> = {[string]: T}

type Face = string
type Skin = Color3
type Hair = {
    OFFSET: CFrame?,
    ROTATION: CFrame?
}   
type Dye = Color3

type CharacterCustomization = {
    category: string,
    index: number
}

type UIElements = {
    buttons: {[string]: {Left: TextButton, Right: TextButton}},
    labels: {[string]: TextLabel},
    updateFuncs: {[string]: UpdateFunction}
}

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

local Faces = require(CharacterCustomizer.Faces) :: CategoryItems<Face>
local Skins = require(CharacterCustomizer.Skins) :: CategoryItems<Skin>
local Dyes = require(CharacterCustomizer.Dyes) :: CategoryItems<Dye>
local Hairs = require(CharacterCustomizer.Hairs) :: CategoryItems<Hair>
local HairMeshes = Assets.Hairs

local currentCategory, currentFaceIndex = "Default", 0
local currentSkinCategory, currentSkinIndex = "Default", 0
local currentHairCategory, currentHairIndex = "Default", 0
local currentDyeCategory, currentDyeIndex = "Default", 0

local function getCurrentCategoryItems<T>(items: CategoryItems<T>, category: string): T
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
    currentIndex += direction
    if currentIndex > maxIndex then return 0 end
    if currentIndex < 0 then return maxIndex end
    return currentIndex
end

local function updateCharacterFace(character: Model, face: string): ()
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local faceDecal = head:FindFirstChild("face") :: Decal?
    if not faceDecal or face == "" then return end
    
    faceDecal.Texture = face
end

local function updateFace(viewportFrame: ViewportFrame, direction: number): string
    local worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")
    local viewportCharacter = worldModel and worldModel:FindFirstChildOfClass("Model")
    if not viewportCharacter then return "Face 0" end
    
    local categoryFaces = getCurrentCategoryItems(Faces, currentCategory)
    currentFaceIndex = updateIndex(currentFaceIndex, direction, getMaxIndex(categoryFaces))
    
    local newFace = categoryFaces[currentFaceIndex]
    if not newFace then return "Face 0" end
    
    updateCharacterFace(viewportCharacter, newFace)
    
    local localCharacter = Players.LocalPlayer.Character
    if localCharacter then
        updateCharacterFace(localCharacter, newFace)
    end
    
    return string.format("Face %d", currentFaceIndex)
end

local function updateCharacterSkin(character: Model, color: Color3): ()
    for _, part in character:GetChildren() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Color = color
        end
    end
end

local function updateSkin(viewportFrame: ViewportFrame, direction: number): string
    local worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")
    local viewportCharacter = worldModel and worldModel:FindFirstChildOfClass("Model")
    if not viewportCharacter then return "Skin 0" end
    
    local categorySkins = getCurrentCategoryItems(Skins, currentSkinCategory)
    currentSkinIndex = updateIndex(currentSkinIndex, direction, getMaxIndex(categorySkins))
    
    local newColor = categorySkins[currentSkinIndex]
    if not newColor then return "Skin 0" end
    
    updateCharacterSkin(viewportCharacter, newColor)
    
    local localCharacter = Players.LocalPlayer.Character
    if localCharacter then
        updateCharacterSkin(localCharacter, newColor)
    end
    
    return string.format("Skin %d", currentSkinIndex)
end

local function updateCharacterHairColor(character: Model, color: Color3): ()
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local hair = head:FindFirstChild("CharacterHair") :: BasePart?
    if hair then hair.Color = color end
end

local function updateDye(viewportFrame: ViewportFrame, direction: number): string
    local worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")
    local viewportCharacter = worldModel and worldModel:FindFirstChildOfClass("Model")
    if not viewportCharacter then return "Dye 0" end
    
    local categoryDyes = getCurrentCategoryItems(Dyes, currentDyeCategory)
    currentDyeIndex = updateIndex(currentDyeIndex, direction, getMaxIndex(categoryDyes))
    
    local newColor = categoryDyes[currentDyeIndex]
    if not newColor then return "Dye 0" end
    
    updateCharacterHairColor(viewportCharacter, newColor)
    
    local localCharacter = Players.LocalPlayer.Character
    if localCharacter then
        updateCharacterHairColor(localCharacter, newColor)
    end
    
    return string.format("Dye %d", currentDyeIndex)
end

local function updateCharacterHair(character: Model, hairIndex: number, hairSettings: Hair): ()
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local existingHair = head:FindFirstChild("CharacterHair")
    if existingHair then existingHair:Destroy() end
    
    local hairMesh = HairMeshes:FindFirstChild(tostring(hairIndex))
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

local function updateHair(viewportFrame: ViewportFrame, direction: number): string
    local worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")
    local viewportCharacter = worldModel and worldModel:FindFirstChildOfClass("Model")
    if not viewportCharacter then return "Hair 0" end
    
    local categoryHairs = getCurrentCategoryItems(Hairs, currentHairCategory)
    if not categoryHairs then return "Hair 0" end
    
    currentHairIndex = updateIndex(currentHairIndex, direction, getMaxIndex(categoryHairs))
    
    local hairSettings = categoryHairs[currentHairIndex]
    if not hairSettings then return "Hair 0" end
    
    updateCharacterHair(viewportCharacter, currentHairIndex, hairSettings)
    
    local localCharacter = Players.LocalPlayer.Character
    if localCharacter then
        updateCharacterHair(localCharacter, currentHairIndex, hairSettings)
    end
    
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

    local WorldModel = Instance.new("WorldModel")
    WorldModel.Parent = setup.viewportFrame
    
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(4, 1, 4)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.CFrame = CFrame.new()
    platform.Parent = WorldModel
    
    viewportCharacter:PivotTo(CFrame.new(0, platform.Size.Y/2, 0) * CFrame.Angles(0, math.rad(180), 0))
    viewportCharacter.Parent = WorldModel
    
    local humanoidRootPart = viewportCharacter:WaitForChild("HumanoidRootPart")
    local humanoid = viewportCharacter:WaitForChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    -- Disable physics/falling state
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)  -- Disable physics
    humanoid.AutoRotate = false
    humanoidRootPart.Anchored = true
    
    -- Setup animator with highest priority idle
    local animator = humanoid:WaitForChild("Animator") or Instance.new("Animator", humanoid)
    
    for _, track in animator:GetPlayingAnimationTracks() do
        track:Stop()
        track:Destroy()
    end
    
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = "rbxassetid://507766666"
    local animTrack = animator:LoadAnimation(idleAnimation)
    animTrack.Looped = true
    animTrack.Priority = Enum.AnimationPriority.Core  -- Highest priority
    animTrack:Play(0.1, 1, 1)  -- Fade time, weight, speed
    
    local _, size = viewportCharacter:GetBoundingBox()
    local maxSize = math.max(size.X, size.Y, size.Z)
    
    setup.camera.CFrame = CFrame.new(Vector3.new(0, 0, maxSize * 3.0), Vector3.new(0, 2.5, 0))
    
    setup.viewportFrame.BackgroundTransparency = 1
    setup.viewportFrame.Size = UDim2.fromScale(1, 1)
    
    local isDragging = false
    local lastMousePos: Vector2?
    local currentRotation = math.rad(180)
    
    viewportFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    
    viewportFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            lastMousePos = nil
        end
    end)
    
    viewportFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging and lastMousePos then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - lastMousePos
            currentRotation += delta.X * 0.005
            lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
            
            viewportCharacter:PivotTo(CFrame.new() * CFrame.Angles(0, currentRotation, 0))
        end
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
    
    local function updateCharacter(newCharacter: Model)
        if not newCharacter then return end
        newCharacter:WaitForChild("HumanoidRootPart")
        setupViewportCharacter(ViewportFrame, newCharacter)
        
        task.wait(0.1)
        for name, updateFunc in updateFuncs do
            labels[name].Text = updateFunc(ViewportFrame, 0)
        end
    end
    
    if character then
        task.spawn(updateCharacter, character)
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

    player.CharacterAdded:Connect(updateCharacter)
end

return LooksUI