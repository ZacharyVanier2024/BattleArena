local InventoryUI = {}
local Players = game:GetService("Players")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

local BUTTON_NAMES = {"Items", "Looks", "Stats"}

function InventoryUI.Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local Canvas = playerGui:WaitForChild("Main").Canvas
    
    local InventoryFrame = Canvas.InventoryFrame
    local A_Frame = InventoryFrame.A_Frame
    local B_Frame = InventoryFrame.B_Frame

    local elements = {
        Main = A_Frame,
        Buttons = {
            Items = A_Frame.A_Items.TextButton,
            Looks = A_Frame.B_Looks.TextButton,
            Stats = A_Frame.C_Stats.TextButton
        },
        Frames = {
            Items = A_Frame.A_Items,
            Looks = A_Frame.B_Looks,
            Stats = A_Frame.C_Stats
        },
        CanvasFrames = {
            Items = B_Frame.ItemsFrame,
            Looks = B_Frame.LooksFrame,
            Stats = B_Frame.StatsFrame
        }
    }

    local config = {
        elements = elements,
        buttonOrder = BUTTON_NAMES,
        defaultButton = BUTTON_NAMES[1],
        closeOnSameButton = false,
        useSlideTransition = false
    }

    for buttonName, button in elements.Buttons do
        button.MouseButton1Click:Connect(function()
            UITweens.ShakeFrameAnimation(config, buttonName)
        end)
    end

    UITweens.InitButtonAnimations(A_Frame)
end

return InventoryUI