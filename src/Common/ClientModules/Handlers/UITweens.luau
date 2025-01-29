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

type UIFrameData = {
    button: GuiButton,
    frame: Frame
}

type UIFrameButtons = {
    [ButtonName]: UIFrameData
}

type UIFrameElements = {
    Main: Frame,
    Buttons: {[ButtonName]: GuiButton},
    Frames: {[ButtonName]: Frame},
    WhiteLine: Frame?,
    Screens: {[ButtonName]: ScreenGui}?
}

export type UIConfig = {
    elements: UIFrameElements,
    buttonOrder: {ButtonName},
    defaultButton: ButtonName,
    closeOnSameButton: boolean?,
    useSlideTransition: boolean?
}

local TweenService = game:GetService("TweenService")
local UITweens = {}
local isAnimating = false

local DEFAULT_TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local DEFAULT_POSITION = UDim2.fromScale(0.5, 0.5)
local DEFAULT_ANCHOR_POINT = Vector2.new(0.5, 0.5)

local HOVER_TRANSPARENCY = 0.8
local DEFAULT_TRANSPARENCY = 1
local HOVER_SCALE = 1.1
local CLICK_SCALE = 0.9
local DEFAULT_SCALE = 1

local HOVER_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
local CLICK_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad)

local SLIDE_OFFSET = 0.15

local function createButtons(elements: UIFrameElements): UIFrameButtons
    if not elements.Buttons or not elements.Frames then
        error("Missing required elements.Buttons or elements.Frames")
    end

    local buttons: UIFrameButtons = {}
    for buttonName, button in elements.Buttons do
        if not elements.Frames[buttonName] then
            error(string.format("Missing frame for button %s", tostring(buttonName)))
        end
        buttons[buttonName] = {
            button = button,
            frame = elements.Frames[buttonName]
        }
    end
    return buttons
end

local function findFrameIndices(buttons: UIFrameButtons, config: UIConfig, selectedButton: ButtonName): (Frame?, number, number)
    if not config.buttonOrder then
        error("Missing buttonOrder in config")
    end

    local currentFrame: Frame? = nil
    local currentIndex = 1
    local targetIndex = 1
    
    for i, buttonName in config.buttonOrder do
        if not buttons[buttonName] then
            error(string.format("Button %s from buttonOrder not found", buttonName))
        end
        
        if buttons[buttonName].frame.Visible then
            currentFrame = buttons[buttonName].frame
            currentIndex = i
        end
        if buttonName == selectedButton then
            targetIndex = i
        end
    end
    
    return currentFrame, currentIndex, targetIndex
end

local function handleWhiteLineTween(elements: UIFrameElements, selectedButton: GuiButton, whiteLine: Frame)
    if not whiteLine then return end

    local buttonWidth = selectedButton.AbsoluteSize.X
    local whiteLineWidth = whiteLine.AbsoluteSize.X
    local centerOffset = (buttonWidth - whiteLineWidth) / 2
    
    local targetPosition = UDim2.new(
        selectedButton.Position.X.Scale,
        selectedButton.Position.X.Offset + centerOffset,
        whiteLine.Position.Y.Scale,
        whiteLine.Position.Y.Offset
    )

    TweenService:Create(whiteLine, DEFAULT_TWEEN_INFO, {Position = targetPosition}):Play()
end

local function setupButtonAnimations(button: GuiButton)
    local originalSize = button.Size

    local function scaleSize(scale: number): UDim2
        return UDim2.new(
            originalSize.X.Scale * scale,
            originalSize.X.Offset * scale,
            originalSize.Y.Scale * scale,
            originalSize.Y.Offset * scale
        )
    end

    button.MouseEnter:Connect(function()
        local tweenInfo = {
            Size = scaleSize(HOVER_SCALE)
        }

        if button:GetAttribute("ImageTransparency") ~= nil then
            tweenInfo.ImageTransparency = HOVER_TRANSPARENCY
        end
        if button:GetAttribute("TextTransparency") ~= nil then
            tweenInfo.TextTransparency = HOVER_TRANSPARENCY
        end

        TweenService:Create(button, HOVER_TWEEN, tweenInfo):Play()
    end)

    button.MouseLeave:Connect(function()
        local tweenInfo = {
            Size = originalSize
        }

        if button:GetAttribute("ImageTransparency") ~= nil then
            tweenInfo.ImageTransparency = DEFAULT_TRANSPARENCY
        end
        if button:GetAttribute("TextTransparency") ~= nil then
            tweenInfo.TextTransparency = DEFAULT_TRANSPARENCY
        end

        TweenService:Create(button, HOVER_TWEEN, tweenInfo):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, CLICK_TWEEN, {
            Size = scaleSize(CLICK_SCALE)
        }):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, CLICK_TWEEN, {
            Size = scaleSize(if button.MouseEnter then HOVER_SCALE else DEFAULT_SCALE)
        }):Play()
    end)
end

function UITweens.InitButtonAnimations(parent: Instance)
    for _, instance in parent:GetDescendants() do
        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            setupButtonAnimations(instance)
        end
    end
end

function UITweens.handleFrameAnimation(config: UIConfig, selectedButton: ButtonName): ()
    if isAnimating then return end
    if not config.elements then return end

    local elements = config.elements
    local buttons = createButtons(elements)
    
    if not buttons[selectedButton] then
        error(string.format("Selected button %s not found", selectedButton))
    end

    local selectedFrame = buttons[selectedButton].frame
    local currentFrame, currentIndex, targetIndex = findFrameIndices(buttons, config, selectedButton)

    if currentFrame == selectedFrame then
        if config.closeOnSameButton then
            isAnimating = true
            currentFrame.Visible = false
            buttons[selectedButton].button.ImageTransparency = 0.5
            
            if config.elements.Screens then
                for name, screen in config.elements.Screens do
                    screen.Enabled = false
                end
            end
            
            task.wait(0.1)
            isAnimating = false
        end
        return
    end

    isAnimating = true

    for _, data in buttons do
        data.button.ImageTransparency = 0.5
    end
    buttons[selectedButton].button.ImageTransparency = 0

    if config.elements.Screens then
        for name, screen in config.elements.Screens do
            screen.Enabled = name == selectedButton
        end
    end

    -- Handle transitions based on config
    if config.useSlideTransition then
        local offset = targetIndex > currentIndex and SLIDE_OFFSET or -SLIDE_OFFSET
        selectedFrame.Position = UDim2.new(0.5 + (offset * -1), 0, 0.5, 0)
        selectedFrame.Visible = true
        
        if currentFrame then
            local currentTween = TweenService:Create(currentFrame, DEFAULT_TWEEN_INFO, {
                Position = UDim2.new(0.5 + offset, 0, 0.5, 0)
            })
            currentTween:Play()
            currentTween.Completed:Connect(function()
                currentFrame.Visible = false
                currentFrame.Position = DEFAULT_POSITION
            end)
        end

        local selectedTween = TweenService:Create(selectedFrame, DEFAULT_TWEEN_INFO, {
            Position = DEFAULT_POSITION
        })
        selectedTween.Completed:Connect(function()
            isAnimating = false
        end)
        selectedTween:Play()
    else
        -- Simple show/hide
        for _, data in buttons do
            data.frame.Visible = false
        end
        selectedFrame.Visible = true
        isAnimating = false
    end

    -- Always animate white line
    if elements.WhiteLine then
        handleWhiteLineTween(elements, buttons[selectedButton].button, elements.WhiteLine)
    end
end

function UITweens.initializeUI(config: UIConfig): ()
    if not config.elements then return end
    if not config.defaultButton then
        error("Missing defaultButton in config")
    end
    
    local elements = config.elements
    
    for buttonName, frame in elements.Frames do
        frame.AnchorPoint = DEFAULT_ANCHOR_POINT
        frame.Position = DEFAULT_POSITION
        frame.Visible = buttonName == config.defaultButton
    end
    
    for buttonName, button in elements.Buttons do
        button.ImageTransparency = buttonName == config.defaultButton and 0 or 0.5
        button.MouseButton1Click:Connect(function()
            UITweens.handleFrameAnimation(config, buttonName)
        end)
    end

    if config.elements.Screens then
        for name, screen in config.elements.Screens do
            screen.Enabled = name == config.defaultButton
        end
    end
end

return UITweens