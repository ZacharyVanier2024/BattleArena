--!strict

local Players = game:GetService("Players")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

type ButtonName = "Boxes" | "Products"
type Config = {
    elements: {
        Main: Frame,
        Buttons: {[ButtonName]: GuiButton},
        Frames: {[ButtonName]: Frame},
        WhiteLine: Frame,
    },
    buttonOrder: {ButtonName},
    defaultButton: ButtonName
}

type ShopUI = {
    Init: () -> ()
}

local ShopUI: ShopUI = {}

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
if not playerGui then return end

local shop = playerGui:WaitForChild("Shop") :: ScreenGui
if not shop then return end

local mainFrame = shop:WaitForChild("MainFrame")

local config: UITweens.UIConfig = {
    elements = {
        Main = mainFrame,
        Buttons = {
            Boxes = mainFrame:WaitForChild("Boxes"),
            Products = mainFrame:WaitForChild("Products"),
        },
        Frames = {
            Boxes = mainFrame:WaitForChild("BoxFrame"),
            Products = mainFrame:WaitForChild("ProductsFrame"),
        },
        WhiteLine = mainFrame:WaitForChild("WhiteLine"),
    },
    buttonOrder = {"Boxes", "Products"},
    defaultButton = "Boxes",
    useSlideTransition = false
}

local function setupFramePositions(): ()
    for _, frame in config.elements.Frames :: {[ButtonName]: Frame} do
        if frame then
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.Position = UDim2.fromScale(0.5, 0.5)
            frame.Visible = false
        end
    end
end

function ShopUI.Init(): ()
    setupFramePositions()
    UITweens.initializeUI(config)
end

return ShopUI