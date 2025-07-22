-- SPY AVANZADO DE REMOTES - PARA DEBUG EN TUS PROPIOS JUEGOS
-- Colocar en StarterPlayerScripts

local rs = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- Configuración
local palabrasClave = {"add", "give", "coins", "damage", "tp", "teleport", "win", "kill", "stats"}
local limiteSpam = 10 -- Llamadas por segundo consideradas sospechosas

local llamadas = {} -- Para contar la frecuencia
local monitoreados = {}

local function contienePalabraClave(arg)
	local s = tostring(arg):lower()
	for _, palabra in pairs(palabrasClave) do
		if string.find(s, palabra) then
			return true
		end
	end
	return false
end

local function esSospechoso(args)
	for _, arg in pairs(args) do
		if typeof(arg) == "number" and arg > 1000 then return true end
		if typeof(arg) == "string" and contienePalabraClave(arg) then return true end
	end
	return false
end

local function log(tag, remote, args)
	local path = remote:GetFullName()
	print("🛰️ [" .. tag .. "] Posible remoto vulnerable detectado: " .. path)

	for i, v in ipairs(args) do
		print("   Arg #" .. i .. ": " .. tostring(v) .. " [" .. typeof(v) .. "]")
	end

	if esSospechoso(args) then
		warn("⚠️  ARGUMENTOS SOSPECHOSOS en " .. path)
	end
end

local function contar(remote)
	local now = tick()
	local key = remote:GetFullName()

	if not llamadas[key] then
		llamadas[key] = {}
	end

	table.insert(llamadas[key], now)

	-- Mantener solo los últimos 1 segundo
	for i = #llamadas[key], 1, -1 do
		if now - llamadas[key][i] > 1 then
			table.remove(llamadas[key], i)
		end
	end

	-- Spam detectado
	if #llamadas[key] > limiteSpam then
		warn("🚨 SPAM DETECTADO: " .. key .. " fue llamado " .. #llamadas[key] .. " veces en 1 segundo")
	end
end

-- Hook RemoteEvent
local function hookEvent(remote)
	if monitoreados[remote] then return end
	monitoreados[remote] = true

	local original = remote.FireServer
	remote.FireServer = function(self, ...)
		local args = {...}
		contar(self)
		if esSospechoso(args) or contienePalabraClave(self.Name) then
			log("RemoteEvent", self, args)
		end
		return original(self, ...)
	end
end

-- Hook RemoteFunction
local function hookFunction(remote)
	if monitoreados[remote] then return end
	monitoreados[remote] = true

	local original = remote.InvokeServer
	remote.InvokeServer = function(self, ...)
		local args = {...}
		contar(self)
		if esSospechoso(args) or contienePalabraClave(self.Name) then
			log("RemoteFunction", self, args)
		end
		return original(self, ...)
	end
end

-- Escanear remotos
local function escanear(obj)
	if obj:IsA("RemoteEvent") then
		hookEvent(obj)
	elseif obj:IsA("RemoteFunction") then
		hookFunction(obj)
	end
end

-- Hook inicial
for _, obj in pairs(rs:GetDescendants()) do
	escanear(obj)
end

-- Nuevos remotos creados después
rs.DescendantAdded:Connect(function(obj)
	task.wait()
	escanear(obj)
end)

print("✅ Spy avanzado activado. Monitoreando remotes sospechosos...")