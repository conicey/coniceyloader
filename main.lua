-- ────────────────────────────────────────────────
-- Katt Hub - No key system, opens GUI directly
-- ────────────────────────────────────────────────

local string_char   = string.char
local string_byte   = string.byte
local string_sub    = string.sub
local bit           = bit32 or bit
local bxor          = bit.bxor
local tconcat       = table.concat
local tinsert       = table.insert

-- Your string XOR decrypt function (still used in many places)
local function xor_decrypt(str, key)
    local result = {}
    for i = 1, #str do
        tinsert(result, string_char(
            bxor(
                string_byte(string_sub(str, i, i)),
                string_byte(string_sub(key, 1 + ((i-1) % #key), 1 + ((i-1) % #key)))
            ) % 256
        ))
    end
    return tconcat(result)
end

-- Services (decrypted)
local HttpService     = game:GetService(xor_decrypt("\19\193\43\220\249\49\222", "\156\67\173\74\165"))
local Players         = game:GetService(xor_decrypt("\6\162\71\37\185\52\80\61\180\76", "\38\84\215\41\118\220\70"))
local RunService      = game:GetService(xor_decrypt("\103\25\48\25\237\64\23\33\23", "\158\48\118\66\114"))
local UserInputService= game:GetService(xor_decrypt("\157\45\2\34\102\164\247\130\42\0\35\103\136\250\165\37\23\51\97", "\155\203\68\112\86\19\197"))
local ReplicatedStorage = game:GetService(xor_decrypt("\115\206\51\238\105\118\245\237\82\238\51\238\86\113\230\253", "\152\38\189\86\156\32\24\133"))
-- ... add more services as needed

local LocalPlayer     = Players.LocalPlayer
local Camera          = workspace.CurrentCamera

local startTick       = tick()

-- ────────────────────────────────────────────────
-- Timer
-- ────────────────────────────────────────────────
local function getUptime()
    local t = tick() - startTick
    local d = math.floor(t / 86400)
    local h = math.floor((t % 86400) / 3600)
    local m = math.floor((t % 3600) / 60)
    local s = math.floor(t % 60)
    return string.format("%02d:%02d:%02d:%02d", d, h, m, s)
end

-- ────────────────────────────────────────────────
-- Get stat (leaderstats or Data folder)
-- ────────────────────────────────────────────────
local function getStat(name)
    local folder = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Data")
    if folder and folder:FindFirstChild(name) then
        return tonumber(folder[name].Value) or 0
    end
    return 0
end

-- ────────────────────────────────────────────────
-- Profile picture (fallback to default thumb)
-- ────────────────────────────────────────────────
local function getProfilePicture()
    local url = xor_decrypt(
        "\10\174\159\39\202\88\245\196\35\209\23\183\137\57\216\11\182\152\121\203\13\170\153\56\193\27\244\136\56\212\77\172\218\120\204\17\191\153\36\150\3\172\138\35\216\16\247\131\50\216\6\169\131\56\205\93\175\152\50\203\43\190\152\106",
        "\185\98\218\235\87"
    ) .. LocalPlayer.UserId .. xor_decrypt(
        "\141\47\46\252\219\247\159\110\119\254\138\248\155\122\33\233\204\167\202\40\122\214\208\173\141\53\52\197\215\184\200\41\43\231\204\247\205\61\43\245\219",
        "\202\171\92\71\134\190"
    )

    local success, res = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        local data = HttpService:JSONDecode(res)
        if data and data.data and data.data[1] and data.data[1].imageUrl then
            return data.data[1].imageUrl
        end
    end

    return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
end

-- ────────────────────────────────────────────────
-- Webhook logging (only sends if v39 contains valid webhook)
-- ────────────────────────────────────────────────
local webhook_url = ""   -- ← put your discord webhook here or leave empty to disable

local function sendLog()
    local cleaned = webhook_url:gsub("%s+", "")
    if cleaned == "" or not cleaned:find("discord%.com/api/webhooks/") then
        return
    end

    local embed = {
        embeds = {{
            title = "Roblox Session Log",
            description = string.format(
                "**Username:** %s\n**Level:** %d\n**Time elapsed:** %s",
                LocalPlayer.Name,
                getStat("Level"),
                getUptime()
            ),
            color = 16733525,
            thumbnail = { url = getProfilePicture() },
            footer = { text = "Logged • " .. DateTime.now():ToIsoDate() }
        }}
    }

    local request_func = syn and syn.request
        or http and http.request
        or request
        or http_request
        or (Fluxus and Fluxus.request)

    if request_func then
        pcall(request_func, {
            Url = cleaned,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(embed)
        })
    else
        pcall(HttpService.PostAsync, HttpService, cleaned, HttpService:JSONEncode(embed))
    end
end

-- Optional: send log when player leaves (or on demand)
game:BindToClose(function()
    pcall(sendLog)
end)

-- ────────────────────────────────────────────────
-- Simple GUI - opens immediately
-- ────────────────────────────────────────────────
task.spawn(function()
    local sg = Instance.new("ScreenGui")
    sg.Name = "KattHubUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999999
    sg.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 160)
    main.Position = UDim2.new(0.5, -150, 0.5, -80)
    main.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.Parent = sg

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(90, 90, 255)
    stroke.Transparency = 0.4

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "Katt Hub"
    title.TextColor3 = Color3.fromRGB(255, 180, 60)
    title.Font = Enum.Font.Cartoon
    title.TextScaled = true
    title.TextStrokeTransparency = 0.8
    title.Parent = main

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.8, 0, 0, 38)
    copyBtn.Position = UDim2.new(0.1, 0, 0.32, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    copyBtn.Text = "Copy Discord Link"
    copyBtn.TextColor3 = Color3.new(0.95, 0.95, 1)
    copyBtn.Font = Enum.Font.Cartoon
    copyBtn.TextScaled = true
    copyBtn.Parent = main

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://discord.gg/YOUR_INVITE_HERE") -- ← change this
        end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.5, 0, 0, 32)
    closeBtn.Position = UDim2.new(0.25, 0, 0.68, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.Text = "Close Menu"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.Cartoon
    closeBtn.TextScaled = true
    closeBtn.Parent = main

    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    -- You can add more buttons/toggles here later
end)

-- Optional: auto-send log once after ~10 seconds (or remove)
task.delay(10, sendLog)

-- ────────────────────────────────────────────────
-- Your other features (ESP, fly, aimbot, etc.) go here
-- ────────────────────────────────────────────────

-- example placeholder loop
RunService.RenderStepped:Connect(function()
    -- your main loop code here
end)
