-- H2K 99 Nights Forest Mod Menu - Android KRNL
-- By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Estado del mod
local ModState = {
    noclip = false,
    infiniteJump = false,
    killAura = false,
    autoWood = false,
    autoScrap = false,
    walkSpeed = 16,
    killAuraRange = 20
}

local Connections = {}

-- Funciones principales
local function findItems(patterns)
    local items = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            for _, pattern in pairs(patterns) do
                if name:find(pattern) then
                    table.insert(items, obj)
                    break
                end
            end
        end
    end
    return items
end

local function bringItems(patterns)
    spawn(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local rootPart = character.HumanoidRootPart
        local items = findItems(patterns)
        for _, item in pairs(items) do
            pcall(function()
                -- Spoof: simular que traes el objeto sin moverte
                local itemCFrame = item.CFrame
                item.CFrame = rootPart.CFrame + Vector3.new(0, 2, 0)
                wait(0.05)
                item.CFrame = itemCFrame -- devolver posición original
            end)
        end
    end)
end

local function performKillAura()
    if not ModState.killAura then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character.HumanoidRootPart
            local distance = (rootPart.Position - target.Position).Magnitude
            if distance <= ModState.killAuraRange then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    pcall(function()
                        humanoid:TakeDamage(25)
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
    end
end

-- Infinite Jump
local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    if ModState.infiniteJump then
        Connections.jump = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.jump then Connections.jump:Disconnect() end
    end
end

-- Speed loop
spawn(function()
    while wait() do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = ModState.walkSpeed
        end
    end
end)

-- Kill Aura loop
spawn(function()
    while wait(0.1) do
        performKillAura()
    end
end)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "H2K_99Nights"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 400)
frame.Position = UDim2.new(0.5, -175, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

-- Logo H2K
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 50)
logo.Position = UDim2.new(0,0,0,0)
logo.BackgroundTransparency = 1
logo.Text = "H2K"
logo.TextColor3 = Color3.fromRGB(0,255,127)
logo.TextScaled = true
logo.Font = Enum.Font.GothamBold
logo.Parent = frame

-- Botones
local function createBtn(text,pos,callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,150,0,35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50,50,100)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Noclip
createBtn("NOCLIP", UDim2.new(0,20,0,60), function()
    toggleNoclip()
end)

-- Infinite Jump
createBtn("INF JUMP", UDim2.new(0,180,0,60), function()
    toggleInfiniteJump()
end)

-- Bring Logs
createBtn("BRING LOGS", UDim2.new(0,20,0,110), function()
    bringItems({"log","wood","branch"})
end)

-- Bring Scrap
createBtn("BRING SCRAP", UDim2.new(0,180,0,110), function()
    bringItems({"scrap","metal","iron"})
end)

-- Kill Aura
createBtn("KILL AURA", UDim2.new(0,20,0,160), function()
    ModState.killAura = not ModState.killAura
end)

-- Speed control
createBtn("SPEED +10", UDim2.new(0,20,0,210), function()
    ModState.walkSpeed = ModState.walkSpeed + 10
end)
createBtn("SPEED -10", UDim2.new(0,180,0,210), function()
    ModState.walkSpeed = math.max(16, ModState.walkSpeed -10)
end)

print("H2K 99 Nights Forest Mod Menu Loaded for Android KRNL")