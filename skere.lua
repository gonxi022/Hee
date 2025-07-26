-- Servicios necesarios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ModMenu"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Crear función para hacer botones
local function createButton(name, position, text)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 200, 0, 40)
	btn.Position = position
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	btn.Parent = gui
	return btn
end

-- Botones
local godBtn = createButton("GodModeBtn", UDim2.new(0, 20, 0, 100), "GodMode: OFF")
local dmgBtn = createButton("DamageBtn", UDim2.new(0, 20, 0, 150), "Daño Letal: OFF")
local disarmBtn = createButton("DesarmarBtn", UDim2.new(0, 20, 0, 200), "Desarmar Enemigos")

-- Variables de control
local godMode = false
local dañoLetal = false
local conectado = false

-- GodMode activador
godBtn.MouseButton1Click:Connect(function()
	godMode = not godMode
	godBtn.Text = "GodMode: " .. (godMode and "ON" or "OFF")

	if godMode then
		if LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
			if hum then
				hum.MaxHealth = math.huge
				hum.Health = math.huge
			end
		end

		LocalPlayer.CharacterAdded:Connect(function(char)
			local hum = char:WaitForChild("Humanoid")
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end)
	end
end)

-- Daño letal activador
dmgBtn.MouseButton1Click:Connect(function()
	dañoLetal = not dañoLetal
	dmgBtn.Text = "Daño Letal: " .. (dañoLetal and "ON" or "OFF")

	if dañoLetal and not conectado then
		conectado = true
		RunService.RenderStepped:Connect(function()
			for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
				if tool:FindFirstChild("Handle") then
					local handle = tool.Handle
					handle.Touched:Connect(function(hit)
						local enemy = hit.Parent:FindFirstChild("Humanoid")
						if enemy and hit.Parent ~= LocalPlayer.Character then
							enemy:TakeDamage(9999)
						end
					end)
				end
			end
		end)
	end
end)

-- Desarmar enemigos al instante
disarmBtn.MouseButton1Click:Connect(function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			pcall(function()
				for _, item in pairs(plr.Backpack:GetChildren()) do
					item:Destroy()
				end
			end)
		end
	end
end)