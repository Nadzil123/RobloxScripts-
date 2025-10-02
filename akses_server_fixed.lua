-- Server-side akses dan pengaturan speed (diperkuat)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ganti ke table UserId (angka) bukan player.Name
local aksesUser = {
    [12345678] = true, -- contoh UserId
    -- [98765432] = true,
}

-- RemoteEvents: satu untuk request dari client, satu untuk update dari server
local req = Instance.new("RemoteEvent")
req.Name = "Speed_RequestSet"
req.Parent = ReplicatedStorage

local upd = Instance.new("RemoteEvent")
upd.Name = "SpeedGUI_Update"
upd.Parent = ReplicatedStorage

-- Rate limit table sederhana
local lastRequest = {}

local MIN_SPEED = 8
local MAX_SPEED = 100
local COOLDOWN = 2 -- detik

Players.PlayerAdded:Connect(function(player)
    local allowed = aksesUser[player.UserId] == true
    upd:FireClient(player, allowed, MIN_SPEED, MAX_SPEED)
end)

req.OnServerEvent:Connect(function(player, requestedSpeed)
    if not aksesUser[player.UserId] then
        warn(("Unauthorized speed request by %s (UserId=%s)"):format(player.Name, player.UserId))
        return
    end

    if typeof(requestedSpeed) ~= "number" then
        warn(("Invalid speed type from %s"):format(player.Name))
        return
    end

    -- rate limit
    local now = tick()
    if lastRequest[player.UserId] and (now - lastRequest[player.UserId] < COOLDOWN) then
        warn(("Rate limited speed request from %s"):format(player.Name))
        return
    end
    lastRequest[player.UserId] = now

    -- clamp to range
    local newSpeed = math.clamp(math.floor(requestedSpeed), MIN_SPEED, MAX_SPEED)

    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = newSpeed
            upd:FireClient(player, true, newSpeed, MIN_SPEED, MAX_SPEED)
            return
        end
    end

    warn(("Failed to set WalkSpeed for %s"):format(player.Name))
end)
