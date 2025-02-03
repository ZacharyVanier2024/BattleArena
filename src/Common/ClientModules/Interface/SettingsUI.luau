local SettingsUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

-- Constants for colors and animation
local ENABLED_COLOR = Color3.fromRGB(0, 255, 0)  -- Green
local DISABLED_COLOR = Color3.fromRGB(255, 0, 0) -- Red
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad)

type ToggleData = {
    toggle: Frame,
    outline: UIStroke,
    label: TextLabel,
    isEnabled: boolean
}

local function setupToggle(toggleData: ToggleData)
    local function updateToggleVisuals(isEnabled: boolean)
        local targetColor = if isEnabled then ENABLED_COLOR else DISABLED_COLOR
        
        -- Tween the outline color
        TweenService:Create(toggleData.outline, TWEEN_INFO, {
            Color = targetColor
        }):Play()
        
        -- Tween the label color
        TweenService:Create(toggleData.label, TWEEN_INFO, {
            TextColor3 = targetColor
        }):Play()
    end
    
    -- Set initial state
    updateToggleVisuals(toggleData.isEnabled)
    
    -- Connect click handler
    toggleData.toggle.TextButton.MouseButton1Click:Connect(function()
        toggleData.isEnabled = not toggleData.isEnabled
        updateToggleVisuals(toggleData.isEnabled)
    end)
end

function SettingsUI.Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local Main = playerGui:WaitForChild("Main")
    local Canvas = Main.Canvas

    local SettingsFrame = Canvas.SettingsFrame
    local ListFrame = SettingsFrame.B_Frame.Frame.ListFrame

    -- Setup Blood Toggle
    local bloodToggle: ToggleData = {
        toggle = ListFrame.Blood.C_Trigger,
        outline = ListFrame.Blood.C_Trigger.TextButton.UIStroke,
        label = ListFrame.Blood.C_Trigger.TextButton.Frame.TextLabel,
        isEnabled = false -- Default state
    }
    setupToggle(bloodToggle)

    -- Setup Trade Invite Toggle
    local tradeInviteToggle: ToggleData = {
        toggle = ListFrame.TradeInvite.C_Trigger,
        outline = ListFrame.TradeInvite.C_Trigger.TextButton.UIStroke,
        label = ListFrame.TradeInvite.C_Trigger.TextButton.Frame.TextLabel,
        isEnabled = false -- Default state
    }
    setupToggle(tradeInviteToggle)

    -- Add button animations to all toggle buttons
    UITweens.InitButtonAnimations(ListFrame)
end

return SettingsUI