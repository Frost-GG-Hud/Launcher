--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                        FROST HUB                          ║
    ║           Modern, Smooth & Lightweight HUD Shell          ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Get Local Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- Fetch Game Name safely
local gameName = "Universal"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        gameName = productInfo.Name
    end
end)

-- Create Main Window
local Window = WindUI:CreateWindow({
    Title = "Frost Hub",
    Author = "by Frost Team",
    Icon = "snowflake",
    Folder = "FrostHub",
    Size = UDim2.fromOffset(620, 440),
    MinSize = Vector2.new(540, 360),
    MaxSize = Vector2.new(850, 580),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 190,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    ToggleKey = Enum.KeyCode.RightShift,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "User Profile",
                Content = "Logged in as " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")",
                Duration = 3,
                Icon = "user",
            })
        end,
    },
    OpenButton = {
        Title = "Frost Hub",
        Icon = "snowflake",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("#00b4d8"),
            Color3.fromHex("#0077b6")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

-- Topbar Tags
Window:Tag({
    Title = "v1.0.0",
    Color = Color3.fromHex("#00b4d8"),
})

Window:Tag({
    Title = "Universal",
    Color = Color3.fromHex("#48cae4"),
})

-- Initial Load Notification
WindUI:Notify({
    Title = "Frost Hub Initialized",
    Content = "Press Right Shift or click the Frost icon to toggle UI.",
    Duration = 4,
    Icon = "snowflake",
})

----------------------------------------------------------------------
-- TAB 1: HOME
----------------------------------------------------------------------
local TabHome = Window:Tab({
    Title = "Home",
    Icon = "home",
})

local HomeSectionInfo = TabHome:Section({
    Title = "Overview",
    Icon = "info",
    Opened = true,
})

HomeSectionInfo:Paragraph({
    Title = "Welcome to Frost Hub",
    Desc = "A modern, ultra-smooth interface designed for high performance and sleek aesthetics.",
    Image = "sparkles",
})

HomeSectionInfo:Paragraph({
    Title = "Current Game",
    Desc = string.format("%s (Place ID: %s)", gameName, tostring(game.PlaceId)),
    Image = "gamepad-2",
})

local HomeSectionQuick = TabHome:Section({
    Title = "Quick Actions",
    Icon = "zap",
    Opened = true,
})

HomeSectionQuick:Button({
    Title = "Send Test Notification",
    Desc = "Test the notification system",
    Icon = "bell",
    Callback = function()
        WindUI:Notify({
            Title = "Frost Hub",
            Content = "Smooth notification working flawlessly!",
            Duration = 3,
            Icon = "check-circle",
        })
    end,
})

HomeSectionQuick:Button({
    Title = "Copy Join Script",
    Desc = "Copy server join script to clipboard",
    Icon = "copy",
    Callback = function()
        local scriptText = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)', game.PlaceId, game.JobId)
        if setclipboard then
            setclipboard(scriptText)
            WindUI:Notify({
                Title = "Success",
                Content = "Join code copied to clipboard!",
                Duration = 2.5,
                Icon = "clipboard-check",
            })
        else
            WindUI:Notify({
                Title = "Notice",
                Content = "Your executor does not support setclipboard.",
                Duration = 3,
                Icon = "alert-circle",
            })
        end
    end,
})

----------------------------------------------------------------------
-- TAB 2: MAIN (Ready for your gameplay features)
----------------------------------------------------------------------
local TabMain = Window:Tab({
    Title = "Main",
    Icon = "layout-grid",
})

local MainSectionChar = TabMain:Section({
    Title = "Character",
    Icon = "user",
    Opened = true,
})

MainSectionChar:Toggle({
    Title = "Speed Boost",
    Desc = "Toggle custom movement speed",
    Value = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Speed Boost",
            Content = state and "Speed boost toggled ON" or "Speed boost toggled OFF",
            Duration = 2,
            Icon = state and "check" or "x",
        })
    end,
})

MainSectionChar:Slider({
    Title = "Walk Speed Value",
    Desc = "Set target walk speed",
    Value = {
        Min = 16,
        Max = 200,
        Default = 16,
    },
    Step = 1,
    Callback = function(val)
        -- Placeholder for character speed modification
    end,
})

MainSectionChar:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in air",
    Value = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Infinite Jump",
            Content = state and "Infinite jump enabled" or "Infinite jump disabled",
            Duration = 2,
            Icon = state and "check" or "x",
        })
    end,
})

local MainSectionWorld = TabMain:Section({
    Title = "World & Environment",
    Icon = "globe",
    Opened = true,
})

MainSectionWorld:Dropdown({
    Title = "Lighting Preset",
    Desc = "Choose a visual environment filter",
    Values = { "Normal", "Frost Blue", "Night Vision", "Warm Sunset", "High Contrast" },
    Value = "Normal",
    Callback = function(selected)
        WindUI:Notify({
            Title = "Lighting",
            Content = "Selected preset: " .. selected,
            Duration = 2,
            Icon = "sun",
        })
    end,
})

local MainSectionEgg = TabMain:Section({
    Title = "Egg & Collectibles",
    Icon = "egg",
    Opened = true,
})

MainSectionEgg:Toggle({
    Title = "Egg Detection Alert",
    Desc = "Notifies when collectibles spawn or are nearby",
    Value = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Egg Alert",
            Content = state and "Egg alerts enabled" or "Egg alerts disabled",
            Duration = 2,
            Icon = state and "bell" or "bell-off",
        })
    end,
})

MainSectionEgg:Dropdown({
    Title = "Target Egg Rarity",
    Desc = "Filter which egg rarity to monitor",
    Values = { "All", "Common", "Rare", "Epic", "Legendary" },
    Value = "All",
    Callback = function(selected)
        WindUI:Notify({
            Title = "Rarity Filter",
            Content = "Filter set to: " .. selected,
            Duration = 2,
            Icon = "filter",
        })
    end,
})

MainSectionEgg:Slider({
    Title = "Alert Distance (Studs)",
    Desc = "Distance threshold for egg notifications",
    Value = {
        Min = 10,
        Max = 200,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        -- Notification distance threshold
    end,
})

----------------------------------------------------------------------
-- TAB 3: VISUALS (Ready for ESP / Display features)
----------------------------------------------------------------------
local TabVisuals = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

local VisualsSectionEsp = TabVisuals:Section({
    Title = "ESP & Highlights",
    Icon = "scan",
    Opened = true,
})

VisualsSectionEsp:Toggle({
    Title = "Player Highlights",
    Desc = "Draw highlight boxes around players",
    Value = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Highlights",
            Content = state and "Highlights enabled" or "Highlights disabled",
            Duration = 2,
            Icon = "eye",
        })
    end,
})

VisualsSectionEsp:Toggle({
    Title = "Name Tags",
    Desc = "Show player display names and health",
    Value = false,
    Callback = function(state)
        -- Placeholder
    end,
})

VisualsSectionEsp:Colorpicker({
    Title = "Highlight Color",
    Desc = "Choose outline color for visual elements",
    Default = Color3.fromRGB(0, 180, 216),
    Callback = function(color)
        -- Placeholder
    end,
})

----------------------------------------------------------------------
-- TAB 4: SETTINGS & CUSTOMIZATION
----------------------------------------------------------------------
local TabSettings = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local SettingsSectionUI = TabSettings:Section({
    Title = "Interface",
    Icon = "palette",
    Opened = true,
})

SettingsSectionUI:Dropdown({
    Title = "Theme",
    Desc = "Switch UI appearance style",
    Values = WindUI:GetThemes(),
    Value = WindUI:GetCurrentTheme(),
    Callback = function(theme)
        Window:SetTheme(theme)
        WindUI:Notify({
            Title = "Theme Changed",
            Content = "Switched to " .. theme .. " theme.",
            Duration = 2,
            Icon = "palette",
        })
    end,
})

SettingsSectionUI:Slider({
    Title = "UI Scale",
    Desc = "Adjust the size of the interface",
    Value = {
        Min = 80,
        Max = 120,
        Default = 100,
    },
    Step = 5,
    Callback = function(val)
        Window:SetUIScale(val / 100)
    end,
})

SettingsSectionUI:Toggle({
    Title = "Window Acrylic Blur",
    Desc = "Toggle acrylic background effect",
    Value = true,
    Callback = function(state)
        Window:ToggleAcrylic(state)
    end,
})

local SettingsSectionConfig = TabSettings:Section({
    Title = "Hub Controls",
    Icon = "sliders",
    Opened = true,
})

SettingsSectionConfig:Keybind({
    Title = "Toggle Keybind",
    Desc = "Keyboard button to hide/show the menu",
    Value = Enum.KeyCode.RightShift,
    Callback = function(key)
        Window:SetToggleKey(key)
        WindUI:Notify({
            Title = "Keybind Updated",
            Content = "Menu toggle set to " .. tostring(key.Name),
            Duration = 2,
            Icon = "keyboard",
        })
    end,
})

SettingsSectionConfig:Button({
    Title = "Reset Window Position",
    Desc = "Re-centers the window on your screen",
    Icon = "crosshair",
    Callback = function()
        Window:SetToTheCenter()
    end,
})

SettingsSectionConfig:Button({
    Title = "Unload Frost Hub",
    Desc = "Cleanly removes the UI from your screen",
    Icon = "trash-2",
    Color = Color3.fromRGB(235, 87, 87),
    Callback = function()
        Window:Dialog({
            Title = "Unload Frost Hub",
            Content = "Are you sure you want to unload and close the interface?",
            Buttons = {
                {
                    Title = "Yes, Unload",
                    Variant = "Primary",
                    Callback = function()
                        Window:Destroy()
                    end,
                },
                {
                    Title = "Cancel",
                    Variant = "Secondary",
                    Callback = function() end,
                },
            },
        })
    end,
})

return Window
