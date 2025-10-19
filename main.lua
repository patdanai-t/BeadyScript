local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local Window = Rayfield:CreateWindow({
   Name = "god weapon",
   LoadingTitle = "Torch ดิว่ะ",
   LoadingSubtitle = "by TheTorch",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "PlayerModConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Key System",
      Subtitle = "Enter Key",
      Note = "ไม่ให้ใช้",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"TheTorch"}
   }
})

local MainTab = Window:CreateTab("PVP", 4483362458)

local SelectedPlayers = {}

local function GetAllPlayers()
   local playerNames = {}
   for _, player in pairs(game.Players:GetPlayers()) do
      table.insert(playerNames, player.Name)
   end
   return playerNames
end

local Section = MainTab:CreateSection("Gun")

local PlayerDropdown
local function UpdateDropdown()
   local playerList = GetAllPlayers()
   if PlayerDropdown then
      PlayerDropdown:Refresh(playerList)
   end
end

PlayerDropdown = MainTab:CreateDropdown({
   Name = "Select Players",
   Options = GetAllPlayers(),
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "PlayerDropdown",
   Callback = function(Options)
      SelectedPlayers = Options
   end,
})

MainTab:CreateButton({
   Name = "Refresh Players",
   Callback = function()
      UpdateDropdown()
      Rayfield:Notify({
         Title = "Success",
         Content = "Player list updated",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local HighlightEnabled = true
local HighlightColor = Color3.fromRGB(0, 255, 255)
local HighlightTransparency = 0.7
local TargetSize = Vector3.new(20, 20, 20)

local function UpdateAllHighlights()
   for _, playerName in pairs(SelectedPlayers) do
      local playerModel = game.Workspace:FindFirstChild(playerName)
      
      if playerModel then
         local head2 = playerModel:FindFirstChild("Head2")
         
         if head2 then
            for _, child in pairs(head2:GetChildren()) do
               if string.match(child.Name, "^TARGET_") and child:IsA("BasePart") then
                  local highlight = child:FindFirstChildOfClass("Highlight")
                  local selectionBox = child:FindFirstChildOfClass("SelectionBox")
                  
                  if highlight then
                     highlight.Enabled = HighlightEnabled
                     highlight.OutlineColor = HighlightColor
                  end
                  
                  if selectionBox then
                     selectionBox.Visible = HighlightEnabled
                     selectionBox.Color3 = HighlightColor
                  end
                  
                  if HighlightEnabled then
                     child.Transparency = HighlightTransparency
                  end
               end
            end
         end
      end
   end
end

local function ModifyTargetSize()
   local modifiedCount = 0
   
   for _, playerName in pairs(SelectedPlayers) do
      local playerModel = game.Workspace:FindFirstChild(playerName)
      
      if playerModel then
         local head2 = playerModel:FindFirstChild("Head2")
         
         if head2 then
            for _, child in pairs(head2:GetChildren()) do
               if string.match(child.Name, "^TARGET_") then
                  if child:IsA("BasePart") then
                     child.Size = TargetSize
                     child.Transparency = HighlightTransparency
                     
                     local highlight = child:FindFirstChildOfClass("Highlight")
                     if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Parent = child
                     end
                     highlight.FillColor = HighlightColor
                     highlight.OutlineColor = HighlightColor
                     highlight.FillTransparency = 1
                     highlight.OutlineTransparency = 0
                     highlight.Enabled = HighlightEnabled
                     
                     local selectionBox = child:FindFirstChildOfClass("SelectionBox")
                     if not selectionBox then
                        selectionBox = Instance.new("SelectionBox")
                        selectionBox.Parent = child
                        selectionBox.Adornee = child
                     end
                     selectionBox.Color3 = HighlightColor
                     selectionBox.LineThickness = 0.05
                     selectionBox.Transparency = 0
                     selectionBox.Visible = HighlightEnabled
                     
                     modifiedCount = modifiedCount + 1
                  end
               end
            end
         end
      end
   end
   
   return modifiedCount
end

MainTab:CreateInput({
   Name = "Target Size (X,Y,Z)",
   PlaceholderText = "20,20,20",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local values = {}
      for value in string.gmatch(Text, "[^,]+") do
         local num = tonumber(value)
         if num then
            table.insert(values, num)
         end
      end
      
      if #values == 3 then
         TargetSize = Vector3.new(values[1], values[2], values[3])
         Rayfield:Notify({
            Title = "Size Updated",
            Content = string.format("Set to %.1f,%.1f,%.1f", values[1], values[2], values[3]),
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Please enter format: X,Y,Z",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

MainTab:CreateButton({
   Name = "Apply Target Size",
   Callback = function()
      if #SelectedPlayers == 0 then
         Rayfield:Notify({
            Title = "Error",
            Content = "Please select at least 1 player",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end
      
      local count = ModifyTargetSize()
      
      Rayfield:Notify({
         Title = "Success",
         Content = "Modified " .. count .. " targets",
         Duration = 5,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateButton({
   Name = "Reset Target Size to 0,0,0",
   Callback = function()
      if #SelectedPlayers == 0 then
         Rayfield:Notify({
            Title = "Error",
            Content = "Please select at least 1 player",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end
      
      TargetSize = Vector3.new(0, 0, 0)
      local count = ModifyTargetSize()
      
      Rayfield:Notify({
         Title = "Success",
         Content = "Reset " .. count .. " targets to 0,0,0",
         Duration = 5,
         Image = 4483362458,
      })
   end,
})

local HighlightSection = MainTab:CreateSection("Highlight Settings")

MainTab:CreateToggle({
   Name = "Enable Highlight",
   CurrentValue = true,
   Flag = "HighlightToggle",
   Callback = function(Value)
      HighlightEnabled = Value
      UpdateAllHighlights()
   end,
})

MainTab:CreateSlider({
   Name = "Transparency",
   Range = {0, 1},
   Increment = 0.1,
   CurrentValue = 0.7,
   Flag = "HighlightTransparency",
   Callback = function(Value)
      HighlightTransparency = Value
      UpdateAllHighlights()
   end,
})

MainTab:CreateColorPicker({
   Name = "Highlight Color",
   Color = Color3.fromRGB(0, 255, 255),
   Flag = "HighlightColor",
   Callback = function(Value)
      HighlightColor = Value
      UpdateAllHighlights()
   end,
})

local AutoMedSection = MainTab:CreateSection("Auto Med")

local AutoMedEnabled = false
local MedToggleKey = Enum.KeyCode.F
local MedKeyName = "F"

MainTab:CreateInput({
   Name = "Toggle Key",
   PlaceholderText = "F",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local keyText = Text:upper()
      local success, keyCode = pcall(function()
         return Enum.KeyCode[keyText]
      end)
      
      if success and keyCode then
         MedToggleKey = keyCode
         MedKeyName = keyText
         Rayfield:Notify({
            Title = "Key Updated",
            Content = "Toggle key set to " .. keyText,
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Invalid key name",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local function StartAutoMed()
   spawn(function()
      while AutoMedEnabled do
         local args = {
            "Medkit",
            "",
            ""
         }
         game.Lighting:WaitForChild("Sky"):WaitForChild("Optimized"):FireServer(unpack(args))
         wait(5)
      end
   end)
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   
   if input.KeyCode == MedToggleKey then
      AutoMedEnabled = not AutoMedEnabled
      
      if AutoMedEnabled then
         StartAutoMed()
         Rayfield:Notify({
            Title = "Auto Med Started",
            Content = "Press " .. MedKeyName .. " to stop",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Auto Med Stopped",
            Content = "Press " .. MedKeyName .. " to start",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end
end)

MainTab:CreateLabel("Current Toggle Key: F")

local AutoArmorSection = MainTab:CreateSection("Auto Armor")

local AutoArmorEnabled = false
local ArmorKeyNumber = 1

MainTab:CreateInput({
   Name = "Armor Key Number (1-8)",
   PlaceholderText = "1",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local number = tonumber(Text)
      if number and number >= 1 and number <= 8 then
         ArmorKeyNumber = math.floor(number)
         Rayfield:Notify({
            Title = "Armor Key Updated",
            Content = "Set to key " .. ArmorKeyNumber,
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Please enter number 1-8",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local function CheckAndEquipArmor()
   local player = game.Players.LocalPlayer
   local character = player.Character
   
   if not character then return end
   
   local playerModel = game.Workspace:FindFirstChild(player.Name)
   if not playerModel then return end
   
   local bodyArmor = playerModel:FindFirstChild("BodyArmor")
   
   if not bodyArmor then
      local VirtualInputManager = game:GetService("VirtualInputManager")
      local keyCode = Enum.KeyCode["One"]
      
      if ArmorKeyNumber == 2 then keyCode = Enum.KeyCode.Two
      elseif ArmorKeyNumber == 3 then keyCode = Enum.KeyCode.Three
      elseif ArmorKeyNumber == 4 then keyCode = Enum.KeyCode.Four
      elseif ArmorKeyNumber == 5 then keyCode = Enum.KeyCode.Five
      elseif ArmorKeyNumber == 6 then keyCode = Enum.KeyCode.Six
      elseif ArmorKeyNumber == 7 then keyCode = Enum.KeyCode.Seven
      elseif ArmorKeyNumber == 8 then keyCode = Enum.KeyCode.Eight
      end
      
      VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
      wait(0.1)
      VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
   end
end

local function StartAutoArmor()
   spawn(function()
      while AutoArmorEnabled do
         CheckAndEquipArmor()
         wait(1)
      end
   end)
end

MainTab:CreateToggle({
   Name = "Auto Equip Armor",
   CurrentValue = false,
   Flag = "AutoArmor",
   Callback = function(Value)
      AutoArmorEnabled = Value
      
      if Value then
         StartAutoArmor()
         
         Rayfield:Notify({
            Title = "Auto Armor Started",
            Content = "Auto armor enabled",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Auto Armor Stopped",
            Content = "Auto armor disabled",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local FarmTab = Window:CreateTab("Farm", 4483362458)

local FarmSection = FarmTab:CreateSection("Auto Farm Parole")

local FarmEnabled = false

local VisitedRotations = {}

local function GetRotationKey(rotation)
   return string.format("%.2f_%.2f_%.2f", rotation.X, rotation.Y, rotation.Z)
end

local function FindAvailableParole()
   local parolesFolder = game.Workspace.JOB.JOB.SCRIPT.Paroles
   
   for _, parole in pairs(parolesFolder:GetChildren()) do
      if parole.Name == "Paroles" and parole:IsA("BasePart") then
         local collection = parole:FindFirstChild("Collection")
         local rotationKey = GetRotationKey(parole.Rotation)
         
         if not collection and not VisitedRotations[rotationKey] then
            return parole, rotationKey
         end
      end
   end
   
   return nil, nil
end

local function CountVisitedRotations()
   local count = 0
   for _ in pairs(VisitedRotations) do
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

local function StartFarm()
   local player = game.Players.LocalPlayer
   
   spawn(function()
      while FarmEnabled do
         if CountVisitedRotations() >= 6 then
            VisitedRotations = {}
            wait(0.5)
         end
         
         local parole, rotationKey = FindAvailableParole()
         
         if parole then
            local success = TeleportToParole(player, parole)
            
            if success then
               wait(0.2)
               local collected = WaitForCollection(parole)
               
               if collected then
                  VisitedRotations[rotationKey] = true
               end
               
               wait(0.3)
            else
               wait(1)
            end
         else
            VisitedRotations = {}
            wait(0.5)
         end
      end
   end)
end

FarmTab:CreateToggle({
   Name = "Auto Farm Parole",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
      FarmEnabled = Value
      
      if Value then
         StartFarm()
         
         Rayfield:Notify({
            Title = "Farm Started",
            Content = "Auto farm enabled",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Farm Stopped",
            Content = "Auto farm disabled",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local GrapeSection = FarmTab:CreateSection("Auto Farm Grape")

local GrapeFarmEnabled = false
local VisitedGrapes = {}

local function GetPositionKey(position)
   return string.format("%.2f_%.2f_%.2f", position.X, position.Y, position.Z)
end

local function CountVisitedGrapes()
   local count = 0
   for _ in pairs(VisitedGrapes) do
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
      if grape:IsA("BasePart") then
         local positionKey = GetPositionKey(grape.Position)
         
         if not VisitedGrapes[positionKey] then
            return grape, positionKey
         end
      end
   end
   
   return nil, nil
end

local function StartGrapeFarm()
   local player = game.Players.LocalPlayer
   
   spawn(function()
      while GrapeFarmEnabled do
         if CountVisitedGrapes() >= 10 then
            VisitedGrapes = {}
            wait(0.5)
         end
         
         local grape, positionKey = FindAvailableGrape()
         
         if grape then
            local success = TeleportAndJump(grape.CFrame)
            
            if success then
               wait(3)
               
               local character = player.Character
               if character then
                  local humanoid = character:FindFirstChild("Humanoid")
                  if humanoid then
                     humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                  end
               end
               
               wait(5)
               
               local args = {
                  "post",
                  "Grape",
                  1,
                  game:GetService("Players").LocalPlayer:WaitForChild("Truck (150Kg)(Free)")
               }
               game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("data"):FireServer(unpack(args))
               
               VisitedGrapes[positionKey] = true
               wait(0.5)
            else
               wait(1)
            end
         else
            VisitedGrapes = {}
            wait(0.5)
         end
      end
   end)
end

FarmTab:CreateToggle({
   Name = "Auto Farm Grape",
   CurrentValue = false,
   Flag = "AutoGrapeFarm",
   Callback = function(Value)
      GrapeFarmEnabled = Value
      
      if Value then
         StartGrapeFarm()
         
         Rayfield:Notify({
            Title = "Grape Farm Started",
            Content = "Auto grape farm enabled",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Grape Farm Stopped",
            Content = "Auto grape farm disabled",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

game.Players.PlayerAdded:Connect(function()
   wait(1)
   UpdateDropdown()
end)

game.Players.PlayerRemoving:Connect(function()
   wait(1)
   UpdateDropdown()
end)
