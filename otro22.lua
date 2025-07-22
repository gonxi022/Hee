-- Esperar a que cargue
repeat wait() until game:IsLoaded()

-- Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Buscar el RemoteEvent dentro de ReplicatedStorage.X
local remoteFolder = ReplicatedStorage:WaitForChild("X")
local clickRemote = nil

-- Buscar primer RemoteEvent disponible en esa carpeta
for _, obj in ipairs(remoteFolder:GetChildren()) do
    if obj:IsA("RemoteEvent") then
        clickRemote = obj
        break
    end
end

-- Verificación por si no lo encuentra
if not clickRemote then
    warn("❌ No se encontró ningún RemoteEvent en ReplicatedStorage.X")
    return
end

-- Crear GUI flotante (Android compatible)
local gui = Instance.new("ScreenGui")
gui.Name = "TapClickMultiplier"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local tapBtn = Instance.new("TextButton")
tapBtn.Size = UDim2.new(0, 250, 0, 60)
tapBtn.Position = UDim2.new(0, 30, 0, 100)
tapBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
tapBtn.TextColor3 = Color3.new(1, 1, 1)
tapBtn.Font = Enum.Font.SourceSansBold
tapBtn.TextSize = 22
tapBtn.Text = "☝️ CLIC x INFINITO"
tapBtn.Parent = gui

-- Valor masivo para test
local INFINITE_CLICKS = 99999999999999999999999999

-- Activar cuando se toca el botón
tapBtn.MouseButton1Click:Connect(function()
    clickRemote:FireServer(INFINITE_CLICKS)
    print("💥 Clic enviado con valor:", INFINITE_CLICKS)
end)