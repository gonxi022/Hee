-- Steal A Fish Server Hopper para Android/KRNL - VERSIÓN COMPACTA Y FUNCIONAL
-- Escanea múltiples servidores, detecta peces raros y jugadores con dinero

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameId = game.PlaceId

-- Variables globales
local isScanning = false
local serverList = {}
local currentScanCount = 0
local maxServersToScan = 15

-- Peces raros conocidos en Steal A Fish
local rareFishKeywords = {
    "deep", "secret", "limited", "rare", "legendary", "mythic", "ancient", 
    "golden", "diamond", "crystal", "void", "shadow", "cosmic", "eternal",
    "prismatic", "celestial", "phantom", "exotic", "rainbow"
}

-- Crear GUI compacta
local function createGUI()
    local existingGui = PlayerGui:FindFirstChild("StealFishHopper")
    if existingGui then existingGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealFishHopper"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Marco principal (más pequeño)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(70, 100, 180)
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Título compacto
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 40)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 80, 140)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🐟 SERVER SCANNER"
    titleLabel.TextColor3 = Color3.white
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleLabel
    
    -- Botón escanear
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0, 150, 0, 35)
    scanButton.Position = UDim2.new(0, 10, 0, 55)
    scanButton.BackgroundColor3 = Color3.fromRGB(50, 170, 50)
    scanButton.BorderSizePixel = 1
    scanButton.BorderColor3 = Color3.fromRGB(30, 100, 30)
    scanButton.Text = "🔍 ESCANEAR"
    scanButton.TextColor3 = Color3.white
    scanButton.TextSize = 14
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.Parent = mainFrame
    
    -- Botón detener
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(0, 140, 0, 35)
    stopButton.Position = UDim2.new(0, 170, 0, 55)
    stopButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopButton.BorderSizePixel = 1
    stopButton.BorderColor3 = Color3.fromRGB(120, 40, 40)
    stopButton.Text = "⏹️ DETENER"
    stopButton.TextColor3 = Color3.white
    stopButton.TextSize = 14
    stopButton.Font = Enum.Font.SourceSansBold
    stopButton.Parent = mainFrame
    stopButton.Visible = false
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 5)
    scanCorner.Parent = scanButton
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 5)
    stopCorner.Parent = stopButton
    
    -- Lista de servidores
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ServerList"
    scrollFrame.Size = UDim2.new(0, 300, 0, 280)
    scrollFrame.Position = UDim2.new(0, 10, 0, 100)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 6)
    scrollCorner.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingAll = UDim.new(0, 5)
    listPadding.Parent = scrollFrame
    
    -- Estado compacto
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 300, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 390)
    statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    statusLabel.BorderSizePixel = 1
    statusLabel.Text = "Listo para escanear"
    statusLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 3)
    statusCorner.Parent = statusLabel
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.white
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeButton
    
    -- Drag
    local dragging = false
    local dragStart, startPos
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleLabel.InputChanged:Connect(function(input)
        if dragging and dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Eventos
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        if not isScanning then
            startServerScan(scanButton, stopButton, statusLabel, scrollFrame)
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        isScanning = false
        scanButton.Visible = true
        stopButton.Visible = false
        statusLabel.Text = "Escaneo detenido"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
    end)
    
    return screenGui, scrollFrame, statusLabel, scanButton, stopButton
end

-- Analizar servidor actual mejorado
local function analyzeServer()
    local data = {
        serverId = game.JobId,
        players = #Players:GetPlayers(),
        maxMoney = 0,
        totalFish = 0,
        rareFish = 0,
        topPlayer = "Ninguno",
        score = 0
    }
    
    -- Analizar jugadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerMoney = 0
            local playerRareFish = 0
            
            -- Dinero del jugador
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")
                if money and tonumber(money.Value) then
                    playerMoney = tonumber(money.Value)
                    if playerMoney > data.maxMoney then
                        data.maxMoney = playerMoney
                        data.topPlayer = player.DisplayName or player.Name
                    end
                end
            end
            
            -- Peces del jugador
            local locations = {player:FindFirstChild("Backpack")}
            if player.Character then
                table.insert(locations, player.Character)
            end
            
            for _, location in pairs(locations) do
                if location then
                    for _, item in pairs(location:GetChildren()) do
                        if item:IsA("Tool") then
                            data.totalFish = data.totalFish + 1
                            local itemName = string.lower(item.Name)
                            
                            -- Detectar peces raros
                            for _, keyword in pairs(rareFishKeywords) do
                                if string.find(itemName, keyword) then
                                    data.rareFish = data.rareFish + 1
                                    playerRareFish = playerRareFish + 1
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Calcular puntuación
    local moneyScore = math.floor(data.maxMoney / 1000)
    local fishScore = data.totalFish * 2
    local rareScore = data.rareFish * 20
    local playerScore = data.players * 3
    
    data.score = moneyScore + fishScore + rareScore + playerScore
    
    return data
end

-- Crear item de servidor en la lista
local function createServerItem(serverData, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(80, 80, 95)
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    -- Indicador de calidad
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 6, 1, 0)
    indicator.Position = UDim2.new(0, 0, 0, 0)
    indicator.BorderSizePixel = 0
    indicator.Parent = frame
    
    if serverData.score >= 100 then
        indicator.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Verde
    elseif serverData.score >= 50 then
        indicator.BackgroundColor3 = Color3.fromRGB(200, 150, 50) -- Amarillo
    else
        indicator.BackgroundColor3 = Color3.fromRGB(200, 80, 80) -- Rojo
    end
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator
    
    -- Información del servidor
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 180, 1, 0)
    infoLabel.Position = UDim2.new(0, 10, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format("⭐ Puntuación: %d\n👥 Jugadores: %d | 💰 Max: $%s\n🐟 Peces: %d | 🔥 Raros: %d", 
        serverData.score, serverData.players, 
        serverData.maxMoney >= 1000 and string.format("%.1fK", serverData.maxMoney/1000) or tostring(serverData.maxMoney),
        serverData.totalFish, serverData.rareFish)
    infoLabel.TextColor3 = Color3.white
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    infoLabel.Parent = frame
    
    -- Botón unirse
    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(0, 80, 0, 35)
    joinButton.Position = UDim2.new(1, -90, 0.5, -17)
    joinButton.BackgroundColor3 = Color3.fromRGB(30, 130, 200)
    joinButton.BorderSizePixel = 1
    joinButton.BorderColor3 = Color3.fromRGB(20, 90, 140)
    joinButton.Text = "UNIRSE"
    joinButton.TextColor3 = Color3.white
    joinButton.TextSize = 12
    joinButton.Font = Enum.Font.SourceSansBold
    joinButton.Parent = frame
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 4)
    joinCorner.Parent = joinButton
    
    -- Evento unirse
    joinButton.MouseButton1Click:Connect(function()
        joinButton.Text = "UNIENDO..."
        joinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        wait(0.3)
        
        if serverData.serverId and serverData.serverId ~= "" then
            local success = pcall(function()
                TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
            end)
            
            if not success then
                joinButton.Text = "ERROR"
                joinButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                wait(1.5)
                joinButton.Text = "UNIRSE"
                joinButton.BackgroundColor3 = Color3.fromRGB(30, 130, 200)
            end
        end
    end)
    
    return frame
end

-- Función principal de escaneo
function startServerScan(scanButton, stopButton, statusLabel, scrollFrame)
    if isScanning then return end
    
    isScanning = true
    currentScanCount = 0
    serverList = {}
    
    scanButton.Visible = false
    stopButton.Visible = true
    statusLabel.Text = "Iniciando escaneo..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Limpiar lista
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Función recursiva para escanear
    local function scanNextServer()
        if not isScanning or currentScanCount >= maxServersToScan then
            -- Finalizar escaneo
            isScanning = false
            scanButton.Visible = true
            stopButton.Visible = false
            statusLabel.Text = string.format("Completado: %d servidores encontrados", #serverList)
            statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            
            -- Ordenar y mostrar
            table.sort(serverList, function(a, b) return a.score > b.score end)
            
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for i, data in ipairs(serverList) do
                if i <= 12 then -- Máximo 12 servidores en lista
                    createServerItem(data, scrollFrame)
                end
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#serverList, 12) * 75)
            return
        end
        
        currentScanCount = currentScanCount + 1
        statusLabel.Text = string.format("Escaneando %d/%d...", currentScanCount, maxServersToScan)
        
        -- Analizar servidor actual
        wait(1)
        local currentData = analyzeServer()
        
        if currentData.score > 15 then -- Solo guardar servidores buenos
            table.insert(serverList, currentData)
            createServerItem(currentData, scrollFrame)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #serverList * 75)
        end
        
        wait(1) -- Pausa antes de saltar
        
        -- Saltar al siguiente servidor
        if isScanning then
            TeleportService:Teleport(gameId, LocalPlayer)
        end
    end
    
    -- Iniciar escaneo
    wait(1)
    scanNextServer()
end

-- Crear GUI y inicializar
wait(1)
createGUI()

print("✅ Steal A Fish Server Scanner cargado!")
print("📱 Interfaz compacta para Android/KRNL")
print("🎯 Busca servidores con peces raros y jugadores ricos")
print("🔍 ¡Presiona ESCANEAR para empezar!")

-- Notificación
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🐟 Server Scanner";
    Text = "¡Cargado! Busca servidores con peces raros.";
    Duration = 4;
})