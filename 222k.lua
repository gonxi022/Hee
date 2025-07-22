-- Mod Menu - Kill All para Prison Life (Android KRNL)
-- Autor: ChatGPT - Optimizado para dispositivos móviles

-- Referencias
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

-- Evita duplicados
pcall(function() CoreGui.ModMenu:Destroy() end)

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ModMenu"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 60)
Frame.Position = UDim2.new(0, 10, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Text = "🔫 Kill All"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Button.TextScaled = true
Button.Font = Enum.Font.GothamBold
local btnCorner = Instance.new("UICorner", Button)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Función Kill All
local function KillAll()
    local gun = nil
    local events = {}

    -- Obtener jugadores
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            for i = 1, 10 do
                table.insert(events, {
                    Hit = v.Character.Head,
                    Distance = 0,
                    Cframe = CFrame.new(),
                    RayObject = Ray.new(Vector3.new(), Vector3.new())
                })
            end
        end
    end

    -- Obtener arma Remington
    local itemGiver = workspace:FindFirstChild("Prison_ITEMS") and workspace.Prison_ITEMS.giver:FindFirstChild("Remington 870")
    if itemGiver then
        workspace.Remote.ItemHandler:InvokeServer(itemGiver.ITEMPICKUP)
    end

    -- Buscar arma en mochila o personaje
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "Remington 870" then gun = v end
    end
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v.Name == "Remington 870" then gun = v end
    end
    if not gun then return end

    -- Disparar a todos
    game.ReplicatedStorage.ShootEvent:FireServer(events, gun)
end

-- Activar desde botón
Button.MouseButton1Click:Connect(function()
    KillAll()
end)