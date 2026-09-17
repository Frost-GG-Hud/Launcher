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
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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

local customSpeedEnabled = false
local customSpeedValue = 16
local infiniteJumpEnabled = false

local function applySpeed()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = customSpeedEnabled and customSpeedValue or 16
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum and customSpeedEnabled then
        hum.WalkSpeed = customSpeedValue
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

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
        customSpeedEnabled = state
        applySpeed()
        WindUI:Notify({
            Title = "Speed Boost",
            Content = state and string.format("Speed boost active (%d)", customSpeedValue) or "Speed boost toggled OFF",
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
        customSpeedValue = val
        if customSpeedEnabled then
            applySpeed()
        end
    end,
})

MainSectionChar:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in air",
    Value = false,
    Callback = function(state)
        infiniteJumpEnabled = state
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

----------------------------------------------------------------------
-- AUTO EGG COLLECTOR ENGINE
----------------------------------------------------------------------
local EggState
pcall(function()
    EggState = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("EggState"))
end)

local PlotState
pcall(function()
    PlotState = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PlotState"))
end)

local MilestoneAdapter
pcall(function()
    local sp = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    local ga = sp and sp:FindFirstChild("Game") and sp.Game:FindFirstChild("GuardAreas")
    if ga and ga:FindFirstChild("GuardTutorialController") and ga.GuardTutorialController:FindFirstChild("MilestoneAdapter") then
        MilestoneAdapter = require(ga.GuardTutorialController.MilestoneAdapter)
    end
end)

local AutoCollector = {
    Enabled = false,
    CurrentTarget = nil,
    TargetArea = "Any Area",
    TargetRarity = "All",
    Stats = {
        Collected = 0,
        Deposited = 0,
    },
    Thread = nil,
}

local statusParagraph = nil
local statsParagraph = nil

local function updateStatus(text, icon)
    if statusParagraph then
        pcall(function()
            statusParagraph:SetDesc(text)
            if icon and statusParagraph.SetImage then
                statusParagraph:SetImage(icon)
            end
        end)
    end
end

local function updateStats()
    if statsParagraph then
        pcall(function()
            statsParagraph:SetDesc(string.format("Deposited: %d  |  Collected: %d", AutoCollector.Stats.Deposited, AutoCollector.Stats.Collected))
        end)
    end
end

local function isCarryingEgg()
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("ItemType") == "AssetEgg" then
                return true, item, item:GetAttribute("UID")
            end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("ItemType") == "AssetEgg" then
                return true, item, item:GetAttribute("UID")
            end
        end
    end
    return false, nil, nil
end

local function getEligibleEggs()
    local eggsData = nil
    if EggState and EggState.ReadFieldEggs then
        pcall(function() eggsData = EggState.ReadFieldEggs() end)
    end
    if not eggsData or not eggsData.Records then
        pcall(function()
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            if net and net:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot") then
                eggsData = net["RF/EggWorld/AskFieldEggSnapshot"]:InvokeServer()
            end
        end)
    end

    local list = {}
    if not eggsData or not eggsData.Records then return list end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.new()

    for _, rec in pairs(eggsData.Records) do
        if rec and (rec.State == "Slot" or rec.State == "Dropped") and rec.BottomCFrame then
            local pos = rec.BottomCFrame.Position
            local dist = (myPos - pos).Magnitude

            -- Area filter
            local areaMatch = (AutoCollector.TargetArea == "Any Area") or (rec.AreaId == AutoCollector.TargetArea)

            -- Rarity filter
            local rarityMatch = (AutoCollector.TargetRarity == "All")
            if not rarityMatch and rec.AssetCategory then
                if rec.AssetCategory == AutoCollector.TargetRarity then
                    rarityMatch = true
                elseif rec.Mutations and #rec.Mutations > 0 then
                    for _, mut in ipairs(rec.Mutations) do
                        if mut == AutoCollector.TargetRarity then
                            rarityMatch = true
                            break
                        end
                    end
                end
            end

            if areaMatch and rarityMatch then
                table.insert(list, {
                    record = rec,
                    dist = dist,
                    pos = pos,
                    uid = rec.Uid,
                    name = rec.AssetCategory or "Unknown",
                    area = rec.AreaId or "World",
                })
            end
        end
    end

    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function walkTo(targetPos, stopDist)
    stopDist = stopDist or 5
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    if (hrp.Position - targetPos).Magnitude <= stopDist then
        return true
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4,
    })

    local success, _ = pcall(function()
        path:ComputeAsync(hrp.Position, targetPos)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        hum:MoveTo(targetPos)
        local startTime = tick()
        while AutoCollector.Enabled and (hrp.Position - targetPos).Magnitude > stopDist do
            if tick() - startTime > 10 then break end
            task.wait(0.2)
        end
        return (hrp.Position - targetPos).Magnitude <= (stopDist + 3)
    end

    local waypoints = path:GetWaypoints()
    local lastPos = hrp.Position
    local lastMovedTime = tick()

    for idx, wp in ipairs(waypoints) do
        if not AutoCollector.Enabled then
            hum:MoveTo(hrp.Position)
            return false
        end

        char = LocalPlayer.Character
        if not char then return false end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return false end

        if (hrp.Position - targetPos).Magnitude <= stopDist then
            hum:MoveTo(hrp.Position)
            return true
        end

        if wp.Action == Enum.PathWaypointAction.Jump then
            hum.Jump = true
        end

        hum:MoveTo(wp.Position)

        local wpReached = false
        local wpStartTime = tick()

        while not wpReached and AutoCollector.Enabled do
            local distToWp = (hrp.Position - wp.Position).Magnitude
            if distToWp <= 3.5 or (hrp.Position - targetPos).Magnitude <= stopDist then
                wpReached = true
                break
            end

            if (hrp.Position - lastPos).Magnitude > 0.8 then
                lastPos = hrp.Position
                lastMovedTime = tick()
            elseif tick() - lastMovedTime > 1.8 then
                hum.Jump = true
                hum:MoveTo(targetPos)
                lastMovedTime = tick()
            end

            if tick() - wpStartTime > 3.5 then
                break
            end

            task.wait(0.05)
        end
    end

    hum:MoveTo(hrp.Position)
    return (hrp.Position - targetPos).Magnitude <= (stopDist + 4)
end

local function collectEgg(eggInfo)
    local targetPos = eggInfo.pos
    local reached = walkTo(targetPos, 6)
    if not reached or not AutoCollector.Enabled then
        return false, "Failed to navigate to egg"
    end

    updateStatus(string.format("Collecting %s egg...", eggInfo.name), "loader")

    -- Trigger ProximityPrompt if in workspace
    for _, part in ipairs(Workspace:GetChildren()) do
        if part.Name == "SmartPromptPart" and (part.Position - targetPos).Magnitude <= 12 then
            local prompt = part:FindFirstChild("CarryAreaEgg")
            if prompt and prompt:IsA("ProximityPrompt") then
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                end
                break
            end
        end
    end

    -- Trigger server carry action legitimately
    pcall(function()
        if EggState and EggState.CarryFieldEgg then
            EggState.CarryFieldEgg(eggInfo.uid)
        else
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            if net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry") then
                net["RF/EggWorld/AskFieldEggCarry"]:InvokeServer(eggInfo.uid)
            end
        end
    end)

    -- Wait for carried state confirmation
    local startWait = tick()
    while tick() - startWait < 4 and AutoCollector.Enabled do
        local carrying, tool, uid = isCarryingEgg()
        if carrying then
            return true, uid or eggInfo.uid
        end
        task.wait(0.15)
    end

    return false, "Collection confirmation timeout"
end

local function depositEgg(eggUid)
    updateStatus("Navigating to pen deposit area...", "map-pin")

    local plotData = nil
    if PlotState and PlotState.ResolvePlot then
        pcall(function() plotData = PlotState.ResolvePlot() end)
    end

    local depositCFrame = nil
    local centerPart = nil

    if plotData then
        centerPart = plotData.CenterPoint
        if plotData.PetArea then
            depositCFrame = plotData.PetArea.CFrame + Vector3.new(0, 1.5, 0)
        elseif plotData.RespawnPointCFrame then
            depositCFrame = plotData.RespawnPointCFrame
        end
    end

    if MilestoneAdapter then
        pcall(function()
            local adapter = MilestoneAdapter.new()
            local cf = adapter:GetEggPlacementBillboardCFrame()
            if cf then depositCFrame = cf end
        end)
    end

    if not depositCFrame or not centerPart then
        for _, p in ipairs(Workspace.Plots:GetChildren()) do
            local sign = p:FindFirstChild("PlotSign")
            if sign then
                local sg = sign:FindFirstChildWhichIsA("SurfaceGui", true) or sign:FindFirstChildWhichIsA("BillboardGui", true)
                local tl = sg and sg:FindFirstChildWhichIsA("TextLabel", true)
                if tl and (tl.Text == LocalPlayer.DisplayName or tl.Text == LocalPlayer.Name) then
                    centerPart = p:FindFirstChild("CenterPoint")
                    local tu = p:FindFirstChild("ToUpdate")
                    local pa = tu and tu:FindFirstChild("PetArea")
                    depositCFrame = pa and (pa.CFrame + Vector3.new(0, 1.5, 0)) or (p:GetPivot() + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end

    if not depositCFrame or not centerPart then
        return false, "Plot not found"
    end

    local reached = walkTo(depositCFrame.Position, 5)
    if not reached or not AutoCollector.Enabled then
        return false, "Failed to navigate to pen"
    end

    updateStatus("Depositing egg in pen...", "download")

    local carrying, tool, uid = isCarryingEgg()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if tool and char and hum and tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.2)
    end

    local localCFrame = centerPart.CFrame:ToObjectSpace(depositCFrame)

    pcall(function()
        if EggState and EggState.PlantEgg then
            EggState.PlantEgg(eggUid or uid, localCFrame)
        else
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            if net and net:FindFirstChild("RF/EggWorld/AskPlaceEgg") then
                net["RF/EggWorld/AskPlaceEgg"]:InvokeServer({
                    Uid = eggUid or uid,
                    LocalCFrame = localCFrame
                })
            end
        end
    end)

    if tool then
        pcall(function() tool:Activate() end)
    end

    local startWait = tick()
    while tick() - startWait < 4 and AutoCollector.Enabled do
        local stillCarrying = isCarryingEgg()
        if not stillCarrying then
            return true
        end
        task.wait(0.15)
    end

    return false, "Deposit confirmation timeout"
end

local function startAutoCollectLoop()
    if AutoCollector.Thread then
        task.cancel(AutoCollector.Thread)
        AutoCollector.Thread = nil
    end

    AutoCollector.Thread = task.spawn(function()
        while AutoCollector.Enabled do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 then
                updateStatus("Waiting for character respawn...", "alert-circle")
                LocalPlayer.CharacterAdded:Wait()
                task.wait(1.5)
                continue
            end

            local carrying, tool, uid = isCarryingEgg()
            if carrying then
                updateStatus("Carrying egg - returning to pen...", "arrow-left-circle")
                local depOk, depErr = depositEgg(uid)
                if depOk then
                    AutoCollector.Stats.Deposited = AutoCollector.Stats.Deposited + 1
                    updateStats()
                    WindUI:Notify({
                        Title = "Egg Deposited!",
                        Content = "Egg successfully placed in pen!",
                        Duration = 3,
                        Icon = "check-circle",
                    })
                else
                    updateStatus("Deposit retry: " .. tostring(depErr), "alert-triangle")
                    task.wait(1.5)
                end
                continue
            end

            updateStatus("Scanning for eligible eggs...", "search")
            local eligible = getEligibleEggs()

            if #eligible == 0 then
                updateStatus("No eligible eggs found. Waiting...", "clock")
                task.wait(2)
                continue
            end

            local targetEgg = eligible[1]
            AutoCollector.CurrentTarget = targetEgg
            updateStatus(string.format("Navigating to %s (%d studs, %s)", targetEgg.name, math.floor(targetEgg.dist), targetEgg.area), "navigation")

            local colOk, colUid = collectEgg(targetEgg)
            if not colOk or not AutoCollector.Enabled then
                updateStatus("Collection unsuccessful, checking next...", "refresh-cw")
                task.wait(1)
                continue
            end

            AutoCollector.Stats.Collected = AutoCollector.Stats.Collected + 1
            updateStats()
            WindUI:Notify({
                Title = "Egg Collected!",
                Content = string.format("Secured %s egg (%s)", targetEgg.name, targetEgg.area),
                Duration = 2.5,
                Icon = "egg",
            })

            local depOk, depErr = depositEgg(colUid or targetEgg.uid)
            if depOk then
                AutoCollector.Stats.Deposited = AutoCollector.Stats.Deposited + 1
                updateStats()
                WindUI:Notify({
                    Title = "Egg Deposited!",
                    Content = string.format("Placed %s egg into pen!", targetEgg.name),
                    Duration = 3,
                    Icon = "check-circle",
                })
                updateStatus("Deposit complete! Searching next egg...", "check")
                task.wait(0.8)
            else
                updateStatus("Deposit issue: " .. tostring(depErr), "alert-triangle")
                task.wait(1.5)
            end
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum:MoveTo(hrp.Position)
        end
        updateStatus("Idle - Auto Collect disabled", "pause")
    end)
end

local function stopAutoCollectLoop()
    AutoCollector.Enabled = false
    if AutoCollector.Thread then
        task.cancel(AutoCollector.Thread)
        AutoCollector.Thread = nil
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        hum:MoveTo(hrp.Position)
    end
    updateStatus("Idle - Auto Collect disabled", "pause")
end

local MainSectionEgg = TabMain:Section({
    Title = "Egg & Collectibles",
    Icon = "egg",
    Opened = true,
})

MainSectionEgg:Toggle({
    Title = "Auto Collect Eggs",
    Desc = "Automates moving to eggs, collecting them, and depositing into your pen",
    Value = false,
    Callback = function(state)
        AutoCollector.Enabled = state
        if state then
            startAutoCollectLoop()
            WindUI:Notify({
                Title = "Auto Collect Started",
                Content = "Automatic egg collection routine is active.",
                Duration = 3,
                Icon = "play",
            })
        else
            stopAutoCollectLoop()
            WindUI:Notify({
                Title = "Auto Collect Stopped",
                Content = "Automatic egg collection routine halted.",
                Duration = 2.5,
                Icon = "square",
            })
        end
    end,
})

statusParagraph = MainSectionEgg:Paragraph({
    Title = "Collector Status",
    Desc = "Idle - Toggle Auto Collect to begin",
    Image = "activity",
})

statsParagraph = MainSectionEgg:Paragraph({
    Title = "Session Statistics",
    Desc = "Deposited: 0  |  Collected: 0",
    Image = "bar-chart-2",
})

MainSectionEgg:Dropdown({
    Title = "Target Area Filter",
    Desc = "Limit collection to specific world areas",
    Values = { "Any Area", "Forest", "Lake", "Snow", "Volcano", "Cosmic" },
    Value = "Any Area",
    Callback = function(selected)
        AutoCollector.TargetArea = selected
        WindUI:Notify({
            Title = "Area Filter",
            Content = "Target area set to: " .. selected,
            Duration = 2,
            Icon = "map-pin",
        })
    end,
})

MainSectionEgg:Dropdown({
    Title = "Target Egg Rarity",
    Desc = "Filter which egg rarity to monitor",
    Values = { "All", "Common", "Rare", "Epic", "Legendary" },
    Value = "All",
    Callback = function(selected)
        AutoCollector.TargetRarity = selected
        WindUI:Notify({
            Title = "Rarity Filter",
            Content = "Filter set to: " .. selected,
            Duration = 2,
            Icon = "filter",
        })
    end,
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
