-- Dupe GUI Universal (Savalied Base - Sintaxis Limpia)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu"))()
end)

if not success or type(Rayfield) ~= "table" then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to load Rayfield! Enable VPN.",
        Duration = 10
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "dupe gui by savalied37",
    LoadingTitle = "Dupe GUI",
    LoadingSubtitle = "by savalied37",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DupeGUI",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local Backpack = LocalPlayer:WaitForChild("Backpack")
local selectedItem = ""
local dupeCount = 1
local pickupCount = 5
local backpackItems = {}

local function getClosestItem(maxDist)
    local closest = nil
    local closestDist = maxDist or 40
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return nil end

    for _, item in pairs(itemsFolder:GetChildren()) do
        -- Busca Mjolnir, Bone Scythe o cualquier item seleccionado en la interfaz
        if item:IsA("Model") and (item.Name == selectedItem or item.Name == "Weapon" or item.Name == "Mjolnir") then
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                local dist = (hrp.Position - targetPart.Position).Magnitude
                if dist < closestDist then
                    closest = item
                    closestDist = dist
                end
            end
        elseif item:IsA("BasePart") and (item.Name == selectedItem or item.Name == "Mjolnir") then
            local dist = (hrp.Position - item.Position).Magnitude
            if dist < closestDist then
                closest = item
                closestDist = dist
            end
        end
    end
    return closest
end

local function refreshBackpackList()
    backpackItems = {}
    for _, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(backpackItems, item.Name)
        end
    end
    if #backpackItems == 0 then table.insert(backpackItems, "Empty") end
    return backpackItems
end

local function findItemModel(itemName)
    local playerFolder = workspace:FindFirstChild("player")
    if playerFolder then
        local model = playerFolder:FindFirstChild(itemName) or playerFolder:FindFirstChild("Weapon")
        if model and model:IsA("Model") then return model end
    end

    local playerModel = workspace:FindFirstChild(LocalPlayer.Name)
    if playerModel then
        local model = playerModel:FindFirstChild(itemName) or playerModel:FindFirstChild("Weapon")
        if model and model:IsA("Model") then return model end
    end

    local character = LocalPlayer.Character
    if character then
        for _, obj in pairs(character:GetChildren()) do
            if obj:IsA("Model") and (obj.Name == itemName or obj.Name == "Weapon") then return obj end
        end
    end
    return nil
end

local function findWeaponModel()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Weapon" or obj.Name == selectedItem) then
            return obj
        end
    end
    return nil
end

local function doDupe(itemName, times, pickups)
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then
        itemsFolder = Instance.new("Folder")
        itemsFolder.Name = "Items"
        itemsFolder.Parent = workspace
    end

    local totalPickups = times * pickups
    local successfulPickups = 0

    for i = 1, times do
        Rayfield:Notify({ Title = "Dupe GUI", Content = "Cycle " .. i .. "/" .. times, Duration = 2 })

        local tool = Backpack:FindFirstChild(itemName)
        if not tool then
            Rayfield:Notify({ Title = "Error", Content = "Tool '" .. itemName .. "' not found!", Duration = 3 })
            return
        end

        local character = LocalPlayer.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:EquipTool(tool) end
        task.wait(0.3)

        local equippedTool = character:FindFirstChildOfClass("Tool")
        if equippedTool then equippedTool.Parent = Backpack end
        task.wait(0.3)

        local itemModel = findItemModel(itemName)
        if itemModel then itemModel.Parent = itemsFolder; task.wait(0.2) end

        local weaponModel = findWeaponModel()
        if weaponModel then weaponModel.Parent = itemsFolder; task.wait(0.2) end

        task.wait(0.3)

        for p = 1, pickups do
            local closestItem = getClosestItem(40)
            if closestItem then
                -- Formato alternativo sin corchetes numéricos para evitar errores de sintaxis
                local args = {}
                table.insert(args, "Pickup")
                table.insert(args, closestItem)
                ReplicatedStorage.Inventory:FireServer(unpack(args))
                successfulPickups = successfulPickups + 1
                task.wait(0.2)
            end
        end
        task.wait(0.5)
    end

    task.wait(1)
    Rayfield:Notify({ Title = "Dupe GUI", Content = "Sending to Vault...", Duration = 3 })

    local vaultSuccess = 0
    for i = 1, totalPickups do
        local safeItems = LocalPlayer:FindFirstChild("SafeItems")
        if safeItems then
            local vaultItem = safeItems:FindFirstChild(itemName)
            if vaultItem then
                local args = {}
                table.insert(args, "Vault")
                table.insert(args, vaultItem)
                ReplicatedStorage:WaitForChild("Vault"):FireServer(unpack(args))
                vaultSuccess = vaultSuccess + 1
                task.wait(0.2)
            end
        end
    end

    Rayfield:Notify({ Title = "Complete!", Content = "Pickup: " .. successfulPickups .. " | Vault: " .. vaultSuccess, Duration = 4 })
end

local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateSection("Settings")

local ItemDropdown = MainTab:CreateDropdown({
    Name = "Select Item",
    Options = refreshBackpackList(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SelectedItem",
    Callback = function(Option) selectedItem = Option[1] or Option end
})

MainTab:CreateSlider({
    Name = "Cycles",
    Range = {1, 50},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "DupeCount",
    Callback = function(Value) dupeCount = Value end
})

MainTab:CreateDropdown({
    Name = "Pickups per Cycle",
    Options = {"1", "5", "10", "15", "20"},
    CurrentOption = {"5"},
    MultipleOptions = false,
    Flag = "PickupCount",
    Callback = function(Option) pickupCount = tonumber(Option[1] or Option) or 5 end
})

MainTab:CreateButton({
    Name = "Refresh Backpack",
    Callback = function()
        local list = refreshBackpackList()
        ItemDropdown:Refresh(list, true)
        Rayfield:Notify({ Title = "Refreshed", Content = "Found: " .. #list, Duration = 2 })
    end
})

MainTab:CreateSection("Actions")

MainTab:CreateButton({
    Name = "Start Dupe",
    Callback = function()
        if selectedItem == "" or selectedItem == "Empty" then
            Rayfield:Notify({ Title = "Error", Content = "Select an item!", Duration = 3 })
            return
        end
        local total = dupeCount * pickupCount
        Rayfield:Notify({ Title = "Starting", Content = selectedItem .. "\nCycles: " .. dupeCount .. " | Pickups: " .. pickupCount .. "\nTotal: " .. total, Duration = 4 })
        task.spawn(function() doDupe(selectedItem, dupeCount, pickupCount) end)
    end
})

MainTab:CreateButton({
    Name = "Vault (1x)",
    Callback = function()
        if selectedItem == "" or selectedItem == "Empty" then return end
        local safeItems = LocalPlayer:FindFirstChild("SafeItems")
        if safeItems then
            local vaultItem = safeItems:FindFirstChild(selectedItem)
            if vaultItem then
                local args = {}
                table.insert(args, "Vault")
                table.insert(args, vaultItem)
                ReplicatedStorage:WaitForChild("Vault"):FireServer(unpack(args))
                Rayfield:Notify({ Title = "Vault", Content = "Sent: " .. selectedItem, Duration = 2 })
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Quick Pickup x5",
    Callback = function()
        for i = 1, 5 do
            local item = getClosestItem(40)
            if item then
                local args = {}
                table.insert(args, "Pickup")
                table.insert(args, item)
                ReplicatedStorage.Inventory:FireServer(unpack(args))
                task.wait(0.15)
            end
        end
        Rayfield:Notify({ Title = "Pickup", Content = "Completed 5 Pickups", Duration = 2 })
    end
})

task.spawn(function()
    task.wait(1)
    local list = refreshBackpackList()
    if #list > 0 and list[1] ~= "Empty" then selectedItem = list[1] end
end)
