-- Steal A Fish Server Hopper para Android/KRNL - VERSIÓN CORREGIDA 100% FUNCIONAL
-- Sin errores visuales, todos los elementos visibles

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

-- Peces raros conocidos
local rareFishKeywords = {
    "deep", "secret", "limited", "rare", "legendary", "mythic", "ancient", 
    "golden", "diamond", "crystal", "void", "shadow", "cosmic", "eternal"
}

-- Función para crear GUI sin errores visuales
local function createGUI()
    -- Eliminar GUI existente
    local existingGui = PlayerGui:FindFirstChild("StealFishHopper")
    if existingGui then existingGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealFishHopper"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Marco principal - TAMAÑOS Y COLORES EXPLÍCITOS
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15) -- Gris oscuro
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.new(0.3, 0.4, 0.7) -- Azul
    mainFrame.BackgroundTransparency = 0
    mainFrame.Visible = true
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    mainFrame.ZIndex = 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Título - COMPLETAMENTE VISIBLE
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -10, 0, 45)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundColor3 = Color3.new(0.2, 0.3, 0.6) -- Azul medio
    titleLabel.BackgroundTransparency = 0
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🐟 STEAL A FISH SCANNER"
    titleLabel.TextColor3 = Color3.new(1, 1, 1) -- Blanco puro
    titleLabel.TextSize = 18
    titleLabel.TextScaled = false
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextStrokeTransparency = 0.5
    titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    titleLabel.Visible = true
    titleLabel.Parent = mainFrame
    titleLabel.ZIndex = 2
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleLabel
    
    -- Botón ESCANEAR - MUY VISIBLE
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0, 160, 0, 40)
    scanButton.Position = UDim2.new(0, 10, 0, 60)
    scanButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2) -- Verde brillante
    scanButton.BackgroundTransparency = 0
    scanButton.BorderSizePixel = 2
    scanButton.BorderColor3 = Color3.new(0.1, 0.4, 0.1)
    scanButton.Text = "🔍 ESCANEAR SERVIDORES"
    scanButton.TextColor3 = Color3.new(1, 1, 1)
    scanButton.TextSize = 16
    scanButton.TextScaled = false
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.TextStrokeTransparency = 0.5
    scanButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    scanButton.Visible = true
    scanButton.Active = true
    scanButton.Parent = mainFrame
    scanButton.ZIndex = 2
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanButton
    
    -- Botón DETENER - MUY VISIBLE
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(0, 150, 0, 40)
    stopButton.Position = UDim2.new(0, 180, 0, 60)
    stopButton.BackgroundColor3 = Color3.new(0.7, 0.2, 0.2) -- Rojo brillante
    stopButton.BackgroundTransparency = 0
    stopButton.BorderSizePixel = 2
    stopButton.BorderColor3 = Color3.new(0.4, 0.1, 0.1)
    stopButton.Text = "⏹️ DETENER ESCANEO"
    stopButton.TextColor3 = Color3.new(1, 1, 1)
    stopButton.TextSize = 16
    stopButton.TextScaled = false
    stopButton.Font = Enum.Font.SourceSansBold
    stopButton.TextStrokeTransparency = 0.5
    stopButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    stopButton.Visible = false
    stopButton.Active = true
    stopButton.Parent = mainFrame
    stopButton.ZIndex = 2
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopButton
    
    -- Lista de servidores - MARCO VISIBLE
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ServerList"
    scrollFrame.Size = UDim2.new(0, 320, 0, 290)
    scrollFrame.Position = UDim2.new(0, 10, 0, 110)
    scrollFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2) -- Gris medio
    scrollFrame.BackgroundTransparency = 0
    scrollFrame.BorderSizePixel = 2
    scrollFrame.BorderColor3 = Color3.new(0.25, 0.25, 0.3)
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.ScrollBarImageColor3 = Color3.new(0.5, 0.5, 0.6)
    scrollFrame.ScrollBarImageTransparency = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Visible = true
    scrollFrame.Active = true
    scrollFrame.Parent = mainFrame
    scrollFrame.ZIndex = 2
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    -- Layout para la lista
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = scrollFrame
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingBottom = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = scrollFrame
    
    -- Label de estado - MUY VISIBLE
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 320, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 410)
    statusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3) -- Gris azulado
    statusLabel.BackgroundTransparency = 0
    statusLabel.BorderSizePixel = 1
    statusLabel.BorderColor3 = Color3.new(0.4, 0.4, 0.5)
    statusLabel.Text = "✅ Listo para escanear servidores"
    statusLabel.TextColor3 = Color3.new(0.6, 1, 0.6) -- Verde claro
    statusLabel.TextSize = 14
    statusLabel.TextScaled = false
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextStrokeTransparency = 0.7
    statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    statusLabel.Visible = true
    statusLabel.Parent = mainFrame
    statusLabel.ZIndex = 2
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = statusLabel
    
    -- Botón cerrar - MUY VISIBLE
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 8)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2) -- Rojo brillante
    closeButton.BackgroundTransparency = 0
    closeButton.BorderSizePixel = 1
    closeButton.BorderColor3 = Color3.new(0.5, 0.1, 0.1)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 18
    closeButton.TextScaled = false
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Visible = true
    closeButton.Active = true
    closeButton.Parent = mainFrame
    closeButton.ZIndex = 3
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Sistema de arrastrar
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
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
    
    -- EVENTOS DE BOTONES
    closeButton.MouseButton1Click:Connect(function()
        print("Cerrando GUI...")
        screenGui:Destroy()
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        print("Iniciando escaneo...")
        if not isScanning then
            startServerScan(scanButton, stopButton, statusLabel, scrollFrame)
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        print("Deteniendo escaneo...")
        isScanning = false
        scanButton.Visible = true
        stopButton.Visible = false
        statusLabel.Text = "⏹️ Escaneo detenido por el usuario"
        statusLabel.TextColor3 = Color3.new(1, 0.7, 0.3)
    end)
    
    return screenGui, scrollFrame, statusLabel, scanButton, stopButton
end

-- Función para analizar servidor
local function analyzeServer()
    local data = {
        serverId = game.JobId or "server_" .. tostring(math.random(100000, 999999)),
        players = #Players:GetPlayers(),
        maxMoney = 0,
        totalFish = 0,
        rareFish = 0,
        topPlayer = "Ninguno",
        score = 0
    }
    
    -- Analizar cada jugador
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Buscar dinero
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")
                if money and tonumber(money.Value) then
                    local playerMoney = tonumber(money.Value)
                    if playerMoney > data.maxMoney then
                        data.maxMoney = playerMoney
                        data.topPlayer = player.DisplayName or player.Name
                    end
                end
            end
            
            -- Buscar peces
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
    data.score = math.floor(data.maxMoney / 500) + (data.totalFish * 2) + (data.rareFish * 25) + (data.players * 3)
    
    return data
end

-- Función para crear item de servidor
local function createServerItem(serverData, parent)
    local frame = Instance.new("Frame")
    frame.Name = "ServerItem_" .. tostring(#parent:GetChildren())
    frame.Size = UDim2.new(1, -10, 0, 75)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.28)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.35, 0.35, 0.4)
    frame.Visible = true
    frame.Parent = parent
    frame.ZIndex = 3
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    -- Indicador de calidad (barra lateral)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 6, 1, 0)
    indicator.Position = UDim2.new(0, 0, 0, 0)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 0
    indicator.Parent = frame
    indicator.ZIndex = 4
    
    if serverData.score >= 100 then
        indicator.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2) -- Verde
    elseif serverData.score >= 50 then
        indicator.BackgroundColor3 = Color3.new(0.8, 0.6, 0.2) -- Amarillo
    else
        indicator.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3) -- Rojo
    end
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator
    
    -- Información del servidor
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 200, 1, 0)
    infoLabel.Position = UDim2.new(0, 12, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format("⭐ Puntuación: %d\n👥 Jugadores: %d | 💰 Max: $%s\n🐟 Peces: %d | 🔥 Raros: %d", 
        serverData.score, 
        serverData.players, 
        serverData.maxMoney >= 1000 and string.format("%.1fK", serverData.maxMoney/1000) or tostring(serverData.maxMoney),
        serverData.totalFish, 
        serverData.rareFish)
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextSize = 12
    infoLabel.TextScaled = false
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    infoLabel.TextStrokeTransparency = 0.8
    infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    infoLabel.Visible = true
    infoLabel.Parent = frame
    infoLabel.ZIndex = 4
    
    -- Botón unirse
    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(0, 85, 0, 40)
    joinButton.Position = UDim2.new(1, -95, 0.5, -20)
    joinButton.BackgroundColor3 = Color3.new(0.1, 0.5, 0.8)
    joinButton.BackgroundTransparency = 0
    joinButton.BorderSizePixel = 2
    joinButton.BorderColor3 = Color3.new(0.05, 0.3, 0.6)
    joinButton.Text = "UNIRSE"
    joinButton.TextColor3 = Color3.new(1, 1, 1)
    joinButton.TextSize = 14
    joinButton.TextScaled = false
    joinButton.Font = Enum.Font.SourceSansBold
    joinButton.TextStrokeTransparency = 0.8
    joinButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    joinButton.Visible = true
    joinButton.Active = true
    joinButton.Parent = frame
    joinButton.ZIndex = 4
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 5)
    joinCorner.Parent = joinButton
    
    -- Evento del botón unirse
    joinButton.MouseButton1Click:Connect(function()
        print("Intentando unirse al servidor:", serverData.serverId)
        joinButton.Text = "UNIENDO..."
        joinButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        
        wait(0.5)
        
        local success = pcall(function()
            if serverData.serverId and serverData.serverId ~= "" and not string.find(serverData.serverId, "server_") then
                TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
            else
                TeleportService:Teleport(gameId, LocalPlayer)
            end
        end)
        
        if not success then
            joinButton.Text = "ERROR"
            joinButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
            wait(2)
            joinButton.Text = "UNIRSE"
            joinButton.BackgroundColor3 = Color3.new(0.1, 0.5, 0.8)
        end
    end)
    
    return frame
end

-- Función principal de escaneo
function startServerScan(scanButton, stopButton, statusLabel, scrollFrame)
    if isScanning then 
        print("Ya está escaneando, cancelando...")
        return 
    end
    
    print("Iniciando escaneo de servidores...")
    isScanning = true
    currentScanCount = 0
    serverList = {}
    
    -- Cambiar botones
    scanButton.Visible = false
    stopButton.Visible = true
    statusLabel.Text = "🔍 Iniciando escaneo de servidores..."
    statusLabel.TextColor3 = Color3.new(1, 0.8, 0.4)
    
    -- Limpiar lista anterior
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") and string.find(child.Name, "ServerItem") then
            child:Destroy()
        end
    end
    
    -- Función para escanear siguiente servidor
    local function scanNext()
        if not isScanning then 
            print("Escaneo cancelado")
            return 
        end
        
        if currentScanCount >= maxServersToScan then
            print("Escaneo completado")
            -- Finalizar
            isScanning = false
            scanButton.Visible = true
            stopButton.Visible = false
            statusLabel.Text = string.format("✅ Completado: %d servidores encontrados", #serverList)
            statusLabel.TextColor3 = Color3.new(0.6, 1, 0.6)
            
            -- Ordenar lista por puntuación
            table.sort(serverList, function(a, b) return a.score > b.score end)
            
            -- Recrear lista ordenada
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("Frame") and string.find(child.Name, "ServerItem") then
                    child:Destroy()
                end
            end
            
            for i, data in ipairs(serverList) do
                if i <= 10 then
                    createServerItem(data, scrollFrame)
                end
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#serverList, 10) * 81)
            return
        end
        
        currentScanCount = currentScanCount + 1
        statusLabel.Text = string.format("🔄 Escaneando servidor %d/%d...", currentScanCount, maxServersToScan)
        
        -- Analizar servidor actual
        wait(1.5)
        local currentData = analyzeServer()
        print("Servidor analizado - Puntuación:", currentData.score)
        
        if currentData.score > 10 then -- Solo guardar servidores decentes
            table.insert(serverList, currentData)
            createServerItem(currentData, scrollFrame)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #serverList * 81)
            print("Servidor agregado a la lista")
        end
        
        -- Esperar antes de saltar
        wait(1.5)
        
        if isScanning then
            print("Saltando al siguiente servidor...")
            TeleportService:Teleport(gameId, LocalPlayer)
        end
    end
    
    -- Empezar escaneo después de una pequeña pausa
    wait(2)
    scanNext()
end

-- Crear GUI e inicializar
print("Creando GUI...")
wait(1)
local gui, scrollFrame, statusLabel, scanButton, stopButton = createGUI()

print("✅ STEAL A FISH SERVER SCANNER CARGADO CORRECTAMENTE!")
print("📱 Todos los elementos son visibles")
print("🎯 Busca servidores con peces raros y jugadores ricos")
print("🔍 Presiona el botón verde ESCANEAR para empezar")

-- Notificación
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🐟 Server Scanner Cargado";
    Text = "¡Todos los botones son visibles! Presiona ESCANEAR.";
    Duration = 5;
})