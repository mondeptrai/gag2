--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           Grow Garden 2 - Ultimate Auto Farm                ║
    ║                    Main Script (Core)                        ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  Auto-enabled features for new players:                     ║
    ║  • Auto Harvest • Auto Sell • Auto Plant • Auto Water      ║
    ║  • Auto Buy Seeds • Auto Buy Gears • Auto Buy Pets          ║
    ║  • Auto Pickup Events • Auto Redeem Codes                  ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- Key Authentication
if not getgenv().Key or getgenv().Key == "ENTER_YOUR_KEY_HERE" then
    warn("❌ Invalid or missing key! Please set your key in Loader.lua")
    return
end

-- Wait for game to load
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration (from Loader)
local Config = getgenv().GardenConfig or {}

-- Networking Module
local Networking = nil

-- Auto Farm Settings
local AutoSettings = {
    AutoHarvest = true,
    AutoSell = true,
    AutoBuySeeds = true,
    AutoBuyGears = true,
    AutoBuyPets = true,
    AutoPlant = true,
    AutoWater = true,
    AutoPickupRainbow = true,
    AutoPickupGold = true,
    AutoHarvestSpecial = true,
    AutoPlaceSprinkler = true,
    AutoSendPets = true,
    AutoSendSeeds = true,
    AutoRedeemCode = true,
    LowEffect = true,
    FPSCap = 5,
    HarvestDelay = 0.05,
    SellDelay = 0.1,
    BuyDelay = 0.02,
    SendPetUsername = "",
    SendSeedUsername = "",
    SendPetNote = "pet mail",
    SendSeedNote = "seed mail",
    DiscordWebhook = "",
    DiscordNotifications = {RainbowSeeds = true, GoldSeeds = true, Pets = true},
}

-- Seed Limits
local SeedPlantLimits = {
    ["Carrot"] = 50, ["Strawberry"] = 50, ["Blueberry"] = 50, ["Tulip"] = 50,
    ["Tomato"] = 50, ["Apple"] = 50, ["Corn"] = 50, ["Cactus"] = 50,
    ["Pineapple"] = 50, ["Bamboo"] = 20, ["Mushroom"] = 20, ["Green Bean"] = 20,
    ["Banana"] = 20, ["Grape"] = 20, ["Coconut"] = 20, ["Mango"] = 20,
    ["Dragon Fruit"] = 20, ["Acorn"] = 20, ["Cherry"] = 20, ["Sunflower"] = 20,
    ["Venus Fly Trap"] = 10, ["Pomegranate"] = 10, ["Poison Apple"] = 10,
    ["Venom Spitter"] = 10,
}

local SeedBuyLimits = {}
for seed, _ in pairs(SeedPlantLimits) do
    SeedBuyLimits[seed] = 9999
end

-- Seed Values (for priority planting)
local SeedValues = {
    ["Mushroom"] = 100, ["Moon Bloom"] = 99, ["Lotus"] = 98, ["Dragon's Breath"] = 97,
    ["Venus Fly Trap"] = 96, ["Ghost Pepper"] = 95, ["Sunflower"] = 93, ["Poison Ivy"] = 92,
    ["Poison Apple"] = 90, ["Pomegranate"] = 89, ["Venom Spitter"] = 88,
    ["Bamboo"] = 80, ["Cacao"] = 85, ["Horned Melon"] = 82, ["Papaya"] = 81,
    ["Banana"] = 70, ["Grape"] = 68, ["Dragon Fruit"] = 66, ["Mango"] = 64,
    ["Coconut"] = 62, ["Pineapple"] = 60, ["Cherry"] = 58, ["Acorn"] = 56,
    ["Corn"] = 50, ["Apple"] = 48, ["Tomato"] = 46, ["Watermelon"] = 44,
    ["Lemon"] = 42, ["Cactus"] = 40, ["Green Bean"] = 38,
    ["Blueberry"] = 30, ["Tulip"] = 28, ["Strawberry"] = 26,
    ["Carrot"] = 20,
}

-- Special Seeds
local SpecialSeeds = {
    "Rainbow Strawberry", "Rainbow Blueberry", "Rainbow Apple", "Rainbow Corn",
    "Rainbow Grape", "Rainbow Pineapple", "Rainbow Banana", "Rainbow Melon",
    "Rainbow Dragon Fruit", "Rainbow Mango", "Rainbow Lotus", "Rainbow Moon Bloom",
    "Gold Strawberry", "Gold Blueberry", "Gold Apple", "Gold Corn",
    "Gold Grape", "Gold Pineapple", "Gold Banana", "Gold Melon",
    "Gold Dragon Fruit", "Gold Mango", "Gold Lotus", "Gold Moon Bloom",
}

-- Create Simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 250, 0, 170)
Frame.Position = UDim2.new(0.01, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.BackgroundTransparency = 0.05
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60, 60, 80)
Stroke.Thickness = 1
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🌱 GrowGarden2 AutoFarm"
Title.TextColor3 = Color3.fromRGB(100, 255, 150)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -10, 0, 20)
Status.Position = UDim2.new(0, 8, 0, 28)
Status.BackgroundTransparency = 1
Status.Text = "⏳ Initializing..."
Status.TextColor3 = Color3.fromRGB(255, 200, 100)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Frame

local Features = Instance.new("TextLabel")
Features.Name = "Features"
Features.Size = UDim2.new(1, -16, 0, 110)
Features.Position = UDim2.new(0, 8, 0, 52)
Features.BackgroundTransparency = 1
Features.Text = "⏳ Loading features..."
Features.TextColor3 = Color3.fromRGB(180, 180, 180)
Features.TextSize = 11
Features.Font = Enum.Font.Gotham
Features.TextXAlignment = Enum.TextXAlignment.Left
Features.TextYAlignment = Enum.TextYAlignment.Top
Features.Parent = Frame

local function UpdateStatus(text)
    Status.Text = text
    print("[AutoFarm] " .. text)
end

local function ShowUI()
    ScreenGui.Parent = PlayerGui
end

-- Load Networking module
local function LoadNetworking()
    UpdateStatus("Loading Networking...")
    
    local success = pcall(function()
        local sharedModules = ReplicatedStorage:WaitForChild("SharedModules", 15)
        if sharedModules then
            Networking = require(sharedModules:WaitForChild("Networking", 15))
        end
    end)
    
    if success and Networking then
        UpdateStatus("✅ Networking loaded!")
        return true
    else
        UpdateStatus("❌ Networking failed!")
        return false
    end
end

-- Load config from Loader
local function LoadConfig()
    UpdateStatus("Loading Config...")
    
    if Config.PetSettings then
        AutoSettings.AutoBuyPets = Config.PetSettings.AutoBuyPets or true
        AutoSettings.AutoBuyPetsRarityFilter = Config.PetSettings.RarityFilter or true
        AutoSettings.AutoBuyPetsMaxPrice = Config.PetSettings.MaxPrice or 0
    end
    
    if Config.MailSystem then
        AutoSettings.SendPetUsername = Config.MailSystem.SendPetUsername or ""
        AutoSettings.SendSeedUsername = Config.MailSystem.SendSeedUsername or ""
        AutoSettings.SendPetNote = Config.MailSystem.PetNote or "pet mail"
        AutoSettings.SendSeedNote = Config.MailSystem.SeedNote or "seed mail"
        AutoSettings.AutoSendPets = Config.MailSystem.AutoSendPets or true
        AutoSettings.AutoSendSeeds = Config.MailSystem.AutoSendSeeds or true
    end
    
    if Config.BuyLimits then
        for seed, limit in pairs(Config.BuyLimits) do
            SeedBuyLimits[seed] = limit
        end
    end
    
    if Config.Webhook then
        AutoSettings.DiscordWebhook = Config.Webhook.URL or ""
        AutoSettings.DiscordNotifications.RainbowSeeds = Config.Webhook.NotifyRainbow ~= false
        AutoSettings.DiscordNotifications.GoldSeeds = Config.Webhook.NotifyGold ~= false
        AutoSettings.DiscordNotifications.Pets = Config.Webhook.NotifyPets ~= false
    end
    
    setfpscap(AutoSettings.FPSCap or 5)
    
    if AutoSettings.LowEffect then
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
            Lighting.GlobalShadows = false
        end)
    end
    
    UpdateStatus("✅ Config loaded!")
end

-- Fire Networking event using metatable Fire method
local function FireNet(category, action, ...)
    if not Networking then return false end
    
    local cat = Networking[category]
    if not cat then return false end
    
    local event = cat[action]
    if not event then return false end
    
    local mt = getmetatable(event)
    if mt and mt.Fire then
        mt.Fire(event, ...)
        return true
    elseif event.FireServer then
        event:FireServer(...)
        return true
    end
    return false
end

-- Get player data
local function GetData(key)
    local success, data = pcall(function()
        local profile = Player:FindFirstChild("profile")
        if profile and profile:FindFirstChild(key) then
            return profile[key].Value
        end
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild(key) then
            return leaderstats[key].Value
        end
        return 0
    end)
    return success and data or 0
end

-- Send Discord notification
local function SendNotification(type, msg)
    if not AutoSettings.DiscordWebhook or AutoSettings.DiscordWebhook == "" then return end
    
    local content = ""
    if type == "rainbow" and AutoSettings.DiscordNotifications.RainbowSeeds then
        content = "🌈 **Rainbow Seed!** " .. msg
    elseif type == "gold" and AutoSettings.DiscordNotifications.GoldSeeds then
        content = "💛 **Gold Seed!** " .. msg
    elseif type == "pet" and AutoSettings.DiscordNotifications.Pets then
        content = "🐾 **Rare Pet!** " .. msg
    end
    
    if content ~= "" then
        pcall(function()
            HttpService:PostAsync(AutoSettings.DiscordWebhook, HttpService:JSONEncode({content = content}))
        end)
    end
end

-- Get garden position for planting
local function GetGardenPosition()
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then return nil end
    
    local playerId = Player.UserId
    
    for _, plot in pairs(gardens:GetChildren()) do
        if plot:IsA("Model") then
            local ownerId = plot:GetAttribute("OwnerId")
            if ownerId == playerId then
                local visual = plot:FindFirstChild("Visual")
                local gardenArea = visual and visual:FindFirstChild("GardenTotalArea")
                if gardenArea and gardenArea:IsA("BasePart") then
                    return gardenArea.Position
                end
            end
        end
    end
    
    -- Fallback: use first plot
    for _, plot in pairs(gardens:GetChildren()) do
        if plot:IsA("Model") then
            local visual = plot:FindFirstChild("Visual")
            local gardenArea = visual and visual:FindFirstChild("GardenTotalArea")
            if gardenArea and gardenArea:IsA("BasePart") then
                return gardenArea.Position
            end
        end
    end
    
    return Vector3.new(0, 5, 0)
end

-- Count seeds in backpack
local function CountSeedsInBackpack(seedName)
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return 0 end
    
    local count = 0
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == seedName and item:IsA("Tool") then
            count = count + 1
        end
    end
    return count
end

-- MAIN LOOPS
local function StartAutoFarm()
    Features.Text = [[🌱 AutoPlant: Starting...
💧 AutoWater: Starting...
💵 AutoSell: Starting...
🛒 AutoBuySeeds: Starting...
🌾 AutoHarvest: Starting...
]]

    UpdateStatus("🚀 Starting all features...")
    
    -- Auto Redeem Code
    task.spawn(function()
        task.wait(3)
        UpdateStatus("📝 Redeeming code...")
        FireNet("Codes", "RedeemCode", "TEAMGREENBEAN")
    end)
    
    -- Auto Sell (NPCS.SellAll)
    task.spawn(function()
        while AutoSettings.AutoSell do
            FireNet("NPCS", "SellAll")
            task.wait(AutoSettings.SellDelay or 0.1)
        end
    end)
    
    -- Auto Buy Seeds (SeedShop.PurchaseSeed)
    task.spawn(function()
        while AutoSettings.AutoBuySeeds do
            task.wait(0.3)
            
            local sheckles = GetData("Sheckles")
            if sheckles < 10 then
                task.wait(2)
            else
                local sortedSeeds = {}
                for seed, value in pairs(SeedValues) do
                    if SeedBuyLimits[seed] and SeedBuyLimits[seed] > 0 then
                        table.insert(sortedSeeds, {seed = seed, value = value})
                    end
                end
                table.sort(sortedSeeds, function(a, b) return a.value > b.value end)
                
                for _, data in ipairs(sortedSeeds) do
                    if not AutoSettings.AutoBuySeeds then break end
                    FireNet("SeedShop", "PurchaseSeed", data.seed)
                    SeedBuyLimits[data.seed] = SeedBuyLimits[data.seed] - 1
                    task.wait(AutoSettings.BuyDelay or 0.02)
                end
            end
            task.wait(0.5)
        end
    end)
    
    -- Auto Buy Gears (GearShop.PurchaseGear)
    task.spawn(function()
        while AutoSettings.AutoBuyGears do
            task.wait(2)
            local gears = {"Common Sprinkler", "Watering Can", "Fertilizer"}
            for _, gear in ipairs(gears) do
                if not AutoSettings.AutoBuyGears then break end
                FireNet("GearShop", "PurchaseGear", gear)
            end
        end
    end)
    
    -- Auto Plant (Plant.PlantSeed - position first!)
    task.spawn(function()
        while AutoSettings.AutoPlant do
            task.wait(0.1)
            
            local gardenPos = GetGardenPosition()
            if not gardenPos then
                task.wait(1)
            else
                local sortedSeeds = {}
                for seed, value in pairs(SeedValues) do
                    if SeedPlantLimits[seed] and SeedPlantLimits[seed] > 0 then
                        table.insert(sortedSeeds, {seed = seed, value = value})
                    end
                end
                table.sort(sortedSeeds, function(a, b) return a.value > b.value end)
                
                for _, data in ipairs(sortedSeeds) do
                    if not AutoSettings.AutoPlant then break end
                    
                    -- Check if we have seeds
                    if CountSeedsInBackpack(data.seed) > 0 then
                        -- Plant at garden position with offset
                        local plantPos = gardenPos + Vector3.new(
                            math.random(-10, 10),
                            0.5,
                            math.random(-10, 10)
                        )
                        -- CRITICAL: position is FIRST argument, seed name is SECOND
                        FireNet("Plant", "PlantSeed", plantPos, data.seed)
                        SeedPlantLimits[data.seed] = SeedPlantLimits[data.seed] - 1
                    end
                    task.wait(0.05)
                end
            end
            task.wait(1)
        end
    end)
    
    -- Auto Harvest (Garden.CollectFruit)
    task.spawn(function()
        while AutoSettings.AutoHarvest do
            FireNet("Garden", "CollectFruit", "", "")
            task.wait(AutoSettings.HarvestDelay or 0.05)
        end
    end)
    
    -- Auto Water (Garden.WaterPlant)
    task.spawn(function()
        while AutoSettings.AutoWater do
            task.wait(2)
            FireNet("Garden", "WaterPlant", 0)
        end
    end)
    
    -- Auto Place Sprinkler (Garden.PlaceSprinkler)
    task.spawn(function()
        while AutoSettings.AutoPlaceSprinkler do
            task.wait(3)
            FireNet("Garden", "PlaceSprinkler", 0)
        end
    end)
    
    -- Auto Pickup Rainbow Seeds
    task.spawn(function()
        while AutoSettings.AutoPickupRainbow do
            task.wait(0.3)
            local weatherValues = ReplicatedStorage:FindFirstChild("WeatherValues")
            local isRainbow = false
            if weatherValues then
                local rainbow = weatherValues:FindFirstChild("Rainbow")
                if rainbow then
                    local playing = rainbow:FindFirstChild("Playing")
                    if playing and playing:IsA("BoolValue") then
                        isRainbow = playing.Value
                    end
                end
            end
            
            if isRainbow then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name and string.find(obj.Name:lower(), "rainbow") then
                        pcall(function()
                            if obj:IsA("Tool") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                                Player.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                            elseif obj:IsA("BasePart") then
                                Player.Character.HumanoidRootPart.CFrame = obj.CFrame
                            end
                        end)
                    end
                end
            end
        end
    end)
    
    -- Auto Pickup Gold Seeds
    task.spawn(function()
        while AutoSettings.AutoPickupGold do
            task.wait(0.3)
            local weatherValues = ReplicatedStorage:FindFirstChild("WeatherValues")
            local isMidas = false
            if weatherValues then
                local midas = weatherValues:FindFirstChild("Midas")
                if midas then
                    local playing = midas:FindFirstChild("Playing")
                    if playing and playing:IsA("BoolValue") then
                        isMidas = playing.Value
                    end
                end
            end
            
            if isMidas then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name and string.find(obj.Name:lower(), "gold") then
                        pcall(function()
                            if obj:IsA("Tool") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                                Player.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                            elseif obj:IsA("BasePart") then
                                Player.Character.HumanoidRootPart.CFrame = obj.CFrame
                            end
                        end)
                    end
                end
            end
        end
    end)
    
    -- Auto Harvest Special Seeds
    task.spawn(function()
        while AutoSettings.AutoHarvestSpecial do
            task.wait(0.2)
            for _, seedName in ipairs(SpecialSeeds) do
                FireNet("Garden", "CollectFruit", seedName, "")
            end
        end
    end)
    
    -- Auto Send Pets Mail
    task.spawn(function()
        while AutoSettings.AutoSendPets and AutoSettings.SendPetUsername ~= "" do
            task.wait(10)
            FireNet("NPCS", "SendPetMail", AutoSettings.SendPetUsername, AutoSettings.SendPetNote)
        end
    end)
    
    -- Auto Send Seeds Mail
    task.spawn(function()
        while AutoSettings.AutoSendSeeds and AutoSettings.SendSeedUsername ~= "" do
            task.wait(10)
            FireNet("NPCS", "SendSeedMail", AutoSettings.SendSeedUsername, AutoSettings.SendSeedNote)
        end
    end)
    
    Features.Text = [[✅ AutoPlant: Active
✅ AutoWater: Active
✅ AutoSell: Active
✅ AutoBuySeeds: Active
✅ AutoHarvest: Active
✅ AutoBuyGears: Active
✅ AutoPickup: Active
🎮 All Systems Running!]]
    
    UpdateStatus("🎮 Auto Farm Running!")
end

-- Initialize
ShowUI()
LoadConfig()

task.spawn(function()
    if LoadNetworking() then
        StartAutoFarm()
    else
        warn("⚠️ Failed to start - Networking module not loaded")
    end
end)
