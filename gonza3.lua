-- Prison Life - Kill All + God Mode FUNCIONAL PARA ANDROID
-- TP persona por persona + meleeEvent agresivo y rápido
-- God Mode inmortal + Botones arrastrables para móvil

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local godModeEnabled = false
local godConnection = nil
local killAllEnabled = false
local killAllConnection = nil
local currentTargetIndex = 1

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PrisonLifeHackGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true -- Importante en móviles
gui.Parent = PlayerGui

-- Función para hacer botones arrastrables (SOLO TOUCH o clic)
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- Botón Kill All
local killButton = Instance.new("TextButton")
killButton.Name = "KillAllButton"
killButton.Size = UDim2.new(0, 220, 0, 70)
killButton.Position = UDim2.new(0, 20, 0, 60)
killButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
killButton.BorderSizePixel = 0
killButton.Text = "🔫 Kill All: OFF"
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.TextScaled = true
killButton.Font = Enum.Font.GothamBold
killButton.Parent = gui

local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 12)
killCorner.Parent = killButton

-- Botón God Mode
local godButton = Instance.new("TextButton")
godButton.Name = "GodModeButton"
godButton.Size = UDim2.new(0, 220, 0, 70)
godButton.Position = UDim2.new(0, 20, 0, 150)
godButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
godButton.BorderSizePixel = 0
godButton.Text = "🛡️ God Mode: OFF"
godButton.TextColor3 = Color3.new(1, 1, 1)
godButton.TextScaled = true
godButton.Font = Enum.Font.GothamBold
godButton.Parent = gui

local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 12)
godCorner.Parent = godButton

-- Hacer botones móviles
makeDraggable(killButton)
makeDraggable(godButton)

-- Función para obtener jugadores enemigos
local function getTargets()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

-- Teletransporte rápido
local function teleportTo(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character
    if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 2)
        return true
    end
    return false
end

-- Kill All optimizado
local function toggleKillAll()
    if killAllEnabled then
        killAllEnabled = false
        killButton.Text = "🔫 Kill All: OFF"
        killButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        if killAllConnection then
            task.cancel(killAllConnection)
            killAllConnection = nil
        end
        return
    end

    killAllEnabled = true
    killButton.Text = "🔥 Kill All: ON"
    killButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

    local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
    if not meleeEvent then
        for _, name in ipairs({"RemoteEvent", "hitEvent", "damageEvent"}) do
            local alt = ReplicatedStorage:FindFirstChild(name)
            if alt then
                meleeEvent = alt
                break
            end
        end
    end

    if not meleeEvent then
        warn("⚠️ No se encontró ningún RemoteEvent de ataque.")
        return
    end

    killAllConnection = task.spawn(function()
        while killAllEnabled do
            local targets = getTargets()
            if #targets == 0 then task.wait(0.5) continue end

            if currentTargetIndex > #targets then currentTargetIndex = 1 end
            local target = targets[currentTargetIndex]

            if teleportTo(target) then
                for i = 1, 40 do
                    pcall(function() meleeEvent:FireServer(target) end)
                    task.wait(0.005)
                end
            end
            currentTargetIndex += 1
            task.wait(0.1)
        end
    end)
end

-- God Mode mejorado
local function toggleGodMode()
    if godModeEnabled then
        godModeEnabled = false
        godButton.Text = "🛡️ God Mode: OFF"
        godButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        if godConnection then
            godConnection:Disconnect()
            godConnection = nil
        end
        return
    end

    godModeEnabled = true
    godButton.Text = "✨ God Mode: ON"
    godButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)

    godConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            if char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Velocity = Vector3.zero
            end
        end
    end)
end

-- Auto-reaplicar hacks al reaparecer
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if godModeEnabled then toggleGodMode() toggleGodMode() end
    if killAllEnabled then toggleKillAll() toggleKillAll() end
end)

-- Conectar botones
killButton.MouseButton1Click:Connect(toggleKillAll)
godButton.MouseButton1Click:Connect(toggleGodMode)

print("✅ Hack Prison Life CARGADO para ANDROID")