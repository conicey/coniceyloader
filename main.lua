-- Conicey Loader - Autofarm + Webhook (Works in PlayerGui, Instant Load)
-- For games with collectibles (Coins/Gems/Orbs) in Workspace + leaderstats Gems/Coins/Level
-- Toggle Autofarm: Teleports & collects nearest items automatically
-- Webhook: Logs username, gems/coins, level, uptime to Discord

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local startTime = tick()
local autofarmEnabled = false
local webhookUrl = ""  -- Paste your Discord webhook here or use GUI input

-- Timer function
local function getUptime()
    local elapsed = tick() - startTime
    local days = math.floor(elapsed / 86400)
    local hours = math.floor((elapsed % 86400) / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

-- Get stat from leaderstats or Data
local function getStat(statName)
    for _, folder in pairs({LocalPlayer:FindFirstChild("leaderstats"), LocalPlayer:FindFirstChild("Data")}) do
        if folder and folder:FindFirstChild(statName) then
            return tonumber(folder[statName].Value) or 0
        end
    end
    return 0
end

-- Send Discord webhook log
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
            color = 16711680,  -- Red
            thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png" },
            footer = { text = os.date("%Y-%m-%d %H:%M:%S") }
        }}
    }
    local success = pcall(function()
        if syn and syn.request then
            syn.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embed)
            })
        elseif http and http.request then
            http.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embed)
            })
        else
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(embed))
        end
    end)
    if success then
        StarterGui:SetCore("SendNotification", {Title = "Conicey Loader", Text = "Log sent!", Duration = 3})
    end
end

-- AUTOFARM LOOP (Collects nearest Coins/Gems/Orbs by teleporting & touching)
spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if autofarmEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local nearest = nil
                local shortestDist = math.huge
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("orb") or obj.Name:lower():find("collect")) then
                        local dist = (hrp.Position - obj.Position).Magnitude
                        if dist < shortestDist and dist < 50 then  -- Within 50 studs
                            shortestDist = dist
                            nearest = obj
                        end
                    end
                end
                if nearest then
                    hrp.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)  -- Teleport above
                end
            end
        end
    end
end)

-- MAIN GUI (BIG, BRIGHT, in PlayerGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ConiceyLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1000000
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
title.Text = "⚡ Conicey Loader - Loaded!"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextStrokeTransparency = 0.5
title.Parent = mainFrame

-- Autofarm Toggle
local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(0.9, 0, 0, 50)
autofarmBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
autofarmBtn.Text = "🚀 Autofarm: OFF"
autofarmBtn.TextColor3 = Color3.new(1,1,1)
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.TextSize = 20
autofarmBtn.Parent = mainFrame

local afCorner = Instance.new("UICorner")
afCorner.CornerRadius = UDim.new(0, 12)
afCorner.Parent = autofarmBtn

autofarmBtn.MouseButton1Click:Connect(function()
    autofarmEnabled = not autofarmEnabled
    autofarmBtn.Text = "🚀 Autofarm: " .. (autofarmEnabled and "ON" or "OFF")
    autofarmBtn.BackgroundColor3 = autofarmEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = autofarmEnabled and "Autofarm Enabled!" or "Autofarm Disabled!",
        Duration = 2
    })
end)

-- Webhook Input & Send
local webhookLabel = Instance.new("TextLabel")
webhookLabel.Size = UDim2.new(0.9, 0, 0, 30)
webhookLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
webhookLabel.BackgroundTransparency = 1
webhookLabel.Text = "Webhook URL:"
webhookLabel.TextColor3 = Color3.new(1,1,1)
webhookLabel.Font = Enum.Font.Gotham
webhookLabel.TextSize = 16
webhookLabel.Parent = mainFrame

local webhookBox = Instance.new("TextBox")
webhookBox.Size = UDim2.new(0.9, 0, 0, 40)
webhookBox.Position = UDim2.new(0.05, 0, 0.48, 0)
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
sendBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
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
    webhookUrl = webhookBox.Text:gsub(" ", "")
    sendWebhook()
end)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.4, 0, 0, 40)
closeBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "❌ Close"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Status Label (updates gems/level/uptime)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)  -- Below close
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

spawn(function()
    while statusLabel.Parent do
        local gems = getStat("Gems") or getStat("Coins") or getStat("Money") or 0
        local level = getStat("Level") or 0
        statusLabel.Text = string.format("Gems: %d | Level: %d | Uptime: %s", gems, level, getUptime())
        task.wait(1)
    end
end)

-- Confirmation Notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader Loaded!",
    Text = "GUI ready in center of screen!\nToggle Autofarm + set Webhook.\nWorks in most simulators!",
    Duration = 8
})

print("Conicey Loader loaded - Autofarm & Webhook active!")
