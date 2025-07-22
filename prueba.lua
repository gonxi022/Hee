-- Esperar que el juego cargue
repeat wait() until game:IsLoaded()

-- Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Referencia al RemoteEvent
local clickEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Click")

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ClickBoostGui"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Crear botón flotante
local boostButton = Instance.new("TextButton")
boostButton.Size = UDim2.new(0, 200, 0, 60)
boostButton.Position = UDim2.new(0, 20, 0, 100)
boostButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
boostButton.TextColor3 = Color3.new(1, 1, 1)
boostButton.Font = Enum.Font.SourceSansBold
boostButton.TextSize = 20
boostButton.Text = "🔥 Activar x10 Clicks"
boostButton.Parent = gui

-- Multiplicador inicial (normal)
local clickMultiplier = 1

-- Escuchar el botón
boostButton.MouseButton1Click:Connect(function()
    if clickMultiplier == 1 then
        clickMultiplier = 10
        boostButton.Text = "✅ x10 Activo"
        boostButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        clickMultiplier = 1
        boostButton.Text = "🔥 Activar x10 Clicks"
        boostButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    end
end)

-- Simular el click real con multiplicador
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickEvent:FireServer(clickMultiplier)
    end
end)