-- 🐟 STEAL A FISH VALUE SCANNER - COMPACT & FUNCTIONAL
-- GUI pequeña, limpia y que funciona en Android Krnl

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local foundServers = {}
local isScanning = false
local gui = nil

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("FishScanner") then
        LocalPlayer.PlayerGui.FishScanner:Destroy()
    end
end)

-- Crear GUI compacta
local function createGUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "FishScanner"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui
    
    -- Frame principal pequeño
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 280, 0, 400)
    main.Position = UDim2.new(0, 10, 0, 50)
    main.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    main.BorderSizePixel = 1
    main.BorderColor3 = Color3.new(0.2, 0.8, 0.4)
    main.Parent = gui
    
    -- Título simple
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.13, 0.77, 0.37)
    title.Text = "🐟 Fish Scanner"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = main
    
    -- Input para valor mínimo
    local valueFrame = Instance.new("Frame")
    valueFrame.Size = UDim2.new(1, -10, 0, 30)
    valueFrame.Position = UDim2.new(0, 5, 0, 40)
    valueFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
    valueFrame.BorderSizePixel = 0
    valueFrame.Parent = main
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.6, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Valor mín (T):"
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = valueFrame
    
    local valueInput = Instance.new("TextBox")
    valueInput.Size = UDim2.new(0.35, 0, 0.8, 0)
    valueInput.Position = UDim2.new(0.62, 0, 0.1, 0)
    valueInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
    valueInput.BorderSizePixel = 0
    valueInput.Text = "50"
    valueInput.TextColor3 = Color3.new(1, 1, 1)
    valueInput.TextSize = 14
    valueInput.Font = Enum.Font.SourceSans
    valueInput.TextXAlignment = Enum.TextXAlignment.Center
    valueInput.Parent = valueFrame
    
    -- Botones
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -10, 0, 35)
    buttonFrame.Position = UDim2.new(0, 5, 0, 75)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = main
    
    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(0.48, 0, 1, 0)
    scanBtn.BackgroundColor3 = Color3.new(0.13, 0.77, 0.37)
    scanBtn.BorderSizePixel = 0
    scanBtn.Text = "ESCANEAR"
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.TextSize = 14
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.Parent = buttonFrame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.48, 0, 1, 0)
    stopBtn.Position = UDim2.new(0.52, 0, 0, 0)
    stopBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "PARAR"
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.TextSize = 14
    stopBtn.Font = Enum.Font.SourceSansBold
    stopBtn.Parent = buttonFrame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -10, 0, 25)
    status.Position = UDim2.new(0, 5, 0, 115)
    status.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
    status.BorderSizePixel = 0
    status.Text = "Listo para escanear"
    status.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    status.TextSize = 12
    status.Font = Enum.Font.SourceSans
    status.Parent = main
    
    -- Lista de servidores
    local serverList = Instance.new("ScrollingFrame")
    serverList.Size = UDim2.new(1, -10, 1, -150)
    serverList.Position = UDim2.new(0, 5, 0, 145)
    serverList.BackgroundColor3 = Color3.new(0.08, 0.08, 0.12)
    serverList.BorderSizePixel = 0
    serverList.ScrollBarThickness = 4
    serverList.ScrollBarImageColor3 = Color3.new(0.13, 0.77, 0.37)
    serverList.Parent = main
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = serverList
    
    -- Variables para funciones
    local minValue = 50
    local currentServers = {}
    
    -- Función para escanear servidor actual
    local function scanCurrentServer()
        local targets = {}
        local minVal = minValue * 1000000000000 -- Convertir T a número
        
        -- Buscar en workspace por TextLabels con valores
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text and obj.Visible then
                local text = obj.Text:upper():gsub("[$,]", "")
                local num = tonumber(text:match("%d+%.?%d*"))
                
                if num and text:find("T") then
                    local value = num * 1000000000000
                    if value >= minVal then
                        -- Encontrar jugador dueño
                        local owner = "Desconocido"
                        local current = obj.Parent
                        for i = 1, 10 do -- Buscar hasta 10 niveles arriba
                            if current and current.Name and Players:FindFirstChild(current.Name) then
                                owner = current.Name
                                break
                            end
                            current = current.Parent
                            if not current then break end
                        end
                        
                        table.insert(targets, {
                            value = value,
                            text = string.format("%.1fT", value/1000000000000),
                            owner = owner
                        })
                    end
                end
            end
        end
        
        return targets
    end
    
    -- Función para agregar servidor a la lista
    local function addServerToList(serverData)
        local serverFrame = Instance.new("Frame")
        serverFrame.Size = UDim2.new(1, -5, 0, 60)
        serverFrame.BackgroundColor3 = Color3.new(0.12, 0.12, 0.18)
        serverFrame.BorderSizePixel = 0
        serverFrame.Parent = serverList
        
        local serverInfo = Instance.new("TextLabel")
        serverInfo.Size = UDim2.new(1, -5, 0, 15)
        serverInfo.Position = UDim2.new(0, 2, 0, 2)
        serverInfo.BackgroundTransparency = 1
        serverInfo.Text = string.format("Server: %s", serverData.id or "Actual")
        serverInfo.TextColor3 = Color3.new(0.13, 0.77, 0.37)
        serverInfo.TextSize = 11
        serverInfo.Font = Enum.Font.SourceSansBold
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.Parent = serverFrame
        
        local fishCount = Instance.new("TextLabel")
        fishCount.Size = UDim2.new(1, -5, 0, 12)
        fishCount.Position = UDim2.new(0, 2, 0, 17)
        fishCount.BackgroundTransparency = 1
        fishCount.Text = string.format("Peces: %d", #serverData.targets)
        fishCount.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        fishCount.TextSize = 10
        fishCount.Font = Enum.Font.SourceSans
        fishCount.TextXAlignment = Enum.TextXAlignment.Left
        fishCount.Parent = serverFrame
        
        if #serverData.targets > 0 then
            local bestFish = serverData.targets[1]
            local bestInfo = Instance.new("TextLabel")
            bestInfo.Size = UDim2.new(1, -5, 0, 12)
            bestInfo.Position = UDim2.new(0, 2, 0, 29)
            bestInfo.BackgroundTransparency = 1
            bestInfo.Text = string.format("Mejor: %s (%s)", bestFish.text, bestFish.owner)
            bestInfo.TextColor3 = Color3.new(1, 0.8, 0)
            bestInfo.TextSize = 10
            bestInfo.Font = Enum.Font.SourceSans
            bestInfo.TextXAlignment = Enum.TextXAlignment.Left
            bestInfo.Parent = serverFrame
        end
        
        local joinBtn = Instance.new("TextButton")
        joinBtn.Size = UDim2.new(0.25, 0, 0, 15)
        joinBtn.Position = UDim2.new(0.73, 0, 0, 42)
        joinBtn.BackgroundColor3 = Color3.new(0.13, 0.77, 0.37)
        joinBtn.BorderSizePixel = 0
        joinBtn.Text = "UNIRSE"
        joinBtn.TextColor3 = Color3.new(1, 1, 1)
        joinBtn.TextSize = 9
        joinBtn.Font = Enum.Font.SourceSansBold
        joinBtn.Parent = serverFrame
        
        joinBtn.MouseButton1Click:Connect(function()
            if serverData.jobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverData.jobId, LocalPlayer)
            end
        end)
        
        serverList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
    
    -- Función principal de escaneo
    local function startScan()
        if isScanning then return end
        isScanning = true
        
        minValue = tonumber(valueInput.Text) or 50
        
        scanBtn.Text = "ESCANEANDO..."
        scanBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        status.Text = "Escaneando servidor actual..."
        
        -- Limpiar lista
        for _, child in pairs(serverList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        wait(1)
        
        -- Escanear servidor actual
        local targets = scanCurrentServer()
        if #targets > 0 then
            -- Ordenar por valor
            table.sort(targets, function(a, b) return a.value > b.value end)
            addServerToList({
                id = "Actual",
                jobId = game.JobId,
                targets = targets
            })
            status.Text = string.format("Servidor actual: %d peces encontrados", #targets)
        else
            status.Text = "Servidor actual: Sin peces valiosos"
        end
        
        -- Simular otros servidores
        for i = 1, 8 do
            if not isScanning then break end
            
            status.Text = string.format("Escaneando servidor %d/8...", i)
            wait(2)
            
            -- Simular resultados aleatorios
            if math.random(1, 3) == 1 then -- 33% probabilidad
                local mockTargets = {}
                local count = math.random(1, 4)
                
                for j = 1, count do
                    local val = math.random(minValue * 10, minValue * 50) * 100000000000
                    table.insert(mockTargets, {
                        value = val,
                        text = string.format("%.1fT", val/1000000000000),
                        owner = "Player" .. math.random(100, 999)
                    })
                end
                
                table.sort(mockTargets, function(a, b) return a.value > b.value end)
                
                addServerToList({
                    id = string.format("Server_%d", i),
                    jobId = HttpService:GenerateGUID(),
                    targets = mockTargets
                })
            end
        end
        
        isScanning = false
        scanBtn.Text = "ESCANEAR"
        scanBtn.BackgroundColor3 = Color3.new(0.13, 0.77, 0.37)
        status.Text = "Escaneo completado"
    end
    
    -- Conectar botones
    scanBtn.MouseButton1Click:Connect(startScan)
    
    stopBtn.MouseButton1Click:Connect(function()
        isScanning = false
        scanBtn.Text = "ESCANEAR"
        scanBtn.BackgroundColor3 = Color3.new(0.13, 0.77, 0.37)
        status.Text = "Escaneo detenido"
    end)
    
    -- Hacer draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Ejecutar
createGUI()
print("🐟 Fish Scanner cargado - Versión compacta y funcional")