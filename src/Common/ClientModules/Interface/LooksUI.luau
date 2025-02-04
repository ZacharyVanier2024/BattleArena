local LooksUI = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

type ViewportSetup = {
    viewportFrame: ViewportFrame,
    character: Model,
    camera: Camera,
    connection: RBXScriptConnection?
}

local function setupViewportCharacter(viewportFrame: ViewportFrame, character: Model): ()
    if not viewportFrame or not character then
        return
    end
    
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
    local viewportCharacter: Model = setup.character:Clone()
    setup.character.Archivable = false
    
    viewportCharacter.Parent = setup.viewportFrame
    
    local humanoidRootPart: BasePart = viewportCharacter:WaitForChild("HumanoidRootPart")
    local humanoid: Humanoid = viewportCharacter:WaitForChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then
        return
    end
    
    viewportCharacter:PivotTo(CFrame.new(0, 0, 0))
    
    for _, part in viewportCharacter:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    local _, size: Vector3 = viewportCharacter:GetBoundingBox()
    local maxSize: number = math.max(size.X, size.Y, size.Z)
    
    local basePosition: Vector3 = Vector3.new(0, 2.5, 0)
    local cameraOffset: Vector3 = Vector3.new(0, 0, maxSize * 2.5)

    viewportCharacter:PivotTo(CFrame.new(basePosition))

    setup.camera.CFrame = CFrame.new(basePosition + cameraOffset, basePosition)
    
    setup.viewportFrame.BackgroundTransparency = 1
    setup.viewportFrame.Size = UDim2.new(1, 0, 1, 0)
    
    local rotationAngle: number = 0
    setup.connection = RunService.RenderStepped:Connect(function(deltaTime: number)
        if not setup.viewportFrame.Parent then
            if setup.connection then
                setup.connection:Disconnect()
            end
            return
        end
        
        rotationAngle += deltaTime * 0.5
        viewportCharacter:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, rotationAngle, 0))
    end)
end

function LooksUI.Init(): ()
    local player: Player = Players.LocalPlayer
    if not player then
        return
    end
    
    local playerGui: PlayerGui = player:WaitForChild("PlayerGui")
    local character: Model = player.Character or player.CharacterAdded:Wait()

    local MainGUI: ScreenGui = playerGui:WaitForChild("Main")
    local Canvas: Frame = MainGUI.Canvas
    local LooksFrame: Frame = Canvas.InventoryFrame.B_Frame.LooksFrame
    local ListFrame: Frame = LooksFrame.ListFrame
    local OptionsFrame: Frame = ListFrame.A_OptionFrame

    local A_HairFrame: Frame = OptionsFrame.A_HairFrame
    local B_DyeFrame: Frame = OptionsFrame.B_DyeFrame
    local C_FaceFrame: Frame = OptionsFrame.C_FaceFrame
    local D_SkinFrame: Frame = OptionsFrame.D_SkinFrame

    local B_CharacterFrame: Frame = ListFrame.B_CharacterFrame
    local ViewportFrame: ViewportFrame = B_CharacterFrame.ViewportFrame
    
    if character then
        task.spawn(function()
            if not character.PrimaryPart then
                character:WaitForChild("HumanoidRootPart")
            end
            setupViewportCharacter(ViewportFrame, character)
        end)
    end
    
    player.CharacterAdded:Connect(function(newCharacter: Model)
        if not newCharacter then
            return
        end
        newCharacter:WaitForChild("HumanoidRootPart")
        setupViewportCharacter(ViewportFrame, newCharacter)
    end)
end

return LooksUI