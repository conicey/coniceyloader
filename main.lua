-- Conicey Loader - Full Kill Aura (Identical to base: instant knife equip + spin + teleport + click spam)

-- ... (keep your existing variables/services at top)

local autokillEnabled = false  -- renamed from autokillEnabled to match "Autofarm" toggle in base

-- In your GUI toggle button (replace the existing autokillBtn connection):
autofarmBtn.MouseButton1Click:Connect(function()
    autokillEnabled = not autokillEnabled
    autofarmBtn.Text = "💀 Autofarm: " .. (autokillEnabled and "ON" or "OFF")
    autofarmBtn.BackgroundColor3 = autokillEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    StarterGui:SetCore("SendNotification", {
        Title = "Conicey Loader",
        Text = autokillEnabled and "Autofarm ON - Spinning to nearest player!" or "Autofarm OFF",
        Duration = 3
    })
end)

-- Replace your old spawn() loop with this one (identical mechanics from base)
spawn(function()
    while true do
        task.wait(0.01)  -- matches base's fast loop (not too laggy)
        
        if not autokillEnabled then
            -- Reset when off (from base v47 logic)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
                LocalPlayer.Character.Humanoid.JumpPower = 50
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
            continue
        end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then
            continue
        end
        
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        -- Find nearest target (simplified from base v51: closest alive non-self)
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tHum = plr.Character.Humanoid
                local tHrp = plr.Character.HumanoidRootPart
                if tHum.Health > 0 then
                    -- Basic team skip if teams exist
                    if not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team) then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist < minDist and dist < 200 then  -- generous range like base
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
        
        -- Instant equip knife (exact from base)
        local knife = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")  -- assume knife is tool
        if knife and knife.Parent ~= char then
            hum:EquipTool(knife)
        end
        
        -- Teleport + random spin (IDENTICAL to base)
        local offset = CFrame.new(0, -3, -3)  -- close offset like base
        local randomSpin = CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        hrp.CFrame = targetHrp.CFrame * offset * randomSpin
        
        -- Camera lock on target (from base)
        if not (autofarmBtn.Text:find("ESP") or similar) then  -- optional, base does it
            Camera.CameraSubject = targetHum
        end
        
        -- Spam click to swing knife (base uses SendMouseButtonEvent)
        pcall(function()
            game:GetService("VirtualUser"):ClickButton1(Vector2.new())  -- modern way, or use your SendMouseButtonEvent if needed
            -- Alternative exact base simulation:
            -- game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,0)
            -- task.wait(0.01)
            -- game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0)
        end)
    end
end)
