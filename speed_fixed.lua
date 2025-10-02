-- Client-side Speed GUI (request-only)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local req = ReplicatedStorage:WaitForChild("Speed_RequestSet")
local upd = ReplicatedStorage:WaitForChild("SpeedGUI_Update")

-- GUI setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "SpeedGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0.5,-100,0.5,-60)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

local title = Instance.new("TextLabel", frame)
title.Text = "Speed Controller"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0,80,0,30)
speedBox.Position = UDim2.new(0,10,0,50)
speedBox.Text = "16"

local setButton = Instance.new("TextButton", frame)
setButton.Text = "Set Speed"
setButton.Size = UDim2.new(0,80,0,30)
setButton.Position = UDim2.new(0,110,0,50)

-- State
local allowed = false
local minSpeed, maxSpeed = 8, 100

upd.OnClientEvent:Connect(function(isAllowed, param1, param2, param3)
    if type(isAllowed) == "boolean" then
        allowed = isAllowed
        if type(param1) == "number" and (param2 == nil) then
            speedBox.Text = tostring(param1)
        else
            if type(param1) == "number" then minSpeed = param1 end
            if type(param2) == "number" then maxSpeed = param2 end
        end
    end
end)

setButton.MouseButton1Click:Connect(function()
    if not allowed then
        warn("Server belum mengizinkan penggunaan speed GUI.")
        return
    end
    local num = tonumber(speedBox.Text)
    if not num then
        warn("Masukkan angka valid.")
        return
    end
    req:FireServer(num)
end)
