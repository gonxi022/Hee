-- Remote Spy Básico (solo cliente)
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" or method == "InvokeServer" then
        print("📡 Remote detectado:", self:GetFullName())
        print("🧪 Método:", method)
        print("📦 Args:", unpack(args))
    end
    
    return oldNamecall(self, ...)
end)

print("✅ Remote Spy activado. Haz clic en el juego y mira la consola.")