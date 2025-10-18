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

local MainTab = Window:CreateTab("Main", 4483362458)

local SelectedPlayers = {}

local function GetAllPlayers()
   local playerNames = {}
   for _, player in pairs(game.Players:GetPlayers()) do
      table.insert(playerNames, player.Name)
   end
   return playerNames
end

local Section = MainTab:CreateSection("Select Players")

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

game.Players.PlayerAdded:Connect(function()
   wait(1)
   UpdateDropdown()
end)

game.Players.PlayerRemoving:Connect(function()
   wait(1)
   UpdateDropdown()
end)