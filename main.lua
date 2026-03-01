-- Conicey Loader - Autofarm (KAT Kill Aura: Spinbot Underneath + Spam Hit)
-- K = toggle menu | L = toggle autofarm | Red X = fully close script
-- + ALWAYS ACTIVE STAFF DETECTOR (disables cheats on detection - no serverhop)
-- FIXED: Huge range, ONLY TELEPORT (no speed/jump), spin underneath + spam hit

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local autofarmEnabled = false
local guiVisible = true

-- ════════════════════════════════════════════════════════════════════════
-- STAFF DETECTOR (EXACT KATT Hub logic - disables cheats on detection)
-- ════════════════════════════════════════════════════════════════════════

local STAFF_GROUP_ID = 0          -- ← CHANGE THIS to your group ID if you want rank check (0 = disabled)
local MIN_STAFF_RANK = 100        -- rank threshold

local STAFF_KEYWORDS = {
    "admin", "mod", "owner", "dev", "developer", "staff", "moderator",
    "roblox", "official", "team", "support", "creator"
}

local function isStaff(player)
    if player == LocalPlayer then return false end

    if player.UserId == game.CreatorId then
        return true, "Game Creator / Owner"
    end

    if STAFF_GROUP_ID > 0 then
        local success, rank = pcall(function()
            return player:GetRankInGroup(STAFF_GROUP_ID)
        end)
        if success and rank >= MIN_STAFF_RANK then
            return true, "Group Rank " .. rank .. "+"
        end
    end

    local nameLower = player.Name:lower()
    local displayLower = player.DisplayName:lower()
    for _, keyword in ipairs(STAFF_KEYWORDS) do
        if nameLower:find(keyword) or displayLower:find(keyword) then
            return true, "Name pattern: " .. keyword
        end
    end

    return false
end

local function notifyAndDisableStaff(player, reason)
    local msg = "STAFF DETECTED: " .. player.Name .. " (" .. player.UserId .. ")\nReason: " .. reason .. "\nAll cheats DISABLED!"

    print("[STAFF DETECTED] " .. msg)

    StarterGui:SetCore("SendNotification", {
        Title = "⚠️ STAFF / ADMIN JOINED ⚠️",
        Text = msg .. "\nCheats auto-disabled.",
        Duration = 25,
        Icon = "rbxassetid://7072721039"
    })

    autofarmEnabled = false
end

Players.PlayerAdded:Connect(function(player)
    task.wait(1.5)
    local isStaffBool, reason = isStaff(player)
    if isStaffBool then
        notifyAndDisableStaff(player, reason)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        task.spawn(function()
            task.wait(2)
            local isStaffBool, reason = isStaff(player)
            if isStaffBool then
                notifyAndDisableStaff(player, reason)
            end
        end)
    end
end

-- ════════════════════════════════════════════════════════════════════════
-- AUTOFARM: HUGE range, ONLY TELEPORT, spinbot underneath + spam hit
-- ════════════════════════════════════════════════════════════════════════

spawn(function()
    while true do
        task.wait(0.01)
        
        if not autofarmEnabled then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        -- Find nearest target (HUGE range - 1000 studs)
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tHum = plr.Character.Humanoid
                local tHrp = plr.Character.HumanoidRootPart
                if tHum.Health > 0.1 then
                    if not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team) then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist < minDist and dist < 1000 then
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
        
        -- ONLY TELEPORT: underneath + spinbot
        local offset = CFrame.new(0, -3, -3)
        local spin = CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        hrp.CFrame = targetHrp.CFrame * offset * spin
        
        -- Camera lock
        workspace.CurrentCamera.CameraSubject = targetHum
        
        -- Spam hitting
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.005)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
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

-- RED X BUTTON - top right - FULL CLOSE
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
    screenGui:Destroy()
    autofarmEnabled = false
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = "Script fully closed",
        Duration = 4
    })
end)

-- Controls
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
            Text = autofarmEnabled and "ON - Spinbot underneath + spam hit" or "OFF",
            Duration = 2
        })
    end
end)

-- Load notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader",
    Text = "K = menu | L = autofarm | Red X = close\nStaff detector active (disables cheats)",
    Duration = 8
})
```<|control12|>```lua
-- Conicey Loader - Autofarm (KAT Kill Aura: Spinbot Underneath + Spam Hit)
-- K = toggle menu | L = toggle autofarm | Red X = fully close script
-- + ALWAYS ACTIVE STAFF DETECTOR (disables cheats on detection - no serverhop)
-- FIXED: ALWAYS strafe circle + ALWAYS look at target

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local autofarmEnabled = false
local guiVisible = true

-- ════════════════════════════════════════════════════════════════════════
-- STAFF DETECTOR (EXACT KATT Hub logic - disables cheats on detection)
-- ════════════════════════════════════════════════════════════════════════

local STAFF_GROUP_ID = 0          -- ← CHANGE THIS to your group ID if you want rank check (0 = disabled)
local MIN_STAFF_RANK = 100        -- rank threshold

local STAFF_KEYWORDS = {
    "admin", "mod", "owner", "dev", "developer", "staff", "moderator",
    "roblox", "official", "team", "support", "creator"
}

local function isStaff(player)
    if player == LocalPlayer then return false end

    if player.UserId == game.CreatorId then
        return true, "Game Creator / Owner"
    end

    if STAFF_GROUP_ID > 0 then
        local success, rank = pcall(function()
            return player:GetRankInGroup(STAFF_GROUP_ID)
        end)
        if success and rank >= MIN_STAFF_RANK then
            return true, "Group Rank " .. rank .. "+"
        end
    end

    local nameLower = player.Name:lower()
    local displayLower = player.DisplayName:lower()
    for _, keyword in ipairs(STAFF_KEYWORDS) do
        if nameLower:find(keyword) or displayLower:find(keyword) then
            return true, "Name pattern: " .. keyword
        end
    end

    return false
end

local function notifyAndDisableStaff(player, reason)
    local msg = "STAFF DETECTED: " .. player.Name .. " (" .. player.UserId .. ")\nReason: " .. reason .. "\nAll cheats DISABLED!"

    print("[STAFF DETECTED] " .. msg)

    StarterGui:SetCore("SendNotification", {
        Title = "⚠️ STAFF / ADMIN JOINED ⚠️",
        Text = msg .. "\nCheats auto-disabled.",
        Duration = 25,
        Icon = "rbxassetid://7072721039"
    })

    autofarmEnabled = false
end

Players.PlayerAdded:Connect(function(player)
    task.wait(1.5)
    local isStaffBool, reason = isStaff(player)
    if isStaffBool then
        notifyAndDisableStaff(player, reason)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        task.spawn(function()
            task.wait(2)
            local isStaffBool, reason = isStaff(player)
            if isStaffBool then
                notifyAndDisableStaff(player, reason)
            end
        end)
    end
end

-- ════════════════════════════════════════════════════════════════════════
-- AUTOFARM: ALWAYS strafe circle + ALWAYS look at target + spin underneath
-- ════════════════════════════════════════════════════════════════════════

spawn(function()
    while true do
        task.wait(0.01)
        
        if not autofarmEnabled then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        -- Find nearest target
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tHum = plr.Character.Humanoid
                local tHrp = plr.Character.HumanoidRootPart
                if tHum.Health > 0.1 then
                    if not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team) then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist < minDist and dist < 1000 then  -- huge range
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
        
        -- ALWAYS STRAFE CIRCLE (underneath level, tight radius)
        local strafeDist = 3.5  -- tight for contact
        local strafeSpeed = 5   -- smooth speed
        local angle = (tick() * strafeSpeed) % (math.pi * 2)
        local strafeOffset = Vector3.new(math.cos(angle) * strafeDist, -3, math.sin(angle) * strafeDist)  -- underneath height
        
        local strafePos = targetHrp.Position + strafeOffset
        
        -- ALWAYS LOOK AT TARGET (knife contact)
        local faceCFrame = CFrame.lookAt(strafePos, targetHrp.Position)
        local spin = CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)  -- KATT spin
        
        hrp.CFrame = faceCFrame * spin
        
        -- Camera lock
        workspace.CurrentCamera.CameraSubject = targetHum
        
        -- Spam hitting
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.005)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        
        -- Touch interest
        pcall(firetouchinterest, hrp, targetHrp, 0)
        task.wait(0.005)
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

-- RED X BUTTON - top right - FULL CLOSE
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
    screenGui:Destroy()
    autofarmEnabled = false
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = "Script fully closed",
        Duration = 4
    })
end)

-- Controls
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
            Text = autofarmEnabled and "ON - Constant strafe + always facing" or "OFF",
            Duration = 2
        })
    end
end)

-- Load notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader",
    Text = "K = menu | L = autofarm | Red X = close\nStaff detector active (disables cheats)",
    Duration = 8
})
