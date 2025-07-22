-- Multiplicador de clics por TAP para Android
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local clickRemote = workspace:WaitForChild("Events"):WaitForChild("AddClick")

-- Crear GUI flotante
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "TapClickMultiplier"
gui.ResetOnSpawn = false

local tapBtn = Instance.new("TextButton")
tapBtn.Size = UDim2.new(0, 250, 0, 60)
tapBtn.Position = UDim2.new(0, 30, 0, 100)
tapBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
tapBtn.TextColor3 = Color3.new(1, 1, 1)
tapBtn.Font = Enum.Font.SourceSansBold
tapBtn.TextSize = 22
tapBtn.Text = "☝️ CLIC x INFINITO"
tapBtn.Parent = gui

-- Valor enorme (¡ajustalo si querés!)
local INFINITE_CLICKS = 99999999999999999999999999999999

-- Cuando el botón se toca
tapBtn.MouseButton1Click:Connect(function()
    clickRemote:FireServer(INFINITE_CLICKS)
    print("💥 Clic con valor aumentado enviado:", INFINITE_CLICKS)
end)