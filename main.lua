-- Conicey Loader - Autokill + Webhook (KAT Kill Aura: Teleports to nearest player)
-- Toggle GUI with K | 💀 Autokill: Kills nearest enemy automatically
-- Works in Knife Ability Test (KAT) & similar PvP games

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local startTime = tick()
local autokillEnabled = false
local webhookUrl = ""
local guiVisible = true

-- Speed/Jump boost vars
local defaultSpeed = 16
local defaultJump = 50
local killSpeed = 80
local killJump = 100

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

-- 💀 AUTOKILL / KILL AURA LOOP (for KAT/PvP)
spawn(function()
    while true do
        task.wait(0.1)  -- Fast but not laggy
        if autokillEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hum = char.Humanoid
                local hrp = char.HumanoidRootPart
                
                -- Boost speed/jump
                hum.WalkSpeed = killSpeed
                hum.JumpPower = killJump
                
                -- Find nearest enemy
                local closestPlayer = nil
                local shortestDist = math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHum = player.Character.Humanoid
                        local targetHRP = player.Character.HumanoidRootPart
                        if targetHum.Health > 0 then  -- Alive
                            -- Skip same team if teams exist
                            if not (LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team) then
                                local dist = (hrp.Position - targetHRP.Position).Magnitude
                                if dist < shortestDist and dist < 150 then  -- 150 stud range
                                    shortestDist = dist
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
                
                -- Teleport & kill
                if closestPlayer then
                    local targetHRP = closestPlayer.Character.HumanoidRootPart
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(math.random(-2,2)*0.5, 2, math.random(-3,3)*0.5)  -- Offset to slash from above/behind
                    -- Optional firetouch if part has it
                    pcall(firetouchinterest, hrp, targetHRP, 0)
                    task.wait(0.05)
                    pcall(firetouchinterest, hrp, targetHRP, 1)
                end
            end
        else
            -- Reset speed/jump when off
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = defaultSpeed
                char.Humanoid.JumpPower = defaultJump
            end
        end
    end
end)

-- GUI (same as before, but Autokill button)
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

-- Autokill Toggle
local autokillBtn = Instance.new("TextButton")
autokillBtn.Size = UDim2.new(0.9, 0, 0, 50)
autokillBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
autokillBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
autokillBtn.Text = "💀 Autokill: OFF"
autokillBtn.TextColor3 = Color3.new(1,1,1)
autokillBtn.Font = Enum.Font.GothamBold
autokillBtn.TextSize = 20
autokillBtn.Parent = mainFrame

local akCorner = Instance.new("UICorner")
akCorner.CornerRadius = UDim.new(0, 12)
akCorner.Parent = autokillBtn

autokillBtn.MouseButton1Click:Connect(function()
    autokillEnabled = not autokillEnabled
    autokillBtn.Text = "💀 Autokill: " .. (autokillEnabled and "ON" or "OFF")
    autokillBtn.BackgroundColor3 = autokillEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = autokillEnabled and "Autokill ON - You'll teleport to nearest players!" or "Autokill OFF",
        Duration = 3
    })
end)

-- Webhook (same)
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

-- Status
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
            statusLabel.Text = string.format("Autokill: %s\nGems/Coins: %s | Level: %s\nUptime: %s\n\nPress K to toggle GUI", status, gems, level, getUptime())
        end
        task.wait(1)
    end
end)

-- K Toggle
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
    Text = "💀 Autokill ready for KAT!\nPress K to toggle | Toggle ON to kill aura",
    Duration = 8
})

print("Conicey Loader | Autokill active - Toggle with GUI button!")
