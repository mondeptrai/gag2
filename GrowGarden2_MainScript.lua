--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           Grow Garden 2 - Ultimate Auto Farm                ║
    ║                    Main Script (Core)                      ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  Auto-enabled features for new players:                   ║
    ║  • Auto Harvest • Auto Sell • Auto Plant • Auto Water     ║
    ║  • Auto Buy Seeds • Auto Buy Gears • Auto Buy Pets         ║
    ║  • Auto Pickup Events • Auto Redeem Codes                 ║
    ║  • Auto Send Mail • Low Effect Mode                       ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- Key Authentication
if not getgenv().Key or getgenv().Key == "ENTER_YOUR_KEY_HERE" then
    warn("❌ Invalid or missing key! Please set your key in Loader.lua")
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration (from Loader)
local Config = getgenv().GardenConfig or {}

-- Auto Farm Settings (Default - will be overridden by Loader config)
local AutoSettings = {
    AutoHarvest = true,
    AutoHarvestSpeed = 0.05,
    AutoHarvestSpecial = true,
    AutoPickupRainbow = true,
    AutoPickupGold = true,
    AutoBuyPets = true,
    AutoBuyPetsMaxPrice = 0,
    AutoBuyPetsRarityFilter = true,
    AutoSell = true,
    AutoSellSpeed = 0.1,
    AutoBuySeeds = true,
    AutoBuyGears = true,
    AutoPlant = true,
    AutoPlantMode = "efficiency",
    AutoStackSeeds = true,
    StackPosition = 1,
    SelectedSeeds = {},
    SelectedSeed = "Carrot",
    SelectedGears = {},
    TargetPlot = 0,
    HarvestDelay = 0.05,
    SellDelay = 0.1,
    PlantDelay = 0.1,
    BuyDelay = 0.02,
    AutoWater = true,
    AutoWaterMode = "value_growtime",
    AutoPlaceSprinkler = true,
    DiscordWebhook = "",
    DiscordNotifications = {
        RainbowSeeds = true,
        GoldSeeds = true,
        Pets = true,
    },
    FPSCap = 5,
    LowEffect = true,
    AutoSendMail = true,
    AutoSendPets = true,
    AutoSendSeeds = true,
    AutoSendSeedNote = true,
    SendPetUsername = "",
    SendSeedUsername = "",
    WishSeedUsername = "",
    SendPetNote = "pet mail",
    SendSeedNote = "seed mail",
    WishSeedNote = "wish mail",
    AutoRedeemCode = true,
    RedeemCode = "TEAMGREENBEAN",
}

-- Seed Limits
local SeedPlantLimits = {
    ["Carrot"] = 50, ["Strawberry"] = 50, ["Blueberry"] = 50, ["Tulip"] = 50,
    ["Tomato"] = 50, ["Apple"] = 50, ["Corn"] = 50, ["Cactus"] = 50,
    ["Pineapple"] = 50, ["Bamboo"] = 20, ["Mushroom"] = 20, ["Green Bean"] = 20,
    ["Banana"] = 20, ["Grape"] = 20, ["Coconut"] = 20, ["Mango"] = 20,
    ["Dragon Fruit"] = 20, ["Acorn"] = 20, ["Cherry"] = 20, ["Sunflower"] = 20,
    ["Venus Fly Trap"] = 10, ["Pomegranate"] = 10, ["Poison Apple"] = 10,
    ["Venom Spitter"] = 10, ["Cacao"] = 5, ["Papaya"] = 5, ["Horned Melon"] = 5,
}

local SeedBuyLimits = {}
for seed, _ in pairs(SeedPlantLimits) do
    SeedBuyLimits[seed] = 9999
end

-- Special Seeds
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
}

-- Pet Rarities
local RarityOrder = {Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6, Super = 7}

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
    ["Carrot"] = 20, ["Rose"] = 25, ["Orchid"] = 35, ["Bonsai"] = 75,
    ["Lavender"] = 45, ["Glow Mushroom"] = 92, ["Romanesco"] = 91, ["Baby Cactus"] = 50,
}

-- Load config from Loader
local function LoadConfig()
    if Config.PetSettings then
        AutoSettings.AutoBuyPets = Config.PetSettings.AutoBuyPets or true
        AutoSettings.AutoBuyPetsRarityFilter = Config.PetSettings.RarityFilter or true
        AutoSettings.AutoBuyPetsMaxPrice = Config.PetSettings.MaxPrice or 0
    end
    
    if Config.MailSystem then
        AutoSettings.SendPetUsername = Config.MailSystem.SendPetUsername or ""
        AutoSettings.SendSeedUsername = Config.MailSystem.SendSeedUsername or ""
        AutoSettings.WishSeedUsername = Config.MailSystem.WishUsername or ""
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
    
    -- Auto-enable all features
    AutoSettings.AutoHarvest = true
    AutoSettings.AutoHarvestSpecial = true
    AutoSettings.AutoPickupRainbow = true
    AutoSettings.AutoPickupGold = true
    AutoSettings.AutoSell = true
    AutoSettings.AutoBuySeeds = true
    AutoSettings.AutoBuyGears = true
    AutoSettings.AutoPlant = true
    AutoSettings.AutoWater = true
    AutoSettings.AutoPlaceSprinkler = true
    AutoSettings.AutoRedeemCode = true
    AutoSettings.AutoStackSeeds = true
    AutoSettings.LowEffect = true
    AutoSettings.AutoSendMail = true
    
    -- Apply FPS Cap
    setfpscap(AutoSettings.FPSCap or 5)
    
    -- Apply Low Effect
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
    
    print("✅ Auto Farm Started - All features enabled!")
end

-- Helper Functions
local function GetRemote(name)
    return ReplicatedStorage:WaitForChild(name, 5)
end

local function SendNotification(type, msg)
    if type == "rainbow" and AutoSettings.DiscordWebhook and AutoSettings.DiscordNotifications.RainbowSeeds then
        local data = {content = "🌈 **Rainbow Seed!**\n" .. msg}
        pcall(function()
            HttpService:PostAsync(AutoSettings.DiscordWebhook, HttpService:JSONEncode(data))
        end)
    elseif type == "gold" and AutoSettings.DiscordWebhook and AutoSettings.DiscordNotifications.GoldSeeds then
        local data = {content = "💛 **Gold Seed!**\n" .. msg}
        pcall(function()
            HttpService:PostAsync(AutoSettings.DiscordWebhook, HttpService:JSONEncode(data))
        end)
    elseif type == "pet" and AutoSettings.DiscordWebhook and AutoSettings.DiscordNotifications.Pets then
        local data = {content = "🐾 **Rare Pet!**\n" .. msg}
        pcall(function()
            HttpService:PostAsync(AutoSettings.DiscordWebhook, HttpService:JSONEncode(data))
        end)
    end
end

local function ShouldAutoBuyPet(rarity)
    if not AutoSettings.AutoBuyPetsRarityFilter then return true end
    if Config.PetSettings and Config.PetSettings.AllowedRarities then
        return Config.PetSettings.AllowedRarities[rarity] == true
    end
    return rarity == "Legendary" or rarity == "Mythic" or rarity == "Super"
end

-- Main Loops
local function StartAutoFarm()
    -- Auto Redeem Code
    task.spawn(function()
        if AutoSettings.AutoRedeemCode then
            task.wait(2)
            local redeemRemote = GetRemote("RedeemCode")
            if redeemRemote then
                redeemRemote:InvokeServer(AutoSettings.RedeemCode)
                print("📝 Code redeemed: " .. AutoSettings.RedeemCode)
            end
        end
    end)
    
    -- Auto Harvest
    task.spawn(function()
        while AutoSettings.AutoHarvest do
            task.wait(AutoSettings.HarvestDelay or 0.05)
            local harvestRemote = GetRemote("HarvestPlot")
            if harvestRemote then
                pcall(function()
                    harvestRemote:FireServer(AutoSettings.TargetPlot)
                end)
            end
        end
    end)
    
    -- Auto Sell
    task.spawn(function()
        while AutoSettings.AutoSell do
            task.wait(AutoSettings.SellDelay or 0.1)
            local sellRemote = GetRemote("SellInventory")
            if sellRemote then
                pcall(function()
                    sellRemote:FireServer()
                end)
            end
        end
    end)
    
    -- Auto Buy Seeds
    task.spawn(function()
        while AutoSettings.AutoBuySeeds do
            task.wait(AutoSettings.BuyDelay or 0.02)
            local buyRemote = GetRemote("BuySeed")
            if buyRemote then
                for seed, limit in pairs(SeedBuyLimits) do
                    if limit > 0 then
                        pcall(function()
                            buyRemote:FireServer(seed, 1)
                        end)
                    end
                end
            end
        end
    end)
    
    -- Auto Buy Gears
    task.spawn(function()
        while AutoSettings.AutoBuyGears do
            task.wait(AutoSettings.BuyDelay or 0.5)
            local buyGearRemote = GetRemote("BuyGear")
            if buyGearRemote then
                local gears = {"Watering Can", "Sprinkler", "Fertilizer", "Hoe", "Shovel"}
                for _, gear in ipairs(gears) do
                    pcall(function()
                        buyGearRemote:FireServer(gear, 1)
                    end)
                end
            end
        end
    end)
    
    -- Auto Plant
    task.spawn(function()
        while AutoSettings.AutoPlant do
            task.wait(AutoSettings.PlantDelay or 0.1)
            local plantRemote = GetRemote("PlantSeed")
            if plantRemote then
                -- Plant by efficiency mode (best seeds first)
                local sortedSeeds = {}
                for seed, value in pairs(SeedValues) do
                    table.insert(sortedSeeds, {seed = seed, value = value})
                end
                table.sort(sortedSeeds, function(a, b) return a.value > b.value end)
                
                for _, data in ipairs(sortedSeeds) do
                    if SeedPlantLimits[data.seed] and SeedPlantLimits[data.seed] > 0 then
                        pcall(function()
                            plantRemote:FireServer(data.seed, AutoSettings.TargetPlot)
                        end)
                        SeedPlantLimits[data.seed] = SeedPlantLimits[data.seed] - 1
                    end
                end
            end
        end
    end)
    
    -- Auto Water
    task.spawn(function()
        while AutoSettings.AutoWater do
            task.wait(1)
            local waterRemote = GetRemote("WaterPlot")
            if waterRemote then
                pcall(function()
                    waterRemote:FireServer(AutoSettings.TargetPlot)
                end)
            end
        end
    end)
    
    -- Auto Place Sprinkler
    task.spawn(function()
        while AutoSettings.AutoPlaceSprinkler do
            task.wait(2)
            local sprinklerRemote = GetRemote("PlaceSprinkler")
            if sprinklerRemote then
                pcall(function()
                    sprinklerRemote:FireServer()
                end)
            end
        end
    end)
    
    -- Auto Pickup Rainbow Seeds
    task.spawn(function()
        while AutoSettings.AutoPickupRainbow do
            task.wait(0.5)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name and string.find(obj.Name, "Rainbow") then
                    pcall(function()
                        if obj:IsA("Tool") then
                            Player.Character:FindFirstChild("HumanoidRootPart").CFrame = obj.Position
                        end
                    end)
                end
            end
        end
    end)
    
    -- Auto Pickup Gold Seeds
    task.spawn(function()
        while AutoSettings.AutoPickupGold do
            task.wait(0.5)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name and string.find(obj.Name, "Gold") then
                    pcall(function()
                        if obj:IsA("Tool") then
                            Player.Character:FindFirstChild("HumanoidRootPart").CFrame = obj.Position
                        end
                    end)
                end
            end
        end
    end)
    
    -- Auto Buy Pets
    task.spawn(function()
        while AutoSettings.AutoBuyPets do
            task.wait(1)
            local buyPetRemote = GetRemote("BuyPet")
            if buyPetRemote then
                pcall(function()
                    buyPetRemote:FireServer()
                end)
            end
        end
    end)
    
    -- Auto Send Mail (Pets)
    task.spawn(function()
        while AutoSettings.AutoSendPets and AutoSettings.SendPetUsername ~= "" do
            task.wait(10)
            local mailRemote = GetRemote("SendPetMail")
            if mailRemote then
                pcall(function()
                    mailRemote:InvokeServer(AutoSettings.SendPetUsername, AutoSettings.SendPetNote)
                end)
            end
        end
    end)
    
    -- Auto Send Mail (Seeds)
    task.spawn(function()
        while AutoSettings.AutoSendSeeds and AutoSettings.SendSeedUsername ~= "" do
            task.wait(10)
            local mailRemote = GetRemote("SendSeedMail")
            if mailRemote then
                pcall(function()
                    mailRemote:InvokeServer(AutoSettings.SendSeedUsername, AutoSettings.SendSeedNote)
                end)
            end
        end
    end)
    
    -- Auto Harvest Special Seeds
    task.spawn(function()
        while AutoSettings.AutoHarvestSpecial do
            task.wait(0.2)
            local harvestRemote = GetRemote("HarvestPlot")
            if harvestRemote then
                for _, seed in ipairs(SpecialSeeds) do
                    pcall(function()
                        harvestRemote:FireServer(seed)
                    end)
                end
            end
        end
    end)
    
    print("🚀 GrowGarden2 Auto Farm Running!")
    print("🎮 Sit back and let the script do everything for you!")
end

-- Initialize
LoadConfig()
StartAutoFarm()
