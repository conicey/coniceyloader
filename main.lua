-- Conicey Loader - Autofarm (KAT Kill Aura: STRAFE CIRCLE + Smart Hit Detection)
-- K = toggle menu visibility | L = toggle autofarm
-- Added small red X button (top-right) → fully closes/destroys the script & GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local autofarmEnabled = false
local guiVisible = true

-- Target tracking for hit detection
local targets = {}  -- {player = {lastHealth=100, attacks=0, skipUntil=0}}

local function updateTargetHealth(plr)
    if not targets[plr] then
        targets[plr] = {lastHealth = plr.Character.Humanoid.Health, attacks = 0, skipUntil = 0}
    end
    local data = targets[plr]
    local currentHealth = plr.Character.Humanoid.Health
    if currentHealth < data.lastHealth then
        data.attacks = 0
    else
        data.attacks = data.attacks + 1
    end
    data.lastHealth = currentHealth
end

local function isHittable(plr)
    if not targets[plr] then return true end
    local data = targets[plr]
    local now = tick()
    if data.skipUntil > now then return false end
    if data.attacks >= 8 then
        data.skipUntil = now + math.random(2, 5)
        return false
    end
    return true
end

-- STRAFE KILL AURA LOOP
spawn(function()
    while true do
        task.wait(0.008)
        
        if not autofarmEnabled then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        hum.WalkSpeed = 85
        hum.JumpPower = 110
        
        -- Find best hittable target
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tHum = plr.Character.Humanoid
                local tHrp = plr.Character.HumanoidRootPart
                if tHum.Health > 0.1 and isHittable(plr) then
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
        
        if not target then continue end
        
        local targetHrp = target.Character.HumanoidRootPart
        local targetHum = target.Character.Humanoid
        
        updateTargetHealth(target)
        
        -- Knife equip
        local knifeNames = {"Knife", "knife", "Default Knife", "KAT Knife", "Classic Knife", "Tool"}
        local knife = nil
        for _, name in ipairs(knifeNames) do
            knife = char:FindFirstChild(name) or LocalPlayer.Backpack:FindFirstChild(name)
            if knife then break end
        end
        knife = knife or char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if knife and knife.Parent ~= char then
            hum:EquipTool(knife)
        end
        
        -- STRAFE CIRCLE
        local strafeDist = 10
        local strafeSpeed = 4
        local angle = (tick() * strafeSpeed) % (math.pi * 2)
        local strafeOffset = Vector3.new(math.cos(angle) * strafeDist, 0, math.sin(angle) * strafeDist)
        local strafePos = targetHrp.Position + strafeOffset
        
        local faceCFrame = CFrame.lookAt(strafePos, targetHrp.Position + Vector3.new(0, 2, 0))
        local tiltSpin = CFrame.Angles(math.rad(math.sin(angle * 2) * 10), math.rad(math.random(-20, 20)), 0)
        
        hrp.CFrame = faceCFrame * tiltSpin
        
        workspace.CurrentCamera.CameraSubject = targetHum
        
        -- Click spam
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.004)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.003)
        end)
        
        -- Touch
        pcall(firetouchinterest, hrp, targetHrp, 0)
        task.wait(0.006)
        pcall(firetouchinterest, hrp, targetHrp, 1)
    end
end)

-- GUI
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

-- Autofarm Toggle Button
local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(0.9, 0, 0, 60)
autofarmBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
autofarmBtn.Text = "💀 Autofarm: OFF (L Key)"
autofarmBtn.TextColor3 = Color3.new(1,1,1)
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.TextSize = 20
autofarmBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = autofarmBtn

-- RED X BUTTON - top right - FULLY CLOSES SCRIPT
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    -- Fully destroy GUI and stop script
    screenGui:Destroy()
    -- Optional: clear variables or disconnect loops if needed
    autofarmEnabled = false
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = "Script closed (X button)",
        Duration = 4
    })
end)

-- Controls: K = menu toggle | L = autofarm toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    elseif input.KeyCode == Enum.KeyCode.L then
        autofarmEnabled = not autofarmEnabled
        autofarmBtn.Text = "💀 Autofarm: " .. (autofarmEnabled and "ON" or "OFF") .. " (L Key)"
        autofarmBtn.BackgroundColor3 = autofarmEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
        StarterGui:SetCore("SendNotification", {
            Title = "Autofarm",
            Text = autofarmEnabled and "ON - Strafing + killing" or "OFF",
            Duration = 2
        })
    end
end)

-- Load notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader",
    Text = "K = menu | L = autofarm toggle\nRed X = close script fully",
    Duration = 8
})
