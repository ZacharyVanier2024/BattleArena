local SettingsUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

local ENABLED_COLOR = Color3.fromRGB(0, 255, 0)
local DISABLED_COLOR = Color3.fromRGB(255, 0, 0)
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
        local targetText = if isEnabled then "Enabled" else "Disabled"
        
        TweenService:Create(toggleData.outline, TWEEN_INFO, {
            Color = targetColor
        }):Play()
        
        TweenService:Create(toggleData.label, TWEEN_INFO, {
            TextColor3 = targetColor
        }):Play()
        
        toggleData.label.Text = targetText
    end
    
    updateToggleVisuals(toggleData.isEnabled)
    
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

    local bloodToggle: ToggleData = {
        toggle = ListFrame.Blood.C_Trigger,
        outline = ListFrame.Blood.C_Trigger.TextButton.UIStroke,
        label = ListFrame.Blood.C_Trigger.TextButton.Frame.TextLabel,
        isEnabled = false
    }
    setupToggle(bloodToggle)

    local tradeInviteToggle: ToggleData = {
        toggle = ListFrame.TradeInvite.C_Trigger,
        outline = ListFrame.TradeInvite.C_Trigger.TextButton.UIStroke,
        label = ListFrame.TradeInvite.C_Trigger.TextButton.Frame.TextLabel,
        isEnabled = false
    }
    setupToggle(tradeInviteToggle)
end

return SettingsUI