--!strict

local Players = game:GetService("Players")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

export type HotbarUI = {
    Init: (self: HotbarUI) -> (),
    Destroy: (self: HotbarUI) -> (),
}

local HotbarUI = {}
HotbarUI.__index = HotbarUI

local BUTTON_NAMES = {"Inventory", "Trade", "Shop", "Crafting", "Settings"}
local FRAME_LETTERS = {A = "Inventory", B = "Trade", C = "Shop", D = "Crafting", E = "Settings"}

function HotbarUI.new(): HotbarUI
    local self = setmetatable({}, HotbarUI)
    return self
end

function HotbarUI:Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local Canvas = playerGui:WaitForChild("Main").Canvas

    if not Canvas:FindFirstChild("HotbarFrame") then
        return
    end

    local hotbarFrame = Canvas.HotbarFrame
    local A_FrameMain = hotbarFrame.A_Frame
    
    local elements = {
        Main = A_FrameMain,
        Buttons = {},
        Frames = {},
        CanvasFrames = {}
    }

    for letter, name in pairs(FRAME_LETTERS) do
        local frame = A_FrameMain[letter.."_Frame"]
        if frame and frame:FindFirstChild("TextButton") then
            elements.Buttons[name] = frame.TextButton
            elements.Frames[name] = frame
            
            local canvasFrame = Canvas[name.."Frame"]
            elements.CanvasFrames[name] = canvasFrame
            if canvasFrame then
                canvasFrame.Visible = false
            end
        end
    end

    local config: UITweens.UIConfig = {
        elements = elements,
        buttonOrder = BUTTON_NAMES,
        closeOnSameButton = true,
        useSlideTransition = true
    }

    UITweens.initializeUI(config)
    UITweens.InitButtonAnimations(hotbarFrame)
end

function HotbarUI:Destroy()
    -- will do it later...
end

return HotbarUI