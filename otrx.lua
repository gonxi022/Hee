-- Esperar a que el juego cargue completamente
repeat wait() until game:IsLoaded()

-- Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Buscar carpeta 'X' en ReplicatedStorage
local remoteFolder = ReplicatedStorage:WaitForChild("X")
local clickRemote = nil

-- Buscar el primer RemoteEvent en esa carpeta
for _, obj in ipairs(remoteFolder:GetChildren()) do
    if obj:IsA("RemoteEvent") then
        clickRemote = obj
        break
    end
end

-- Verificar que se encontró el RemoteEvent
if not clickRemote then
    warn("❌ No se encontró ningún RemoteEvent en ReplicatedStorage.X")
    return
end

-- Crear GUI flotante
local gui = Instance.new("ScreenGui")
gui.Name = "TapClickMultiplier"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

-- Crear botón flotante
local tapBtn = Instance.new("TextButton")
tapBtn.Size = UDim2.new(0, 250, 0, 60)
tapBtn.Position = UDim2.new(0, 30, 0, 100)
tapBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
tapBtn.TextColor3 = Color3.new(1, 1, 1)
tapBtn.Font = Enum.Font.SourceSansBold
tapBtn.TextSize = 22
tapBtn.Text = "☝️ CLIC x INFINITO"
tapBtn.Parent = gui

-- Valor de clic simulado (enorme)
local INFINITE_CLICKS = 999999999999999999

-- Al tocar el botón, enviar ese valor como si fuera un clic
tapBtn.MouseButton1Click:Connect(function()
    local args = {Clicks = INFINITE_CLICKS}  -- Cambiá "Clicks" si tu Remote usa otro nombre
    clickRemote:FireServer(args)
    print("💥 Clic masivo enviado:", args.Clicks)
end)

print("✅ Script cargado: tocá el botón para recibir clics infinitos.")