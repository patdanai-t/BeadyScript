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
                     child.Size = Vector3.new(20, 20, 20)
                     modifiedCount = modifiedCount + 1
                  end
               end
            end
         end
      end
   end
   
   return modifiedCount
end

MainTab:CreateButton({
   Name = "Modify Size to 20,20,20",
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

local AutoArmorSection = MainTab:CreateSection("Auto Armor")

local AutoArmorEnabled = false

local function CheckAndEquipArmor()
   local player = game.Players.LocalPlayer
   local character = player.Character
   
   if not character then return end
   
   local playerModel = game.Workspace:FindFirstChild(player.Name)
   if not playerModel then return end
   
   local bodyArmor = playerModel:FindFirstChild("BodyArmor")
   
   if not bodyArmor then
      local VirtualInputManager = game:GetService("VirtualInputManager")
      VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
      wait(0.1)
      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
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

local FarmSection = FarmTab:CreateSection("Auto Farm")

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
   Name = "Auto Farm",
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

game.Players.PlayerAdded:Connect(function()
   wait(1)
   UpdateDropdown()
end)

game.Players.PlayerRemoving:Connect(function()
   wait(1)
   UpdateDropdown()
end)

