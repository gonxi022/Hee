--Mod menu y botones
local modMenu = Instance.new("ScreenGui")
local noClip = Instance.new("TextButton")
local Speed = Instance.new("TextButton")
local killAll

local noClipEnabled = false
local SpeedEnabled = false

--Propiedades

modMenu.Name = "modMenu"
modMenu.ResetOnSpawn = false
modMenu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

--Noclip
noClip.Name = "NoClip"
noClip.Size = UDim2.new(0, 150, 0, 50)
noClip.Position = UDim2.new(0, 120, 0, 120)
noClip.Text = "NoClipOff"
noClip.Parent = modMenu
noClip.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
noClip.TextColor3 = Color3.fromRGB(255, 255, 255)
noClip.Font = Enum.Font.SourceSans
noClip.TextSize = 20 

--Speed
Speed.Name = "Speed"
Speed.Size = UDim2.new(0, 150, 0, 50)
Speed.Position = UDim2.new(0, 120, 0, 180)
Speed.Text = "Speed"
Speed.Parent = modMenu
Speed.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Speed.TextColor3 = Color3.fromRGB(255, 255, 255)
Speed.Font = Enum.Font.SourceSans
Speed.TextSize = 20 

--KillAll
local killAll = Instance.new("TextButton")
killAll.Name = "KillAll"
killAll.Size = UDim2.new(0, 150, 0, 50)
killAll.Position = UDim2.new(0, 120, 0, 240)
killAll.Text = "Kill All"
killAll.Parent = modMenu
killAll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
killAll.TextColor3 = Color3.fromRGB(255, 255, 255)
killAll.Font = Enum.Font.SourceSans
killAll.TextSize = 20

--Funciones

--Noclip
noClip.MouseButton1Click:Connect(function()
  noClipEnabled = not noClipEnabled
  noClip.Text = noClipEnabled and
  "NoClipOn" or "NoClipOff"
end)

local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

RunService.Stepped:Connect(function()
  if player.Character then
    for _, part in 
    pairs(player.Character:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide = not noClipEnabled
      end
    end
  end
end)

--Speed
Speed.MouseButton1Click:Connect(function()
  SpeedEnabled = not SpeedEnabled
  Speed.Text = SpeedEnabled and 
  "SpeedOn" or "SpeedOff"
  local character = player.Character 
  if character then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then 
      if SpeedEnabled then
        humanoid.WalkSpeed = 50
      else
          humanoid.WalkSpeed = 16
      end
    end
  end
end)

--KillAll
--Función para eliminar a todos los jugadores
local function killAllPlayers()
  for _, player in pairs(game.Players:GetPlayers()) do
    player.Character:Destroy()
  end
end

killAll.MouseButton1Click:Connect(killAllPlayers)