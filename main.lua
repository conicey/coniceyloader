-- Conicey Loader - Autofarm + Webhook (Works in PlayerGui, Instant Load)
-- Toggle GUI with K key | Autofarm collects nearest coins/gems/orbs/drops

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local startTime = tick()
local autofarmEnabled = false
local webhookUrl = ""  -- Paste your Discord webhook here or use GUI input
local guiVisible = true   -- starts visible

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
            color = 16711680,
            thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png" },
            footer = { text = os.date("%Y-%m-%d %H:%M:%S") }
        }}
    }
    pcall(function()
        local req = syn and syn.request or http and http.request or request or HttpService.PostAsync
        if req == HttpService.PostAsync then
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(embed))
        else
            req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embed)})
        end
    end)
    StarterGui:SetCore("SendNotification", {Title = "Conicey Loader", Text = "Log sent!", Duration = 3})
end

-- Improved Autofarm (collect nearest collectible)
spawn(function()
    while true do
        if autofarmEnabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local nearest, minDist = nil, 80  -- increased range a bit
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        local nameLower = v.Name:lower()
                        if nameLower:find("coin") or nameLower:find("gem") or nameLower:find("orb") or nameLower:find("drop") or nameLower:find("collect") then
                            local dist = (hrp.Position - v.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                nearest = v
                            end
                        end
                    end
                end
                if nearest then
                    hrp.CFrame = nearest.CFrame * CFrame.new(0, 4, 0)  -- slightly higher to avoid clipping
                    -- Fire touch interest if exists (helps in some games)
                    if nearest:FindFirstChildOfClass("TouchInterest") then
                        firetouchinterest(hrp, nearest, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, nearest, 1)
                    end
                end
            end
        end
        task.wait(0.12)  -- smoother, less laggy than Heartbeat for farming
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

-- Autofarm Toggle
local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Size = UDim2.new(0.9, 0, 0, 50)
autofarmBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
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
    autofarmBtn.BackgroundColor3 = autofarmEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 0, 0)
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = autofarmEnabled and "Autofarm Enabled" or "Autofarm Disabled",
        Duration = 2.5
    })
end)

-- Webhook section
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
        StarterGui:SetCore("SendNotification", {Title = "Conicey Loader", Text = "Enter a webhook URL first", Duration = 4})
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
            statusLabel.Text = string.format("Gems/Coins: %s\nLevel: %s\nUptime: %s\n\nPress K to hide/show", gems, level, getUptime())
        end
        task.wait(1.5)
    end
end)

-- Toggle GUI with K key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
        StarterGui:SetCore("SendNotification", {
            Title = "Conicey Loader",
            Text = guiVisible and "GUI Shown (K to hide)" or "GUI Hidden (K to show)",
            Duration = 2
        })
    end
end)

-- Initial notification
StarterGui:SetCore("SendNotification", {
    Title = "⚡ Conicey Loader Loaded!",
    Text = "Press K to toggle GUI\nAutofarm + Webhook ready",
    Duration = 7
})

print("Conicey Loader loaded | Press K to toggle GUI")
