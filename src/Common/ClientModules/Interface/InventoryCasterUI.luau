--!strict

local Players = game:GetService("Players")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

type Config = {
    elements: {
        Main: Frame,
        Buttons: {
            Items: GuiButton,
            Looks: GuiButton,
            Stats: GuiButton,
        },
        Frames: {
            Items: Frame,
            Looks: Frame,
            Stats: Frame,
        },
        WhiteLine: Frame,
    },
    buttonOrder: {string},
    defaultButton: string
}

type InventoryCasterUI = {
    Init: () -> ()
}

local InventoryCasterUI: InventoryCasterUI = {}

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")
if not playerGui then return end

local inventoryCaster = playerGui:WaitForChild("InventoryCaster") :: ScreenGui
if not inventoryCaster then return end

local config: Config = {
    elements = {
        Main = inventoryCaster.MainFrame,
        Buttons = {
            Items = inventoryCaster.MainFrame.Items,
            Looks = inventoryCaster.MainFrame.Looks,
            Stats = inventoryCaster.MainFrame.Stats,
        },
        Frames = {
            Items = inventoryCaster.MainFrame.ItemsFrame,
            Looks = inventoryCaster.MainFrame.CustomizeFrame,
            Stats = inventoryCaster.MainFrame.StatsFrame,
        },
        WhiteLine = inventoryCaster.MainFrame.WhiteLine,
    },
    buttonOrder = {"Items", "Looks", "Stats"},
    defaultButton = "Items"
}

local function setupFramePositions()
    for _, frame in config.elements.Frames :: {[string]: Frame} do
        if frame then
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.Position = UDim2.fromScale(0.5, 0.5)
            frame.Visible = false
        end
    end
end

function InventoryCasterUI.Init(): ()
    setupFramePositions()
    UITweens.initializeUI(config)
end

return InventoryCasterUI