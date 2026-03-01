-- Conicey Loader - Autofarm/Kill Aura (Identical to base: equip knife + teleport close + spin + click spam)
-- Toggle GUI with K | Autofarm = Kill Aura in KAT/PvP games

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")  -- for simulated clicks
local LocalPlayer = Players.LocalPlayer

local startTime = tick()
local autokillEnabled = false
local webhookUrl = ""
local guiVisible = true

-- Timer
local function getUptime()
    local elapsed = tick() - startTime
    local days = math.floor(elapsed / 86400)
    local hours = math.floor((elapsed % 86400) / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

-- Get stat
local function getStat(statName)
    for _, folder in pairs({LocalPlayer:FindFirstChild("leaderstats"), LocalPlayer:FindFirstChild("Data")}) do
        if folder and folder:FindFirstChild(statName) then
            return tonumber(folder[statName].Value) or 0
        end
    end
    return 0
end

-- Webhook
local function sendWebhook()
    if webhookUrl == "" then return end
    local gems = getStat("Gems") or getStat("Coins") or getStat("Money") or 0
    local level = getStat("Level") or 0
    local embed = {
        embeds = {{
            title = "Conicey Loader Log",
            description = string.format(
                "**Player:** %s\n**Gems/Coins:** %d\n**Level:** %d\n**Uptime:** %s",
                LocalPlayer.Name, gems, level, getUptime()
            ),
            color = 16711680,
            thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png" },
            footer = { text = os.date("%Y-%m-%d %H:%M:%S") }
        }}
    }
    pcall(function()
        local req = syn and syn.request or http and http.request or request or HttpService.PostAsync
        if type(req) == "function" and req ~= HttpService.PostAsync then
            req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embed)})
        else
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(embed))
        end
    end)
    StarterGui:SetCore("SendNotification", {Title = "Conicey Loader", Text = "Log sent!", Duration = 3})
end

-- KILL AURA / AUTOFARM LOOP (exact behavior from base script)
spawn(function()
    while true do
        task.wait(0.01)  -- fast loop like base

        if not autokillEnabled then
            -- Reset when disabled
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
                LocalPlayer.Character.Humanoid.JumpPower = 50
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
            continue
        end

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then
            continue
        end

        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid

        -- Find nearest valid target (simplified from base v51)
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tHum = plr.Character.Humanoid
                local tHrp = plr.Character.HumanoidRootPart
                if tHum.Health > 0 then
                    -- Skip teammates if teams exist
                    if not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team) then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist < minDist and dist < 200 then
                            minDist = dist
                            target = plr
                        end
                    end
                end
            end
        end

        if not target or not target.Character then
            continue
        end

        local targetHrp = target.Character.HumanoidRootPart
        local targetHum = target.Character.Humanoid

        -- Instant equip knife/tool (exact from base)
        local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if tool and tool.Parent ~= char then
            hum:EquipTool(tool)
        end

        -- Teleport close + random spin (IDENTICAL to base teleport + CFrame.Angles spin)
        local offset = CFrame.new(0, -3, -3)  -- very close, like base offset
        local randomSpin = CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        hrp.CFrame = targetHrp.CFrame * offset * randomSpin

        -- Camera lock on target (base does this)
        workspace.CurrentCamera.CameraSubject = targetHum

        -- Aggressive click spam to swing knife (base uses SendMouseButtonEvent spam)
        pcall(function()
            -- Modern VirtualUser simulation (works in most executors)
            VirtualUser:ClickButton1(Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2))
            task.wait(0.005)  -- very fast spam
            VirtualUser:ClickButton1(Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2))
        end)
    end
end)

-- MAIN GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ConiceyLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1000000
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.Enabled = guiVisible

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 400)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
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
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "⚡ Conicey Loader"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextStrokeTransparency = 0.5
title.Parent = mainFrame

-- Autofarm Toggle (now Kill Aura)
local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(0.9, 0, 0, 50)
autofarmBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
autofarmBtn.Text = "💀 Autofarm: OFF"
autofarmBtn.TextColor3 = Color3.new(1,1,1)
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.TextSize = 20
autofarmBtn.Parent = mainFrame

local akCorner = Instance.new("UICorner")
akCorner.CornerRadius = UDim.new(0, 12)
akCorner.Parent = autofarmBtn

autofarmBtn.MouseButton1Click:Connect(function()
    autokillEnabled = not autokillEnabled
    autofarmBtn.Text = "💀 Autofarm: " .. (autokillEnabled and "ON" or "OFF")
    autofarmBtn.BackgroundColor3 = autokillEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = autokillEnabled and "Autofarm ON - Spinning + killing nearest player" or "Autofarm OFF",
        Duration = 3
    })
end)

-- Webhook Input & Send (unchanged)
local webhookLabel = Instance.new("TextLabel")
webhookLabel.Size = UDim2.new(0.9, 0, 0, 30)
webhookLabel.Position = UDim2.new(0.05, 0, 0.38, 0)
webhookLabel.BackgroundTransparency = 1
webhookLabel.Text = "Webhook URL:"
webhookLabel.TextColor3 = Color3.new(1,1,1)
webhookLabel.Font = Enum.Font.Gotham
webhookLabel.TextSize = 16
webhookLabel.Parent = mainFrame

local webhookBox = Instance.new("TextBox")
webhookBox.Size = UDim2.new(0.9, 0, 0, 40)
webhookBox.Position = UDim2.new(0.05, 0, 0.46, 0)
webhookBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
webhookBox.Text = webhookUrl
webhookBox.PlaceholderText = "Paste Discord webhook here..."
webhookBox.TextColor3 = Color3.new(1,1,1)
webhookBox.Font = Enum.Font.Gotham
webhookBox.TextSize = 14
webhookBox.Parent = mainFrame

local wbCorner = Instance.new("UICorner")
wbCorner.CornerRadius = UDim.new(0, 8)
wbCorner.Parent = webhookBox

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0.9, 0, 0, 45)
sendBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
sendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sendBtn.Text = "📤 Send Log Now"
sendBtn.TextColor3 = Color3.new(1,1,1)
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 18
sendBtn.Parent = mainFrame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 12)
sendCorner.Parent = sendBtn

sendBtn.MouseButton1Click:Connect(function()
    webhookUrl = webhookBox.Text:gsub("%s+", "")
    if webhookUrl ~= "" then
        sendWebhook()
    else
        StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Enter webhook URL!", Duration = 3})
    end
end)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 50)
statusLabel.Position = UDim2.new(0.05, 0, 0.78, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 15
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

spawn(function()
    while true do
        if statusLabel.Parent then
            local gems = getStat("Gems") or getStat("Coins") or getStat("Money") or "?"
            local level = getStat("Level") or "?"
            local status = autokillEnabled and "ON" or "OFF"
            statusLabel.Text = string.format("Autofarm: %s\nGems/Coins: %s | Level: %s\nUptime: %s\n\nPress K to toggle GUI", status, gems, level, getUptime())
        end
        task.wait(1)
    end
end)

-- Toggle GUI with K key
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
        StarterGui:SetCore("SendNotification", {
            Title = "Conicey Loader",
            Text = guiVisible and "GUI Shown" or "GUI Hidden",
            Duration = 2
        })
    end
end)

-- Load notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader Loaded!",
    Text = "💀 Autofarm ready (identical to base script)\nPress K to toggle | Toggle ON to spin-kill",
    Duration = 8
})

print("Conicey Loader loaded | Autofarm (kill aura) active - Toggle in GUI")
