--!strict

export type GuiButton = {
    AbsoluteSize: Vector2,
    Position: UDim2,
    ImageTransparency: number,
    MouseButton1Click: RBXScriptSignal,
    MouseEnter: RBXScriptSignal,
    MouseLeave: RBXScriptSignal,
    MouseButton1Down: RBXScriptSignal,
    MouseButton1Up: RBXScriptSignal,
    Size: UDim2
}

export type Frame = {
    AnchorPoint: Vector2,
    Position: UDim2,
    Visible: boolean,
    AbsoluteSize: Vector2,
    Size: UDim2
}

export type ButtonName = string

type UIFrameData = {button: GuiButton, frame: Frame}
type UIFrameButtons = {[ButtonName]: UIFrameData}
type UIFrameElements = {
    Main: Frame,
    Buttons: {[ButtonName]: GuiButton},
    Frames: {[ButtonName]: Frame},
    WhiteLine: Frame?,
    CanvasFrames: {[ButtonName]: Frame}?
}

export type UIConfig = {
    elements: UIFrameElements,
    buttonOrder: {ButtonName},
    defaultButton: ButtonName?,
    useSlideTransition: boolean?
}

local TweenService: TweenService = game:GetService("TweenService")
local UITweens: {[string]: any} = {}
local isAnimating: boolean = false

local DEFAULT_TWEEN_INFO: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local DEFAULT_POSITION: UDim2 = UDim2.fromScale(0.5, 0.5)
local HOVER_TRANSPARENCY: number = 0.8
local DEFAULT_TRANSPARENCY: number = 1
local HOVER_SCALE: number = 1.1
local CLICK_SCALE: number = 0.9
local DEFAULT_SCALE: number = 1
local HOVER_TWEEN: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
local CLICK_TWEEN: TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
local SLIDE_DISTANCE: number = 0.15
local SLIDE_OUT_TWEEN: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SLIDE_IN_TWEEN: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SHAKE_INTENSITY: number = 3
local SHAKE_DURATION: number = 0.2
local SHAKE_FREQUENCY: number = 30

local function createButtons(elements: UIFrameElements): UIFrameButtons
    if not elements.Buttons or not elements.Frames then error("Missing required elements") end
    local buttons: UIFrameButtons = {}
    for buttonName: ButtonName, button: GuiButton in elements.Buttons do
        if not elements.Frames[buttonName] then error("Missing frame for button "..tostring(buttonName)) end
        buttons[buttonName] = {button = button, frame = elements.Frames[buttonName]}
    end
    return buttons
end

local function findFrameIndices(buttons: UIFrameButtons, config: UIConfig, selectedButton: ButtonName): (Frame?, number, number)
    if not config.buttonOrder then error("Missing buttonOrder in config") end
    local currentFrame: Frame? = nil
    local currentIndex: number, targetIndex: number = 1, 1
    for i: number, buttonName: ButtonName in config.buttonOrder do
        if not buttons[buttonName] then error("Button "..buttonName.." not found") end
        if buttons[buttonName].frame.Visible then
            currentFrame = buttons[buttonName].frame
            currentIndex = i
        end
        if buttonName == selectedButton then targetIndex = i end
    end
    return currentFrame, currentIndex, targetIndex
end

local function handleWhiteLineTween(elements: UIFrameElements, selectedButton: GuiButton, whiteLine: Frame?): ()
    if not whiteLine then return end
    local buttonWidth: number = selectedButton.AbsoluteSize.X
    local whiteLineWidth: number = whiteLine.AbsoluteSize.X
    local centerOffset: number = (buttonWidth - whiteLineWidth) / 2
    local targetPosition: UDim2 = UDim2.new(
        selectedButton.Position.X.Scale,
        selectedButton.Position.X.Offset + centerOffset,
        whiteLine.Position.Y.Scale,
        whiteLine.Position.Y.Offset
    )
    TweenService:Create(whiteLine, DEFAULT_TWEEN_INFO, {Position = targetPosition}):Play()
end

local function setupButtonAnimations(button: GuiButton): ()
    local originalSize: UDim2 = button.Size
    local isTextButton: boolean = button:IsA("TextButton")
    local function scaleSize(scale: number): UDim2
        return UDim2.new(
            originalSize.X.Scale * scale,
            originalSize.X.Offset * scale,
            originalSize.Y.Scale * scale,
            originalSize.Y.Offset * scale
        )
    end

    button.MouseEnter:Connect(function()
        local tweenInfo: {[string]: any} = {Size = scaleSize(HOVER_SCALE)}
        tweenInfo[if isTextButton then "TextTransparency" else "ImageTransparency"] = HOVER_TRANSPARENCY
        TweenService:Create(button, HOVER_TWEEN, tweenInfo):Play()
    end)

    button.MouseLeave:Connect(function()
        local tweenInfo: {[string]: any} = {Size = originalSize}
        tweenInfo[if isTextButton then "TextTransparency" else "ImageTransparency"] = DEFAULT_TRANSPARENCY
        TweenService:Create(button, HOVER_TWEEN, tweenInfo):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, CLICK_TWEEN, {Size = scaleSize(CLICK_SCALE)}):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, CLICK_TWEEN, {
            Size = scaleSize(if button.MouseEnter then HOVER_SCALE else DEFAULT_SCALE)
        }):Play()
    end)
end

function UITweens.InitButtonAnimations(parent: Instance): ()
    for _, instance: Instance in parent:GetDescendants() do
        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            setupButtonAnimations(instance)
        end
    end
end

local function getButtonIndex(config: UIConfig, buttonName: ButtonName): number
    for i: number, name: ButtonName in config.buttonOrder do
        if name == buttonName then return i end
    end
    return 1
end

function UITweens.handleFrameAnimation(config: UIConfig, selectedButton: ButtonName): ()
    if isAnimating or not config.elements then return end
    local elements: UIFrameElements = config.elements
    local buttons: UIFrameButtons = createButtons(elements)
    if not buttons[selectedButton] then error("Selected button "..selectedButton.." not found") end
    isAnimating = true

    local currentVisibleButton: ButtonName? = nil
    if config.elements.CanvasFrames then
        for name: ButtonName, frame: Frame in config.elements.CanvasFrames do
            if frame.Visible then currentVisibleButton = name break end
        end
    end

    if config.elements.CanvasFrames then
        local selectedFrame: Frame = config.elements.CanvasFrames[selectedButton]
        if currentVisibleButton == selectedButton then
            local tween: Tween = TweenService:Create(selectedFrame, SLIDE_OUT_TWEEN, {
                Position = UDim2.new(0.5, 0, 1 + SLIDE_DISTANCE, 0)
            })
            tween.Completed:Connect(function()
                selectedFrame.Visible = false
                selectedFrame.Position = DEFAULT_POSITION
                isAnimating = false
            end)
            tween:Play()
            return
        end

        if currentVisibleButton then
            local currentFrame: Frame = config.elements.CanvasFrames[currentVisibleButton]
            local currentTween: Tween = TweenService:Create(currentFrame, SLIDE_OUT_TWEEN, {
                Position = UDim2.new(0.5, 0, 1 + SLIDE_DISTANCE, 0)
            })
            currentTween.Completed:Connect(function()
                currentFrame.Visible = false
                currentFrame.Position = DEFAULT_POSITION
            end)
            currentTween:Play()
        end

        selectedFrame.Position = UDim2.new(0.5, 0, -SLIDE_DISTANCE, 0)
        selectedFrame.Visible = true

        local tween = TweenService:Create(selectedFrame, SLIDE_IN_TWEEN, {Position = DEFAULT_POSITION})
        tween.Completed:Connect(function() isAnimating = false end)
        tween:Play()
    end

    if elements.WhiteLine then
        handleWhiteLineTween(elements, buttons[selectedButton].button, elements.WhiteLine)
    end
end

function UITweens.initializeUI(config: UIConfig): ()
    if not config.elements then return end
    local elements = config.elements
    
    for buttonName, button in elements.Buttons do
        button.MouseButton1Click:Connect(function()
            UITweens.handleFrameAnimation(config, buttonName)
        end)
    end

    if config.defaultButton and config.elements.CanvasFrames then
        for name, frame in config.elements.CanvasFrames do
            frame.Visible = name == config.defaultButton
        end
    end
end

function UITweens.ShakeFrameAnimation(config: UIConfig, selectedButton: ButtonName): ()
    if isAnimating or not config.elements then return end
    local elements = config.elements
    
    if not elements.CanvasFrames then return end
    local selectedFrame = elements.CanvasFrames[selectedButton]
    
    local currentVisibleButton: ButtonName? = nil
    for name, frame in elements.CanvasFrames do
        if frame.Visible then
            currentVisibleButton = name
            break
        end
    end
    
    isAnimating = true
    
    if currentVisibleButton == selectedButton then
        local startTime = os.clock()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            local elapsed = os.clock() - startTime
            if elapsed >= SHAKE_DURATION then
                connection:Disconnect()
                selectedFrame.Position = DEFAULT_POSITION
                isAnimating = false
                return
            end
            
            local progress = elapsed / SHAKE_DURATION
            local dampening = 1 - progress
            local offset = math.sin(elapsed * SHAKE_FREQUENCY) * SHAKE_INTENSITY * dampening
            
            selectedFrame.Position = UDim2.new(0.5, offset, 0.5, 0)
        end)
        return
    end
    
    if currentVisibleButton then
        elements.CanvasFrames[currentVisibleButton].Visible = false
    end
    
    selectedFrame.Visible = true
    selectedFrame.Position = DEFAULT_POSITION
    
    local startTime = os.clock()
    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        local elapsed = os.clock() - startTime
        if elapsed >= SHAKE_DURATION then
            connection:Disconnect()
            selectedFrame.Position = DEFAULT_POSITION
            isAnimating = false
            return
        end
        
        local progress = elapsed / SHAKE_DURATION
        local dampening = 1 - progress
        local offset = math.sin(elapsed * SHAKE_FREQUENCY) * SHAKE_INTENSITY * dampening
        
        selectedFrame.Position = UDim2.new(0.5, offset, 0.5, 0)
    end)
end

return UITweens