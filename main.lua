-- Conicey Loader - Minimal: Autofarm (KAT Kill Aura) + K Toggle GUI
-- Exact stolen from Katt base: knife equip + teleport close + spin + click spam

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local autokillEnabled = false
local guiVisible = true

-- KILL AURA LOOP (exact from Katt base)
spawn(function()
    while true do
        task.wait(0.01)
        if not autokillEnabled then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        -- Nearest target
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
                if not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team) then
                    local dist = (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist and dist < 200 then
                        minDist = dist
                        target = plr
                    end
                end
            end
        end
        
        if not target then continue end
        
        local targetHrp = target.Character.HumanoidRootPart
        local targetHum = target.Character.Humanoid
        
        -- Equip knife/tool
        local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if tool and tool.Parent ~= char then
            hum:EquipTool(tool)
        end
        
        -- Teleport close + random spin (Katt exact)
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, -3, -3) * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        
        -- Camera lock
        workspace.CurrentCamera.CameraSubject = targetHum
        
        -- Click spam (Katt exact)
        pcall(function()
            VirtualUser:ClickButton1(Vector2.new())
        end)
    end
end)

-- GUI (exact working test style)
local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ConiceyLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999999
screenGui.Parent = pg
screenGui.Enabled = guiVisible

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 80)
title.BackgroundTransparency = 1
title.Text = "⚡ Conicey Loader"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextStrokeTransparency = 0.5
title.Parent = mainFrame

-- Autofarm Toggle
local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(0.9, 0, 0, 60)
autofarmBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
autofarmBtn.Text = "💀 Autofarm: OFF"
autofarmBtn.TextColor3 = Color3.new(1,1,1)
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.TextSize = 24
autofarmBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = autofarmBtn

autofarmBtn.MouseButton1Click:Connect(function()
    autokillEnabled = not autokillEnabled
    autofarmBtn.Text = "💀 Autofarm: " .. (autokillEnabled and "ON" or "OFF")
    autofarmBtn.BackgroundColor3 = autokillEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
end)

-- K Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)

-- Load confirm
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader Loaded!",
    Text = "Big GUI in center!\nToggle Autofarm + Press K to hide/show",
    Duration = 8
})
