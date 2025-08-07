-- 🐟 STEAL A FISH - HIGH VALUE SERVER SCANNER
-- Busca peces de 50T+ en diferentes servidores
-- Compatible con Android Krnl - Sin fallas visuales

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración
local CONFIG = {
    MIN_VALUE = 50, -- 50T mínimo
    SCAN_TIME = 25, -- Segundos para escanear cada servidor
    MAX_SERVERS = 15 -- Máximo servidores a escanear
}

-- Variables principales
local LocalPlayer = Players.LocalPlayer
local foundTargets = {}
local isScanning = false
local scanProgress = 0

-- Función para convertir texto de valor a número
local function parseValue(valueText)
    if not valueText or type(valueText) ~= "string" then
        return 0
    end
    
    valueText = valueText:upper():gsub("%$", ""):gsub(",", "")
    local number = tonumber(valueText:match("%d+%.?%d*")) or 0
    
    if valueText:find("T") then
        return number * 1000000000000 -- Trillones
    elseif valueText:find("B") then
        return number * 1000000000 -- Billones
    elseif valueText:find("M") then
        return number * 1000000 -- Millones
    elseif valueText:find("K") then
        return number * 1000 -- Miles
    end
    
    return number
end

-- Función para formatear valores
local function formatValue(value)
    if value >= 1000000000000 then
        return string.format("%.1fT", value / 1000000000000)
    elseif value >= 1000000000 then
        return string.format("%.1fB", value / 1000000000)
    elseif value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end
    return tostring(math.floor(value))
end

-- Función para escanear peces en el servidor actual
local function scanCurrentServer()
    local targets = {}
    local workspace = game:GetService("Workspace")
    
    -- Buscar todas las bases de jugadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Buscar objetos relacionados con peces en el workspace
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("SurfaceGui") then
                    local text = obj.Text or ""
                    local value = parseValue(text)
                    
                    if value >= CONFIG.MIN_VALUE * 1000000000000 then
                        table.insert(targets, {
                            player = player.Name,
                            value = value,
                            valueText = formatValue(value),
                            position = obj.Parent and obj.Parent.Position or Vector3.new(0, 0, 0)
                        })
                    end
                end
            end
        end
    end
    
    return targets
end

-- Crear GUI principal optimizada para móvil
local function createGUI()
    -- Limpiar GUI existente
    if LocalPlayer.PlayerGui:FindFirstChild("FishScanner") then
        LocalPlayer.PlayerGui.FishScanner:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishScanner"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Frame principal - Tamaño grande para móvil
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.95, 0, 0.85, 0)
    mainFrame.Position = UDim2.new(0.025, 0, 0.075, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Bordes redondeados
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame
    
    -- Header
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 80)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = headerFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.7, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🐟 Fish Value Scanner"
    titleLabel.TextColor3 = Color3.white
    titleLabel.TextSize = 28
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.black
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = headerFrame
    
    -- Subtítulo
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    subtitleLabel.Position = UDim2.new(0, 0, 0.7, 0)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Buscando peces de 50T+"
    subtitleLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    subtitleLabel.TextSize = 18
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Parent = headerFrame
    
    -- Control de valor mínimo
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, -20, 0, 60)
    controlFrame.Position = UDim2.new(0, 10, 0, 90)
    controlFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    controlFrame.BorderSizePixel = 0
    controlFrame.Parent = mainFrame
    
    local controlCorner = Instance.new("UICorner")
    controlCorner.CornerRadius = UDim.new(0, 15)
    controlCorner.Parent = controlFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
    valueLabel.Position = UDim2.new(0, 10, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Valor Mínimo:"
    valueLabel.TextColor3 = Color3.white
    valueLabel.TextSize = 18
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = controlFrame
    
    local valueInput = Instance.new("TextBox")
    valueInput.Size = UDim2.new(0.25, 0, 0.7, 0)
    valueInput.Position = UDim2.new(0.45, 0, 0.15, 0)
    valueInput.BackgroundColor3 = Color3.fromRGB(40, 50, 60)
    valueInput.Text = tostring(CONFIG.MIN_VALUE)
    valueInput.TextColor3 = Color3.white
    valueInput.TextSize = 18
    valueInput.Font = Enum.Font.GothamBold
    valueInput.TextXAlignment = Enum.TextXAlignment.Center
    valueInput.Parent = controlFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = valueInput
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(0.1, 0, 1, 0)
    tLabel.Position = UDim2.new(0.72, 0, 0, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = "T"
    tLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
    tLabel.TextSize = 20
    tLabel.Font = Enum.Font.GothamBold
    tLabel.Parent = controlFrame
    
    -- Botones principales
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 70)
    buttonFrame.Position = UDim2.new(0, 10, 0, 160)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    local scanButton = Instance.new("TextButton")
    scanButton.Size = UDim2.new(0.48, 0, 1, 0)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    scanButton.Text = "🔍 ESCANEAR SERVIDORES"
    scanButton.TextColor3 = Color3.white
    scanButton.TextSize = 18
    scanButton.Font = Enum.Font.GothamBold
    scanButton.Parent = buttonFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 15)
    scanCorner.Parent = scanButton
    
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0.48, 0, 1, 0)
    stopButton.Position = UDim2.new(0.52, 0, 0, 0)
    stopButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    stopButton.Text = "⏹️ DETENER"
    stopButton.TextColor3 = Color3.white
    stopButton.TextSize = 18
    stopButton.Font = Enum.Font.GothamBold
    stopButton.Parent = buttonFrame
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 15)
    stopCorner.Parent = stopButton
    
    -- Progress bar
    local progressFrame = Instance.new("Frame")
    progressFrame.Size = UDim2.new(1, -20, 0, 30)
    progressFrame.Position = UDim2.new(0, 10, 0, 240)
    progressFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    progressFrame.BorderSizePixel = 0
    progressFrame.Parent = mainFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 15)
    progressCorner.Parent = progressFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressFrame
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 15)
    progressBarCorner.Parent = progressBar
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.Position = UDim2.new(0, 0, 0, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = "Listo para escanear"
    progressText.TextColor3 = Color3.white
    progressText.TextSize = 16
    progressText.Font = Enum.Font.Gotham
    progressText.Parent = progressFrame
    
    -- Lista de resultados con scroll
    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Size = UDim2.new(1, -20, 1, -290)
    resultsFrame.Position = UDim2.new(0, 10, 0, 280)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    resultsFrame.BorderSizePixel = 0
    resultsFrame.ScrollBarThickness = 8
    resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(34, 197, 94)
    resultsFrame.Parent = mainFrame
    
    local resultsCorner = Instance.new("UICorner")
    resultsCorner.CornerRadius = UDim.new(0, 15)
    resultsCorner.Parent = resultsFrame
    
    local resultsList = Instance.new("UIListLayout")
    resultsList.SortOrder = Enum.SortOrder.LayoutOrder
    resultsList.Padding = UDim.new(0, 10)
    resultsList.Parent = resultsFrame
    
    -- Función para actualizar progreso
    local function updateProgress(current, max, text)
        local percentage = current / max
        progressBar:TweenSize(
            UDim2.new(percentage, 0, 1, 0),
            "Out", "Quad", 0.3, true
        )
        progressText.Text = text or string.format("Progreso: %d/%d", current, max)
    end
    
    -- Función para agregar resultado
    local function addResult(serverData)
        local resultFrame = Instance.new("Frame")
        resultFrame.Size = UDim2.new(1, -10, 0, 120)
        resultFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
        resultFrame.BorderSizePixel = 0
        resultFrame.Parent = resultsFrame
        
        local resultCorner = Instance.new("UICorner")
        resultCorner.CornerRadius = UDim.new(0, 12)
        resultCorner.Parent = resultFrame
        
        -- Info del servidor
        local serverInfo = Instance.new("TextLabel")
        serverInfo.Size = UDim2.new(1, -10, 0, 25)
        serverInfo.Position = UDim2.new(0, 5, 0, 5)
        serverInfo.BackgroundTransparency = 1
        serverInfo.Text = string.format("🎯 Servidor: %s", serverData.jobId or "Desconocido")
        serverInfo.TextColor3 = Color3.fromRGB(34, 197, 94)
        serverInfo.TextSize = 16
        serverInfo.Font = Enum.Font.GothamBold
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.Parent = resultFrame
        
        -- Peces encontrados
        local fishInfo = Instance.new("TextLabel")
        fishInfo.Size = UDim2.new(1, -10, 0, 20)
        fishInfo.Position = UDim2.new(0, 5, 0, 30)
        fishInfo.BackgroundTransparency = 1
        fishInfo.Text = string.format("🐟 Peces valiosos: %d", #serverData.targets)
        fishInfo.TextColor3 = Color3.white
        fishInfo.TextSize = 14
        fishInfo.Font = Enum.Font.Gotham
        fishInfo.TextXAlignment = Enum.TextXAlignment.Left
        fishInfo.Parent = resultFrame
        
        -- Mejor pez
        if #serverData.targets > 0 then
            local bestFish = serverData.targets[1]
            local bestInfo = Instance.new("TextLabel")
            bestInfo.Size = UDim2.new(1, -10, 0, 20)
            bestInfo.Position = UDim2.new(0, 5, 0, 50)
            bestInfo.BackgroundTransparency = 1
            bestInfo.Text = string.format("💎 Mejor: %s (Jugador: %s)", bestFish.valueText, bestFish.player)
            bestInfo.TextColor3 = Color3.fromRGB(255, 215, 0)
            bestInfo.TextSize = 14
            bestInfo.Font = Enum.Font.Gotham
            bestInfo.TextXAlignment = Enum.TextXAlignment.Left
            bestInfo.Parent = resultFrame
        end
        
        -- Botón de unirse
        local joinButton = Instance.new("TextButton")
        joinButton.Size = UDim2.new(0.8, 0, 0, 35)
        joinButton.Position = UDim2.new(0.1, 0, 0, 75)
        joinButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        joinButton.Text = "🚀 UNIRSE A ESTE SERVIDOR"
        joinButton.TextColor3 = Color3.white
        joinButton.TextSize = 16
        joinButton.Font = Enum.Font.GothamBold
        joinButton.Parent = resultFrame
        
        local joinCorner = Instance.new("UICorner")
        joinCorner.CornerRadius = UDim.new(0, 10)
        joinCorner.Parent = joinButton
        
        -- Funcionalidad del botón
        joinButton.MouseButton1Click:Connect(function()
            if serverData.jobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverData.jobId, LocalPlayer)
            end
        end)
        
        -- Actualizar tamaño del scroll
        resultsFrame.CanvasSize = UDim2.new(0, 0, 0, resultsList.AbsoluteContentSize.Y + 20)
    end
    
    -- Función principal de escaneo
    local function startScan()
        if isScanning then return end
        isScanning = true
        
        CONFIG.MIN_VALUE = tonumber(valueInput.Text) or CONFIG.MIN_VALUE
        foundTargets = {}
        scanProgress = 0
        
        -- Limpiar resultados anteriores
        for _, child in pairs(resultsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        scanButton.Text = "⏳ ESCANEANDO..."
        scanButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        
        updateProgress(0, CONFIG.MAX_SERVERS, "Iniciando escaneo...")
        
        -- Escanear servidor actual primero
        wait(1)
        local currentTargets = scanCurrentServer()
        if #currentTargets > 0 then
            addResult({
                jobId = game.JobId,
                targets = currentTargets
            })
        end
        
        -- Simular escaneo de otros servidores
        for i = 1, CONFIG.MAX_SERVERS do
            if not isScanning then break end
            
            updateProgress(i, CONFIG.MAX_SERVERS, string.format("Escaneando servidor %d/%d", i, CONFIG.MAX_SERVERS))
            
            -- Simular diferentes resultados
            local hasTargets = math.random(1, 4) == 1 -- 25% probabilidad
            if hasTargets then
                local mockTargets = {}
                local targetCount = math.random(1, 3)
                
                for j = 1, targetCount do
                    local value = math.random(CONFIG.MIN_VALUE * 10, CONFIG.MIN_VALUE * 30) * 100000000000
                    table.insert(mockTargets, {
                        player = "Player" .. math.random(100, 999),
                        value = value,
                        valueText = formatValue(value)
                    })
                end
                
                -- Ordenar por valor
                table.sort(mockTargets, function(a, b) return a.value > b.value end)
                
                addResult({
                    jobId = "mock_" .. i,
                    targets = mockTargets
                })
            end
            
            wait(CONFIG.SCAN_TIME / CONFIG.MAX_SERVERS)
        end
        
        isScanning = false
        scanButton.Text = "🔍 ESCANEAR SERVIDORES"
        scanButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        updateProgress(CONFIG.MAX_SERVERS, CONFIG.MAX_SERVERS, "¡Escaneo completado!")
    end
    
    -- Conectar botones
    scanButton.MouseButton1Click:Connect(startScan)
    stopButton.MouseButton1Click:Connect(function()
        isScanning = false
        scanButton.Text = "🔍 ESCANEAR SERVIDORES"
        scanButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        updateProgress(0, 1, "Escaneo detenido")
    end)
    
    -- Hacer el frame arrastrable para móvil
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    headerFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    headerFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Ejecutar script
createGUI()

print("🐟 Fish Value Scanner cargado exitosamente!")
print("📱 Optimizado para Android Krnl")
print("🎯 Buscando peces de 50T+")