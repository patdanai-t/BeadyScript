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
