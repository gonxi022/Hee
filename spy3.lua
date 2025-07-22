-- 📡 Remote Spy - Solo Espía, no modifica
local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Solo detectar eventos enviados al servidor
    if method == "FireServer" or method == "InvokeServer" then
        if typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
            warn("📡 Remote detectado:", self:GetFullName())
            print("🛠 Método:", method)

            for i, v in ipairs(args) do
                print("   ➤ Arg #" .. i .. ":", typeof(v), "|", tostring(v))
            end
        end
    end

    return old(self, ...)
end)

print("✅ Remote Spy activo. Tocá botones o hacé clicks en el juego para ver los remotes.")