
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Nombres de admins autorizados para ver y usar el botón
local admins = {
    ["gonchii002"] = true,
    ["AdminEjemplo"] = true,
}

if not admins[player.Name] then return end

-- Esperar o crear el RemoteEvent
local killAllEvent = ReplicatedStorage:FindFirstChild("KillAllEvent")
if not killAllEvent then
    killAllEvent = Instance.new("RemoteEvent")
    killAllEvent.Name = "KillAllEvent"
    killAllEvent.Parent = ReplicatedStorage
end

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminKillGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "KillAllButton"
button.Size = UDim2.new(0,150,0,50)
button.Position = UDim2.new(0,10,0,10)
button.BackgroundColor3 = Color3.new(1,0,0)
button.Text = "KILL ALL INSTANT"
button.TextColor3 = Color3.new(1,1,1)
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    killAllEvent:FireServer()
end)
