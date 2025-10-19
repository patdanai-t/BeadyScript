--[[
    God Weapon Script
    Author: TheTorch
]]

local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
    Title = "god weapon",
    Subtitle = "by TheTorch",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.Insert,
    AcrylicBlur = true,
})

local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({Name = "PVP", Image = "rbxassetid://4483362458"})
local FarmTab = TabGroup:Tab({Name = "Farm", Image = "rbxassetid://4483362458"})

local Config = {
    SelectedPlayers = {},
    Highlight = {
        Enabled = true,
        Color = Color3.fromRGB(0, 255, 255),
        Transparency = 0.7
    },
    Target = {
        Size = Vector3.new(20, 20, 20)
    },
    AutoMed = {
        Enabled = false,
        Key = Enum.KeyCode.F,
        KeyName = "F"
    },
    AutoArmor = {
        Enabled = false,
        KeyNumber = 1
    },
    Farm = {
        Parole = {
            Enabled = false,
            VisitedRotations = {}
        },
        Grape = {
            Enabled = false,
            VisitedGrapes = {}
        }
    }
}

local function GetAllPlayers()
    local playerNames = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    return playerNames
end

local function UpdateAllHighlights()
    for _, playerName in pairs(Config.SelectedPlayers) do
        local playerModel = game.Workspace:FindFirstChild(playerName)
        if not playerModel then continue end
        
        local head2 = playerModel:FindFirstChild("Head2")
        if not head2 then continue end
        
        for _, child in pairs(head2:GetChildren()) do
            if string.match(child.Name, "^TARGET_") and child:IsA("BasePart") then
                local highlight = child:FindFirstChildOfClass("Highlight")
                local selectionBox = child:FindFirstChildOfClass("SelectionBox")
                
                if highlight then
                    highlight.Enabled = Config.Highlight.Enabled
                    highlight.OutlineColor = Config.Highlight.Color
                end
                
                if selectionBox then
                    selectionBox.Visible = Config.Highlight.Enabled
                    selectionBox.Color3 = Config.Highlight.Color
                end
                
                if Config.Highlight.Enabled then
                    child.Transparency = Config.Highlight.Transparency
                end
            end
        end
    end
end

local function ModifyTargetSize()
    local modifiedCount = 0
    
    for _, playerName in pairs(Config.SelectedPlayers) do
        local playerModel = game.Workspace:FindFirstChild(playerName)
        if not playerModel then continue end
        
        local head2 = playerModel:FindFirstChild("Head2")
        if not head2 then continue end
        
        for _, child in pairs(head2:GetChildren()) do
            if not string.match(child.Name, "^TARGET_") then continue end
            if not child:IsA("BasePart") then continue end
            
            child.Size = Config.Target.Size
            child.Transparency = Config.Highlight.Transparency
            
            local highlight = child:FindFirstChildOfClass("Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Parent = child
            end
            highlight.FillColor = Config.Highlight.Color
            highlight.OutlineColor = Config.Highlight.Color
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
            highlight.Enabled = Config.Highlight.Enabled
            
            local selectionBox = child:FindFirstChildOfClass("SelectionBox")
            if not selectionBox then
                selectionBox = Instance.new("SelectionBox")
                selectionBox.Parent = child
                selectionBox.Adornee = child
            end
            selectionBox.Color3 = Config.Highlight.Color
            selectionBox.LineThickness = 0.05
            selectionBox.Transparency = 0
            selectionBox.Visible = Config.Highlight.Enabled
            
            modifiedCount = modifiedCount + 1
        end
    end
    
    return modifiedCount
end

local GunSection = MainTab:Section({Side = "Left"})

GunSection:Header({Text = "Gun Settings"})

local PlayerDropdown = GunSection:Dropdown({
    Name = "Select Players",
    Multi = true,
    Required = false,
    Options = GetAllPlayers(),
    Callback = function(Selected)
        Config.SelectedPlayers = {}
        for playerName, isSelected in pairs(Selected) do
            if isSelected then
                table.insert(Config.SelectedPlayers, playerName)
            end
        end
    end
}, "PlayerDropdown")

GunSection:Button({
    Name = "Refresh Players",
    Callback = function()
        PlayerDropdown:ClearOptions()
        PlayerDropdown:InsertOptions(GetAllPlayers())
        Window:Notify({
            Title = "Success",
            Description = "Player list updated",
            Duration = 3
        })
    end
})

GunSection:Input({
    Name = "Target Size (X,Y,Z)",
    Placeholder = "20,20,20",
    AcceptedCharacters = "All",
    Callback = function(Text)
        local values = {}
        for value in string.gmatch(Text, "[^,]+") do
            local num = tonumber(value)
            if num then table.insert(values, num) end
        end
        
        if #values == 3 then
            Config.Target.Size = Vector3.new(values[1], values[2], values[3])
            Window:Notify({
                Title = "Size Updated",
                Description = string.format("Set to %.1f,%.1f,%.1f", values[1], values[2], values[3]),
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "Please enter format: X,Y,Z",
                Duration = 3
            })
        end
    end
})

GunSection:Button({
    Name = "Apply Target Size",
    Callback = function()
        if #Config.SelectedPlayers == 0 then
            Window:Notify({
                Title = "Error",
                Description = "Please select at least 1 player",
                Duration = 3
            })
            return
        end
        
        local count = ModifyTargetSize()
        Window:Notify({
            Title = "Success",
            Description = "Modified " .. count .. " targets",
            Duration = 5
        })
    end
})

GunSection:Button({
    Name = "Reset Target Size to 0,0,0",
    Callback = function()
        if #Config.SelectedPlayers == 0 then
            Window:Notify({
                Title = "Error",
                Description = "Please select at least 1 player",
                Duration = 3
            })
            return
        end
        
        Config.Target.Size = Vector3.new(0, 0, 0)
        local count = ModifyTargetSize()
        Window:Notify({
            Title = "Success",
            Description = "Reset " .. count .. " targets to 0,0,0",
            Duration = 5
        })
    end
})

local HighlightSection = MainTab:Section({Side = "Right"})

HighlightSection:Header({Text = "Highlight Settings"})

HighlightSection:Toggle({
    Name = "Enable Highlight",
    Default = true,
    Callback = function(Value)
        Config.Highlight.Enabled = Value
        UpdateAllHighlights()
    end
}, "HighlightToggle")

HighlightSection:Slider({
    Name = "Transparency",
    Default = 0.7,
    Minimum = 0,
    Maximum = 1,
    DisplayMethod = "Round",
    Precision = 1,
    Callback = function(Value)
        Config.Highlight.Transparency = Value
        UpdateAllHighlights()
    end
}, "HighlightTransparency")

HighlightSection:Colorpicker({
    Name = "Highlight Color",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(Color)
        Config.Highlight.Color = Color
        UpdateAllHighlights()
    end
}, "HighlightColor")

HighlightSection:Divider()
HighlightSection:Header({Text = "Auto Med"})

HighlightSection:Input({
    Name = "Toggle Key",
    Placeholder = "F",
    AcceptedCharacters = "Alphabetic",
    Callback = function(Text)
        local keyText = Text:upper()
        local success, keyCode = pcall(function()
            return Enum.KeyCode[keyText]
        end)
        
        if success and keyCode then
            Config.AutoMed.Key = keyCode
            Config.AutoMed.KeyName = keyText
            Window:Notify({
                Title = "Key Updated",
                Description = "Toggle key set to " .. keyText,
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "Invalid key name",
                Duration = 3
            })
        end
    end
})

local function StartAutoMed()
    spawn(function()
        while Config.AutoMed.Enabled do
            local args = {"Medkit", "", ""}
            game.Lighting:WaitForChild("Sky"):WaitForChild("Optimized"):FireServer(unpack(args))
            wait(5)
        end
    end)
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ~= Config.AutoMed.Key then return end
    
    Config.AutoMed.Enabled = not Config.AutoMed.Enabled
    
    if Config.AutoMed.Enabled then
        StartAutoMed()
        Window:Notify({
            Title = "Auto Med Started",
            Description = "Press " .. Config.AutoMed.KeyName .. " to stop",
            Duration = 3
        })
    else
        Window:Notify({
            Title = "Auto Med Stopped",
            Description = "Press " .. Config.AutoMed.KeyName .. " to start",
            Duration = 3
        })
    end
end)

HighlightSection:Label({Text = "Current Toggle Key: F"})

HighlightSection:Divider()
HighlightSection:Header({Text = "Auto Armor"})

HighlightSection:Input({
    Name = "Armor Key Number (1-8)",
    Placeholder = "1",
    AcceptedCharacters = "Numeric",
    Callback = function(Text)
        local number = tonumber(Text)
        if number and number >= 1 and number <= 8 then
            Config.AutoArmor.KeyNumber = math.floor(number)
            Window:Notify({
                Title = "Armor Key Updated",
                Description = "Set to key " .. Config.AutoArmor.KeyNumber,
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "Please enter number 1-8",
                Duration = 3
            })
        end
    end
})

local function CheckAndEquipArmor()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local playerModel = game.Workspace:FindFirstChild(player.Name)
    if not playerModel then return end
    
    local bodyArmor = playerModel:FindFirstChild("BodyArmor")
    if bodyArmor then return end
    
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local keyMap = {
        [1] = Enum.KeyCode.One,
        [2] = Enum.KeyCode.Two,
        [3] = Enum.KeyCode.Three,
        [4] = Enum.KeyCode.Four,
        [5] = Enum.KeyCode.Five,
        [6] = Enum.KeyCode.Six,
        [7] = Enum.KeyCode.Seven,
        [8] = Enum.KeyCode.Eight
    }
    
    local keyCode = keyMap[Config.AutoArmor.KeyNumber]
    if not keyCode then return end
    
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function StartAutoArmor()
    spawn(function()
        while Config.AutoArmor.Enabled do
            CheckAndEquipArmor()
            wait(1)
        end
    end)
end

HighlightSection:Toggle({
    Name = "Auto Equip Armor",
    Default = false,
    Callback = function(Value)
        Config.AutoArmor.Enabled = Value
        
        if Value then
            StartAutoArmor()
            Window:Notify({
                Title = "Auto Armor Started",
                Description = "Auto armor enabled",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Auto Armor Stopped",
                Description = "Auto armor disabled",
                Duration = 3
            })
        end
    end
}, "AutoArmor")

local ParoleSection = FarmTab:Section({Side = "Left"})

ParoleSection:Header({Text = "Auto Farm Parole"})

local function GetRotationKey(rotation)
    return string.format("%.2f_%.2f_%.2f", rotation.X, rotation.Y, rotation.Z)
end

local function FindAvailableParole()
    local parolesFolder = game.Workspace.JOB.JOB.SCRIPT.Paroles
    
    for _, parole in pairs(parolesFolder:GetChildren()) do
        if parole.Name ~= "Paroles" or not parole:IsA("BasePart") then continue end
        
        local collection = parole:FindFirstChild("Collection")
        local rotationKey = GetRotationKey(parole.Rotation)
        
        if not collection and not Config.Farm.Parole.VisitedRotations[rotationKey] then
            return parole, rotationKey
        end
    end
    
    return nil, nil
end

local function CountVisitedRotations()
    local count = 0
    for _ in pairs(Config.Farm.Parole.VisitedRotations) do
        count = count + 1
    end
    return count
end

local function TeleportToParole(player, parole)
    local character = player.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    hrp.CFrame = parole.CFrame
    wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    
    return true
end

local function WaitForCollection(parole)
    local maxWait = 10
    local waited = 0
    
    while waited < maxWait do
        local collection = parole:FindFirstChild("Collection")
        if collection then
            collection.AncestryChanged:Wait()
            return true
        end
        wait(0.1)
        waited = waited + 0.1
    end
    
    return false
end

local function StartParoleFarm()
    local player = game.Players.LocalPlayer
    
    spawn(function()
        while Config.Farm.Parole.Enabled do
            if CountVisitedRotations() >= 6 then
                Config.Farm.Parole.VisitedRotations = {}
                wait(0.5)
            end
            
            local parole, rotationKey = FindAvailableParole()
            
            if parole then
                local success = TeleportToParole(player, parole)
                
                if success then
                    wait(0.2)
                    local collected = WaitForCollection(parole)
                    
                    if collected then
                        Config.Farm.Parole.VisitedRotations[rotationKey] = true
                    end
                    
                    wait(0.3)
                else
                    wait(1)
                end
            else
                Config.Farm.Parole.VisitedRotations = {}
                wait(0.5)
            end
        end
    end)
end

ParoleSection:Toggle({
    Name = "Auto Farm Parole",
    Default = false,
    Callback = function(Value)
        Config.Farm.Parole.Enabled = Value
        
        if Value then
            StartParoleFarm()
            Window:Notify({
                Title = "Farm Started",
                Description = "Auto farm enabled",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Farm Stopped",
                Description = "Auto farm disabled",
                Duration = 3
            })
        end
    end
}, "AutoFarm")

local GrapeSection = FarmTab:Section({Side = "Right"})

GrapeSection:Header({Text = "Auto Farm Grape"})

local function GetPositionKey(position)
    return string.format("%.2f_%.2f_%.2f", position.X, position.Y, position.Z)
end

local function CountVisitedGrapes()
    local count = 0
    for _ in pairs(Config.Farm.Grape.VisitedGrapes) do
        count = count + 1
    end
    return count
end

local function TeleportAndJump(cframe)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    hrp.CFrame = cframe
    wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    
    return true
end

local function FindAvailableGrape()
    local grapeFolder = game.Workspace.JOB.JOB.SCRIPT.Grape
    
    for _, grape in pairs(grapeFolder:GetChildren()) do
        if not grape:IsA("BasePart") then continue end
        
        local positionKey = GetPositionKey(grape.Position)
        
        if not Config.Farm.Grape.VisitedGrapes[positionKey] then
            return grape, positionKey
        end
    end
    
    return nil, nil
end

local function StartGrapeFarm()
    local player = game.Players.LocalPlayer
    
    spawn(function()
        while Config.Farm.Grape.Enabled do
            local args = {
                "post",
                "Grape",
                5,
                player:WaitForChild("Truck (150Kg)(Free)")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("data"):FireServer(unpack(args))
            wait(5)
        end
    end)
    
    spawn(function()
        while Config.Farm.Grape.Enabled do
            if CountVisitedGrapes() >= 10 then
                Config.Farm.Grape.VisitedGrapes = {}
                wait(0.5)
            end
            
            local grape, positionKey = FindAvailableGrape()
            
            if grape then
                local success = TeleportAndJump(grape.CFrame)
                
                if success then
                    Config.Farm.Grape.VisitedGrapes[positionKey] = true
                    wait(5)
                else
                    wait(1)
                end
            else
                Config.Farm.Grape.VisitedGrapes = {}
                wait(0.5)
            end
        end
    end)
end

GrapeSection:Toggle({
    Name = "Auto Farm Grape",
    Default = false,
    Callback = function(Value)
        Config.Farm.Grape.Enabled = Value
        
        if Value then
            StartGrapeFarm()
            Window:Notify({
                Title = "Grape Farm Started",
                Description = "Auto grape farm enabled",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Grape Farm Stopped",
                Description = "Auto grape farm disabled",
                Duration = 3
            })
        end
    end
}, "AutoGrapeFarm")

game.Players.PlayerAdded:Connect(function()
    wait(1)
    PlayerDropdown:ClearOptions()
    PlayerDropdown:InsertOptions(GetAllPlayers())
end)

game.Players.PlayerRemoving:Connect(function()
    wait(1)
    PlayerDropdown:ClearOptions()
    PlayerDropdown:InsertOptions(GetAllPlayers())
end)

MacLib:SetFolder("GodWeapon")
FarmTab:InsertConfigSection("Left")

MainTab:Select()
MacLib:LoadAutoLoadConfig()

Window:Notify({
    Title = "god weapon",
    Description = "Script loaded successfully!",
    Duration = 5
})
