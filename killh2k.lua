-- 💀 H2K PRISON LIFE - ULTIMATE KILL ALL
-- El kill all más roto con melee event
-- Compatible Android Krnl - By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Estados del mod
local ModState = {
    killAll = false,
    noclip = false,
    killAura = false,
    isOpen = true
}

local Connections = {}

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("H2KPrisonLife") then
        LocalPlayer.PlayerGui:FindFirstChild("H2KPrisonLife"):Destroy()
    end
end)

-- Variables para melee kill
local meleeEvent = nil
local remotes = {}

-- Encontrar eventos de melee
local function findMeleeEvents()
    -- Buscar en ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if obj.Name:lower():find("melee") or obj.Name:lower():find("punch") or obj.Name:lower():find("hit") then
                table.insert(remotes, obj)
            end
        end
    end
    
    -- Si no encuentra eventos específicos, usar eventos generales
    if #remotes == 0 then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(remotes, obj)
            end
        end
    end
    
    meleeEvent = remotes[1] -- Usar el primer evento encontrado
end

-- Encontrar eventos al cargar
findMeleeEvents()

-- Función de Kill All con melee event
local function executeKillAll()
    if not meleeEvent then
        findMeleeEvents()
    end
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local targetHumanoid = target.Character:FindFirstChild("Humanoid")
            local targetRootPart = target.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHumanoid and targetRootPart and targetHumanoid.Health > 0 then
                -- Múltiples métodos de kill para máxima efectividad
                spawn(function()
                    -- Método 1: Melee Event
                    if meleeEvent then
                        for i = 1, 20 do
                            pcall(function()
                                meleeEvent:FireServer(target.Character, 999999)
                            end)
                            wait(0.01)
                        end
                    end
                    
                    -- Método 2: Damage directo
                    pcall(function()
                        targetHumanoid.Health = 0
                    end)
                    
                    -- Método 3: RemoteEvent alternativo
                    for _, remote in pairs(remotes) do
                        pcall(function()
                            remote:FireServer("Damage", target.Character, 999999)
                            remote:FireServer("Kill", target.Character)
                            remote:FireServer(target.Character, "Death")
                        end)
                    end
                end)
            end
        end
    end
end

-- Función de Kill Aura
local function killAura()
    if ModState.killAura then
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= LocalPlayer and target.Character then
                local targetRootPart = target.Character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = target.Character:FindFirstChild("Humanoid")
                
                if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (RootPart.Position - targetRootPart.Position).Magnitude
                    
                    if distance <= 50 then -- 50 studs de rango
                        if meleeEvent then
                            pcall(function()
                                meleeEvent:FireServer(target.Character, 999999)
                            end)
                        end
                        
                        pcall(function()
                            targetHumanoid.Health = 0
                        end)
                    end
                end
            end
        end
    end
end

-- Función de Noclip
local function toggleNoclip()
    ModState.noclip = not ModState.noclip
    
    if ModState.noclip then
        Connections.noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part ~= RootPart then
                    part.CanCollide = false
                end
            end
        end)
    else
        if Connections.noclipConnection then
            Connections.noclipConnection:Disconnect()
            Connections.noclipConnection = nil
        end
        
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = true
            end
        end
    end
end

-- Crear icono flotante H2K
local function createFloatingIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KIcon"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Icono flotante
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, 60, 0, 60)
    iconFrame.Position = UDim2.new(1, -80, 0, 100)
    iconFrame.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
    
    -- Gradiente
    local iconGradient = Instance.new("UIGradient")
    iconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
    }
    iconGradient.Rotation = 45
    iconGradient.Parent = iconFrame
    
    -- Sombra
    local iconShadow = Instance.new("Frame")
    iconShadow.Size = UDim2.new(1, 8, 1, 8)
    iconShadow.Position = UDim2.new(0, -4, 0, -4)
    iconShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    iconShadow.BackgroundTransparency = 0.7
    iconShadow.ZIndex = iconFrame.ZIndex - 1
    iconShadow.Parent = iconFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = iconShadow
    
    -- Texto H2K
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.TextSize = 18
    iconText.Font = Enum.Font.GothamBold
    iconText.TextStrokeTransparency = 0
    iconText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    iconText.Parent = iconFrame
    
    -- Botón clickeable
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Parent = iconFrame
    
    return {
        gui = screenGui,
        frame = iconFrame,
        button = iconButton
    }
end

-- Crear mod menu principal
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KPrisonLife"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, -6)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 21)
    shadowCorner.Parent = shadow
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    -- Gradiente header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    -- Logo y título
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 22
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    logo.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Prison Life"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    -- Contenido
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Sección Kill All
    local killAllSection = Instance.new("Frame")
    killAllSection.Size = UDim2.new(1, 0, 0, 70)
    killAllSection.Position = UDim2.new(0, 0, 0, 0)
    killAllSection.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    killAllSection.BorderSizePixel = 0
    killAllSection.Parent = content
    
    local killAllCorner = Instance.new("UICorner")
    killAllCorner.CornerRadius = UDim.new(0, 8)
    killAllCorner.Parent = killAllSection
    
    local killAllLabel = Instance.new("TextLabel")
    killAllLabel.Size = UDim2.new(1, -80, 1, 0)
    killAllLabel.Position = UDim2.new(0, 15, 0, 0)
    killAllLabel.BackgroundTransparency = 1
    killAllLabel.Text = "💀 Kill All Players\nMata a todos (Melee Event)"
    killAllLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAllLabel.TextSize = 13
    killAllLabel.Font = Enum.Font.Gotham
    killAllLabel.TextXAlignment = Enum.TextXAlignment.Left
    killAllLabel.TextYAlignment = Enum.TextYAlignment.Center
    killAllLabel.Parent = killAllSection
    
    local killAllBtn = Instance.new("TextButton")
    killAllBtn.Size = UDim2.new(0, 60, 0, 30)
    killAllBtn.Position = UDim2.new(1, -70, 0.5, -15)
    killAllBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    killAllBtn.Text = "KILL"
    killAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAllBtn.TextSize = 12
    killAllBtn.Font = Enum.Font.GothamBold
    killAllBtn.Parent = killAllSection
    
    local killAllBtnCorner = Instance.new("UICorner")
    killAllBtnCorner.CornerRadius = UDim.new(0, 6)
    killAllBtnCorner.Parent = killAllBtn
    
    -- Sección Kill Aura
    local killAuraSection = Instance.new("Frame")
    killAuraSection.Size = UDim2.new(1, 0, 0, 60)
    killAuraSection.Position = UDim2.new(0, 0, 0, 80)
    killAuraSection.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    killAuraSection.BorderSizePixel = 0
    killAuraSection.Parent = content
    
    local killAuraCorner = Instance.new("UICorner")
    killAuraCorner.CornerRadius = UDim.new(0, 8)
    killAuraCorner.Parent = killAuraSection
    
    local killAuraLabel = Instance.new("TextLabel")
    killAuraLabel.Size = UDim2.new(1, -70, 1, 0)
    killAuraLabel.Position = UDim2.new(0, 15, 0, 0)
    killAuraLabel.BackgroundTransparency = 1
    killAuraLabel.Text = "⚔️ Kill Aura\nMata cerca tuyo"
    killAuraLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraLabel.TextSize = 13
    killAuraLabel.Font = Enum.Font.Gotham
    killAuraLabel.TextXAlignment = Enum.TextXAlignment.Left
    killAuraLabel.TextYAlignment = Enum.TextYAlignment.Center
    killAuraLabel.Parent = killAuraSection
    
    local killAuraToggle = Instance.new("TextButton")
    killAuraToggle.Size = UDim2.new(0, 50, 0, 25)
    killAuraToggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    killAuraToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    killAuraToggle.Text = "OFF"
    killAuraToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraToggle.TextSize = 11
    killAuraToggle.Font = Enum.Font.GothamBold
    killAuraToggle.Parent = killAuraSection
    
    local killAuraToggleCorner = Instance.new("UICorner")
    killAuraToggleCorner.CornerRadius = UDim.new(0, 6)
    killAuraToggleCorner.Parent = killAuraToggle
    
    -- Sección Noclip
    local noclipSection = Instance.new("Frame")
    noclipSection.Size = UDim2.new(1, 0, 0, 60)
    noclipSection.Position = UDim2.new(0, 0, 0, 150)
    noclipSection.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    noclipSection.BorderSizePixel = 0
    noclipSection.Parent = content
    
    local noclipCorner = Instance.new("UICorner")
    noclipCorner.CornerRadius = UDim.new(0, 8)
    noclipCorner.Parent = noclipSection
    
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(1, -70, 1, 0)
    noclipLabel.Position = UDim2.new(0, 15, 0, 0)
    noclipLabel.BackgroundTransparency = 1
    noclipLabel.Text = "👻 Noclip\nAtravesar paredes"
    noclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipLabel.TextSize = 13
    noclipLabel.Font = Enum.Font.Gotham
    noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noclipLabel.TextYAlignment = Enum.TextYAlignment.Center
    noclipLabel.Parent = noclipSection
    
    local noclipToggle = Instance.new("TextButton")
    noclipToggle.Size = UDim2.new(0, 50, 0, 25)
    noclipToggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    noclipToggle.Text = "OFF"
    noclipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipToggle.TextSize = 11
    noclipToggle.Font = Enum.Font.GothamBold
    noclipToggle.Parent = noclipSection
    
    local noclipToggleCorner = Instance.new("UICorner")
    noclipToggleCorner.CornerRadius = UDim.new(0, 6)
    noclipToggleCorner.Parent = noclipToggle
    
    -- Créditos
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, 0, 0, 15)
    credits.Position = UDim2.new(0, 0, 1, -15)
    credits.BackgroundTransparency = 1
    credits.Text = "by H2K"
    credits.TextColor3 = Color3.fromRGB(150, 150, 150)
    credits.TextSize = 11
    credits.Font = Enum.Font.GothamBold
    credits.Parent = content
    
    return {
        gui = screenGui,
        mainFrame = mainFrame,
        closeBtn = closeBtn,
        killAllBtn = killAllBtn,
        killAuraToggle = killAuraToggle,
        noclipToggle = noclipToggle,
        header = header
    }
end

-- Crear icono y menú
local icon = createFloatingIcon()
local menu = createModMenu()

-- Kill Aura loop
spawn(function()
    while wait(0.1) do
        killAura()
    end
end)

-- Conectar funciones del icono
icon.button.MouseButton1Click:Connect(function()
    ModState.isOpen = not ModState.isOpen
    menu.mainFrame.Visible = ModState.isOpen
    
    -- Animación del icono
    local scaleTween = TweenService:Create(icon.frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 55, 0, 55)})
    local scaleBackTween = TweenService:Create(icon.frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 60, 0, 60)})
    
    scaleTween:Play()
    scaleTween.Completed:Connect(function()
        scaleBackTween:Play()
    end)
end)

-- Conectar funciones del menú
menu.closeBtn.MouseButton1Click:Connect(function()
    menu.mainFrame.Visible = false
    ModState.isOpen = false
end)

menu.killAllBtn.MouseButton1Click:Connect(function()
    executeKillAll()
    
    -- Feedback visual
    menu.killAllBtn.Text = "KILLED!"
    menu.killAllBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    wait(1)
    menu.killAllBtn.Text = "KILL"
    menu.killAllBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
end)

menu.killAuraToggle.MouseButton1Click:Connect(function()
    ModState.killAura = not ModState.killAura
    menu.killAuraToggle.Text = ModState.killAura and "ON" or "OFF"
    menu.killAuraToggle.BackgroundColor3 = ModState.killAura and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)
end)

menu.noclipToggle.MouseButton1Click:Connect(function()
    toggleNoclip()
    menu.noclipToggle.Text = ModState.noclip and "ON" or "OFF"
    menu.noclipToggle.BackgroundColor3 = ModState.noclip and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)
end)

-- Hacer arrastrable
local dragging = false
local dragStart = nil
local startPos = nil

menu.header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menu.mainFrame.Position
    end
end)

menu.header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        menu.mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

menu.header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Actualizar personaje al respawnear
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Reactivar noclip si estaba activo
    if ModState.noclip then
        toggleNoclip()
        toggleNoclip()
    end
end)

-- Limpiar al salir
game:BindToClose(function()
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
end)

print("💀 H2K Prison Life Mod cargado!")
print("🎯 Kill All con Melee Event activo")
print("📱 Compatible Android Krnl")
print("⚔️ Funciones: Kill All, Kill Aura, Noclip")
print("✨ By H2K - El mod más roto para Prison Life")