--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           Grow Garden 2 - Ultimate Auto Farm                ║
    ║                    Main Script (Core)                        ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  ALL FEATURES AUTO-ENABLED - Based on UltimateGUI          ║
    ║  Features: AutoHarvest, AutoSell, AutoBuy, AutoPlant, etc. ║
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
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration (from Loader)
local Config = getgenv().GardenConfig or {}

-- Networking Module
local Networking = nil

-- Colors
local Colors = {
    Background = Color3.fromRGB(18, 18, 28),
    Primary = Color3.fromRGB(72, 195, 115),
    Success = Color3.fromRGB(72, 195, 115),
    Warning = Color3.fromRGB(255, 200, 75),
    Danger = Color3.fromRGB(255, 90, 90),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 180),
}

-- ============================================
-- AUTO FARM SETTINGS (ALL ENABLED BY DEFAULT)
-- ============================================
local AutoSettings = {
    -- Core Auto Features
    AutoHarvest = true,
    AutoHarvestSpeed = 0.01,
    AutoHarvestSpecial = true,
    AutoSell = true,
    AutoSellSpeed = 0.1,
    AutoBuySeeds = true,
    AutoBuyGears = true,
    AutoBuyPets = true,
    AutoPlant = true,
    AutoPlantMode = "efficiency",
    AutoWater = true,
    AutoPlaceSprinkler = true,
    
    -- Event Pickup
    AutoPickupRainbow = true,
    AutoPickupGold = true,
    
    -- Mail System
    AutoSendMail = true,
    AutoSendPets = true,
    AutoSendSeeds = true,
    SendPetUsername = "",
    SendSeedUsername = "",
    WishSeedUsername = "",
    SendPetNote = "pet mail",
    SendSeedNote = "seed mail",
    WishSeedNote = "wish",
    
    -- Redeem Codes
    AutoRedeemCode = true,
    RedeemCode = "TEAMGREENBEAN",
    
    -- Pet Settings
    AutoBuyPetsRarityFilter = true,
    AutoBuyPetsMaxPrice = 0,
    AllowedRarities = {
        Common = false,
        Uncommon = false,
        Rare = false,
        Epic = false,
        Legendary = true,
        Mythic = true,
        Super = true,
    },
    
    -- Delays
    HarvestDelay = 0.01,
    SellDelay = 0.1,
    PlantDelay = 0.1,
    BuyDelay = 0.02,
    
    -- Performance
    FPSCap = 60,
    LowEffect = true,
    
    -- Webhook
    DiscordWebhook = "",
    DiscordNotifications = {
        RainbowSeeds = true,
        GoldSeeds = true,
        Pets = true,
    },
}

-- ============================================
-- SEED DATA (FROM ULTIMATE GUI)
-- ============================================

local SeedList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple",
    "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean",
    "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn",
    "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple",
    "Moon Bloom", "Dragon's Breath", "Ghost Pepper", "Poison Ivy",
    "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon"
}

local SeedSellValues = {
    ["Mushroom"] = 13000, ["Moon Bloom"] = 9000, ["Lotus"] = 6500,
    ["Dragon's Breath"] = 3400, ["Venus Fly Trap"] = 3000, ["Ghost Pepper"] = 2500,
    ["Beanstalk"] = 2000, ["Sunflower"] = 1750, ["Poison Ivy"] = 1700,
    ["Romanesco"] = 1500, ["Poison Apple"] = 900, ["Pomegranate"] = 900,
    ["Bamboo"] = 800, ["Glow Mushroom"] = 700, ["Pumpkin"] = 350,
    ["Cherry"] = 350, ["Acorn"] = 200, ["Horned Melon"] = 200,
    ["Dragon Fruit"] = 150, ["Thorn Rose"] = 140, ["Pinetree"] = 100,
    ["Mango"] = 90, ["Baby Cactus"] = 70, ["Coconut"] = 60,
    ["Tulip"] = 60, ["Grape"] = 45, ["Cactus"] = 40,
    ["Banana"] = 35, ["Corn"] = 34, ["Pineapple"] = 30,
    ["Apple"] = 12, ["Green Bean"] = 10, ["Tomato"] = 9,
    ["Carrot"] = 5, ["Blueberry"] = 5, ["Strawberry"] = 3,
}

local SeedValues = {
    ["Mushroom"] = 100, ["Moon Bloom"] = 99, ["Lotus"] = 98, ["Dragon's Breath"] = 97,
    ["Venus Fly Trap"] = 96, ["Ghost Pepper"] = 95, ["Sunflower"] = 93, ["Poison Ivy"] = 92,
    ["Poison Apple"] = 90, ["Pomegranate"] = 89, ["Venom Spitter"] = 88,
    ["Bamboo"] = 85, ["Glow Mushroom"] = 84, ["Cherry"] = 83, ["Acorn"] = 82,
    ["Horned Melon"] = 81, ["Dragon Fruit"] = 80, ["Mango"] = 79,
    ["Baby Cactus"] = 78, ["Coconut"] = 77, ["Tulip"] = 76, ["Grape"] = 75,
    ["Cactus"] = 74, ["Banana"] = 73, ["Corn"] = 72, ["Pineapple"] = 71,
    ["Apple"] = 70, ["Green Bean"] = 69, ["Tomato"] = 68, ["Carrot"] = 67,
    ["Blueberry"] = 66, ["Strawberry"] = 65,
}

local SeedGrowTimes = {
    ["Carrot"] = 4, ["Strawberry"] = 11, ["Blueberry"] = 3, ["Tulip"] = 8,
    ["Tomato"] = 12, ["Apple"] = 5, ["Bamboo"] = 14, ["Corn"] = 10,
    ["Cactus"] = 20, ["Pineapple"] = 25, ["Mushroom"] = 30, ["Green Bean"] = 15,
    ["Banana"] = 12, ["Grape"] = 18, ["Coconut"] = 12, ["Mango"] = 20,
    ["Dragon Fruit"] = 25, ["Acorn"] = 30, ["Cherry"] = 35, ["Sunflower"] = 40,
    ["Venus Fly Trap"] = 50, ["Pomegranate"] = 60, ["Poison Apple"] = 75,
    ["Moon Bloom"] = 8, ["Dragon's Breath"] = 10, ["Ghost Pepper"] = 90,
    ["Poison Ivy"] = 85, ["Baby Cactus"] = 15, ["Glow Mushroom"] = 20,
    ["Romanesco"] = 35, ["Horned Melon"] = 40,
}

local SeedPlantLimits = {
    ["Carrot"] = 50, ["Strawberry"] = 50, ["Blueberry"] = 50, ["Tulip"] = 50,
    ["Tomato"] = 50, ["Apple"] = 50, ["Corn"] = 50, ["Cactus"] = 50,
    ["Pineapple"] = 50, ["Bamboo"] = 20, ["Mushroom"] = 20, ["Green Bean"] = 20,
    ["Banana"] = 20, ["Grape"] = 20, ["Coconut"] = 20, ["Mango"] = 20,
    ["Dragon Fruit"] = 20, ["Acorn"] = 20, ["Cherry"] = 20, ["Sunflower"] = 20,
    ["Venus Fly Trap"] = 10, ["Pomegranate"] = 10, ["Poison Apple"] = 10,
    ["Venom Spitter"] = 10, ["Moon Bloom"] = 10, ["Dragon's Breath"] = 10,
}

local SeedBuyLimits = {
    ["Carrot"] = 100, ["Strawberry"] = 100, ["Blueberry"] = 100, ["Tulip"] = 100,
    ["Tomato"] = 100, ["Apple"] = 100, ["Corn"] = 100, ["Cactus"] = 100,
    ["Pineapple"] = 100, ["Bamboo"] = 500, ["Mushroom"] = 500, ["Green Bean"] = 100,
    ["Banana"] = 100, ["Grape"] = 100, ["Coconut"] = 100, ["Mango"] = 100,
    ["Dragon Fruit"] = 100, ["Acorn"] = 100, ["Cherry"] = 100, ["Sunflower"] = 100,
    ["Venus Fly Trap"] = 100, ["Pomegranate"] = 100, ["Poison Apple"] = 100,
    ["Venom Spitter"] = 100, ["Moon Bloom"] = 50000, ["Dragon's Breath"] = 50000,
    ["Ghost Pepper"] = 50000, ["Poison Ivy"] = 50000, ["Baby Cactus"] = 50000,
    ["Glow Mushroom"] = 50000, ["Romanesco"] = 50000, ["Horned Melon"] = 50000,
}

local SpecialSeeds = {
    "Rainbow Strawberry", "Rainbow Blueberry", "Rainbow Apple", "Rainbow Corn",
    "Rainbow Grape", "Rainbow Pineapple", "Rainbow Banana", "Rainbow Melon",
    "Rainbow Dragon Fruit", "Rainbow Mango", "Rainbow Lotus", "Rainbow Moon Bloom",
    "Rainbow Bamboo", "Rainbow Tulip", "Rainbow Sunflower", "Rainbow Rose",
    "Rainbow Cactus", "Rainbow Cacao", "Rainbow Horned Melon",
    "Gold Strawberry", "Gold Blueberry", "Gold Apple", "Gold Corn",
    "Gold Grape", "Gold Pineapple", "Gold Banana", "Gold Melon",
    "Gold Dragon Fruit", "Gold Mango", "Gold Lotus", "Gold Moon Bloom",
    "Gold Bamboo", "Gold Tulip", "Gold Sunflower", "Gold Rose",
    "Gold Cactus", "Gold Cacao", "Gold Horned Melon",
    "Rainbow Egg", "Gold Egg", "Golden Egg", "Rainbow Seed", "Gold Seed",
    "Shiny Strawberry", "Shiny Blueberry", "Shiny Apple",
    "Event Seed", "Special Rainbow", "Special Gold",
}

local GearList = {
    "Common Sprinkler", "Sign", "Lantern",
    "Wheelbarrow", "Uncommon Sprinkler", "Rare Sprinkler", "Legendary Sprinkler",
    "Super Sprinkler", "Trowel", "Speed Mushroom", "Jump Mushroom",
    "Gnome", "Shrink Mushroom", "Supersize Mushroom", "Invisibility Mushroom",
    "Teleporter", "Basic Pot", "Flashbang"
}

local PetData = {
    ["Cat"] = {rarity = "Common", price = 50},
    ["Dog"] = {rarity = "Common", price = 75},
    ["Hamster"] = {rarity = "Common", price = 100},
    ["Duck"] = {rarity = "Uncommon", price = 500},
    ["Fox"] = {rarity = "Uncommon", price = 750},
    ["Owl"] = {rarity = "Rare", price = 2000},
    ["Phoenix"] = {rarity = "Legendary", price = 50000},
    ["Dragon"] = {rarity = "Mythic", price = 100000},
    ["Unicorn"] = {rarity = "Super", price = 500000},
}

local RARITY_PRIORITY = {
    ["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3,
    ["Epic"] = 4, ["Legendary"] = 5, ["Mythic"] = 6, ["Super"] = 7,
}

local GLOBAL_MAX_PLANTS = 800

-- Trackers
local PlantedSeedsCount = {}
local BoughtSeedsCount = {}

-- ============================================
-- UI CREATION
-- ============================================
local ScreenGui, MainFrame, StatusLabel, FeaturesLabel, StatusLabel2

local function CreateUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowGarden2_AutoFarm"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 320)
    MainFrame.Position = UDim2.new(0.01, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(55, 55, 80)
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "🌱 GrowGarden2 AutoFarm"
    Title.TextColor3 = Colors.Primary
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Status Line 1
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -10, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 40)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏳ Loading..."
    StatusLabel.TextColor3 = Colors.Warning
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame
    
    -- Status Line 2
    StatusLabel2 = Instance.new("TextLabel")
    StatusLabel2.Size = UDim2.new(1, -10, 0, 20)
    StatusLabel2.Position = UDim2.new(0, 10, 0, 62)
    StatusLabel2.BackgroundTransparency = 1
    StatusLabel2.Text = ""
    StatusLabel2.TextColor3 = Colors.TextDim
    StatusLabel2.TextSize = 12
    StatusLabel2.Font = Enum.Font.Gotham
    StatusLabel2.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel2.Parent = MainFrame
    
    -- Features List
    FeaturesLabel = Instance.new("TextLabel")
    FeaturesLabel.Size = UDim2.new(1, -20, 1, -80)
    FeaturesLabel.Position = UDim2.new(0, 10, 0, 85)
    FeaturesLabel.BackgroundTransparency = 1
    FeaturesLabel.Text = "⏳ Initializing features..."
    FeaturesLabel.TextColor3 = Colors.TextDim
    FeaturesLabel.TextSize = 11
    FeaturesLabel.Font = Enum.Font.Gotham
    FeaturesLabel.TextXAlignment = Enum.TextXAlignment.Left
    FeaturesLabel.TextYAlignment = Enum.TextYAlignment.Top
    FeaturesLabel.Parent = MainFrame
    
    print("[GrowGarden2] UI Created")
end

local function SetStatus(line1, line2)
    if StatusLabel then StatusLabel.Text = line1 end
    if StatusLabel2 then StatusLabel2.Text = line2 or "" end
    print("[Status] " .. line1 .. (line2 and " | " .. line2 or ""))
end

local function SetFeatures(text)
    if FeaturesLabel then FeaturesLabel.Text = text end
end

local function UpdateFeature(index, enabled, name)
    local lines = {}
    for line in (FeaturesLabel.Text or ""):gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    if lines[index] then
        local prefix = enabled and "✅" or "❌"
        lines[index] = prefix .. " " .. name .. ": " .. (enabled and "Active" or "Disabled")
        SetFeatures(table.concat(lines, "\n"))
    end
end

-- ============================================
-- LOAD CONFIG FROM LOADER
-- ============================================
local function LoadConfig()
    SetStatus("📋 Loading Config", "")
    
    -- Pet Settings
    if Config.PetSettings then
        AutoSettings.AutoBuyPets = Config.PetSettings.AutoBuyPets ~= false
        AutoSettings.AutoBuyPetsRarityFilter = Config.PetSettings.RarityFilter ~= false
        AutoSettings.AutoBuyPetsMaxPrice = Config.PetSettings.MaxPrice or 0
        
        if Config.PetSettings.AllowedRarities then
            AutoSettings.AllowedRarities = Config.PetSettings.AllowedRarities
        end
    end
    
    -- Mail System
    if Config.MailSystem then
        AutoSettings.SendPetUsername = Config.MailSystem.SendPetUsername or ""
        AutoSettings.SendSeedUsername = Config.MailSystem.SendSeedUsername or ""
        AutoSettings.WishSeedUsername = Config.MailSystem.WishUsername or ""
        AutoSettings.SendPetNote = Config.MailSystem.PetNote or "pet mail"
        AutoSettings.SendSeedNote = Config.MailSystem.SeedNote or "seed mail"
        AutoSettings.WishSeedNote = Config.MailSystem.WishNote or "wish"
        AutoSettings.AutoSendPets = Config.MailSystem.AutoSendPets ~= false
        AutoSettings.AutoSendSeeds = Config.MailSystem.AutoSendSeeds ~= false
        AutoSettings.AutoSendMail = AutoSettings.AutoSendPets or AutoSettings.AutoSendSeeds
    end
    
    -- Buy Limits
    if Config.BuyLimits then
        for seed, limit in pairs(Config.BuyLimits) do
            -- Handle naming differences
            local normalizedSeed = seed:gsub("(%l)(%w*)", function(a,b) return a:upper()..b end)
            if SeedBuyLimits[seed] ~= nil then
                SeedBuyLimits[seed] = limit
            elseif SeedBuyLimits[normalizedSeed] ~= nil then
                SeedBuyLimits[normalizedSeed] = limit
            end
        end
    end
    
    -- Webhook
    if Config.Webhook then
        AutoSettings.DiscordWebhook = Config.Webhook.URL or ""
        AutoSettings.DiscordNotifications.RainbowSeeds = Config.Webhook.NotifyRainbow ~= false
        AutoSettings.DiscordNotifications.GoldSeeds = Config.Webhook.NotifyGold ~= false
        AutoSettings.DiscordNotifications.Pets = Config.Webhook.NotifyPets ~= false
    end
    
    -- Apply Performance Settings
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
    
    SetStatus("✅ Config Loaded", "")
end

-- ============================================
-- LOAD NETWORKING MODULE
-- ============================================
local function LoadNetworking()
    SetStatus("🔌 Loading Networking", "")
    print("[GrowGarden2] Loading Networking module...")
    
    local success = pcall(function()
        local sharedModules = ReplicatedStorage:WaitForChild("SharedModules", 20)
        if sharedModules then
            local NetworkingModule = sharedModules:WaitForChild("Networking", 20)
            if NetworkingModule then
                Networking = require(NetworkingModule)
                print("[GrowGarden2] Networking loaded!")
            end
        end
    end)
    
    if success and Networking then
        SetStatus("✅ Networking OK", "")
        return true
    else
        warn("[GrowGarden2] Networking failed!")
        SetStatus("⚠️ Networking Fallback", "")
        return false
    end
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetData(dataType)
    local success, result = pcall(function()
        if dataType == "Sheckles" then
            if Player:FindFirstChild("leaderstats") then
                local sheckles = Player.leaderstats:FindFirstChild("Sheckles")
                return sheckles and sheckles.Value or 0
            end
            return 0
        end
        return 0
    end)
    return success and result or 0
end

local function GetSeedStock(seedName)
    local success, result = pcall(function()
        local StockValues = ReplicatedStorage:WaitForChild("StockValues", 5)
        if not StockValues then return nil end
        local SeedShop = StockValues:WaitForChild("SeedShop", 5)
        if not SeedShop then return nil end
        local Items = SeedShop:WaitForChild("Items", 5)
        if not Items then return nil end
        local seedItem = Items:FindFirstChild(seedName)
        if seedItem and seedItem:IsA("IntValue") then
            return seedItem.Value
        end
        return nil
    end)
    return success and result
end

local function GetAllFruits()
    local fruits = {}
    local Gardens = workspace:FindFirstChild("Gardens")
    if not Gardens then return fruits end
    
    for _, plot in pairs(Gardens:GetChildren()) do
        if plot:IsA("Model") then
            local plantsFolder = plot:FindFirstChild("Plants")
            if plantsFolder then
                for _, plant in pairs(plantsFolder:GetChildren()) do
                    local seedName = plant:GetAttribute("SeedName")
                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    
                    if fruitsFolder then
                        for _, fruit in pairs(fruitsFolder:GetChildren()) do
                            local sizeMulti = fruit:GetAttribute("SizeMulti") or 1
                            local fruitValue = SeedSellValues[seedName] or 10
                            local actualValue = math.floor(fruitValue * sizeMulti)
                            local fruitId = fruit:GetAttribute("FruitId") or fruit.Name
                            
                            table.insert(fruits, {
                                Model = fruit,
                                Plant = plant,
                                FruitId = fruitId,
                                SeedName = seedName,
                                SizeMulti = sizeMulti,
                                Value = actualValue,
                            })
                        end
                    else
                        local harvestPart = plant:FindFirstChild("HarvestPart")
                        if harvestPart then
                            table.insert(fruits, {
                                Model = plant,
                                Plant = plant,
                                FruitId = "",
                                SeedName = seedName,
                                SizeMulti = plant:GetAttribute("SizeMulti") or 1,
                                Value = SeedSellValues[seedName] or 10,
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sort by weight (largest first)
    local maxSize = 0
    for _, f in ipairs(fruits) do
        if f.SizeMulti > maxSize then maxSize = f.SizeMulti end
    end
    
    for _, f in ipairs(fruits) do
        f.Weight = maxSize > 0 and math.floor((f.SizeMulti / maxSize) * 512) or 0
    end
    
    table.sort(fruits, function(a, b) return (a.Weight or 0) > (b.Weight or 0) end)
    
    return fruits
end

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

local function TeleportTo(pos)
    local character = Player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(pos)
        end
    end
end

local function ShouldAutoBuyRarity(rarity)
    return AutoSettings.AllowedRarities[rarity] == true
end

-- ============================================
-- NETWORKING FIRE FUNCTIONS
-- ============================================

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

local SeedBuffers = {
    ["Carrot"] = buffer.fromstring("j\x00\x06Carrot"),
    ["Strawberry"] = buffer.fromstring("j\x00\x0AStrawberry"),
    ["Blueberry"] = buffer.fromstring("j\x00\x09Blueberry"),
    ["Tulip"] = buffer.fromstring("j\x00\x05Tulip"),
    ["Tomato"] = buffer.fromstring("j\x00\x06Tomato"),
    ["Apple"] = buffer.fromstring("j\x00\x05Apple"),
    ["Corn"] = buffer.fromstring("j\x00\x04Corn"),
    ["Cactus"] = buffer.fromstring("j\x00\x06Cactus"),
    ["Pineapple"] = buffer.fromstring("j\x00\x09Pineapple"),
    ["Bamboo"] = buffer.fromstring("j\x00\x06Bamboo"),
    ["Mushroom"] = buffer.fromstring("j\x00\x08Mushroom"),
    ["Green Bean"] = buffer.fromstring("j\x00\x09Green Bean"),
    ["Banana"] = buffer.fromstring("j\x00\x06Banana"),
    ["Grape"] = buffer.fromstring("j\x00\x05Grape"),
    ["Coconut"] = buffer.fromstring("j\x00\x07Coconut"),
    ["Mango"] = buffer.fromstring("j\x00\x05Mango"),
    ["Dragon Fruit"] = buffer.fromstring("j\x00\x0CDragon Fruit"),
    ["Acorn"] = buffer.fromstring("j\x00\x05Acorn"),
    ["Cherry"] = buffer.fromstring("j\x00\x06Cherry"),
    ["Sunflower"] = buffer.fromstring("j\x00\x09Sunflower"),
    ["Venus Fly Trap"] = buffer.fromstring("j\x00\x0EVenus Fly Trap"),
    ["Pomegranate"] = buffer.fromstring("j\x00\x0BPomegranate"),
    ["Poison Apple"] = buffer.fromstring("j\x00\x0CPoison Apple"),
    ["Venom Spitter"] = buffer.fromstring("j\x00\x0DVenom Spitter"),
    ["Moon Bloom"] = buffer.fromstring("j\x00\x09Moon Bloom"),
    ["Dragon's Breath"] = buffer.fromstring("j\x00\x0EDragon's Breath"),
    ["Ghost Pepper"] = buffer.fromstring("j\x00\x0BGhost Pepper"),
    ["Poison Ivy"] = buffer.fromstring("j\x00\x09Poison Ivy"),
    ["Baby Cactus"] = buffer.fromstring("j\x00\x0ABaby Cactus"),
    ["Glow Mushroom"] = buffer.fromstring("j\x00\x0DGlow Mushroom"),
    ["Romanesco"] = buffer.fromstring("j\x00\x09Romanesco"),
    ["Horned Melon"] = buffer.fromstring("j\x00\x0BHorned Melon"),
}

local function FirePurchase(seedName)
    -- Method 1: Networking module
    local success = pcall(function()
        if Networking and Networking.SeedShop and Networking.SeedShop.PurchaseSeed then
            local purchaseSeed = Networking.SeedShop.PurchaseSeed
            local mt = getmetatable(purchaseSeed)
            if mt and mt.Fire then
                mt.Fire(purchaseSeed, seedName)
                return true
            end
        end
    end)
    if success then return true end
    
    -- Method 2: Buffer packet
    pcall(function()
        local PacketRemote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
        local seedBuffer = SeedBuffers[seedName]
        if seedBuffer then
            PacketRemote:FireServer(seedBuffer)
        end
    end)
    
    return false
end

local function FireGearPurchase(gearName)
    pcall(function()
        if Networking and Networking.GearShop and Networking.GearShop.PurchaseGear then
            local purchaseGear = Networking.GearShop.PurchaseGear
            local mt = getmetatable(purchaseGear)
            if mt and mt.Fire then
                mt.Fire(purchaseGear, gearName)
            end
        end
    end)
end

local function FallbackSellAll()
    pcall(function()
        local PacketRemote = ReplicatedStorage:FindFirstChild("SharedModules") 
            and ReplicatedStorage.SharedModules:FindFirstChild("Packet") 
            and ReplicatedStorage.SharedModules.Packet:FindFirstChild("RemoteEvent")
        
        if PacketRemote then
            local npcs = workspace:FindFirstChild("NPCS")
            if npcs then
                for _, npc in pairs(npcs:GetChildren()) do
                    if npc:IsA("Model") then
                        local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                        if npcHrp then
                            TeleportTo(npcHrp.Position)
                            task.wait(0.1)
                            for _, child in pairs(npcHrp:GetChildren()) do
                                if child:IsA("ProximityPrompt") then
                                    fireproximityprompt(child)
                                    task.wait(0.05)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function SendDiscordNotification(type, data)
    if not AutoSettings.DiscordWebhook or AutoSettings.DiscordWebhook == "" then return end
    
    local content = ""
    if type == "pet" and AutoSettings.DiscordNotifications.Pets then
        content = "🐾 **Rare Pet!** " .. (data.petName or "Unknown") .. " [" .. (data.rarity or "Unknown") .. "]"
    elseif type == "rainbow" and AutoSettings.DiscordNotifications.RainbowSeeds then
        content = "🌈 **Rainbow Seed!** " .. (data.seedName or "Unknown")
    elseif type == "gold" and AutoSettings.DiscordNotifications.GoldSeeds then
        content = "💛 **Gold Seed!** " .. (data.seedName or "Unknown")
    end
    
    if content ~= "" then
        pcall(function()
            HttpService:PostAsync(AutoSettings.DiscordWebhook, HttpService:JSONEncode({content = content}))
        end)
    end
end

-- ============================================
-- AUTO FEATURES
-- ============================================

local function StartAutoHarvest()
    print("[AutoHarvest] Started")
    task.spawn(function()
        while AutoSettings.AutoHarvest do
            local fruits = GetAllFruits()
            
            for _, fruit in ipairs(fruits) do
                if not AutoSettings.AutoHarvest then break end
                
                local interactModel = fruit.Model
                if interactModel and interactModel:IsDescendantOf(workspace) then
                    local plantUUID = fruit.Plant:GetAttribute("PlantUUID") or ""
                    local fruitId = fruit.FruitId or ""
                    
                    FireNet("Garden", "CollectFruit", plantUUID, fruitId)
                end
                task.wait(AutoSettings.HarvestDelay)
            end
            
            task.wait(AutoSettings.HarvestDelay)
        end
    end)
end

local function StartAutoSell()
    print("[AutoSell] Started")
    task.spawn(function()
        while AutoSettings.AutoSell do
            if not FireNet("NPCS", "SellAll") then
                FallbackSellAll()
            end
            task.wait(AutoSettings.SellDelay)
        end
    end)
end

local function StartAutoBuySeeds()
    print("[AutoBuySeeds] Started")
    task.spawn(function()
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
                    
                    local stock = GetSeedStock(data.seed)
                    if stock == nil or stock > 0 then
                        FirePurchase(data.seed)
                        SeedBuyLimits[data.seed] = SeedBuyLimits[data.seed] - 1
                    end
                    task.wait(AutoSettings.BuyDelay)
                end
            end
            task.wait(0.5)
        end
    end)
end

local function StartAutoBuyGears()
    print("[AutoBuyGears] Started")
    task.spawn(function()
        while AutoSettings.AutoBuyGears do
            for _, gear in ipairs({"Common Sprinkler", "Watering Can", "Fertilizer"}) do
                if not AutoSettings.AutoBuyGears then break end
                FireGearPurchase(gear)
            end
            task.wait(2)
        end
    end)
end

local function StartAutoPlant()
    print("[AutoPlant] Started")
    task.spawn(function()
        while AutoSettings.AutoPlant do
            local gardenPos = GetGardenPosition()
            if gardenPos then
                local sortedSeeds = {}
                for seed, value in pairs(SeedValues) do
                    if SeedPlantLimits[seed] and SeedPlantLimits[seed] > 0 and CountSeedsInBackpack(seed) > 0 then
                        table.insert(sortedSeeds, {seed = seed, value = value})
                    end
                end
                table.sort(sortedSeeds, function(a, b) return a.value > b.value end)
                
                for _, data in ipairs(sortedSeeds) do
                    if not AutoSettings.AutoPlant then break end
                    
                    local plantPos = gardenPos + Vector3.new(math.random(-10, 10), 0.5, math.random(-10, 10))
                    FireNet("Plant", "PlantSeed", plantPos, data.seed)
                    SeedPlantLimits[data.seed] = SeedPlantLimits[data.seed] - 1
                    task.wait(0.05)
                end
            end
            task.wait(1)
        end
    end)
end

local function StartAutoWater()
    print("[AutoWater] Started")
    task.spawn(function()
        while AutoSettings.AutoWater do
            FireNet("Garden", "WaterPlant", 0)
            task.wait(2)
        end
    end)
end

local function StartAutoPlaceSprinkler()
    print("[AutoPlaceSprinkler] Started")
    task.spawn(function()
        while AutoSettings.AutoPlaceSprinkler do
            FireNet("Garden", "PlaceSprinkler", 0)
            task.wait(3)
        end
    end)
end

local function StartAutoHarvestSpecial()
    print("[AutoHarvestSpecial] Started")
    task.spawn(function()
        while AutoSettings.AutoHarvestSpecial do
            for _, seedName in ipairs(SpecialSeeds) do
                FireNet("Garden", "CollectFruit", seedName, "")
            end
            task.wait(0.2)
        end
    end)
end

local function StartAutoPickupRainbow()
    print("[AutoPickupRainbow] Started")
    task.spawn(function()
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
                                    if obj:IsA("Tool") then
                                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and obj:FindFirstChild("Handle") then
                                            hrp.CFrame = obj.Handle.CFrame
                                            SendDiscordNotification("rainbow", {seedName = obj.Name})
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
end

local function StartAutoPickupGold()
    print("[AutoPickupGold] Started")
    task.spawn(function()
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
                                    if obj:IsA("Tool") then
                                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and obj:FindFirstChild("Handle") then
                                            hrp.CFrame = obj.Handle.CFrame
                                            SendDiscordNotification("gold", {seedName = obj.Name})
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
end

local function StartAutoBuyPets()
    print("[AutoBuyPets] Started")
    task.spawn(function()
        while AutoSettings.AutoBuyPets do
            task.wait(0.3)
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:match("Pet") then
                    pcall(function()
                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local petHrp = obj:FindFirstChild("HumanoidRootPart")
                            if petHrp then
                                local distance = (hrp.Position - petHrp.Position).Magnitude
                                if distance > 50 then
                                    hrp.CFrame = petHrp.CFrame
                                    task.wait(0.1)
                                end
                                
                                for _, child in pairs(petHrp:GetChildren()) do
                                    if child:IsA("ProximityPrompt") then
                                        fireproximityprompt(child)
                                        SendDiscordNotification("pet", {petName = obj.Name, rarity = "Unknown"})
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)
end

local function StartAutoRedeemCode()
    print("[AutoRedeemCode] Started")
    task.spawn(function()
        task.wait(3)
        FireNet("Codes", "RedeemCode", AutoSettings.RedeemCode or "TEAMGREENBEAN")
        print("[GrowGarden2] Code redeemed: " .. (AutoSettings.RedeemCode or "TEAMGREENBEAN"))
    end)
end

-- ============================================
-- START ALL FEATURES
-- ============================================

local function StartAllFeatures()
    SetStatus("🚀 Starting...", "")
    SetFeatures([[⏳ Loading features...]])
    
    task.wait(0.5)
    
    -- Initialize seed counts
    for _, seed in ipairs(SeedList) do
        if not BoughtSeedsCount[seed] then BoughtSeedsCount[seed] = 0 end
        if not PlantedSeedsCount[seed] then PlantedSeedsCount[seed] = 0 end
    end
    
    -- Start all features (all enabled by default)
    if AutoSettings.AutoHarvest then StartAutoHarvest() end
    if AutoSettings.AutoSell then StartAutoSell() end
    if AutoSettings.AutoBuySeeds then StartAutoBuySeeds() end
    if AutoSettings.AutoBuyGears then StartAutoBuyGears() end
    if AutoSettings.AutoPlant then StartAutoPlant() end
    if AutoSettings.AutoWater then StartAutoWater() end
    if AutoSettings.AutoPlaceSprinkler then StartAutoPlaceSprinkler() end
    if AutoSettings.AutoHarvestSpecial then StartAutoHarvestSpecial() end
    if AutoSettings.AutoPickupRainbow then StartAutoPickupRainbow() end
    if AutoSettings.AutoPickupGold then StartAutoPickupGold() end
    if AutoSettings.AutoBuyPets then StartAutoBuyPets() end
    if AutoSettings.AutoRedeemCode then StartAutoRedeemCode() end
    
    -- Update features display
    SetFeatures([[
🌾 AutoHarvest: Active
💵 AutoSell: Active
🛒 AutoBuySeeds: Active
⚙️ AutoBuyGears: Active
🌱 AutoPlant: Active
💧 AutoWater: Active
🚿 AutoSprinkler: Active
✨ AutoHarvestSpecial: Active
🌈 AutoPickupRainbow: Active
💛 AutoPickupGold: Active
🐾 AutoBuyPets: Active
📝 AutoRedeemCode: Active
🎮 ALL FEATURES ACTIVE!
    ]])
    
    SetStatus("🎮 Auto Farm Running!", "All features enabled!")
    print("[GrowGarden2] 🎉 All features started successfully!")
end

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

CreateUI()
LoadConfig()

-- Try loading Networking, continue even if it fails
if not LoadNetworking() then
    task.wait(2)
    LoadNetworking()
end

StartAllFeatures()
