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
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Configure WindUI Parent to avoid CoreGui/Plugin capability isolation
if WindUI and WindUI.SetParent and LocalPlayer then
    pcall(function()
        WindUI:SetParent(LocalPlayer:WaitForChild("PlayerGui"))
    end)
end
if WindUI and WindUI.Creator and WindUI.Creator.UpdateFont then
    local origUpdateFont = WindUI.Creator.UpdateFont
    WindUI.Creator.UpdateFont = function(u)
        WindUI.Creator.Font = u
        for _, x in next, WindUI.Creator.FontObjects do
            pcall(function()
                x.FontFace = Font.new(u, x.FontFace.Weight, x.FontFace.Style)
            end)
        end
    end
end

-- Fetch Game Name safely
local gameName = "Steal An Egg"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        gameName = productInfo.Name
    end
end)

-- Create Main Window
local Window = WindUI:CreateWindow({
    Title = string.format("Frost Hub, %s Script", gameName),
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
    Title = "V 0.0.1",
    Color = Color3.fromHex("#00b4d8"),
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


----------------------------------------------------------------------
-- AUTO EGG COLLECTOR & MOVEMENT ENGINE
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

local EggRecords
pcall(function()
    EggRecords = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("EggRecords"))
end)

local AssetEarnings
pcall(function()
    AssetEarnings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("AssetEarnings"))
end)

local CarrySignal = Instance.new("BindableEvent")
local DepositSignal = Instance.new("BindableEvent")

local AutoCollector = {
    Enabled = false,
    CurrentTarget = nil,
    TargetArea = "Any Area",
    TargetRarity = "All",
    MovementMethod = "Pathfinding", -- "Pathfinding", "Walk", "Tween"
    TweenSpeed = 60,
    WalkSpeed = 24,
    PathfindingSpeed = 32,
    CancelCurrentMovement = nil,
    IsCarrying = false,
    CarriedEggUid = nil,
    CarriedPayload = nil,
    StealByValueEnabled = false,
    MinEggValue = 0,
    MinEggValueRaw = "0",
    Stats = {
        Collected = 0,
    },
    Thread = nil,
}

local AutoPlanter = {
    Enabled = false,
    Stats = {
        Planted = 0,
    },
    Thread = nil,
}

-- Value Parsing & Formatting Helpers (Supports K, M, B, T)
local function parseValueString(str)
    if type(str) == "number" then return str end
    if type(str) ~= "string" then return 0 end
    str = str:gsub("%s+", ""):upper()
    local numStr, suffix = str:match("^([%d%.]+)([KMBGT]?)$")
    if not numStr then return tonumber(str) or 0 end
    local num = tonumber(numStr) or 0
    if suffix == "K" then
        return num * 1e3
    elseif suffix == "M" then
        return num * 1e6
    elseif suffix == "B" then
        return num * 1e9
    elseif suffix == "T" then
        return num * 1e12
    end
    return num
end

local function formatValue(num)
    if not num or num < 0 then return "0" end
    if num >= 1e12 then
        return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then
        return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num / 1e3)
    else
        return tostring(math.floor(num))
    end
end

-- Evaluates the actual post-hatch pet money income per second for an egg record
local function getEggHatchIncomePerSecond(eggRecord)
    if not eggRecord then return nil end
    local rate = nil
    pcall(function()
        if AssetEarnings and EggRecords and EggRecords.ToAssetItemData then
            local itemData = EggRecords.ToAssetItemData(eggRecord)
            if itemData then
                rate = AssetEarnings.RatePerSecond(itemData)
            end
        end
        if not rate and AssetEarnings and AssetEarnings.RatePerSecond and eggRecord.AssetCategory then
            rate = AssetEarnings.RatePerSecond({
                Category = eggRecord.AssetCategory,
                Scale = eggRecord.AssetScale or 1,
                Mutations = eggRecord.Mutations or {},
            })
        end
    end)
    return rate
end

-- Resolve Safe Area Position (Separate from player's plot!)
local function getSafeAreaPosition()
    local sz = Workspace:FindFirstChild("__OBJECTS")
        and Workspace.__OBJECTS:FindFirstChild("Areas")
        and Workspace.__OBJECTS.Areas:FindFirstChild("EggCarryBounds")
        and Workspace.__OBJECTS.Areas.EggCarryBounds:FindFirstChild("SafeZone")
    if sz then
        return Vector3.new(515, sz.Position.Y + 1.5, sz.Position.Z)
    end
    local sa = Workspace:FindFirstChild("__OBJECTS")
        and Workspace.__OBJECTS:FindFirstChild("Areas")
        and Workspace.__OBJECTS.Areas:FindFirstChild("StartArea")
    if sa then
        return sa.Position + Vector3.new(-25, 1.5, 0)
    end
    return Vector3.new(500, 68, -364)
end

-- Dynamically discover all game areas (including Cherry Blossom, Titan Temple, Cosmic, Light Dark, etc.)
local function getAvailableAreas()
    local areaSet = {}
    pcall(function()
        local configs = ReplicatedStorage.Data.Areas.Configs:GetChildren()
        for _, c in ipairs(configs) do
            areaSet[c.Name] = true
        end
    end)
    pcall(function()
        local ga = Workspace.__OBJECTS.Areas.GuardAreas:GetChildren()
        for _, c in ipairs(ga) do
            areaSet[c.Name] = true
        end
    end)
    pcall(function()
        if EggState and EggState.ReadFieldEggs then
            local data = EggState.ReadFieldEggs()
            if data and data.Records then
                for _, rec in pairs(data.Records) do
                    if rec and rec.AreaId then
                        areaSet[rec.AreaId] = true
                    end
                end
            end
        end
    end)
    local list = { "Any Area" }
    local sorted = {}
    for area in pairs(areaSet) do
        table.insert(sorted, area)
    end
    table.sort(sorted)
    for _, a in ipairs(sorted) do
        table.insert(list, a)
    end
    return list
end

-- Dynamically discover all egg rarities (Common, Uncommon, Rare, Epic, Legendary, Mythic, Cosmic, etc.)
local function getAvailableEggCategories()
    local raritySet = {}
    pcall(function()
        local configs = ReplicatedStorage.Data.Assets.Configs:GetChildren()
        for _, c in ipairs(configs) do
            pcall(function()
                local mod = require(c)
                if mod and mod.Rarity then
                    local name = type(mod.Rarity) == "table" and (mod.Rarity.DisplayName or mod.Rarity._id) or tostring(mod.Rarity)
                    if name and name ~= "" then
                        raritySet[name] = true
                    end
                end
            end)
        end
    end)
    local list = { "All" }
    local sorted = {}
    for r in pairs(raritySet) do
        table.insert(sorted, r)
    end
    table.sort(sorted)
    for _, r in ipairs(sorted) do
        table.insert(list, r)
    end
    return list
end


local function setupFieldEggNetworking()
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)
        if not net then return end
        local shiftedEvent = net:WaitForChild("RE/EggWorld/FieldEggShifted", 5)
        if not shiftedEvent or not shiftedEvent:IsA("RemoteEvent") then return end

        shiftedEvent.OnClientEvent:Connect(function(payload)
            if type(payload) ~= "table" then return end

            if payload.CarrierUserId == LocalPlayer.UserId and payload.State == "Carried" then
                AutoCollector.IsCarrying = true
                AutoCollector.CarriedEggUid = payload.Uid
                AutoCollector.CarriedPayload = payload
                if AutoCollector.CancelCurrentMovement then
                    AutoCollector.CancelCurrentMovement()
                end
                CarrySignal:Fire(payload)
            elseif (payload.Uid == AutoCollector.CarriedEggUid and (payload.State ~= "Carried" or payload.CarrierUserId ~= LocalPlayer.UserId))
                or (payload.CarrierUserId == LocalPlayer.UserId and payload.State ~= "Carried") then
                AutoCollector.IsCarrying = false
                AutoCollector.CarriedEggUid = nil
                AutoCollector.CarriedPayload = nil
                DepositSignal:Fire(payload)
            end
        end)
    end)

    pcall(function()
        if EggState and EggState.CarryChanged and typeof(EggState.CarryChanged.Connect) == "function" then
            EggState.CarryChanged:Connect(function(carrierUserId, eggUid)
                if carrierUserId == LocalPlayer.UserId then
                    AutoCollector.IsCarrying = true
                    AutoCollector.CarriedEggUid = eggUid
                    if AutoCollector.CancelCurrentMovement then
                        AutoCollector.CancelCurrentMovement()
                    end
                    CarrySignal:Fire({ CarrierUserId = carrierUserId, Uid = eggUid, State = "Carried" })
                elseif AutoCollector.CarriedEggUid == eggUid and carrierUserId ~= LocalPlayer.UserId then
                    AutoCollector.IsCarrying = false
                    AutoCollector.CarriedEggUid = nil
                    DepositSignal:Fire({ CarrierUserId = carrierUserId, Uid = eggUid, State = "None" })
                end
            end)
        end
    end)

    pcall(function()
        if EggState and EggState.FieldGone and typeof(EggState.FieldGone.Connect) == "function" then
            EggState.FieldGone:Connect(function(uid)
                if uid == AutoCollector.CarriedEggUid then
                    AutoCollector.IsCarrying = false
                    AutoCollector.CarriedEggUid = nil
                    DepositSignal:Fire({ Uid = uid, State = "Gone" })
                end
            end)
        end
    end)
end
task.spawn(setupFieldEggNetworking)

local statusParagraph = nil
local statsParagraph = nil

-- Movement UI element handles (single speed slider directly below Movement Method)
local tweenSpeedSlider = nil
local walkSpeedSlider = nil
local pathSpeedSlider = nil

local function updateMovementUIVisibility()
    local method = AutoCollector.MovementMethod
    local isTween = (method == "Tween")
    local isWalk = (method == "Walk")
    local isPath = (method == "Pathfinding")

    if tweenSpeedSlider and tweenSpeedSlider.ElementFrame then
        tweenSpeedSlider.ElementFrame.Visible = isTween
    end
    if walkSpeedSlider and walkSpeedSlider.ElementFrame then
        walkSpeedSlider.ElementFrame.Visible = isWalk
    end
    if pathSpeedSlider and pathSpeedSlider.ElementFrame then
        pathSpeedSlider.ElementFrame.Visible = isPath
    end
end

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
            statsParagraph:SetDesc(string.format("Collected: %d  |  Planted: %d", AutoCollector.Stats.Collected, AutoPlanter.Stats.Planted))
        end)
    end
end

local function isCarryingEgg()
    if AutoCollector.IsCarrying and AutoCollector.CarriedEggUid then
        return true, nil, AutoCollector.CarriedEggUid
    end

    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("ItemType") == "AssetEgg" or item:GetAttribute("UID") or item.Name:lower():find("egg")) then
                local uid = item:GetAttribute("UID") or "carried_egg"
                AutoCollector.IsCarrying = true
                AutoCollector.CarriedEggUid = uid
                return true, item, uid
            end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("ItemType") == "AssetEgg" or item:GetAttribute("UID") or item.Name:lower():find("egg")) then
                local uid = item:GetAttribute("UID") or "carried_egg"
                AutoCollector.IsCarrying = true
                AutoCollector.CarriedEggUid = uid
                return true, item, uid
            end
        end
    end

    if EggState and EggState.ReadFieldEggs then
        local eggsData = nil
        pcall(function() eggsData = EggState.ReadFieldEggs() end)
        if eggsData and eggsData.Records then
            for _, rec in pairs(eggsData.Records) do
                if rec and rec.State == "Carried" and rec.CarrierUserId == LocalPlayer.UserId then
                    AutoCollector.IsCarrying = true
                    AutoCollector.CarriedEggUid = rec.Uid
                    return true, nil, rec.Uid
                end
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
                local petRarity = nil
                pcall(function()
                    local cfg = ReplicatedStorage.Data.Assets.Configs:FindFirstChild(rec.AssetCategory)
                    if cfg then
                        local mod = require(cfg)
                        if mod and mod.Rarity then
                            petRarity = type(mod.Rarity) == "table" and (mod.Rarity.DisplayName or mod.Rarity._id) or tostring(mod.Rarity)
                        end
                    end
                end)
                if petRarity and petRarity == AutoCollector.TargetRarity then
                    rarityMatch = true
                elseif rec.AssetCategory == AutoCollector.TargetRarity then
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

            -- Steal by Value filter (Pet money income per second after hatch)
            local valueMatch = true
            local rate = nil
            if AutoCollector.StealByValueEnabled then
                rate = getEggHatchIncomePerSecond(rec)
                if not rate then
                    -- If the value cannot be determined yet, do not steal the egg
                    valueMatch = false
                elseif rate < AutoCollector.MinEggValue then
                    valueMatch = false
                end
            else
                rate = getEggHatchIncomePerSecond(rec)
            end

            if areaMatch and rarityMatch and valueMatch then
                table.insert(list, {
                    record = rec,
                    dist = dist,
                    pos = pos,
                    uid = rec.Uid,
                    name = rec.AssetCategory or "Unknown",
                    area = rec.AreaId or "World",
                    value = rate or 0,
                    valueFormatted = formatValue(rate or 0),
                })
            end
        end
    end

    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

----------------------------------------------------------------------
-- NAVIGATION STRATEGIES (Tween, Walk, Pathfinding)
----------------------------------------------------------------------

-- Calculate adaptive movement speed that respects game movement validation
local function getAdaptiveSpeed(requestedSpeed)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local legitimateSpeed = (hum and hum.WalkSpeed and hum.WalkSpeed > 0) and hum.WalkSpeed or 32
    local speed = tonumber(requestedSpeed) or legitimateSpeed
    -- Keep speed adaptive so it stays within reasonable movement limits
    if speed > legitimateSpeed then
        speed = legitimateSpeed
    end
    return math.max(16, speed)
end

-- 1. Tween Navigation
local function travelByTween(targetPos, stopDist, isApproachingEgg)
    stopDist = stopDist or 5
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    local initialDist = (hrp.Position - targetPos).Magnitude
    if initialDist <= stopDist then return true end

    local speed = getAdaptiveSpeed(AutoCollector.TweenSpeed)
    print("[AutoCollect] Movement started")
    print(string.format("[AutoCollect] Speed = %d", math.floor(speed)))

    local activeTween = nil
    local cancelled = false

    local function stopActiveTween()
        if activeTween then
            activeTween:Cancel()
            activeTween = nil
        end
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.new()
            hrp.AssemblyAngularVelocity = Vector3.new()
        end
    end

    AutoCollector.CancelCurrentMovement = function()
        cancelled = true
        stopActiveTween()
    end

    local arrived = false

    while not arrived and not cancelled and (AutoCollector.Enabled or AutoPlanter.Enabled) and AutoCollector.MovementMethod == "Tween" do
        char = LocalPlayer.Character
        if not char then break end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then break end

        if isApproachingEgg and AutoCollector.IsCarrying then
            cancelled = true
            break
        end

        local currentPos = hrp.Position
        local remainingDist = (currentPos - targetPos).Magnitude
        if remainingDist <= stopDist then
            arrived = true
            break
        end

        speed = getAdaptiveSpeed(AutoCollector.TweenSpeed)
        local stepDist = math.min(remainingDist, 35)
        local direction = (targetPos - currentPos).Unit
        local nextStepPos = currentPos + direction * stepDist

        -- Adjust Y to terrain height to avoid clipping under terrain or large CFrame jumps
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { char, Workspace:FindFirstChild("__OBJECTS") and Workspace.__OBJECTS:FindFirstChild("Areas") }
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(nextStepPos + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0), raycastParams)
        if hit and hit.Position then
            nextStepPos = Vector3.new(nextStepPos.X, hit.Position.Y + 2.5, nextStepPos.Z)
        end

        local stepDuration = stepDist / speed
        if stepDuration <= 0.02 then
            stepDuration = 0.05
        end

        stopActiveTween()
        local stepCFrame = CFrame.new(nextStepPos, nextStepPos + Vector3.new(direction.X, 0, direction.Z))

        hum:MoveTo(nextStepPos)

        activeTween = TweenService:Create(
            hrp,
            TweenInfo.new(stepDuration, Enum.EasingStyle.Linear),
            { CFrame = stepCFrame }
        )
        activeTween:Play()

        local pollStart = tick()
        while (tick() - pollStart) < stepDuration and not cancelled and (AutoCollector.Enabled or AutoPlanter.Enabled) and AutoCollector.MovementMethod == "Tween" do
            if isApproachingEgg and AutoCollector.IsCarrying then
                cancelled = true
                break
            end
            if (hrp.Position - targetPos).Magnitude <= stopDist then
                arrived = true
                break
            end
            task.wait(0.03)
        end

        if (hrp.Position - targetPos).Magnitude <= stopDist then
            arrived = true
            break
        end
    end

    stopActiveTween()
    AutoCollector.CancelCurrentMovement = nil

    if hrp and hrp.Parent then
        hrp.AssemblyLinearVelocity = Vector3.new()
    end

    return arrived or (isApproachingEgg and AutoCollector.IsCarrying)
end

-- 2. Direct Walk Navigation
local function travelByWalk(targetPos, stopDist, isApproachingEgg)
    stopDist = stopDist or 5
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= stopDist then return true end

    local speed = getAdaptiveSpeed(AutoCollector.WalkSpeed)
    hum.WalkSpeed = speed
    print("[AutoCollect] Movement started")
    print(string.format("[AutoCollect] Speed = %d", math.floor(speed)))

    local cancelled = false
    AutoCollector.CancelCurrentMovement = function()
        cancelled = true
        if hum and hrp and hrp.Parent then hum:MoveTo(hrp.Position) end
    end

    hum:MoveTo(targetPos)

    local lastPos = hrp.Position
    local lastMoveTime = tick()

    while not cancelled and (AutoCollector.Enabled or AutoPlanter.Enabled) and AutoCollector.MovementMethod == "Walk" do
        char = LocalPlayer.Character
        if not char then break end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then break end

        if isApproachingEgg and AutoCollector.IsCarrying then
            cancelled = true
            break
        end

        local currentDist = (hrp.Position - targetPos).Magnitude
        if currentDist <= stopDist then
            hum:MoveTo(hrp.Position)
            AutoCollector.CancelCurrentMovement = nil
            return true
        end

        speed = getAdaptiveSpeed(AutoCollector.WalkSpeed)
        hum.WalkSpeed = speed
        hum:MoveTo(targetPos)

        if (hrp.Position - lastPos).Magnitude > 0.8 then
            lastPos = hrp.Position
            lastMoveTime = tick()
        elseif tick() - lastMoveTime > 1.5 then
            hum.Jump = true
            lastMoveTime = tick()
        end

        task.wait(0.1)
    end

    if hum and hrp and hrp.Parent then hum:MoveTo(hrp.Position) end
    AutoCollector.CancelCurrentMovement = nil
    return (hrp.Position - targetPos).Magnitude <= (stopDist + 2) or (isApproachingEgg and AutoCollector.IsCarrying)
end

-- 3. Pathfinding Navigation
local function travelByPathfinding(targetPos, stopDist, isApproachingEgg)
    stopDist = stopDist or 5
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    if (hrp.Position - targetPos).Magnitude <= stopDist then
        return true
    end

    local speed = getAdaptiveSpeed(AutoCollector.PathfindingSpeed or AutoCollector.WalkSpeed)
    hum.WalkSpeed = speed
    print("[AutoCollect] Movement started")
    print(string.format("[AutoCollect] Speed = %d", math.floor(speed)))

    local cancelled = false
    AutoCollector.CancelCurrentMovement = function()
        cancelled = true
        if hum and hrp and hrp.Parent then hum:MoveTo(hrp.Position) end
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
        while not cancelled and (AutoCollector.Enabled or AutoPlanter.Enabled) and AutoCollector.MovementMethod == "Pathfinding" and (hrp.Position - targetPos).Magnitude > stopDist do
            if isApproachingEgg and AutoCollector.IsCarrying then break end
            if tick() - startTime > 10 then break end
            task.wait(0.1)
        end
        AutoCollector.CancelCurrentMovement = nil
        return (hrp.Position - targetPos).Magnitude <= (stopDist + 3) or (isApproachingEgg and AutoCollector.IsCarrying)
    end

    local waypoints = path:GetWaypoints()
    local lastPos = hrp.Position
    local lastMovedTime = tick()

    for idx, wp in ipairs(waypoints) do
        if cancelled or (not AutoCollector.Enabled and not AutoPlanter.Enabled) or AutoCollector.MovementMethod ~= "Pathfinding" then
            if hum and hrp and hrp.Parent then hum:MoveTo(hrp.Position) end
            AutoCollector.CancelCurrentMovement = nil
            return (isApproachingEgg and AutoCollector.IsCarrying) or false
        end

        if isApproachingEgg and AutoCollector.IsCarrying then
            if hum and hrp and hrp.Parent then hum:MoveTo(hrp.Position) end
            AutoCollector.CancelCurrentMovement = nil
            return true
        end

        char = LocalPlayer.Character
        if not char then break end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then break end

        if (hrp.Position - targetPos).Magnitude <= stopDist then
            hum:MoveTo(hrp.Position)
            AutoCollector.CancelCurrentMovement = nil
            return true
        end

        hum.WalkSpeed = getAdaptiveSpeed(AutoCollector.PathfindingSpeed or AutoCollector.WalkSpeed)

        if wp.Action == Enum.PathWaypointAction.Jump then
            hum.Jump = true
        end

        hum:MoveTo(wp.Position)

        local wpReached = false
        local wpStartTime = tick()

        while not wpReached and not cancelled and (AutoCollector.Enabled or AutoPlanter.Enabled) and AutoCollector.MovementMethod == "Pathfinding" do
            if isApproachingEgg and AutoCollector.IsCarrying then
                wpReached = true
                break
            end
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

            task.wait(0.04)
        end
    end

    if hum and hrp and hrp.Parent then hum:MoveTo(hrp.Position) end
    AutoCollector.CancelCurrentMovement = nil
    return (hrp.Position - targetPos).Magnitude <= (stopDist + 4) or (isApproachingEgg and AutoCollector.IsCarrying)
end

-- Strategy Dispatcher
local function travelTo(targetPos, stopDist, statusText, isApproachingEgg)
    if statusText then
        updateStatus(statusText, "navigation")
    end

    if AutoCollector.MovementMethod == "Tween" then
        return travelByTween(targetPos, stopDist, isApproachingEgg)
    elseif AutoCollector.MovementMethod == "Walk" then
        return travelByWalk(targetPos, stopDist, isApproachingEgg)
    else
        return travelByPathfinding(targetPos, stopDist, isApproachingEgg)
    end
end

----------------------------------------------------------------------
-- EGG COLLECTION & DEPOSIT
----------------------------------------------------------------------

local function collectEgg(eggInfo)
    local targetPos = eggInfo.pos
    local reached = travelTo(targetPos, 6, string.format("Approaching %s (%s)", eggInfo.name, AutoCollector.MovementMethod), true)

    if AutoCollector.IsCarrying then
        print("[AutoCollect] Egg equipped")
        print("[AutoCollect] State = Carried")
        return true, AutoCollector.CarriedEggUid or eggInfo.uid
    end

    if not reached or not AutoCollector.Enabled then
        local carrying, _, uid = isCarryingEgg()
        if carrying or AutoCollector.IsCarrying then
            print("[AutoCollect] Egg equipped")
            print("[AutoCollect] State = Carried")
            return true, uid or AutoCollector.CarriedEggUid or eggInfo.uid
        end
        return false, "Failed to navigate to egg"
    end

    updateStatus(string.format("Collecting %s egg...", eggInfo.name), "loader")

    -- 1. Trigger ProximityPrompt if in workspace
    for _, part in ipairs(Workspace:GetChildren()) do
        if part.Name == "SmartPromptPart" and (part.Position - targetPos).Magnitude <= 15 then
            local prompt = part:FindFirstChild("CarryAreaEgg")
            if prompt and prompt:IsA("ProximityPrompt") then
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                end
                break
            end
        end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Name == "CarryAreaEgg" and desc.Parent and desc.Parent:IsA("BasePart") and (desc.Parent.Position - targetPos).Magnitude <= 15 then
            if fireproximityprompt then
                fireproximityprompt(desc)
            end
            break
        end
    end

    -- 2. Server carry invocation fallback
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
        if net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry") then
            local pc = LocalPlayer:FindFirstChild("PlayerScripts")
                and LocalPlayer.PlayerScripts:FindFirstChild("Game")
                and LocalPlayer.PlayerScripts.Game:FindFirstChild("PlatformController")
            if pc then
                net["RF/EggWorld/AskFieldEggCarry"]:InvokeServer(pc)
            end
            net["RF/EggWorld/AskFieldEggCarry"]:InvokeServer({ Uid = eggInfo.uid })
        end
        if EggState and EggState.CarryFieldEgg then
            EggState.CarryFieldEgg(eggInfo.uid)
        end
    end)

    -- 3. Event-driven wait for carried state confirmation
    local carryConfirmed = false
    local carryConn = nil

    carryConn = CarrySignal.Event:Connect(function()
        carryConfirmed = true
    end)

    local startWait = tick()
    while tick() - startWait < 3 and AutoCollector.Enabled and not carryConfirmed do
        local carrying = isCarryingEgg()
        if carrying or AutoCollector.IsCarrying then
            carryConfirmed = true
            break
        end
        task.wait(0.05)
    end

    if carryConn then
        carryConn:Disconnect()
    end

    if carryConfirmed or AutoCollector.IsCarrying then
        print("[AutoCollect] Egg equipped")
        print("[AutoCollect] State = Carried")
        return true, AutoCollector.CarriedEggUid or eggInfo.uid
    end

    return false, "Collection confirmation timeout"
end

local function secureCarriedEggAtSafeArea(eggUid)
    local safePos = getSafeAreaPosition()
    print("[AutoCollect] Target = Safe Area")
    updateStatus(string.format("Returning to Safe Area (%s)...", AutoCollector.MovementMethod), "shield")

    local reached = travelTo(safePos, 8, string.format("Returning to Safe Area (%s)", AutoCollector.MovementMethod), false)
    if not reached or not AutoCollector.Enabled then
        return false, "Failed to navigate to safe area"
    end

    print("[AutoCollect] Arrived at Safe Area")
    updateStatus("Safe Area reached - Securing egg...", "check-circle")

    -- Complete normal egg collection/deposit interaction:
    -- Unequip the egg via server remote / EggState / Humanoid
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
        if net and net:FindFirstChild("RF/EggWorld/AskDoffTool") then
            net["RF/EggWorld/AskDoffTool"]:InvokeServer()
        end
    end)
    pcall(function()
        if EggState and EggState.DoffEggTool then
            EggState.DoffEggTool()
        end
    end)
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:UnequipTools()
        end
    end)

    -- Wait until unequipped / carried state clears
    local startWait = tick()
    while tick() - startWait < 2 and AutoCollector.Enabled do
        local carrying = isCarryingEgg()
        if not carrying and not AutoCollector.IsCarrying then
            break
        end
        task.wait(0.1)
    end

    AutoCollector.IsCarrying = false
    AutoCollector.CarriedEggUid = nil
    AutoCollector.CarriedPayload = nil
    print("[AutoCollect] Deposit completed")
    return true
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
            if carrying or AutoCollector.IsCarrying then
                if AutoCollector.CancelCurrentMovement then
                    AutoCollector.CancelCurrentMovement()
                end
                local secOk, secErr = secureCarriedEggAtSafeArea(uid or AutoCollector.CarriedEggUid)
                if secOk then
                    AutoCollector.Stats.Collected = AutoCollector.Stats.Collected + 1
                    updateStats()
                    WindUI:Notify({
                        Title = "Egg Secured!",
                        Content = "Egg successfully secured in Safe Area!",
                        Duration = 3,
                        Icon = "shield-check",
                    })
                else
                    updateStatus("Safe Area retry: " .. tostring(secErr), "alert-triangle")
                    task.wait(0.5)
                end
                continue
            end

            updateStatus("Scanning for eligible eggs...", "search")
            local eligible = getEligibleEggs()

            if #eligible == 0 then
                if AutoCollector.StealByValueEnabled then
                    updateStatus(string.format("No eggs found >= %s/s. Waiting...", formatValue(AutoCollector.MinEggValue)), "clock")
                else
                    updateStatus("No eligible eggs found. Waiting...", "clock")
                end
                task.wait(1.5)
                continue
            end

            local targetEgg = eligible[1]
            AutoCollector.CurrentTarget = targetEgg
            updateStatus(string.format("Navigating to %s ($%s/s, %d studs, %s)", targetEgg.name, targetEgg.valueFormatted, math.floor(targetEgg.dist), targetEgg.area), "navigation")

            local colOk, colUid = collectEgg(targetEgg)
            if not colOk or not AutoCollector.Enabled then
                if AutoCollector.IsCarrying then
                    colOk = true
                    colUid = AutoCollector.CarriedEggUid or targetEgg.uid
                else
                    updateStatus("Collection unsuccessful, checking next...", "refresh-cw")
                    task.wait(0.5)
                    continue
                end
            end

            -- IMMEDIATELY CANCEL EGG MOVEMENT AND SWITCH TARGET TO SAFE AREA
            if AutoCollector.CancelCurrentMovement then
                AutoCollector.CancelCurrentMovement()
            end

            local secOk, secErr = secureCarriedEggAtSafeArea(colUid or targetEgg.uid)
            if secOk then
                AutoCollector.Stats.Collected = AutoCollector.Stats.Collected + 1
                updateStats()
                WindUI:Notify({
                    Title = "Egg Secured!",
                    Content = string.format("Secured %s egg (%s, $%s/s) in Safe Area!", targetEgg.name, targetEgg.area, targetEgg.valueFormatted),
                    Duration = 3,
                    Icon = "shield-check",
                })
                updateStatus("Egg secured! Searching next egg...", "check")
                task.wait(0.5)
            else
                updateStatus("Securing issue: " .. tostring(secErr), "alert-triangle")
                task.wait(1)
            end
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum:MoveTo(hrp.Position)
        end
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new()
        end
        updateStatus("Idle - Auto Collect disabled", "pause")
    end)
end

local function stopAutoCollectLoop()
    AutoCollector.Enabled = false
    if AutoCollector.CancelCurrentMovement then
        AutoCollector.CancelCurrentMovement()
    end
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
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.new()
    end
    updateStatus("Idle - Auto Collect disabled", "pause")
end

----------------------------------------------------------------------
-- AUTO PLANT ENGINE (Independent Feature)
----------------------------------------------------------------------

local function getPlantableEggs()
    local list = {}
    local function scan(parent)
        if not parent then return end
        for _, item in ipairs(parent:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("ItemType") == "Asset" or item:GetAttribute("Category") or item:GetAttribute("UID")) then
                table.insert(list, {
                    tool = item,
                    uid = item:GetAttribute("UID"),
                    name = item:GetAttribute("Category") or item.Name,
                })
            end
        end
    end
    scan(LocalPlayer:FindFirstChild("Backpack"))
    scan(LocalPlayer.Character)
    return list
end

local function plantEggAtPlot(eggEntry)
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
        return false, "Player plot not found"
    end

    updateStatus(string.format("Planting %s in your plot (%s)...", eggEntry.name, AutoCollector.MovementMethod), "download")
    print(string.format("[Plant] Moving to plot to plant %s", eggEntry.name))

    local reached = travelTo(depositCFrame.Position, 5, string.format("Moving to plot (%s)", AutoCollector.MovementMethod))
    if not reached or not AutoPlanter.Enabled then
        return false, "Failed to navigate to plot"
    end

    print("[Plant] Plot reached - Planting egg")
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local tool = eggEntry.tool
    if tool and char and hum and tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.2)
    end

    local localCFrame = centerPart.CFrame:ToObjectSpace(depositCFrame)
    local targetUid = eggEntry.uid or (tool and tool:GetAttribute("UID"))

    pcall(function()
        if EggState and EggState.PlantEgg then
            EggState.PlantEgg(targetUid, localCFrame)
        else
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            if net and net:FindFirstChild("RF/EggWorld/AskPlaceEgg") then
                net["RF/EggWorld/AskPlaceEgg"]:InvokeServer({
                    Uid = targetUid,
                    LocalCFrame = localCFrame
                })
            end
        end
    end)

    if tool then
        pcall(function() tool:Activate() end)
    end

    -- Confirm planting succeeded: tool is consumed from backpack/character
    local startWait = tick()
    local confirmed = false
    while tick() - startWait < 4 and AutoPlanter.Enabled do
        if not tool or tool.Parent == nil or (tool.Parent ~= char and tool.Parent ~= LocalPlayer:FindFirstChild("Backpack")) then
            confirmed = true
            break
        end
        task.wait(0.1)
    end

    if confirmed then
        print(string.format("[Plant] Planting confirmed: %s", eggEntry.name))
        return true
    end

    return false, "Planting confirmation timeout"
end

local function startAutoPlantLoop()
    if AutoPlanter.Thread then
        task.cancel(AutoPlanter.Thread)
        AutoPlanter.Thread = nil
    end

    AutoPlanter.Thread = task.spawn(function()
        while AutoPlanter.Enabled do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 then
                updateStatus("Waiting for character respawn...", "alert-circle")
                LocalPlayer.CharacterAdded:Wait()
                task.wait(1.5)
                continue
            end

            local plantable = getPlantableEggs()
            if #plantable == 0 then
                updateStatus("No plantable eggs in inventory. Waiting...", "clock")
                task.wait(2)
                continue
            end

            local eggToPlant = plantable[1]
            local ok, err = plantEggAtPlot(eggToPlant)
            if ok then
                AutoPlanter.Stats.Planted = AutoPlanter.Stats.Planted + 1
                updateStats()
                WindUI:Notify({
                    Title = "Egg Planted!",
                    Content = string.format("Successfully planted %s in your pen! (Total: %d)", eggToPlant.name, AutoPlanter.Stats.Planted),
                    Duration = 3,
                    Icon = "check-circle",
                })
                task.wait(0.5)
            else
                updateStatus("Plant retry: " .. tostring(err), "alert-triangle")
                task.wait(1.5)
            end
        end
    end)
end

local function stopAutoPlantLoop()
    AutoPlanter.Enabled = false
    if AutoCollector.CancelCurrentMovement then
        AutoCollector.CancelCurrentMovement()
    end
    if AutoPlanter.Thread then
        task.cancel(AutoPlanter.Thread)
        AutoPlanter.Thread = nil
    end
    updateStatus("Idle - Auto Plant disabled", "pause")
end

----------------------------------------------------------------------
-- TAB 2: SECTIONS (Movement System & Egg Collectibles)
----------------------------------------------------------------------

local MainSectionMovement = TabMain:Section({
    Title = "Movement System",
    Icon = "navigation",
    Opened = true,
})

MainSectionMovement:Dropdown({
    Title = "Movement Method",
    Desc = "Choose travel system for egg collection",
    Values = { "Pathfinding", "Walk", "Tween" },
    Value = "Pathfinding",
    Callback = function(selected)
        if AutoCollector.CancelCurrentMovement then
            AutoCollector.CancelCurrentMovement()
        end
        AutoCollector.MovementMethod = selected
        updateMovementUIVisibility()
        WindUI:Notify({
            Title = "Movement Method",
            Content = "Switched to: " .. selected,
            Duration = 2,
            Icon = "navigation",
        })
    end,
})

tweenSpeedSlider = MainSectionMovement:Slider({
    Title = "Tween Speed",
    Desc = "Studs per second during tween travel",
    Value = {
        Min = 10,
        Max = 1000,
        Default = 215,
    },
    Step = 1,
    Callback = function(val)
        AutoCollector.TweenSpeed = val
    end,
})

walkSpeedSlider = MainSectionMovement:Slider({
    Title = "Walk Speed Changer",
    Desc = "Adjust character walk speed for movement testing",
    Value = {
        Min = 16,
        Max = 500,
        Default = 24,
    },
    Step = 1,
    Callback = function(val)
        AutoCollector.WalkSpeed = val
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    end,
})

pathSpeedSlider = MainSectionMovement:Slider({
    Title = "Pathfinding Speed",
    Desc = "Character speed while navigating waypoints",
    Value = {
        Min = 16,
        Max = 500,
        Default = 32,
    },
    Step = 1,
    Callback = function(val)
        AutoCollector.PathfindingSpeed = val
        if LocalPlayer.Character and AutoCollector.MovementMethod == "Pathfinding" then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    end,
})

-- Initialize UI visibility based on current movement method
updateMovementUIVisibility()

local MainSectionEgg = TabMain:Section({
    Title = "Egg & Collectibles",
    Icon = "egg",
    Opened = true,
})

MainSectionEgg:Toggle({
    Title = "Auto Collect Eggs",
    Desc = "Automates stealing eggs and securing them into the Safe Area",
    Value = false,
    Callback = function(state)
        AutoCollector.Enabled = state
        if state then
            startAutoCollectLoop()
            WindUI:Notify({
                Title = "Auto Collect Started",
                Content = string.format("Routine active using %s movement.", AutoCollector.MovementMethod),
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

MainSectionEgg:Toggle({
    Title = "Auto Plant Eggs",
    Desc = "Automates planting eggs from your inventory into your plot",
    Value = false,
    Callback = function(state)
        AutoPlanter.Enabled = state
        if state then
            startAutoPlantLoop()
            WindUI:Notify({
                Title = "Auto Plant Started",
                Content = "Planting eggs from inventory into pen.",
                Duration = 3,
                Icon = "play",
            })
        else
            stopAutoPlantLoop()
            WindUI:Notify({
                Title = "Auto Plant Stopped",
                Content = "Auto plant routine halted.",
                Duration = 2.5,
                Icon = "square",
            })
        end
    end,
})

MainSectionEgg:Toggle({
    Title = "Steal by Value",
    Desc = "Only steal eggs with post-hatch pet value above minimum",
    Value = false,
    Callback = function(state)
        AutoCollector.StealByValueEnabled = state
        WindUI:Notify({
            Title = "Steal by Value",
            Content = state and string.format("Enabled (Min: %s/s)", formatValue(AutoCollector.MinEggValue)) or "Disabled",
            Duration = 2,
            Icon = state and "dollar-sign" or "x",
        })
    end,
})

MainSectionEgg:Input({
    Title = "Steal By Value",
    Desc = "Minimum value; supports k, m, b",
    Value = "0",
    Placeholder = "e.g. 1M, 500K, 3K, 5B",
    Callback = function(text)
        AutoCollector.MinEggValueRaw = text
        AutoCollector.MinEggValue = parseValueString(text)
        WindUI:Notify({
            Title = "Min Egg Value",
            Content = string.format("Threshold set to: %s/sec ($%d)", formatValue(AutoCollector.MinEggValue), math.floor(AutoCollector.MinEggValue)),
            Duration = 2,
            Icon = "dollar-sign",
        })
    end,
})

statusParagraph = MainSectionEgg:Paragraph({
    Title = "Collector Status",
    Desc = "Idle - Toggle Auto Collect to begin",
    Image = "activity",
})

MainSectionEgg:Dropdown({
    Title = "Target Area Filter",
    Desc = "Limit collection to specific world areas",
    Values = getAvailableAreas(),
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
    Values = getAvailableEggCategories(),
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


----------------------------------------------------------------------
-- TAB 4: SETTINGS
----------------------------------------------------------------------
local TabSettings = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local SettingsSection = TabSettings:Section({
    Title = "Settings",
    Icon = "sliders",
    Opened = true,
})

return Window
