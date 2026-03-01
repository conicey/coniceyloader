-- Conicey Loader - Autofarm (KAT Kill Aura) + K = toggle menu, L = toggle autofarm

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local autofarmEnabled = false
local guiVisible = true

-- IMPROVED KILL AURA LOOP
spawn(function()
    while true do
        task.wait(0.008)  -- slightly faster, still stable
        
        if not autofarmEnabled then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        hum.WalkSpeed = 85
        hum.JumpPower = 110
        
        -- Find nearest alive target (skip team)
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tHum = plr.Character.Humanoid
                local tHrp = plr.Character.HumanoidRootPart
                if tHum.Health > 0.1 then
                    if not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team) then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist < minDist and dist < 220 then
                            minDist = dist
                            target = plr
                        end
                    end
                end
            end
        end
        
        if not target or not target.Character then continue end
        
        local targetHrp = target.Character.HumanoidRootPart
        local targetHum = target.Character.Humanoid
        
        -- Better knife equip (more names checked)
        local knifeNames = {"Knife", "knife", "Default Knife", "KAT Knife", "Classic Knife"}
        local knife = nil
        for _, name in ipairs(knifeNames) do
            knife = char:FindFirstChild(name) or LocalPlayer.Backpack:FindFirstChild(name)
            if knife then break end
        end
        knife = knife or char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if knife and knife.Parent ~= char then
            hum:EquipTool(knife)
        end
        
        -- Improved teleport: small prediction + varied spin
        local lookVector = targetHrp.CFrame.LookVector * 1.8   -- slight prediction forward
        local offset = CFrame.new(0, -2.8, -2.8) + lookVector
        local spin = CFrame.Angles(0, math.rad(math.random(-220, 220)), math.rad(math.random(-15, 15)))
        hrp.CFrame = targetHrp.CFrame * offset * spin
        
        -- Camera lock
        workspace.CurrentCamera.CameraSubject = targetHum
        
        -- Faster & more reliable click spam
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)   -- press left
            task.wait(0.004)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)  -- release
            task.wait(0.003)
        end)
        
        -- Extra touch interest (helps in some cases)
        pcall(firetouchinterest, hrp, targetHrp, 0)
        task.wait(0.006)
        pcall(firetouchinterest, hrp, targetHrp, 1)
    end
end)

-- GUI (same working style)
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
    autofarmEnabled = not autofarmEnabled
    autofarmBtn.Text = "💀 Autofarm: " .. (autofarmEnabled and "ON" or "OFF")
    autofarmBtn.BackgroundColor3 = autofarmEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
end)

-- K = toggle menu visibility
-- L = toggle autofarm
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    elseif input.KeyCode == Enum.KeyCode.L then
        autofarmEnabled = not autofarmEnabled
        autofarmBtn.Text = "💀 Autofarm: " .. (autofarmEnabled and "ON" or "OFF")
        autofarmBtn.BackgroundColor3 = autofarmEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    end
end)

-- Load notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader",
    Text = "Menu: K to show/hide\nAutofarm: L to toggle\n(Improved killing)",
    Duration = 8
})
