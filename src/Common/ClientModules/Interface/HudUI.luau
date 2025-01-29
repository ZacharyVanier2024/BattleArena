--!strict

local HudUI = {}

local Players = game:GetService("Players")
local UITweens = require(script.Parent.Parent.Handlers.UITweens)

type ButtonName = "Personal" | "Trade" | "Shop" | "Crafting" | "Settings"

type GuiScreen = ScreenGui & {
    MainFrame: Frame
}

type HudGui = Frame & {
    TabHolder: Frame & {
        Personal: GuiButton,
        Trade: GuiButton,
        Shop: GuiButton,
        Crafting: GuiButton,
        Settings: GuiButton,
    }
}

local player = Players.LocalPlayer
assert(player, "Player not found")

local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local hud = playerGui:WaitForChild("HUD") :: HudGui
local tabHolder = hud.TabHolder

local guiScreens = {
    InventoryCaster = playerGui:WaitForChild("InventoryCaster") :: GuiScreen,
    Trade = playerGui:WaitForChild("Trade") :: GuiScreen,
    Shop = playerGui:WaitForChild("Shop") :: GuiScreen, 
    Crafting = playerGui:WaitForChild("Crafting") :: GuiScreen,
    Settings = playerGui:WaitForChild("Settings") :: GuiScreen
}

local config: UITweens.UIConfig = {
    elements = {
        Main = hud,
        Buttons = {
            Personal = tabHolder.Personal,
            Trade = tabHolder.Trade,
            Shop = tabHolder.Shop,
            Crafting = tabHolder.Crafting,
            Settings = tabHolder.Settings,
        },
        Frames = {
            Personal = guiScreens.InventoryCaster.MainFrame,
            Trade = guiScreens.Trade.MainFrame,
            Shop = guiScreens.Shop.MainFrame,
            Crafting = guiScreens.Crafting.MainFrame,
            Settings = guiScreens.Settings.MainFrame,
        },
        Screens = {
            Personal = guiScreens.InventoryCaster,
            Trade = guiScreens.Trade,
            Shop = guiScreens.Shop,
            Crafting = guiScreens.Crafting,
            Settings = guiScreens.Settings,
        }
    },
    buttonOrder = {"Personal", "Trade", "Shop", "Crafting", "Settings"},
    defaultButton = "Personal",
    closeOnSameButton = true,
    useSlideTransition = true
}

function HudUI.Init(): ()
    UITweens.initializeUI(config)
    UITweens.InitButtonAnimations(player.PlayerGui)
end

return HudUI