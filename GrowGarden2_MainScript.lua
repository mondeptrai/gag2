--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           Grow Garden 2 - Ultimate Auto Farm                ║
    ║                    Main Script (Core)                        ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  ALL FEATURES AUTO-ENABLED - Based on UltimateGUI          ║
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

-- ============================================
-- AUTO FARM SETTINGS (ALL ENABLED BY DEFAULT)
-- ============================================
local AutoSettings = {
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
    AutoPickupRainbow = true,
    AutoPickupGold = true,
    AutoRedeemCode = true,
    HarvestDelay = 0.01,
    SellDelay = 0.1,
    PlantDelay = 0.1,
    BuyDelay = 0.02,
    FPSCap = 60,
    LowEffect = true,
    RedeemCode = "TEAMGREENBEAN",
    DiscordWebhook = "",
    DiscordNotifications = {
        RainbowSeeds = true,
        GoldSeeds = true,
        Pets = true,
    },
}

-- ============================================
-- SEED DATA
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
    ["Sunflower"] = 1750, ["Poison Ivy"] = 1700, ["Romanesco"] = 1500,
    ["Poison Apple"] = 900, ["Pomegranate"] = 900, ["Bamboo"] = 800,
    ["Glow Mushroom"] = 700, ["Cherry"] = 350, ["Acorn"] = 200,
    ["Horned Melon"] = 200, ["Dragon Fruit"] = 150, ["Mango"] = 90,
    ["Baby Cactus"] = 70, ["Coconut"] = 60, ["Tulip"] = 60,
    ["Grape"] = 45, ["Cactus"] = 40, ["Banana"] = 35, ["Corn"] = 34,
    ["Pineapple"] = 30, ["Apple"] = 12, ["Green Bean"] = 10, ["Tomato"] = 9,
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

local SeedPlantLimits = {
    ["Carrot"] = 50, ["Strawberry"] = 50, ["Blueberry"] = 50, ["Tulip"] = 50,
    ["Tomato"] = 50, ["Apple"] = 50, ["Corn"] = 50, ["Cactus"] = 50,
    ["Pineapple"] = 50, ["Bamboo"] = 20, ["Mushroom"] = 20, ["Green Bean"] = 20,
    ["Banana"] = 20, ["Grape"] = 20, ["Coconut"] = 20, ["Mango"] = 20,
    ["Dragon Fruit"] = 20, ["Acorn"] = 20, ["Cherry"] = 20, ["Sunflower"] = 20,
    ["Venus Fly Trap"] = 10, ["Pomegranate"] = 10, ["Poison Apple"] = 10,
    ["Venom Spitter"] = 10, ["Moon Bloom"] = 10, ["Dragon's Breath"] = 10,
}

local SpecialSeeds = {
    "Rainbow Strawberry", "Rainbow Blueberry", "Rainbow Apple", "Rainbow Corn",
    "Rainbow Grape", "Rainbow Pineapple", "Rainbow Banana", "Rainbow Melon",
    "Rainbow Dragon Fruit", "Rainbow Mango", "Rainbow Lotus", "Rainbow Moon Bloom",
    "Gold Strawberry", "Gold Blueberry", "Gold Apple", "Gold Corn",
    "Gold Grape", "Gold Pineapple", "Gold Banana", "Gold Melon",
    "Gold Dragon Fruit", "Gold Mango", "Gold Lotus", "Gold Moon Bloom",
}

local GLOBAL_MAX_PLANTS = 800
local PlantedSeedsCount = {}
local BoughtSeedsCount = {}

-- ============================================
-- UI CREATION
-- ============================================
local ScreenGui, StatusLabel, FeaturesLabel

local function CreateUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowGarden2_AutoFarm"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 350)
    Frame.Position = UDim2.new(0.01, 0, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Frame.BackgroundTransparency = 0.05
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "🌱 GrowGarden2 AutoFarm"
    Title.TextColor3 = Color3.fromRGB(72, 195, 115)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -10, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 40)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏳ Loading..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 75)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Frame
    
    FeaturesLabel = Instance.new("TextLabel")
    FeaturesLabel.Size = UDim2.new(1, -20, 1, -60)
    FeaturesLabel.Position = UDim2.new(0, 10, 0, 70)
    FeaturesLabel.BackgroundTransparency = 1
    FeaturesLabel.Text = "⏳ Initializing..."
    FeaturesLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    FeaturesLabel.TextSize = 11
    FeaturesLabel.Font = Enum.Font.Gotham
    FeaturesLabel.TextXAlignment = Enum.TextXAlignment.Left
    FeaturesLabel.TextYAlignment = Enum.TextYAlignment.Top
    FeaturesLabel.Parent = Frame
    
    print("[GrowGarden2] UI Created")
end

local function SetStatus(text)
    if StatusLabel then StatusLabel.Text = text end
    print("[Status] " .. text)
end

local function SetFeatures(text)
    if FeaturesLabel then FeaturesLabel.Text = text end
end

-- ============================================
-- LOAD CONFIG FROM LOADER
-- ============================================
local function LoadConfig()
    SetStatus("📋 Loading Config...")
    
    if Config.BuyLimits then
        for seed, limit in pairs(Config.BuyLimits) do
            local normSeed = seed:gsub("(%l)(%w*)", function(a,b) return a:upper()..b end)
            if SeedBuyLimits[seed] then SeedBuyLimits[seed] = limit
            elseif SeedBuyLimits[normSeed] then SeedBuyLimits[normSeed] = limit end
        end
    end
    
    if Config.Webhook then
        AutoSettings.DiscordWebhook = Config.Webhook.URL or ""
        AutoSettings.DiscordNotifications.RainbowSeeds = Config.Webhook.NotifyRainbow ~= false
        AutoSettings.DiscordNotifications.GoldSeeds = Config.Webhook.NotifyGold ~= false
        AutoSettings.DiscordNotifications.Pets = Config.Webhook.NotifyPets ~= false
    end
    
    if Config.MailSystem then
        AutoSettings.SendPetUsername = Config.MailSystem.SendPetUsername or ""
        AutoSettings.SendSeedUsername = Config.MailSystem.SendSeedUsername or ""
    end
    
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
    
    SetStatus("✅ Config Loaded")
end

-- ============================================
-- NETWORKING (EXACT COPY FROM ULTIMATE GUI)
-- ============================================
local NetworkingCache = nil

local function GetNetworking()
    if NetworkingCache then return NetworkingCache end
    
    local success, net = pcall(function()
        local sm = ReplicatedStorage:WaitForChild("SharedModules", 15)
        if not sm then return nil end
        return require(sm:WaitForChild("Networking", 15))
    end)
    
    if success and net then
        NetworkingCache = net
        print("[GrowGarden2] Networking loaded!")
    end
    
    return success and net or nil
end

local function GetNetworkingEvents()
    if NetworkingCache then return NetworkingCache end
    
    local net = GetNetworking()
    if net then
        NetworkingCache = net
    end
    return NetworkingCache
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
    
    for _, f in ipairs(fruits)
 do
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

local function SendDiscordNotification(type, data)
    if not AutoSettings.DiscordWebhook or AutoSettings.DiscordWebhook == "" then return end
    
    local content = ""
    if type == "pet" and AutoSettings.DiscordNotifications.Pets then
        content = "🐾 **Rare Pet!** " .. (data.petName or "Unknown")
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
-- CORE ACTIONS (EXACT COPY FROM ULTIMATE GUI)
-- ============================================

-- Sell All Items
local function SellAllItems()
    local net = GetNetworkingEvents()
    if net and net.NPCS and net.NPCS.SellAll then
        net.NPCS.SellAll:Fire()
        return true
    end
    
    -- Fallback: Proximity prompt
    pcall(function()
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
    end)
    
    return false
end

-- Harvest Plant
local function HarvestPlant(model, fruitId)
    local success = false
    
    pcall(function()
        local plantUUID = model:GetAttribute("PlantUUID")
        local net = GetNetworkingEvents()
        
        if net and net.Garden and net.Garden.CollectFruit then
            net.Garden.CollectFruit:Fire(plantUUID or "", fruitId or "")
            success = true
            return
        end
        
        -- Fallback: Proximity prompt
        if model:IsDescendantOf(workspace) then
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("ProximityPrompt") then
                    fireproximityprompt(part)
                    success = true
                    return
                end
            end
        end
    end)
    
    return success
end

-- Buy Seed
local function BuySeed(seedName)
    local success, err = pcall(function()
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        if Networking.SeedShop and Networking.SeedShop.PurchaseSeed then
            local purchaseSeed = Networking.SeedShop.PurchaseSeed
            local mt = getmetatable(purchaseSeed)
            if mt and mt.Fire then
                mt.Fire(purchaseSeed, seedName)
                return true
            end
        end
    end)
    return success and err == true
end

-- Plant Seed (position first, then seed name)
local function PlantSeed(seedName)
    local success = pcall(function()
        if CountSeedsInBackpack(seedName) == 0 then
            return false
        end
        
        local gardenPos = GetGardenPosition()
        if not gardenPos then return false end
        
        local plantPos = gardenPos + Vector3.new(math.random(-5, 5), 0.5, math.random(-5, 5))
        
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        local plantSeed = Networking.Plant.PlantSeed
        local mt = getmetatable(plantSeed)
        
        if mt and mt.Fire then
            mt.Fire(plantSeed, plantPos, seedName)
            return true
        end
    end)
    return success
end

-- Buy Gear
local function BuyGear(gearName)
    pcall(function()
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        if Networking.GearShop and Networking.GearShop.PurchaseGear then
            local purchaseGear = Networking.GearShop.PurchaseGear
            local mt = getmetatable(purchaseGear)
            if mt and mt.Fire then
                mt.Fire(purchaseGear, gearName)
            end
        end
    end)
end

-- Water Plant
local function WaterPlants()
    pcall(function()
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        if Networking.Garden and Networking.Garden.WaterPlant then
            local waterPlant = Networking.Garden.WaterPlant
            local mt = getmetatable(waterPlant)
            if mt and mt.Fire then
                mt.Fire(waterPlant, 0)
            end
        end
    end)
end

-- Place Sprinkler
local function PlaceSprinkler()
    pcall(function()
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        if Networking.Garden and Networking.Garden.PlaceSprinkler then
            local placeSprinkler = Networking.Garden.PlaceSprinkler
            local mt = getmetatable(placeSprinkler)
            if mt and mt.Fire then
                mt.Fire(placeSprinkler, 0)
            end
        end
    end)
end

-- Collect Special Fruit
local function CollectSpecialFruit(seedName)
    pcall(function()
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        if Networking.Garden and Networking.Garden.CollectFruit then
            local collectFruit = Networking.Garden.CollectFruit
            local mt = getmetatable(collectFruit)
            if mt and mt.Fire then
                mt.Fire(collectFruit, seedName, "")
            end
        end
    end)
end

-- Redeem Code
local function RedeemCode(code)
    pcall(function()
        local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
        if Networking.Codes and Networking.Codes.RedeemCode then
            local redeemCode = Networking.Codes.RedeemCode
            local mt = getmetatable(redeemCode)
            if mt and mt.Fire then
                mt.Fire(redeemCode, code)
            end
        end
    end)
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
                    HarvestPlant(interactModel, fruit.FruitId or "")
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
            SellAllItems()
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
                        if BuySeed(data.seed) then
                            SeedBuyLimits[data.seed] = SeedBuyLimits[data.seed] - 1
                        end
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
                BuyGear(gear)
            end
            task.wait(2)
        end
    end)
end

local function StartAutoPlant()
    print("[AutoPlant] Started")
    task.spawn(function()
        while AutoSettings.AutoPlant do
            local sortedSeeds = {}
            for seed, value in pairs(SeedValues) do
                if SeedPlantLimits[seed] and SeedPlantLimits[seed] > 0 and CountSeedsInBackpack(seed) > 0 then
                    table.insert(sortedSeeds, {seed = seed, value = value})
                end
            end
            table.sort(sortedSeeds, function(a, b) return a.value > b.value end)
            
            for _, data in ipairs(sortedSeeds) do
                if not AutoSettings.AutoPlant then break end
                
                if PlantSeed(data.seed) then
                    SeedPlantLimits[data.seed] = SeedPlantLimits[data.seed] - 1
                end
                task.wait(AutoSettings.PlantDelay)
            end
            
            task.wait(1)
        end
    end)
end

local function StartAutoWater()
    print("[AutoWater] Started")
    task.spawn(function()
        while AutoSettings.AutoWater do
            WaterPlants()
            task.wait(2)
        end
    end)
end

local function StartAutoPlaceSprinkler()
    print("[AutoPlaceSprinkler] Started")
    task.spawn(function()
        while AutoSettings.AutoPlaceSprinkler do
            PlaceSprinkler()
            task.wait(3)
        end
    end)
end

local function StartAutoHarvestSpecial()
    print("[AutoHarvestSpecial] Started")
    task.spawn(function()
        while AutoSettings.AutoHarvestSpecial do
            for _, seedName in ipairs(SpecialSeeds) do
                CollectSpecialFruit(seedName)
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
                                        SendDiscordNotification("pet", {petName = obj.Name})
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
        RedeemCode(AutoSettings.RedeemCode or "TEAMGREENBEAN")
        print("[GrowGarden2] Code redeemed: " .. (AutoSettings.RedeemCode or "TEAMGREENBEAN"))
    end)
end

-- ============================================
-- START ALL FEATURES
-- ============================================

local function StartAllFeatures()
    SetStatus("🚀 Starting Features...")
    
    -- Initialize
    for _, seed in ipairs(SeedList) do
        if not BoughtSeedsCount[seed] then BoughtSeedsCount[seed] = 0 end
        if not PlantedSeedsCount[seed] then PlantedSeedsCount[seed] = 0 end
    end
    
    -- Start all features
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
    
    SetFeatures([[
🌾 AutoHarvest: ✅
💵 AutoSell: ✅
🛒 AutoBuySeeds: ✅
⚙️ AutoBuyGears: ✅
🌱 AutoPlant: ✅
💧 AutoWater: ✅
🚿 AutoSprinkler: ✅
✨ AutoHarvestSpecial: ✅
🌈 AutoPickupRainbow: ✅
💛 AutoPickupGold: ✅
🐾 AutoBuyPets: ✅
📝 AutoRedeemCode: ✅
🎮 ALL FEATURES ACTIVE!
    ]])
    
    SetStatus("🎮 Auto Farm Running!")
    print("[GrowGarden2] 🎉 All features started!")
end

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

CreateUI()
LoadConfig()
StartAllFeatures()
