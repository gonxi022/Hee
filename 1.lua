-- H2K 99 Nights Forest Mod Menu - Android KRNL Spoof Edition
-- Autor: H2K
-- Totalmente funcional con spoof

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Estado del Mod
local ModState = {
    isOpen = false,
    noclip = false,
    infiniteJump = false,
    killAura = true, -- ON por defecto
    autoWood = true,
    autoScrap = true,
    autoMedical = true,
    fullbright = false,
    esp = false,
    killAuraRange = 20,
    walkSpeed = 16
}

local Connections = {}
local ESPObjects = {}
local lastTapTime = 0

-- Limpiar GUIs anteriores
pcall(function()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("H2K") then gui:Destroy() end
    end
end)

-- ======================
-- FUNCIONES DE JUEGO
-- ======================

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
        Wood = {"log","wood","timber","branch"},
        Scrap = {"scrap","metal","iron","steel","can","bolt","pipe"},
        Medical = {"medkit","bandage","firstaid","medicine","health"}
    }
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            for _, pat in pairs(patterns[itemType] or {}) do
                if name:find(pat) then
                    table.insert(items, obj)
                    break
                end
            end
        end
    end
    return items
end

-- Spoof para mover objetos invisibles a tu posición
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
                    item.Anchored = false
                    item.CanCollide = false
                    -- Spoof: mover item a campfire
                    if campfire then
                        item.CFrame = campfire.CFrame + Vector3.new(math.random(-3,3),3,math.random(-3,3))
                    end
                end)
                wait(0.05)
            end
        end
    end)
end

-- Kill Aura con spoof
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
                        -- Spoof: Teleport "invisible" del objetivo
                        local fakeCFrame = rootPart.CFrame + Vector3.new(0,0,0) -- se queda en su lugar
                        targetRoot.CFrame = fakeCFrame
                        if tool then tool:Activate() end
                        -- Daño directo
                        targetHuman:TakeDamage(25)
                        -- RemoteEvents
                        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                            if obj:IsA("RemoteEvent") then
                                local name = obj.Name:lower()
                                if name:find("damage") or name:find("hit") or name:find("attack") then
                                    obj:FireServer(targetRoot,50)
                                    obj:FireServer(player.Character,50)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- Noclip
local function toggleNoclip()
    ModState.noclip = not ModState.noclip
    if ModState.noclip then
        Connections.noclip = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.noclip then Connections.noclip:Disconnect() end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- Infinite Jump
local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    if ModState.infiniteJump then
        Connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.infiniteJump then Connections.infiniteJump:Disconnect() end
    end
end

-- Fullbright
local function toggleFullbright()
    ModState.fullbright = not ModState.fullbright
    if ModState.fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
    end
end

-- ESP
local function createESP(player)
    if ESPObjects[player] then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Size = UDim2.new(0,200,0,50)
    esp.StudsOffset = Vector3.new(0,3,0)
    esp.Adornee = character.HumanoidRootPart
    esp.Parent = character.HumanoidRootPart
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1,0,0.5,0)
    name.BackgroundTransparency = 1
    name.Text = player.Name
    name.TextColor3 = Color3.fromRGB(255,255,255)
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.Parent = esp
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1,0,0.5,0)
    distLabel.Position = UDim2.new(0,0,0.5,0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.TextColor3 = Color3.fromRGB(0,255,127)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = esp
    
    ESPObjects[player] = {gui = esp, distance = distLabel}
end

local function toggleESP()
    ModState.esp = not ModState.esp
    if ModState.esp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then createESP(p) end
        end
        Connections.esp = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                wait(1)
                createESP(player)
            end)
        end)
        Connections.espUpdate = RunService.Heartbeat:Connect(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for p,data in pairs(ESPObjects) do
                local tRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and data.distance then
                    local dist = math.floor((myRoot.Position - tRoot.Position).Magnitude)
                    data.distance.Text = dist.." studs"
                end
            end
        end)
    else
        for _, data in pairs(ESPObjects) do
            if data.gui then data.gui:Destroy() end
        end
        ESPObjects = {}
        if Connections.esp then Connections.esp:Disconnect() end
        if Connections.espUpdate then Connections.espUpdate:Disconnect() end
    end
end

-- ======================
-- LOOPS
-- ======================

spawn(function()
    while wait(0.1) do
        performKillAura()
    end
end)

spawn(function()
    while wait() do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = ModState.walkSpeed
        end
    end
end)

-- Auto brings
spawn(function()
    while wait(5) do
        if ModState.autoWood then bringItems("Wood") end
        if ModState.autoScrap then bringItems("Scrap") end
        if ModState.autoMedical then bringItems("Medical") end
    end
end)

print("H2K 99 Nights Forest Mod Menu loaded (Android KRNL Spoof)")