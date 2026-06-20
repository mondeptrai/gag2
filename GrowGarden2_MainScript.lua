--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           Grow Garden 2 - Ultimate Auto Farm                ║
    ║                    Main Script (Core)                        ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  All features auto-enabled - No configuration needed!       ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- Key Authentication
if not getgenv().Key or getgenv().Key == "ENTER_YOUR_KEY_HERE" then
    warn("❌ Invalid or missing key! Please set your key in Loader.lua")
    return
end

-- Wait for game to load
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
print("[GrowGarden2] Game loaded, starting...")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration (from Loader)
local Config = getgenv().GardenConfig or {}

-- Networking Module
local Networking = nil

-- Auto Farm Settings (ALL ENABLED BY DEFAULT)
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
    FPSCap = 60,
    HarvestDelay = 0.05,
    SellDelay = 0.1,
    PlantDelay = 0.1,
    BuyDelay = 0.02,
    SendPetUsername = "",
    SendSeedUsername = "",
    SendPetNote = "pet mail",
    SendSeedNote = "seed mail",
    DiscordWebhook = "",
}

-- Seed Limits
local SeedPlantLimits = {
    ["Carrot"] = 100, ["Strawberry"] = 100, ["Blueberry"] = 100, ["Tulip"] = 100,
    ["Tomato"] = 100, ["Apple"] = 100, ["Corn"] = 100, ["Cactus"] = 100,
    ["Pineapple"] = 100, ["Bamboo"] = 50, ["Mushroom"] = 50, ["Green Bean"] = 50,
    ["Banana"] = 50, ["Grape"] = 50, ["Coconut"] = 50, ["Mango"] = 50,
    ["Dragon Fruit"] = 50, ["Acorn"] = 50, ["Cherry"] = 50, ["Sunflower"] = 50,
    ["Venus Fly Trap"] = 30, ["Pomegranate"] = 30, ["Poison Apple"] = 30,
    ["Venom Spitter"] = 30,
}

local SeedBuyLimits = {}
for seed, _ in pairs(SeedPlantLimits) do
    SeedBuyLimits[seed] = 9999
end

-- Seed Values
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

-- UI Elements (make them global so we can update them)
local ScreenGui, Frame, StatusLabel, FeaturesLabel

-- Create UI
local function CreateUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowGarden2_AutoFarm"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    Frame = Instance.new("Frame")
    Frame.Name = "MainFrame"
    Frame.Size = UDim2.new(0, 280, 0, 220)
    Frame.Position = UDim2.new(0.01, 0, 0.4, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BackgroundTransparency = 0.05
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundTransparency = 1
    Title.Text = "🌱 GrowGarden2 AutoFarm"
    Title.TextColor3 = Color3.fromRGB(100, 255, 150)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, -10, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 35)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏳ Loading..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Frame
    
    FeaturesLabel = Instance.new("TextLabel")
    FeaturesLabel.Name = "Features"
    FeaturesLabel.Size = UDim2.new(1, -20, 1, -70)
    FeaturesLabel.Position = UDim2.new(0, 10, 0, 65)
    FeaturesLabel.BackgroundTransparency = 1
    FeaturesLabel.Text = "⏳ Initializing..."
    FeaturesLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    FeaturesLabel.TextSize = 12
    FeaturesLabel.Font = Enum.Font.Gotham
    FeaturesLabel.TextXAlignment = Enum.TextXAlignment.Left
    FeaturesLabel.TextYAlignment = Enum.TextYAlignment.Top
    FeaturesLabel.Parent = Frame
    
    print("[GrowGarden2] UI Created")
end

-- Update Status
local function SetStatus(text)
    if StatusLabel then
        StatusLabel.Text = text
    end
    print("[Status] " .. text)
end

-- Update Features
local function SetFeatures(text)
    if FeaturesLabel then
        FeaturesLabel.Text = text
    end
end

-- Load Networking module
local function LoadNetworking()
    SetStatus("Loading Networking...")
    print("[GrowGarden2] Loading Networking module...")
    
    local success = pcall(function()
        local sharedModules = ReplicatedStorage:WaitForChild("SharedModules", 20)
        if sharedModules then
            print("[GrowGarden2] SharedModules found, loading Networking...")
            local NetworkingModule = sharedModules:WaitForChild("Networking", 20)
            if NetworkingModule then
                Networking = require(NetworkingModule)
                
                -- Debug: List available categories
                print("[GrowGarden2] Networking module loaded!")
                print("[GrowGarden2] Available categories:")
                for k, v in pairs(Networking) do
                    if type(v) == "table" then
                        print("  - " .. tostring(k))
                    end
                end
            else
                error("Networking module not found")
            end
        else
            error("SharedModules not found")
        end
    end)
    
    if success and Networking then
        SetStatus("✅ Networking: OK")
        return true
    else
        SetStatus("⚠️ Networking: Using Fallbacks")
        warn("[GrowGarden2] Failed to load Networking module, using fallback methods!")
        return false
    end
end

-- Load config from Loader
local function LoadConfig()
    SetStatus("Loading Config...")
    print("[GrowGarden2] Loading configuration...")
    
    if Config.PetSettings then
        AutoSettings.AutoBuyPets = Config.PetSettings.AutoBuyPets or true
        AutoSettings.AutoBuyPetsRarityFilter = Config.PetSettings.RarityFilter or true
    end
    
    if Config.MailSystem then
        AutoSettings.SendPetUsername = Config.MailSystem.SendPetUsername or ""
        AutoSettings.SendSeedUsername = Config.MailSystem.SendSeedUsername or ""
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
    end
    
    -- Apply settings
    setfpscap(AutoSettings.FPSCap or 60)
    
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
    
    SetStatus("✅ Config: OK")
    print("[GrowGarden2] Configuration loaded!")
end

-- Fire Networking event
local function FireNet(category, action, ...)
    if not Networking then 
        print("[FireNet] No Networking, trying fallback...")
        return false 
    end
    
    local cat = Networking[category]
    if not cat then 
        print("[FireNet] Category not found: " .. tostring(category))
        return false 
    end
    
    local event = cat[action]
    if not event then 
        print("[FireNet] Action not found: " .. tostring(action))
        return false 
    end
    
    local mt = getmetatable(event)
    if mt and mt.Fire then
        mt.Fire(event, ...)
        return true
    elseif event.FireServer then
        event:FireServer(...)
        return true
    end
    print("[FireNet] No Fire method found for: " .. category .. "." .. action)
    return false
end

-- Fallback: Direct Packet Remote
local function FirePacket(...)
    local PacketRemote = ReplicatedStorage:FindFirstChild("SharedModules") 
        and ReplicatedStorage.SharedModules:FindFirstChild("Packet") 
        and ReplicatedStorage.SharedModules.Packet:FindFirstChild("RemoteEvent")
    
    if PacketRemote then
        PacketRemote:FireServer(...)
        return true
    end
    return false
end

-- Fallback: Proximity sell (walk to NPC and trigger)
local function FallbackSellAll()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local npcs = workspace:FindFirstChild("NPCS")
    if not npcs then return false end
    
    for _, npc in pairs(npcs:GetChildren()) do
        if npc:IsA("Model") then
            local npcHrp = npc:FindFirstChild("HumanoidRootPart")
            if npcHrp then
                hrp.CFrame = npcHrp.CFrame * CFrame.new(0, 0, 3)
                task.wait(0.1)
                return true
            end
        end
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

-- Get garden position
local function GetGardenPosition()
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then return nil end
    
    local playerId = Player.UserId
    
    for _, plot in pairs(gardens:GetChildren()) do
        if plot:IsA("Model") then
            local ownerId = plot:GetAttribute("OwnerId")
            if ownerId == playerId then
                local visual = plot:FindFirstChild("Visual")
                local area = visual and visual:FindFirstChild("GardenTotalArea")
                if area and area:IsA("BasePart") then
                    return area.Position
                end
            end
        end
    end
    
    return nil
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

-- START ALL AUTO FEATURES
local function StartAllAutoFeatures()
    print("[GrowGarden2] Starting all auto features...")
    SetStatus("🚀 Starting Auto Farm...")
    SetFeatures([[🌱 AutoPlant: Starting...
💧 AutoWater: Starting...
💵 AutoSell: Starting...
🛒 AutoBuySeeds: Starting...
🌾 AutoHarvest: Starting...
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Starting...
🎯 AutoPickup: Starting...]])
    
    -- Small delay to let UI update
    task.wait(0.5)
    
    -- 1. AUTO SELL
    task.spawn(function()
        print("[AutoSell] Started")
        SetFeatures([[✅ AutoSell: Active
💧 AutoWater: Starting...
🌱 AutoPlant: Starting...
🛒 AutoBuySeeds: Starting...
🌾 AutoHarvest: Starting...
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Starting...
🎯 AutoPickup: Starting...]])
        
        while AutoSettings.AutoSell do
            -- Try Networking first, then fallback
            if not FireNet("NPCS", "SellAll") then
                FallbackSellAll()
            end
            task.wait(AutoSettings.SellDelay or 0.1)
        end
    end)
    
    -- 2. AUTO BUY SEEDS
    task.spawn(function()
        print("[AutoBuySeeds] Started")
        SetFeatures([[✅ AutoSell: Active
💧 AutoWater: Starting...
🌱 AutoPlant: Starting...
🛒 AutoBuySeeds: Active
🌾 AutoHarvest: Starting...
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Starting...
🎯 AutoPickup: Starting...]])
        
        while AutoSettings.AutoBuySeeds do
            local sheckles = GetData("Sheckles")
            if sheckles >= 10 then
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
    
    -- 3. AUTO BUY GEARS
    task.spawn(function()
        print("[AutoBuyGears] Started")
        SetFeatures([[✅ AutoSell: Active
💧 AutoWater: Starting...
🌱 AutoPlant: Starting...
🛒 AutoBuySeeds: Active
🌾 AutoHarvest: Starting...
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Active
🎯 AutoPickup: Starting...]])
        
        while AutoSettings.AutoBuyGears do
            local gears = {"Common Sprinkler", "Watering Can", "Fertilizer"}
            for _, gear in ipairs(gears) do
                if not AutoSettings.AutoBuyGears then break end
                FireNet("GearShop", "PurchaseGear", gear)
            end
            task.wait(2)
        end
    end)
    
    -- 4. AUTO PLANT
    task.spawn(function()
        print("[AutoPlant] Started")
        SetFeatures([[✅ AutoSell: Active
💧 AutoWater: Starting...
🌱 AutoPlant: Active
🛒 AutoBuySeeds: Active
🌾 AutoHarvest: Starting...
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Active
🎯 AutoPickup: Starting...]])
        
        while AutoSettings.AutoPlant do
            local gardenPos = GetGardenPosition()
            if gardenPos then
                local sortedSeeds = {}
                for seed, value in pairs(SeedValues) do
                    if SeedPlantLimits[seed] and SeedPlantLimits[seed] > 0 then
                        table.insert(sortedSeeds, {seed = seed, value = value})
                    end
                end
                table.sort(sortedSeeds, function(a, b) return a.value > b.value end)
                
                for _, data in ipairs(sortedSeeds) do
                    if not AutoSettings.AutoPlant then break end
                    
                    if CountSeedsInBackpack(data.seed) > 0 then
                        local plantPos = gardenPos + Vector3.new(math.random(-10, 10), 0.5, math.random(-10, 10))
                        FireNet("Plant", "PlantSeed", plantPos, data.seed)
                        SeedPlantLimits[data.seed] = SeedPlantLimits[data.seed] - 1
                    end
                    task.wait(0.05)
                end
            end
            task.wait(1)
        end
    end)
    
    -- 5. AUTO HARVEST
    task.spawn(function()
        print("[AutoHarvest] Started")
        SetFeatures([[✅ AutoSell: Active
💧 AutoWater: Starting...
🌱 AutoPlant: Active
🛒 AutoBuySeeds: Active
🌾 AutoHarvest: Active
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Active
🎯 AutoPickup: Starting...]])
        
        while AutoSettings.AutoHarvest do
            FireNet("Garden", "CollectFruit", "", "")
            task.wait(AutoSettings.HarvestDelay or 0.05)
        end
    end)
    
    -- 6. AUTO WATER
    task.spawn(function()
        print("[AutoWater] Started")
        SetFeatures([[✅ AutoSell: Active
💧 AutoWater: Active
🌱 AutoPlant: Active
🛒 AutoBuySeeds: Active
🌾 AutoHarvest: Active
🐾 AutoBuyPets: Starting...
⚙️ AutoGears: Active
🎯 AutoPickup: Starting...]])
        
        while AutoSettings.AutoWater do
            FireNet("Garden", "WaterPlant", 0)
            task.wait(2)
        end
    end)
    
    -- 7. AUTO PLACE SPRINKLER
    task.spawn(function()
        print("[AutoSprinkler] Started")
        while AutoSettings.AutoPlaceSprinkler do
            FireNet("Garden", "PlaceSprinkler", 0)
            task.wait(3)
        end
    end)
    
    -- 8. AUTO PICKUP RAINBOW
    task.spawn(function()
        print("[AutoPickupRainbow] Started")
        while AutoSettings.AutoPickupRainbow do
            task.wait(0.3)
            local weatherValues = ReplicatedStorage:FindFirstChild("WeatherValues")
            if weatherValues then
                local rainbow = weatherValues:FindFirstChild("Rainbow")
                if rainbow then
                    local playing = rainbow:FindFirstChild("Playing")
                    if playing and playing.Value then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name:lower():find("rainbow") then
                                pcall(function()
                                    if obj:IsA("Tool") and Player.Character then
                                        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and obj:FindFirstChild("Handle") then
                                            hrp.CFrame = obj.Handle.CFrame
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- 9. AUTO PICKUP GOLD
    task.spawn(function()
        print("[AutoPickupGold] Started")
        while AutoSettings.AutoPickupGold do
            task.wait(0.3)
            local weatherValues = ReplicatedStorage:FindFirstChild("WeatherValues")
            if weatherValues then
                local midas = weatherValues:FindFirstChild("Midas")
                if midas then
                    local playing = midas:FindFirstChild("Playing")
                    if playing and playing.Value then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name:lower():find("gold") then
                                pcall(function()
                                    if obj:IsA("Tool") and Player.Character then
                                        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and obj:FindFirstChild("Handle") then
                                            hrp.CFrame = obj.Handle.CFrame
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- 10. AUTO HARVEST SPECIAL
    task.spawn(function()
        print("[AutoHarvestSpecial] Started")
        while AutoSettings.AutoHarvestSpecial do
            for _, seedName in ipairs(SpecialSeeds) do
                FireNet("Garden", "CollectFruit", seedName, "")
            end
            task.wait(0.2)
        end
    end)
    
    -- 11. AUTO REDEEM CODE
    if AutoSettings.AutoRedeemCode then
        task.spawn(function()
            print("[AutoRedeemCode] Started")
            task.wait(3)
            FireNet("Codes", "RedeemCode", "TEAMGREENBEAN")
            print("[GrowGarden2] Code redeemed: TEAMGREENBEAN")
        end)
    end
    
    -- ALL STARTED
    task.wait(1)
    SetStatus("🎮 Auto Farm Running!")
    SetFeatures([[✅ AutoSell: Active
✅ AutoBuySeeds: Active
✅ AutoBuyGears: Active
✅ AutoPlant: Active
✅ AutoHarvest: Active
✅ AutoWater: Active
✅ AutoSprinkler: Active
✅ AutoPickup: Active
✅ AutoHarvestSpecial: Active
🎮 ALL FEATURES ACTIVE!]])
    
    print("[GrowGarden2] 🎮 All features started!")
end

-- MAIN INITIALIZATION
CreateUI()
LoadConfig()

-- Try to load Networking, if fails, try anyway
if not LoadNetworking() then
    warn("[GrowGarden2] Networking failed, retrying...")
    task.wait(2)
    if not LoadNetworking() then
        warn("[GrowGarden2] Networking still failed, starting without it...")
    end
end

-- Start all features
StartAllAutoFeatures()
