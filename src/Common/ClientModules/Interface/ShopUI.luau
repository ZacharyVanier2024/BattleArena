type Elements = {
    Main: Frame,
    Buttons: {[string]: TextButton},
    Frames: {[string]: Frame},
    CanvasFrames: {[string]: Frame}
}

type Config = {
    elements: Elements,
    buttonOrder: {string},
    defaultButton: string,
    closeOnSameButton: boolean,
    useSlideTransition: boolean
}

local ShopUI = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

local BUTTON_NAMES = {"Boxes", "Products"}

function ShopUI:Init()
    local player = Players.LocalPlayer
    if not player then
        return
    end

    local playerGui = player:WaitForChild("PlayerGui")
    local Canvas = playerGui:WaitForChild("Main").Canvas
    
    local ShopFrame = Canvas.ShopFrame
    local A_Frame = ShopFrame.A_Frame
    local B_Frame = ShopFrame.B_Frame

    if not A_Frame or not B_Frame then
        return
    end

    local elements: Elements = {
        Main = A_Frame,
        Buttons = {
            Boxes = A_Frame.A_Boxes.TextButton,
            Products = A_Frame.B_Products.TextButton
        },
        Frames = {
            Boxes = A_Frame.A_Boxes,
            Products = A_Frame.B_Products
        },
        CanvasFrames = {
            Boxes = B_Frame.BoxesFrame,
            Products = B_Frame.ProductsFrame
        }
    }

    local config: Config = {
        elements = elements,
        buttonOrder = BUTTON_NAMES,
        defaultButton = BUTTON_NAMES[1],
        closeOnSameButton = false,
        useSlideTransition = false
    }

    for buttonName: string, button: TextButton in elements.Buttons do
        if button then
            button.MouseButton1Click:Connect(function()
                UITweens.ShakeFrameAnimation(config, buttonName)
            end)
        end
    end

    UITweens.InitButtonAnimations(A_Frame)
    
    if B_Frame.BoxesFrame and B_Frame.ProductsFrame then
        B_Frame.BoxesFrame.Visible = true
        B_Frame.ProductsFrame.Visible = false
    end
end

return ShopUI