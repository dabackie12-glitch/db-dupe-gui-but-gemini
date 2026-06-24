-- Universal Dupe GUI by savalied37 (Rayfield)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local success, Rayfield = pcall(function()
    -- Borra la línea vieja que usaba sirius.menu y pon esta:
    -- Borra el anterior y pon este link espejo en el HttpGet:
    return loadstring(game:HttpGet("https://pastebin.com"))()

end)

if not success or type(Rayfield) ~= "table" then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to load Rayfield! try again ivan",
        Duration = 10
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Universal Dupe GUI",
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

-- Busca cualquier parte física del ítem cerca, validando por nombre o proximidad
local function getClosestItem(maxDist, itemName)
    local closest = nil
    local closestDist = maxDist or 40
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local itemsFolder = workspace:FindFirstChild("Items") or workspace
    
    for _, item in pairs(itemsFolder:GetDescendants()) do
        if item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool") then
            local targetPart = item:IsA("Model") and item.PrimaryPart or (item:IsA("BasePart") and item or nil)
            if not targetPart and item:FindFirstChildWhichIsA("BasePart") then
                targetPart = item:FindFirstChildWhichIsA("BasePart")
            end

            if targetPart and not item:IsDescendantOf(character) then
                -- Si no se especifica nombre, busca cualquier cosa. Si se especifica, filtra dinámicamente.
                if not itemName or (item.Name:lower() == itemName:lower() or item.Name == "Weapon") then
                    local dist = (hrp.Position - targetPart.Position).Magnitude
                    if dist < closestDist then
                        closest = item
                        closestDist = dist
                    end
                end
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
    if LocalPlayer.Character then
        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") and not table.find(backpackItems, item.Name) then
                table.insert(backpackItems, item.Name)
            end
        end
    end
    if #backpackItems == 0 then table.insert(backpackItems, "Empty") end
    return backpackItems
end

-- Encuentra dinámicamente el modelo físico generado al soltar o equipar el ítem
local function findAnyItemModel(itemName)
    local character = LocalPlayer.Character
    if not character then return nil end

    local searchTargets = {character, workspace:FindFirstChild("player"), workspace:FindFirstChild(LocalPlayer.Name)}
    for _, target in pairs(searchTargets) do
        if target then
            for _, obj in pairs(target:GetChildren()) do
                if obj:IsA("Model") and (obj.Name == itemName or obj.Name == "Weapon") then
                    return obj
                end
            end
        end
    end

    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == itemName or obj.Name == "Weapon") then
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
        local character = LocalPlayer.Character
        if not character then return end

        local equippedTool = character:FindFirstChild(itemName)
        if equippedTool then 
            equippedTool.Parent = Backpack 
            task.wait(0.1)
            tool = Backpack:FindFirstChild(itemName)
        end

        if not tool then
            Rayfield:Notify({ Title = "Error", Content = "Tool '" .. itemName .. "' not found!", Duration = 3 })
            return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:EquipTool(tool) end
        task.wait(0.3)

        equippedTool = character:FindFirstChildOfClass("Tool")
        if equippedTool then equippedTool.Parent = Backpack end
        task.wait(0.3)

        local itemModel = findAnyItemModel(itemName)
        if itemModel then 
            itemModel.Parent = itemsFolder
            task.wait(0.2) 
        end

        task.wait(0.3)

        for p = 1, pickups do
            local closestItem = getClosestItem(40, itemName)
            if closestItem then
                local args = { [1] = "Pickup", [2] = closestItem }
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
    local safeItems = LocalPlayer:FindFirstChild("SafeItems") or LocalPlayer:FindFirstChild("Inventory")
    
    for i = 1, totalPickups do
        if safeItems then
            local vaultItem = safeItems:FindFirstChild(itemName)
            if vaultItem then
                local args = { "Vault", vaultItem }
                ReplicatedStorage:WaitForChild("Vault"):FireServer(unpack(args))
                vaultSuccess = vaultSuccess + 1
                task.wait(0.2)
            end
        end
    end

    Rayfield:Notify({ Title = "Complete!", Content = "Pickup: " .. successfulPickups .. " | Vault: " .. vaultSuccess, Duration = 4 })
end

-- [ INTERFAZ GRÁFICA RAYFIELD ]
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
        local safeItems = LocalPlayer:FindFirstChild("SafeItems") or LocalPlayer:FindFirstChild("Inventory")
        if safeItems then
            local vaultItem = safeItems:FindFirstChild(selectedItem)
            if vaultItem then
                local args = { "Vault", vaultItem }
                ReplicatedStorage:WaitForChild("Vault"):FireServer(unpack(args))
                Rayfield:Notify({ Title = "Vault", Content = "Sent: " .. selectedItem, Duration = 2 })
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Quick Pickup x5",
    Callback = function()
        -- Pasa el objeto seleccionado para que recoja el correcto
        local targetName = (selectedItem ~= "" and selectedItem ~= "Empty") and selectedItem or nil
        for i = 1, 5 do
            local item = getClosestItem(40, targetName)
            if item then
                local args = { [1] = "Pickup", [2] = item }
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
