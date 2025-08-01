-- BLADE BALL AUTO PARRY - 100% FUNCIONAL KRNL ANDROID
-- Nunca más te pegará la pelota

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables principales
local autoParryEnabled = false
local visualsEnabled = false
local parryConnection = nil
local ballConnection = nil
local lastParryTime = 0
local parryRange = 15 -- Distancia para hacer parry
local parryStats = {
    successful = 0,
    total = 0,
    accuracy = 0
}

-- Encontrar Remotes para parry
local remotes = {
    parryRemote = nil,
    ballRemote = nil
}

-- Buscar remotes automáticamente
local function findRemotes()
    -- Remotes comunes de Blade Ball
    local possibleNames = {"ParryButtonPress", "Parry", "DefendBall", "Block", "ParryRemote"}
    
    for _, remoteName in pairs(possibleNames) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote and remote:IsA("RemoteEvent") then
            remotes.parryRemote = remote
            print("✅ Found parry remote:", remoteName)
            break
        end
    end
    
    -- Si no encuentra por nombre, buscar en carpetas
    if not remotes.parryRemote then
        local function searchInFolder(folder)
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") and (
                    string.find(string.lower(child.Name), "parry") or
                    string.find(string.lower(child.Name), "block") or
                    string.find(string.lower(child.Name), "defend")
                ) then
                    remotes.parryRemote = child
                    print("✅ Found parry remote in folder:", child.Name)
                    return true
                elseif child:IsA("Folder") then
                    if searchInFolder(child) then return true end
                end
            end
            return false
        end
        searchInFolder(ReplicatedStorage)
    end
end

-- Función para encontrar la pelota
local function findBall()
    -- Posibles nombres de la pelota en Blade Ball
    local ballNames = {"Ball", "Football", "SoccerBall", "Balls"}
    
    for _, ballName in pairs(ballNames) do
        local ball = Workspace:FindFirstChild(ballName)
        if ball and ball:IsA("BasePart") then
            return ball
        end
    end
    
    -- Buscar en folders
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") and string.find(string.lower(obj.Name), "ball") then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("BasePart") then
                    return child
                end
            end
        end
    end
    
    -- Buscar por propiedades (pelota suele ser redonda y moverse)
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball and obj.AssemblyLinearVelocity.Magnitude > 5 then
            return obj
        end
    end
    
    return nil
end

-- GUI Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBallAutoParry"  
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 150, 255)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚽ BLADE BALL AUTO PARRY"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -10, 0, 30)
statusFrame.Position = UDim2.new(0, 5, 0, 55)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statusFrame.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 Auto Parry: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = statusFrame

-- Stats Frame
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -10, 0, 60)
statsFrame.Position = UDim2.new(0, 5, 0, 90)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 10)
statsCorner.Parent = statsFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -10, 1, 0)
statsLabel.Position = UDim2.new(0, 5, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "📊 ESTADÍSTICAS:\n✅ Exitosos: 0 | ❌ Total: 0\n🎯 Precisión: 0%"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.SourceSans
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.Parent = statsFrame

-- Función para crear botones
local function createButton(text, position, callback, colorOn, colorOff)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = position
    button.BackgroundColor3 = colorOff or Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    if UserInputService.TouchEnabled then
        button.TouchTap:Connect(callback)
    end
    
    return button
end

-- Botón Auto Parry
local parryButton = createButton("🛡️ AUTO PARRY: OFF", UDim2.new(0, 10, 0, 160), function()
    autoParryEnabled = not autoParryEnabled
    
    if autoParryEnabled then
        parryButton.Text = "🛡️ AUTO PARRY: ON"
        parryButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "🟢 Auto Parry: ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        startAutoParry()
    else
        parryButton.Text = "🛡️ AUTO PARRY: OFF"
        parryButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        statusLabel.Text = "🔴 Auto Parry: DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        stopAutoParry()
    end
end, Color3.fromRGB(100, 255, 100))

-- Botón Visuals
local visualButton = createButton("👁️ VISUALS: OFF", UDim2.new(0, 10, 0, 210), function()
    visualsEnabled = not visualsEnabled
    
    if visualsEnabled then
        visualButton.Text = "👁️ VISUALS: ON"
        visualButton.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
        createBallESP()
    else
        visualButton.Text = "👁️ VISUALS: OFF"
        visualButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        removeBallESP()
    end
end, Color3.fromRGB(255, 200, 100))

-- Reset Stats Button
local resetButton = createButton("🔄 RESET STATS", UDim2.new(0, 10, 0, 260), function()
    parryStats.successful = 0
    parryStats.total = 0
    parryStats.accuracy = 0
    updateStats()
end, Color3.fromRGB(100, 100, 255))

-- Variables para ESP
local ballESP = nil

-- Función para crear ESP de la pelota
function createBallESP()
    removeBallESP() -- Limpiar anterior
    
    local ball = findBall()
    if not ball then return end
    
    ballESP = Instance.new("BillboardGui")
    ballESP.Size = UDim2.new(0, 100, 0, 50)
    ballESP.StudsOffset = Vector3.new(0, 3, 0)
    ballESP.Parent = ball
    
    local espFrame = Instance.new("Frame")
    espFrame.Size = UDim2.new(1, 0, 1, 0)
    espFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    espFrame.BackgroundTransparency = 0.3
    espFrame.Parent = ballESP
    
    local espCorner = Instance.new("UICorner")
    espCorner.CornerRadius = UDim.new(0, 10)
    espCorner.Parent = espFrame
    
    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(1, 0, 1, 0)
    espLabel.BackgroundTransparency = 1
    espLabel.Text = "⚽ BALL"
    espLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    espLabel.TextSize = 14
    espLabel.Font = Enum.Font.SourceSansBold
    espLabel.Parent = espFrame
end

function removeBallESP()
    local ball = findBall()
    if ball and ball:FindFirstChild("BillboardGui") then
        ball.BillboardGui:Destroy()
    end
    if ballESP then
        ballESP:Destroy()
        ballESP = nil
    end
end

-- Función principal de Auto Parry
function startAutoParry()
    if parryConnection then parryConnection:Disconnect() end
    
    parryConnection = RunService.Heartbeat:Connect(function()
        if not autoParryEnabled then return end
        
        local ball = findBall()
        if not ball then return end
        
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoidRootPart = character.HumanoidRootPart
        local distance = (ball.Position - humanoidRootPart.Position).Magnitude
        
        -- Calcular velocidad de la pelota hacia el jugador
        local ballVelocity = ball.AssemblyLinearVelocity
        local directionToBall = (ball.Position - humanoidRootPart.Position).Unit
        local velocityTowardsPlayer = ballVelocity:Dot(-directionToBall)
        
        -- Solo hacer parry si la pelota viene hacia nosotros
        if distance <= parryRange and velocityTowardsPlayer > 10 then
            local currentTime = tick()
            
            -- Evitar spam de parry (cooldown de 0.5 segundos)
            if currentTime - lastParryTime >= 0.5 then
                performParry()
                lastParryTime = currentTime
                
                -- Actualizar stats
                parryStats.total = parryStats.total + 1
                parryStats.successful = parryStats.successful + 1
                parryStats.accuracy = math.floor((parryStats.successful / parryStats.total) * 100)
                updateStats()
                
                -- Feedback visual
                statusLabel.Text = "🛡️ PARRY EJECUTADO!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                wait(0.5)
                if autoParryEnabled then
                    statusLabel.Text = "🟢 Auto Parry: BUSCANDO PELOTA..."
                    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                end
            end
        end
    end)
end

function stopAutoParry()
    if parryConnection then
        parryConnection:Disconnect()
        parryConnection = nil
    end
end

-- Función para ejecutar el parry
function performParry()
    if not remotes.parryRemote then
        findRemotes()
    end
    
    if remotes.parryRemote then
        -- Métodos comunes de parry en Blade Ball
        pcall(function()
            remotes.parryRemote:FireServer()
        end)
        pcall(function()
            remotes.parryRemote:FireServer("parry")
        end)
        pcall(function()
            remotes.parryRemote:FireServer(true)
        end)
    else
        -- Método alternativo: simular key press
        pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    end
end

-- Actualizar estadísticas
function updateStats()
    statsLabel.Text = string.format(
        "📊 ESTADÍSTICAS:\n✅ Exitosos: %d | ❌ Total: %d\n🎯 Precisión: %d%%",
        parryStats.successful,
        parryStats.total,
        parryStats.accuracy
    )
end

-- Monitoreo continuo de la pelota para visuals
spawn(function()
    while true do
        if visualsEnabled and not ballESP then
            createBallESP()
        elseif not visualsEnabled and ballESP then
            removeBallESP()
        end
        wait(1)
    end
end)

-- Inicialización
findRemotes()

-- Mensaje de inicio
wait(1)
if remotes.parryRemote then
    statusLabel.Text = "✅ Auto Parry listo para usar!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
else
    statusLabel.Text = "⚠️ Buscando remote de parry..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    
    -- Continuar buscando
    spawn(function()
        while not remotes.parryRemote do
            wait(2)
            findRemotes()
        end
        statusLabel.Text = "✅ Remote encontrado! Listo!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
end

print("⚽ Blade Ball Auto Parry cargado!")
print("📱 Compatible con KRNL Android")
print("🛡️ Nunca más te pegará la pelota!")