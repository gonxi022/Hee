-- 99 Nights in the Forest H2K Mod Menu - ANDROID OPTIMIZED
-- By H2K - Versión Completa Funcional

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Estado del mod
local ModState = {
    isOpen = false,
    noclip = false,
    infiniteJump = false,
    killAura = false,
    autoWood = false,
    autoScrap = false,
    autoMedical = false,
    fullbright = false,
    esp = false,
    killAuraRange = 20,
    walkSpeed = 16
}

local Connections = {}
local ESPObjects = {}

-- Limpiar GUIs anteriores
pcall(function()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("H2K") then
            gui:Destroy()
        end
    end
end)

-- Funciones principales
local function findCampfire()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("campfire") or name:find("fire") or name:find("camp") then
                return obj
            end
        end
    end
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function findItems(itemType)
    local items = {}
    local patterns = {
        Wood = {"log", "wood", "timber", "branch"},
        Scrap = {"scrap", "metal", "iron", "steel", "can", "bolt", "pipe"},
        Medical = {"medkit", "bandage", "firstaid", "medicine", "health"}
    }
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            for _, pattern in pairs(patterns[itemType] or {}) do
                if name:find(pattern) then
                    if obj:FindFirstChild("ProximityPrompt") or obj:FindFirstChild("ClickDetector") or obj.CanCollide then
                        table.insert(items, obj)
                        break
                    end
                end
            end
        end
    end
    return items
end

local function bringItems(itemType)
    spawn(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        local campfire = findCampfire()
        local items = findItems(itemType)
        
        for i, item in pairs(items) do
            if item and item.Parent then
                pcall(function()
                    -- Teleport al item
                    local originalPos = rootPart.CFrame
                    rootPart.CFrame = item.CFrame + Vector3.new(0, 5, 0)
                    wait(0.1)
                    
                    -- Interactuar
                    local prompt = item:FindFirstChild("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                    
                    -- Mover item
                    if item.Parent and campfire then
                        item.Anchored = false
                        item.CanCollide = false
                        item.CFrame = campfire.CFrame + Vector3.new(
                            math.random(-3, 3), 3, math.random(-3, 3)
                        )
                    end
                    
                    wait(0.2)
                end)
                
                if i % 5 == 0 then
                    wait(0.5) -- Pausa cada 5 items
                end
            end
        end
        
        if campfire then
            rootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
        end
    end)
end

local function performKillAura()
    if not ModState.killAura then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local tool = character:FindFirstChildOfClass("Tool")
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHuman = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and targetHuman and targetHuman.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                if distance <= ModState.killAuraRange then
                    pcall(function()
                        -- Usar herramienta equipada
                        if tool then
                            tool:Activate()
                            
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("RemoteEvent") then
                                    obj:FireServer(targetRoot)
                                    obj:FireServer(player.Character)
                                    obj:FireServer(100)
                                end
                            end
                        end
                        
                        -- Daño directo
                        targetHuman:TakeDamage(25)
                        
                        -- Buscar RemoteEvents del juego
                        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                            if obj:IsA("RemoteEvent") then
                                local name = obj.Name:lower()
                                if name:find("damage") or name:find("hit") or name:find("attack") then
                                    obj:FireServer(targetRoot, 50)
                                    obj:FireServer(player.Character, 50)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

local function toggleNoclip()
    ModState.noclip = not ModState.noclip
    
    if ModState.noclip then
        Connections.noclip = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.noclip then
            Connections.noclip:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    
    if ModState.infiniteJump then
        Connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.infiniteJump then
            Connections.infiniteJump:Disconnect()
        end
    end
end

local function toggleFullbright()
    ModState.fullbright = not ModState.fullbright
    
    if ModState.fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end

local function createESP(player)
    if ESPObjects[player] then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.Parent = character.HumanoidRootPart
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0.5, 0)
    name.BackgroundTransparency = 1
    name.Text = player.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.TextStrokeTransparency = 0
    name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    name.Parent = esp
    
    local distance = Instance.new("TextLabel")
    distance.Size = UDim2.new(1, 0, 0.5, 0)
    distance.Position = UDim2.new(0, 0, 0.5, 0)
    distance.BackgroundTransparency = 1
    distance.Text = "0 studs"
    distance.TextColor3 = Color3.fromRGB(0, 255, 127)
    distance.TextScaled = true
    distance.Font = Enum.Font.Gotham
    distance.TextStrokeTransparency = 0
    distance.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distance.Parent = esp
    
    ESPObjects[player] = {gui = esp, distance = distance}
end

local function toggleESP()
    ModState.esp = not ModState.esp
    
    if ModState.esp then
        -- Crear ESP para jugadores actuales
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
        
        -- Conexión para nuevos jugadores
        Connections.esp = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                wait(1)
                createESP(player)
            end)
        end)
        
        -- Actualizar distancias
        Connections.espUpdate = RunService.Heartbeat:Connect(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            
            for player, data in pairs(ESPObjects) do
                local theirRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if theirRoot and data.distance then
                    local dist = math.floor((myRoot.Position - theirRoot.Position).Magnitude)
                    data.distance.Text = dist .. " studs"
                end
            end
        end)
    else
        -- Remover ESP
        for _, data in pairs(ESPObjects) do
            if data.gui then
                data.gui:Destroy()
            end
        end
        ESPObjects = {}
        
        if Connections.esp then
            Connections.esp:Disconnect()
        end
        if Connections.espUpdate then
            Connections.espUpdate:Disconnect()
        end
    end
end

-- Auto loops
local function autoLoop(itemType)
    spawn(function()
        local stateKey = "auto" .. itemType
        while ModState[stateKey] do
            bringItems(itemType)
            wait(8)
        end
    end)
end

-- Crear GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_99Nights"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui
    
    -- Ícono flotante
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 80, 0, 80)
    iconFrame.Position = UDim2.new(0, 30, 0, 100)
    iconFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    iconFrame.BorderSizePixel = 0
    iconFrame.Active = true
    iconFrame.Draggable = true
    iconFrame.Parent = screenGui
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 40)
    iconCorner.Parent = iconFrame
    
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = Color3.fromRGB(0, 255, 127)
    iconStroke.Thickness = 3
    iconStroke.Parent = iconFrame
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(0, 255, 127)
    iconText.TextScaled = true
    iconText.Font = Enum.Font.GothamBold
    iconText.TextStrokeTransparency = 0
    iconText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    iconText.Parent = iconFrame
    
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Parent = iconFrame
    
    -- Menú principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainMenu"
    mainFrame.Size = UDim2.new(0, 400, 0, 580)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -290)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 255, 127)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 NIGHTS FOREST"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 70, 0, 40)
    logo.Position = UDim2.new(1, -80, 0, 10)
    logo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(0, 255, 127)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logo
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 15)
    closeBtnCorner.Parent = closeBtn
    
    -- Contenido scrollable
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -80)
    scrollFrame.Position = UDim2.new(0, 10, 0, 70)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    scrollFrame.Parent = mainFrame
    
    -- Función para crear secciones
    local function createSection(name, pos, height)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, height)
        section.Position = UDim2.new(0, 0, 0, pos)
        section.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        section.BorderSizePixel = 0
        section.Parent = scrollFrame
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 10)
        sectionCorner.Parent = section
        
        return section
    end
    
    -- Función para crear botones
    local function createButton(text, pos, size, color, parent)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        return btn
    end
    
    -- Función para crear títulos
    local function createTitle(text, pos, parent)
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = pos
        title.BackgroundTransparency = 1
        title.Text = text
        title.TextColor3 = Color3.fromRGB(0, 255, 127)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = parent
        
        return title
    end
    
    -- Sección Auto Bring
    local bringSection = createSection("Bring", 10, 140)
    createTitle("AUTO BRING TO CAMPFIRE", UDim2.new(0, 10, 0, 5), bringSection)
    
    local autoWoodBtn = createButton("AUTO WOOD: OFF", UDim2.new(0, 10, 0, 40), UDim2.new(0, 115, 0, 35), Color3.fromRGB(139, 69, 19), bringSection)
    local autoScrapBtn = createButton("AUTO SCRAP: OFF", UDim2.new(0, 135, 0, 40), UDim2.new(0, 115, 0, 35), Color3.fromRGB(128, 128, 128), bringSection)
    local autoMedBtn = createButton("AUTO MED: OFF", UDim2.new(0, 260, 0, 40), UDim2.new(0, 115, 0, 35), Color3.fromRGB(220, 20, 60), bringSection)
    
    local bringWoodBtn = createButton("BRING LOGS", UDim2.new(0, 10, 0, 85), UDim2.new(0, 115, 0, 35), Color3.fromRGB(101, 67, 33), bringSection)
    local bringScrapBtn = createButton("BRING SCRAP", UDim2.new(0, 135, 0, 85), UDim2.new(0, 115, 0, 35), Color3.fromRGB(90, 90, 90), bringSection)
    local bringMedBtn = createButton("BRING MEDS", UDim2.new(0, 260, 0, 85), UDim2.new(0, 115, 0, 35), Color3.fromRGB(180, 20, 50), bringSection)
    
    -- Sección Movement
    local movSection = createSection("Movement", 160, 100)
    createTitle("MOVEMENT HACKS", UDim2.new(0, 10, 0, 5), movSection)
    
    local noclipBtn = createButton("NOCLIP: OFF", UDim2.new(0, 10, 0, 40), UDim2.new(0, 180, 0, 35), Color3.fromRGB(60, 60, 100), movSection)
    local jumpBtn = createButton("INF JUMP: OFF", UDim2.new(0, 200, 0, 40), UDim2.new(0, 180, 0, 35), Color3.fromRGB(60, 100, 60), movSection)
    
    -- Sección Combat
    local combatSection = createSection("Combat", 270, 120)
    createTitle("COMBAT SYSTEM", UDim2.new(0, 10, 0, 5), combatSection)
    
    local killAuraBtn = createButton("KILL AURA: OFF", UDim2.new(0, 10, 0, 40), UDim2.new(0, 120, 0, 35), Color3.fromRGB(200, 50, 50), combatSection)
    
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0, 80, 0, 30)
    rangeLabel.Position = UDim2.new(0, 140, 0, 45)
    rangeLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    rangeLabel.Text = "Range: 20"
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Gotham
    rangeLabel.Parent = combatSection
    
    local rangeLabelCorner = Instance.new("UICorner")
    rangeLabelCorner.CornerRadius = UDim.new(0, 6)
    rangeLabelCorner.Parent = rangeLabel
    
    local rangeMinus = createButton("-", UDim2.new(0, 230, 0, 40), UDim2.new(0, 35, 0, 35), Color3.fromRGB(255, 50, 50), combatSection)
    local rangePlus = createButton("+", UDim2.new(0, 275, 0, 40), UDim2.new(0, 35, 0, 35), Color3.fromRGB(50, 255, 50), combatSection)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0, 120, 0, 25)
    targetLabel.Position = UDim2.new(0, 320, 0, 47)
    targetLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    targetLabel.Text = "Targets: 0"
    targetLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    targetLabel.TextSize = 14
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Parent = combatSection
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 6)
    targetCorner.Parent = targetLabel
    
    -- Sección Visual
    local visualSection = createSection("Visual", 400, 100)
    createTitle("VISUAL MODS", UDim2.new(0, 10, 0, 5), visualSection)
    
    local fullbrightBtn = createButton("FULLBRIGHT: OFF", UDim2.new(0, 10, 0, 40), UDim2.new(0, 180, 0, 35), Color3.fromRGB(255, 215, 0), visualSection)
    local espBtn = createButton("PLAYER ESP: OFF", UDim2.new(0, 200, 0, 40), UDim2.new(0, 180, 0, 35), Color3.fromRGB(75, 0, 130), visualSection)
    
    -- Sección Utils
    local utilsSection = createSection("Utils", 510, 80)
    createTitle("UTILITIES", UDim2.new(0, 10, 0, 5), utilsSection)
    
    local refreshBtn = createButton("REFRESH", UDim2.new(0, 10, 0, 40), UDim2.new(0, 120, 0, 30), Color3.fromRGB(0, 150, 255), utilsSection)
    local destroyBtn = createButton("DESTROY GUI", UDim2.new(0, 140, 0, 40), UDim2.new(0, 120, 0, 30), Color3.fromRGB(255, 100, 100), utilsSection)
    local tpCampBtn = createButton("TP CAMPFIRE", UDim2.new(0, 270, 0, 40), UDim2.new(0, 120, 0, 30), Color3.fromRGB(255, 140, 0), utilsSection)
    
    -- Info footer
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 40)
    infoLabel.Position = UDim2.new(0, 10, 0, 600)
    infoLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    infoLabel.Text = "H2K 99 Nights Forest | Android Optimized v3.2"
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = scrollFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoLabel
    
    -- EVENTOS
    iconButton.MouseButton1Click:Connect(function()
        ModState.isOpen = not ModState.isOpen
        mainFrame.Visible = ModState.isOpen
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        ModState.isOpen = false
        mainFrame.Visible = false
    end)
    
    -- Auto brings
    autoWoodBtn.MouseButton1Click:Connect(function()
        ModState.autoWood = not ModState.autoWood
        autoWoodBtn.Text = "AUTO WOOD: " .. (ModState.autoWood and "ON" or "OFF")
        autoWoodBtn.BackgroundColor3 = ModState.autoWood and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(139, 69, 19)
        if ModState.autoWood then autoLoop("Wood") end
    end)
    
    autoScrapBtn.MouseButton1Click:Connect(function()
        ModState.autoScrap = not ModState.autoScrap
        autoScrapBtn.Text = "AUTO SCRAP: " .. (ModState.autoScrap and "ON" or "OFF")
        autoScrapBtn.BackgroundColor3 = ModState.autoScrap and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(128, 128, 128)
        if ModState.autoScrap then autoLoop("Scrap") end
    end)
    
    autoMedBtn.MouseButton1Click:Connect(function()
        ModState.autoMedical = not ModState.autoMedical
        autoMedBtn.Text = "AUTO MED: " .. (ModState.autoMedical and "ON" or "OFF")
        autoMedBtn.BackgroundColor3 = ModState.autoMedical and Color3.fromRGB(0, 150,0) or Color3.fromRGB(220, 20, 60)
        if ModState.autoMedical then autoLoop("Medical") end
    end)
    
    -- Manual brings
    bringWoodBtn.MouseButton1Click:Connect(function()
        spawn(function() bringItems("Wood") end)
    end)
    
    bringScrapBtn.MouseButton1Click:Connect(function()
        spawn(function() bringItems("Scrap") end)
    end)
    
    bringMedBtn.MouseButton1Click:Connect(function()
        spawn(function() bringItems("Medical") end)
    end)
    
    -- Movement
    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoclip()
        noclipBtn.Text = "NOCLIP: " .. (ModState.noclip and "ON" or "OFF")
        noclipBtn.BackgroundColor3 = ModState.noclip and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 100)
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        toggleInfiniteJump()
        jumpBtn.Text = "INF JUMP: " .. (ModState.infiniteJump and "ON" or "OFF")
        jumpBtn.BackgroundColor3 = ModState.infiniteJump and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 100, 60)
    end)
    
    -- Combat
    killAuraBtn.MouseButton1Click:Connect(function()
        ModState.killAura = not ModState.killAura
        killAuraBtn.Text = "KILL AURA: " .. (ModState.killAura and "ON" or "OFF")
        killAuraBtn.BackgroundColor3 = ModState.killAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 50, 50)
    end)
    
    rangeMinus.MouseButton1Click:Connect(function()
        ModState.killAuraRange = math.max(5, ModState.killAuraRange - 5)
        rangeLabel.Text = "Range: " .. ModState.killAuraRange
    end)
    
    rangePlus.MouseButton1Click:Connect(function()
        ModState.killAuraRange = math.min(50, ModState.killAuraRange + 5)
        rangeLabel.Text = "Range: " .. ModState.killAuraRange
    end)
    
    -- Visual
    fullbrightBtn.MouseButton1Click:Connect(function()
        toggleFullbright()
        fullbrightBtn.Text = "FULLBRIGHT: " .. (ModState.fullbright and "ON" or "OFF")
        fullbrightBtn.BackgroundColor3 = ModState.fullbright and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 215, 0)
    end)
    
    espBtn.MouseButton1Click:Connect(function()
        toggleESP()
        espBtn.Text = "PLAYER ESP: " .. (ModState.esp and "ON" or "OFF")
        espBtn.BackgroundColor3 = ModState.esp and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(75, 0, 130)
    end)
    
    -- Utils
    refreshBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        wait(0.5)
        createGUI()
    end)
    
    destroyBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        for _, connection in pairs(Connections) do
            if connection then connection:Disconnect() end
        end
    end)
    
    tpCampBtn.MouseButton1Click:Connect(function()
        local campfire = findCampfire()
        local character = LocalPlayer.Character
        if campfire and character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
        end
    end)
    
    -- Target counter loop
    spawn(function()
        while mainFrame.Parent do
            if ModState.killAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local count = 0
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= ModState.killAuraRange then
                            count = count + 1
                        end
                    end
                end
                
                targetLabel.Text = "Targets: " .. count
            else
                targetLabel.Text = "Targets: 0"
            end
            wait(0.5)
        end
    end)
    
    return screenGui
end

-- Kill aura loop
spawn(function()
    while wait(0.1) do
        performKillAura()
    end
end)

-- Speed control
spawn(function()
    while wait() do
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            if ModState.walkSpeed ~= 16 then
                character.Humanoid.WalkSpeed = ModState.walkSpeed
            end
        end
    end
end)

-- Initialize GUI
createGUI()

-- Touch controls for mobile
UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
    if not processedByUI then
        -- Double tap to toggle GUI
        local currentTime = tick()
        if currentTime - (lastTapTime or 0) < 0.5 then
            ModState.isOpen = not ModState.isOpen
            if PlayerGui:FindFirstChild("H2K_99Nights") then
                PlayerGui.H2K_99Nights.MainMenu.Visible = ModState.isOpen
            end
        end
        lastTapTime = currentTime
    end
end)

-- Backup hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        ModState.isOpen = not ModState.isOpen
        if PlayerGui:FindFirstChild("H2K_99Nights") then
            PlayerGui.H2K_99Nights.MainMenu.Visible = ModState.isOpen
        end
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.J then
        toggleInfiniteJump()
    elseif input.KeyCode == Enum.KeyCode.K then
        ModState.killAura = not ModState.killAura
    elseif input.KeyCode == Enum.KeyCode.F then
        toggleFullbright()
    elseif input.KeyCode == Enum.KeyCode.E then
        toggleESP()
    end
end)

print("H2K 99 Nights Forest Mod Menu loaded successfully!")
print("Touch the H2K icon or press Right Ctrl to open menu")
print("Hotkeys: N=Noclip, J=Jump, K=KillAura, F=Fullbright, E=ESP")