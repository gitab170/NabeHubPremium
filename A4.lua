-- ==========================================
-- NabeHub v1.1 汎用版
-- by なべうどん
-- ==========================================

-- Orion Lib ロード
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion'))()

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "NabeHub v1.1",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NabeHub",
    IntroEnabled = true,
    IntroText = "NabeHub v1.1\n全ゲーム対応汎用Hub",
    Theme = {
        Background = Color3.fromRGB(15, 12, 12),
        ElementBackground = Color3.fromRGB(25, 18, 18),
        TabBackground = Color3.fromRGB(20, 15, 15),
        TabBackgroundSelected = Color3.fromRGB(150, 30, 30),
        TextColor = Color3.fromRGB(230, 210, 210),
        Shadow = Color3.fromRGB(120, 25, 25),
        SliderProgress = Color3.fromRGB(150, 30, 30),
        ElementStroke = Color3.fromRGB(120, 25, 25),
        TabStroke = Color3.fromRGB(120, 25, 25),
        ToggleEnabled = Color3.fromRGB(150, 30, 30),
        ToggleBackground = Color3.fromRGB(45, 40, 40),
        InputBackground = Color3.fromRGB(25, 20, 20),
        DropdownSelected = Color3.fromRGB(60, 25, 25),
        DropdownUnselected = Color3.fromRGB(25, 18, 18),
        NotificationBackground = Color3.fromRGB(25, 18, 18),
        Topbar = Color3.fromRGB(20, 15, 15)
    }
})

-- ==========================================
-- 共通変数
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- ==========================================
-- 設定
-- ==========================================
local Settings = {
    Walkspeed = {enabled = false, value = 16, mode = "CFrame"},
    JumpPower = {enabled = false, value = 50},
    Fly = {enabled = false, speed = 50},
    Noclip = {enabled = false},
    InfJump = {enabled = false},
    Gravity = {enabled = false, value = 196.2},
    SpeedBoost = {enabled = false, multiplier = 2},
    ClickTP = {enabled = false, height = 3},
    PlayerTP = {target = nil, offset = 3, position = "後ろ"},
    SyncTP = {enabled = false, distance = 5, smoothness = 0.5},
    SavedPositions = {},
    TourTP = {enabled = false, interval = 1},
    ESP = {enabled = false, names = true, distance = true, health = false, color = Color3.fromRGB(255,255,255), size = 16},
    BoxESP = {enabled = false, color = Color3.fromRGB(255,0,0), thickness = 1, transparency = 0.5},
    Tracer = {enabled = false, color = Color3.fromRGB(255,255,255), thickness = 1, origin = "画面下"},
    FOV = {enabled = false, value = 70},
    Fullbright = {enabled = false, brightness = 2},
    TimeChange = {enabled = false, value = 12, speed = 1},
    CameraZoom = {enabled = false, distance = 10},
    ThirdPerson = {enabled = false, distance = 10},
    AutoClick = {enabled = false, interval = 0.1, button = "左"},
    AntiAFK = {enabled = false, action = "ジャンプ", interval = 60},
    AutoRespawn = {enabled = false},
    ServerInfo = {enabled = true, interval = 1},
    FPSBoost = {enabled = false},
    Stopwatch = {enabled = false, elapsed = 0},
    Countdown = {enabled = false, duration = 60, remaining = 60},
    AntiTP = {enabled = false, sensitivity = 100},
    AntiFreeze = {enabled = false},
    AutoAvoid = {enabled = false, distance = 10},
    SelectedTarget = nil,
    TargetFollow = {enabled = false, distance = 5, smoothness = 0.5},
    CameraLock = {enabled = false},
    Spectate = {enabled = false},
    Aim = {
        enabled = false, targetPart = "Head", strength = 50,
        speed = 20, fovRadius = 200, smoothing = 10,
        visibleCheck = false, teamCheck = false,
        showFOV = false, prediction = false, maxDistance = 0,
    },
}

-- ==========================================
-- タブ作成
-- ==========================================
local MoveTab = Window:MakeTab({Name = "移動", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TP_Tab = Window:MakeTab({Name = "テレポート", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisTab = Window:MakeTab({Name = "視覚", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AimTab = Window:MakeTab({Name = "オートエイム", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local UtilTab = Window:MakeTab({Name = "ユーティリティ", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local DefTab = Window:MakeTab({Name = "防御", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TargetTab = Window:MakeTab({Name = "ターゲット", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ConfigTab = Window:MakeTab({Name = "設定", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- ==========================================
-- 共通関数
-- ==========================================
local function getHRP()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
end

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(list, p.DisplayName .. " (" .. p.Name .. ")")
        end
    end
    return list
end

local function getPlayerFromSelection(selection)
    if not selection then return nil end
    local username = selection:match("%((.-)%)")
    if username then return Players:FindFirstChild(username) end
    return nil
end

local function notify(title, content)
    OrionLib:MakeNotification({
        Name = title,
        Content = content,
        Time = 3
    })
end

-- ==========================================
-- メインループ
-- ==========================================
local aimTarget = nil
local aimFovCircle = nil
local espDrawings = {}
local originalGraphics = {}

RunService.Heartbeat:Connect(function(dt)
    local hrp = getHRP()
    local hum = getHumanoid()

    -- Walkspeed
    if Settings.Walkspeed.enabled and hrp and hum then
        if Settings.Walkspeed.mode == "CFrame" then
            hrp.CFrame = hrp.CFrame + hum.MoveDirection * (Settings.Walkspeed.value * dt)
        else
            hum.WalkSpeed = Settings.Walkspeed.value
        end
    elseif hum then
        hum.WalkSpeed = 16
    end

    -- JumpPower
    if hum then
        hum.JumpPower = Settings.JumpPower.enabled and Settings.JumpPower.value or 50
    end

    -- Fly
    if Settings.Fly.enabled and hrp then
        local bv = hrp:FindFirstChild("FlyBV") or Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
        local bg = hrp:FindFirstChild("FlyBG") or Instance.new("BodyGyro")
        bg.Name = "FlyBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.Parent = hrp
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
        bv.Velocity = direction * Settings.Fly.speed
        bg.CFrame = Camera.CFrame
        if hum then hum.PlatformStand = true end
    else
        if hrp then
            if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
            if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end

    -- Noclip
    if Settings.Noclip.enabled and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- SpeedBoost
    if Settings.SpeedBoost.enabled and hum then
        hum.WalkSpeed = 16 * Settings.SpeedBoost.multiplier
    end

    -- FOV
    if Settings.FOV.enabled then
        Camera.FieldOfView = Settings.FOV.value
    end

    -- CameraZoom / ThirdPerson
    if Settings.ThirdPerson.enabled then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = Settings.ThirdPerson.distance
        LP.CameraMinZoomDistance = Settings.ThirdPerson.distance
    elseif Settings.CameraZoom.enabled then
        LP.CameraMaxZoomDistance = Settings.CameraZoom.distance
        LP.CameraMinZoomDistance = Settings.CameraZoom.distance
    else
        LP.CameraMaxZoomDistance = 10
        LP.CameraMinZoomDistance = 0.5
    end

    -- TimeChange
    if Settings.TimeChange.enabled then
        Lighting.ClockTime += Settings.TimeChange.speed * dt
        if Lighting.ClockTime > 24 then Lighting.ClockTime = 0 end
    end

    -- Fullbright
    if Settings.Fullbright.enabled then
        Lighting.Brightness = Settings.Fullbright.brightness
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end

    -- SyncTP
    if Settings.SyncTP.enabled and Settings.SelectedTarget then
        local target = Settings.SelectedTarget
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            local tCF = target.Character.HumanoidRootPart.CFrame
            local tPos = tCF.Position - tCF.LookVector * Settings.SyncTP.distance
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(tPos, tCF.Position), Settings.SyncTP.smoothness)
        end
    end

    -- TargetFollow
    if Settings.TargetFollow.enabled and Settings.SelectedTarget then
        local target = Settings.SelectedTarget
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            local tCF = target.Character.HumanoidRootPart.CFrame
            local tPos = tCF.Position - tCF.LookVector * Settings.TargetFollow.distance
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(tPos, tCF.Position), Settings.TargetFollow.smoothness)
        end
    end

    -- CameraLock
    if Settings.CameraLock.enabled and Settings.SelectedTarget then
        local target = Settings.SelectedTarget
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    -- Spectate
    if Settings.Spectate.enabled and Settings.SelectedTarget then
        local target = Settings.SelectedTarget
        if target.Character then
            Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
        end
    elseif not Settings.Spectate.enabled and LP.Character then
        Camera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid")
    end

    -- AntiTP
    if Settings.AntiTP.enabled and hrp then
        if Settings.AntiTP.lastPos then
            local dist = (hrp.Position - Settings.AntiTP.lastPos).Magnitude
            if dist > Settings.AntiTP.sensitivity then
                hrp.CFrame = Settings.AntiTP.lastPos
            end
        end
        Settings.AntiTP.lastPos = hrp.CFrame
    end

    -- AntiFreeze
    if Settings.AntiFreeze.enabled and hrp and hrp.Anchored then
        hrp.Anchored = false
        notify("防御", "アンカー解除")
    end

    -- AutoAvoid
    if Settings.AutoAvoid.enabled and hrp then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local oHRP = p.Character.HumanoidRootPart
                if (hrp.Position - oHRP.Position).Magnitude < Settings.AutoAvoid.distance then
                    local away = (hrp.Position - oHRP.Position).Unit
                    hrp.CFrame = CFrame.new(hrp.Position + away * 5, hrp.Position + away * 10)
                end
            end
        end
    end

    -- オートエイム
    if Settings.Aim.enabled then
        if Settings.Aim.showFOV then
            if not aimFovCircle then
                aimFovCircle = Drawing.new("Circle")
                aimFovCircle.Thickness = 2
                aimFovCircle.Filled = false
                aimFovCircle.Color = Color3.fromRGB(255, 100, 100)
                aimFovCircle.Transparency = 0.8
            end
            aimFovCircle.Radius = Settings.Aim.fovRadius
            aimFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            aimFovCircle.Visible = true
        elseif aimFovCircle then
            aimFovCircle.Visible = false
        end

        if not aimTarget or not aimTarget.Character then
            local closest = nil
            local closestDist = Settings.Aim.fovRadius
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local phum = player.Character:FindFirstChild("Humanoid")
                    local pPart = player.Character:FindFirstChild(Settings.Aim.targetPart)
                    if phum and phum.Health > 0 and pPart then
                        if Settings.Aim.teamCheck and LP.Team and player.Team and LP.Team == player.Team then
                            continue
                        end
                        local screenPos, onScreen = Camera:WorldToScreenPoint(pPart.Position)
                        if onScreen then
                            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist < closestDist then
                                if Settings.Aim.maxDistance > 0 then
                                    local worldDist = (Camera.CFrame.Position - pPart.Position).Magnitude
                                    if worldDist > Settings.Aim.maxDistance then continue end
                                end
                                closestDist = dist
                                closest = player
                            end
                        end
                    end
                end
            end
            aimTarget = closest
        end

        if aimTarget and aimTarget.Character then
            local tPart = aimTarget.Character:FindFirstChild(Settings.Aim.targetPart)
            local tHum = aimTarget.Character:FindFirstChild("Humanoid")
            if tPart and tHum and tHum.Health > 0 then
                local targetPos = tPart.Position
                if Settings.Aim.prediction then
                    local vel = tPart.AssemblyLinearVelocity
                    local dist = (Camera.CFrame.Position - tPart.Position).Magnitude
                    local timeToReach = dist / math.max(Settings.Aim.speed * 10, 100)
                    targetPos = targetPos + vel * timeToReach
                end
                local camPos = Camera.CFrame.Position
                local currentLook = Camera.CFrame.LookVector
                local targetLook = (targetPos - camPos).Unit
                local lerpFactor = math.min(1, (Settings.Aim.strength / 100) * dt * Settings.Aim.smoothing)
                local newLook = currentLook:Lerp(targetLook, lerpFactor)
                Camera.CFrame = CFrame.lookAt(camPos, camPos + newLook)
            else
                aimTarget = nil
            end
        end
    else
        aimTarget = nil
        if aimFovCircle then aimFovCircle.Visible = false end
    end
end)

-- ==========================================
-- 無限ジャンプ
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump.enabled then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ==========================================
-- クリックTP
-- ==========================================
Mouse.Button1Down:Connect(function()
    if Settings.ClickTP.enabled then
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, Settings.ClickTP.height, 0))
        end
    end
end)

-- ==========================================
-- 自動クリック
-- ==========================================
task.spawn(function()
    while true do
        if Settings.AutoClick.enabled then
            if Settings.AutoClick.button == "左" then
                VirtualUser:ClickButton1(Vector2.new())
            else
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
        task.wait(Settings.AutoClick.interval)
    end
end)

-- ==========================================
-- アンチAFK
-- ==========================================
task.spawn(function()
    while true do
        if Settings.AntiAFK.enabled then
            local hrp = getHRP()
            local hum = getHumanoid()
            if hrp and hum then
                if Settings.AntiAFK.action == "ジャンプ" then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                elseif Settings.AntiAFK.action == "回転" then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), 0)
                elseif Settings.AntiAFK.action == "小移動" then
                    hrp.CFrame = hrp.CFrame + Vector3.new(1, 0, 1)
                end
            end
        end
        task.wait(Settings.AntiAFK.interval)
    end
end)

-- ==========================================
-- 自動リスポーン
-- ==========================================
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if Settings.AutoRespawn.enabled then
            task.wait(0.5)
            LP:LoadCharacter()
        end
    end)
end)

-- ==========================================
-- 巡回TP
-- ==========================================
task.spawn(function()
    local tourIndex = 1
    while true do
        if Settings.TourTP.enabled then
            local others = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(others, p.Character.HumanoidRootPart)
                end
            end
            if #others > 0 then
                if tourIndex > #others then tourIndex = 1 end
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = others[tourIndex].CFrame * CFrame.new(0, 0, 3)
                end
                tourIndex += 1
            end
        end
        task.wait(Settings.TourTP.interval)
    end
end)

-- ==========================================
-- タイマー
-- ==========================================
task.spawn(function()
    while true do
        if Settings.Stopwatch.enabled then
            Settings.Stopwatch.elapsed += 1
        end
        if Settings.Countdown.enabled then
            Settings.Countdown.remaining -= 1
            if Settings.Countdown.remaining <= 0 then
                Settings.Countdown.enabled = false
                notify("タイマー", "カウントダウン終了！")
            end
        end
        task.wait(1)
    end
end)

-- ==========================================
-- ESP
-- ==========================================
local function updateESP()
    for _, d in pairs(espDrawings) do
        if d then d:Remove() end
    end
    espDrawings = {}
    if not Settings.ESP.enabled then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")

            if Settings.ESP.names then
                local nameDraw = Drawing.new("Text")
                nameDraw.Visible = false
                nameDraw.Center = true
                nameDraw.Outline = true
                nameDraw.Color = Settings.ESP.color
                nameDraw.Size = Settings.ESP.size
                local text = p.Name
                if Settings.ESP.distance then
                    text = text .. " (" .. string.format("%.1f", (Camera.CFrame.Position - hrp.Position).Magnitude) .. "m)"
                end
                if Settings.ESP.health and hum then
                    text = text .. " [" .. string.format("%.0f", hum.Health) .. "HP]"
                end
                nameDraw.Text = text
                RunService.RenderStepped:Connect(function()
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        nameDraw.Position = Vector2.new(pos.X, pos.Y - 30)
                        nameDraw.Visible = true
                    else
                        nameDraw.Visible = false
                    end
                end)
                table.insert(espDrawings, nameDraw)
            end

            if Settings.BoxESP.enabled then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Color = Settings.BoxESP.color
                box.Thickness = Settings.BoxESP.thickness
                box.Transparency = Settings.BoxESP.transparency
                RunService.RenderStepped:Connect(function()
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local scale = (1 / (Camera.CFrame.Position - hrp.Position).Magnitude) * 1000
                        box.Size = Vector2.new(scale * 1.5, scale * 2)
                        box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                end)
                table.insert(espDrawings, box)
            end

            if Settings.Tracer.enabled then
                local tracer = Drawing.new("Line")
                tracer.Visible = false
                tracer.Color = Settings.Tracer.color
                tracer.Thickness = Settings.Tracer.thickness
                RunService.RenderStepped:Connect(function()
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local startY = Settings.Tracer.origin == "画面下" and Camera.ViewportSize.Y or Camera.ViewportSize.Y / 2
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, startY)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                end)
                table.insert(espDrawings, tracer)
            end
        end
    end
end

task.spawn(function()
    while true do
        updateESP()
        task.wait(2)
    end
end)

-- ==========================================
-- FPSブースト
-- ==========================================
local function applyFPSBoost()
    originalGraphics = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Material ~= Enum.Material.Plastic then
            originalGraphics[v] = v.Material
            v.Material = Enum.Material.Plastic
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
end

local function revertFPSBoost()
    for v, mat in pairs(originalGraphics) do
        if v and v.Parent then v.Material = mat end
    end
    originalGraphics = {}
end

-- ==========================================
-- サーバー情報
-- ==========================================
local infoGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
infoGui.Name = "NabeServerInfo"
infoGui.ResetOnSpawn = false

local infoFrame = Instance.new("Frame", infoGui)
infoFrame.Size = UDim2.new(0, 200, 0, 80)
infoFrame.Position = UDim2.new(0, 5, 0, 5)
infoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
infoFrame.BackgroundTransparency = 0.3
infoFrame.BorderSizePixel = 1
infoFrame.BorderColor3 = Color3.fromRGB(150, 30, 30)
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 6)

local infoLabel = Instance.new("TextLabel", infoFrame)
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(230, 210, 210)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UIPadding", infoLabel).PaddingLeft = UDim.new(0, 10)

task.spawn(function()
    while true do
        if Settings.ServerInfo.enabled then
            local ping = 0
            pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            local mem = 0
            pcall(function() mem = Stats:GetTotalMemoryUsageMb() end)
            local text = string.format("NabeHub Info\nPing: %dms\nMemory: %dMB\nPlayers: %d/%d", math.floor(ping), math.floor(mem), #Players:GetPlayers(), Players.MaxPlayers)
            infoLabel.Text = text
        end
        task.wait(Settings.ServerInfo.interval)
    end
end)

-- ==========================================
-- UI構築 - 移動タブ
-- ==========================================
MoveTab:AddSection({Name = "Walkspeed"})
MoveTab:AddToggle({Name = "Walkspeed", Default = false, Callback = function(v) Settings.Walkspeed.enabled = v end})
MoveTab:AddSlider({Name = "速度", Min = 16, Max = 500, Default = 16, Increment = 1, Callback = function(v) Settings.Walkspeed.value = v end})
MoveTab:AddDropdown({Name = "加速方式", Default = "CFrame", Options = {"CFrame", "Humanoid"}, Callback = function(v) Settings.Walkspeed.mode = v end})

MoveTab:AddSection({Name = "JumpPower"})
MoveTab:AddToggle({Name = "JumpPower", Default = false, Callback = function(v) Settings.JumpPower.enabled = v end})
MoveTab:AddSlider({Name = "ジャンプ力", Min = 50, Max = 1000, Default = 50, Increment = 10, Callback = function(v) Settings.JumpPower.value = v end})

MoveTab:AddSection({Name = "Fly"})
MoveTab:AddToggle({Name = "Fly", Default = false, Callback = function(v) Settings.Fly.enabled = v end})
MoveTab:AddSlider({Name = "飛行速度", Min = 10, Max = 500, Default = 50, Increment = 10, Callback = function(v) Settings.Fly.speed = v end})

MoveTab:AddSection({Name = "Noclip"})
MoveTab:AddToggle({Name = "Noclip", Default = false, Callback = function(v) Settings.Noclip.enabled = v end})

MoveTab:AddSection({Name = "無限ジャンプ"})
MoveTab:AddToggle({Name = "無限ジャンプ", Default = false, Callback = function(v) Settings.InfJump.enabled = v end})

MoveTab:AddSection({Name = "重力"})
MoveTab:AddToggle({Name = "重力変更", Default = false, Callback = function(v)
    Settings.Gravity.enabled = v
    if v then Settings.Gravity.value = Workspace.Gravity
    else Workspace.Gravity = 196.2 end
end})
MoveTab:AddSlider({Name = "重力値", Min = 0, Max = 300, Default = 196.2, Increment = 1, Callback = function(v)
    Settings.Gravity.value = v
    if Settings.Gravity.enabled then Workspace.Gravity = v end
end})

MoveTab:AddSection({Name = "スピードブースト"})
MoveTab:AddToggle({Name = "スピードブースト", Default = false, Callback = function(v) Settings.SpeedBoost.enabled = v end})
MoveTab:AddSlider({Name = "倍率", Min = 1, Max = 10, Default = 2, Increment = 0.5, Callback = function(v) Settings.SpeedBoost.multiplier = v end})

-- ==========================================
-- UI構築 - テレポートタブ
-- ==========================================
TP_Tab:AddSection({Name = "クリックTP"})
TP_Tab:AddToggle({Name = "クリックTP", Default = false, Callback = function(v) Settings.ClickTP.enabled = v end})
TP_Tab:AddSlider({Name = "テレポート高さ", Min = 0, Max = 20, Default = 3, Increment = 1, Callback = function(v) Settings.ClickTP.height = v end})

TP_Tab:AddSection({Name = "プレイヤーTP"})
local tpTargetDropdown = TP_Tab:AddDropdown({
    Name = "ターゲット選択", Default = "", Options = getPlayerList(),
    Callback = function(v) Settings.PlayerTP.target = getPlayerFromSelection(v) end
})
TP_Tab:AddButton({Name = "リスト更新", Callback = function() tpTargetDropdown:Refresh(getPlayerList(), true) end})
TP_Tab:AddDropdown({Name = "TP位置", Default = "後ろ", Options = {"前", "後ろ", "左", "右", "上"}, Callback = function(v) Settings.PlayerTP.position = v end})
TP_Tab:AddSlider({Name = "距離オフセット", Min = 1, Max = 20, Default = 3, Increment = 1, Callback = function(v) Settings.PlayerTP.offset = v end})
TP_Tab:AddButton({Name = "テレポート実行", Callback = function()
    local target = Settings.PlayerTP.target
    local hrp = getHRP()
    if target and target.Character and hrp then
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            local cf = tHRP.CFrame
            local pos = Settings.PlayerTP.position
            local off = Settings.PlayerTP.offset
            if pos == "前" then hrp.CFrame = cf * CFrame.new(0, 0, -off)
            elseif pos == "後ろ" then hrp.CFrame = cf * CFrame.new(0, 0, off)
            elseif pos == "左" then hrp.CFrame = cf * CFrame.new(-off, 0, 0)
            elseif pos == "右" then hrp.CFrame = cf * CFrame.new(off, 0, 0)
            elseif pos == "上" then hrp.CFrame = cf * CFrame.new(0, off, 0) end
            notify("テレポート", target.DisplayName .. " へテレポート")
        end
    else
        notify("エラー", "ターゲットを選択してください")
    end
end})

TP_Tab:AddSection({Name = "CFrame同期TP"})
TP_Tab:AddToggle({Name = "CFrame同期TP", Default = false, Callback = function(v) Settings.SyncTP.enabled = v end})
TP_Tab:AddSlider({Name = "維持距離", Min = 1, Max = 30, Default = 5, Increment = 1, Callback = function(v) Settings.SyncTP.distance = v end})
TP_Tab:AddSlider({Name = "追従スムーズ", Min = 0.1, Max = 1, Default = 0.5, Increment = 0.05, Callback = function(v) Settings.SyncTP.smoothness = v end})

TP_Tab:AddSection({Name = "座標TP"})
local coordInput = TP_Tab:AddTextbox({
    Name = "座標入力 (X,Y,Z)", Default = "", TextDisappear = false,
    Callback = function(v) Settings.coordInput = v end
})
TP_Tab:AddButton({Name = "座標へテレポート", Callback = function()
    if not Settings.coordInput then return end
    local parts = string.split(Settings.coordInput, ",")
    if #parts == 3 then
        local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
        local hrp = getHRP()
        if hrp and x and y and z then
            hrp.CFrame = CFrame.new(x, y, z)
            notify("テレポート", "座標へ移動しました")
        end
    else
        notify("エラー", "形式: X,Y,Z")
    end
end})

TP_Tab:AddSection({Name = "位置保存"})
for i = 1, 5 do
    TP_Tab:AddButton({Name = "スロット" .. i .. " 保存", Callback = function()
        local hrp = getHRP()
        if hrp then
            Settings.SavedPositions[i] = hrp.CFrame
            notify("保存", "スロット" .. i .. " に保存しました")
        end
    end})
    TP_Tab:AddButton({Name = "スロット" .. i .. " へ移動", Callback = function()
        local hrp = getHRP()
        if hrp and Settings.SavedPositions[i] then
            hrp.CFrame = Settings.SavedPositions[i]
            notify("テレポート", "スロット" .. i .. " へ移動しました")
        else
            notify("エラー", "スロット" .. i .. " は空です")
        end
    end})
end

TP_Tab:AddSection({Name = "巡回TP"})
TP_Tab:AddToggle({Name = "巡回TP", Default = false, Callback = function(v) Settings.TourTP.enabled = v end})
TP_Tab:AddSlider({Name = "巡回間隔", Min = 0.1, Max = 5, Default = 1, Increment = 0.1, Callback = function(v) Settings.TourTP.interval = v end})

-- ==========================================
-- UI構築 - 視覚タブ
-- ==========================================
VisTab:AddSection({Name = "ESP"})
VisTab:AddToggle({Name = "ESP", Default = false, Callback = function(v) Settings.ESP.enabled = v end})
VisTab:AddToggle({Name = "名前表示", Default = true, Callback = function(v) Settings.ESP.names = v end})
VisTab:AddToggle({Name = "距離表示", Default = true, Callback = function(v) Settings.ESP.distance = v end})
VisTab:AddToggle({Name = "HP表示", Default = false, Callback = function(v) Settings.ESP.health = v end})
VisTab:AddSlider({Name = "文字サイズ", Min = 10, Max = 30, Default = 16, Increment = 1, Callback = function(v) Settings.ESP.size = v end})

VisTab:AddSection({Name = "ボックスESP"})
VisTab:AddToggle({Name = "ボックスESP", Default = false, Callback = function(v) Settings.BoxESP.enabled = v end})
VisTab:AddSlider({Name = "太さ", Min = 1, Max = 5, Default = 1, Increment = 1, Callback = function(v) Settings.BoxESP.thickness = v end})
VisTab:AddSlider({Name = "透過度", Min = 0, Max = 1, Default = 0.5, Increment = 0.1, Callback = function(v) Settings.BoxESP.transparency = v end})

VisTab:AddSection({Name = "トレーサー"})
VisTab:AddToggle({Name = "トレーサー", Default = false, Callback = function(v) Settings.Tracer.enabled = v end})
VisTab:AddSlider({Name = "太さ", Min = 1, Max = 5, Default = 1, Increment = 1, Callback = function(v) Settings.Tracer.thickness = v end})
VisTab:AddDropdown({Name = "起点位置", Default = "画面下", Options = {"画面下", "画面中央"}, Callback = function(v) Settings.Tracer.origin = v end})

VisTab:AddSection({Name = "FOV"})
VisTab:AddToggle({Name = "FOV変更", Default = false, Callback = function(v) Settings.FOV.enabled = v end})
VisTab:AddSlider({Name = "FOV値", Min = 30, Max = 120, Default = 70, Increment = 1, Callback = function(v) Settings.FOV.value = v end})

VisTab:AddSection({Name = "フルブライト"})
VisTab:AddToggle({Name = "フルブライト", Default = false, Callback = function(v)
    Settings.Fullbright.enabled = v
    if not v then
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
end})
VisTab:AddSlider({Name = "明るさ", Min = 1, Max = 5, Default = 2, Increment = 0.1, Callback = function(v) Settings.Fullbright.brightness = v end})

VisTab:AddSection({Name = "時間変更"})
VisTab:AddToggle({Name = "時間変更", Default = false, Callback = function(v) Settings.TimeChange.enabled = v end})
VisTab:AddSlider({Name = "時間", Min = 0, Max = 24, Default = 12, Increment = 1, Callback = function(v)
    Settings.TimeChange.value = v
    if Settings.TimeChange.enabled then Lighting.ClockTime = v end
end})
VisTab:AddSlider({Name = "時間速度", Min = 0, Max = 10, Default = 1, Increment = 0.5, Callback = function(v) Settings.TimeChange.speed = v end})

VisTab:AddSection({Name = "カメラズーム"})
VisTab:AddToggle({Name = "カメラズーム", Default = false, Callback = function(v) Settings.CameraZoom.enabled = v end})
VisTab:AddSlider({Name = "距離", Min = 1, Max = 100, Default = 10, Increment = 1, Callback = function(v) Settings.CameraZoom.distance = v end})

VisTab:AddSection({Name = "三人称視点"})
VisTab:AddToggle({Name = "三人称視点", Default = false, Callback = function(v) Settings.ThirdPerson.enabled = v end})
VisTab:AddSlider({Name = "カメラ距離", Min = 1, Max = 50, Default = 10, Increment = 1, Callback = function(v) Settings.ThirdPerson.distance = v end})

-- ==========================================
-- UI構築 - オートエイムタブ
-- ==========================================
AimTab:AddSection({Name = "オートエイム"})
AimTab:AddToggle({Name = "オートエイム", Default = false, Callback = function(v) Settings.Aim.enabled = v end})
AimTab:AddDropdown({Name = "部位", Default = "Head", Options = {"Head", "Torso", "HumanoidRootPart", "Left Leg", "Right Leg"}, Callback = function(v) Settings.Aim.targetPart = v end})
AimTab:AddSlider({Name = "強さ", Min = 1, Max = 100, Default = 50, Increment = 1, Callback = function(v) Settings.Aim.strength = v end})
AimTab:AddSlider({Name = "スピード", Min = 1, Max = 100, Default = 20, Increment = 1, Callback = function(v) Settings.Aim.speed = v end})
AimTab:AddSlider({Name = "FOV範囲", Min = 10, Max = 500, Default = 200, Increment = 10, Callback = function(v) Settings.Aim.fovRadius = v end})
AimTab:AddSlider({Name = "なめらかさ", Min = 1, Max = 50, Default = 10, Increment = 1, Callback = function(v) Settings.Aim.smoothing = v end})
AimTab:AddSlider({Name = "最大距離（0=無制限）", Min = 0, Max = 1000, Default = 0, Increment = 10, Callback = function(v) Settings.Aim.maxDistance = v end})
AimTab:AddToggle({Name = "FOV円表示", Default = false, Callback = function(v) Settings.Aim.showFOV = v end})
AimTab:AddToggle({Name = "壁越しチェック", Default = false, Callback = function(v) Settings.Aim.visibleCheck = v end})
AimTab:AddToggle({Name = "チームチェック", Default = false, Callback = function(v) Settings.Aim.teamCheck = v end})
AimTab:AddToggle({Name = "移動予測", Default = false, Callback = function(v) Settings.Aim.prediction = v end})

-- ==========================================
-- UI構築 - ユーティリティタブ
-- ==========================================
UtilTab:AddSection({Name = "自動クリック"})
UtilTab:AddToggle({Name = "自動クリック", Default = false, Callback = function(v) Settings.AutoClick.enabled = v end})
UtilTab:AddSlider({Name = "クリック間隔", Min = 0.01, Max = 1, Default = 0.1, Increment = 0.01, Callback = function(v) Settings.AutoClick.interval = v end})
UtilTab:AddDropdown({Name = "クリックボタン", Default = "左", Options = {"左", "右"}, Callback = function(v) Settings.AutoClick.button = v end})

UtilTab:AddSection({Name = "アンチAFK"})
UtilTab:AddToggle({Name = "アンチAFK", Default = false, Callback = function(v) Settings.AntiAFK.enabled = v end})
UtilTab:AddDropdown({Name = "動作", Default = "ジャンプ", Options = {"ジャンプ", "回転", "小移動"}, Callback = function(v) Settings.AntiAFK.action = v end})
UtilTab:AddSlider({Name = "間隔", Min = 10, Max = 120, Default = 60, Increment = 5, Callback = function(v) Settings.AntiAFK.interval = v end})

UtilTab:AddSection({Name = "自動リスポーン"})
UtilTab:AddToggle({Name = "自動リスポーン", Default = false, Callback = function(v) Settings.AutoRespawn.enabled = v end})

UtilTab:AddSection({Name = "サーバー情報"})
UtilTab:AddToggle({Name = "サーバー情報表示", Default = true, Callback = function(v)
    Settings.ServerInfo.enabled = v
    infoFrame.Visible = v
end})

UtilTab:AddSection({Name = "FPSブースト"})
UtilTab:AddToggle({Name = "FPSブースト", Default = false, Callback = function(v)
    Settings.FPSBoost.enabled = v
    if v then applyFPSBoost() else revertFPSBoost() end
end})

UtilTab:AddSection({Name = "ストップウォッチ"})
UtilTab:AddToggle({Name = "ストップウォッチ開始", Default = false, Callback = function(v)
    Settings.Stopwatch.enabled = v
    if v then Settings.Stopwatch.elapsed = 0 end
end})
UtilTab:AddButton({Name = "リセット", Callback = function() Settings.Stopwatch.elapsed = 0 end})

UtilTab:AddSection({Name = "カウントダウン"})
UtilTab:AddSlider({Name = "時間（秒）", Min = 1, Max = 600, Default = 60, Increment = 1, Callback = function(v)
    Settings.Countdown.duration = v
    Settings.Countdown.remaining = v
end})
UtilTab:AddToggle({Name = "カウントダウン開始", Default = false, Callback = function(v)
    Settings.Countdown.enabled = v
    if v then Settings.Countdown.remaining = Settings.Countdown.duration end
end})

UtilTab:AddSection({Name = "リスポーン"})
UtilTab:AddButton({Name = "即時リスポーン", Callback = function()
    local hum = getHumanoid()
    if hum then
        hum.Health = 0
        task.wait(0.5)
        LP:LoadCharacter()
    end
end})

-- ==========================================
-- UI構築 - 防御タブ
-- ==========================================
DefTab:AddSection({Name = "アンチテレポート"})
DefTab:AddToggle({Name = "アンチTP", Default = false, Callback = function(v) Settings.AntiTP.enabled = v end})
DefTab:AddSlider({Name = "検知感度", Min = 10, Max = 500, Default = 100, Increment = 10, Callback = function(v) Settings.AntiTP.sensitivity = v end})

DefTab:AddSection({Name = "アンチフリーズ"})
DefTab:AddToggle({Name = "アンチフリーズ", Default = false, Callback = function(v) Settings.AntiFreeze.enabled = v end})

DefTab:AddSection({Name = "自動回避"})
DefTab:AddToggle({Name = "自動回避", Default = false, Callback = function(v) Settings.AutoAvoid.enabled = v end})
DefTab:AddSlider({Name = "回避距離", Min = 1, Max = 30, Default = 10, Increment = 1, Callback = function(v) Settings.AutoAvoid.distance = v end})

-- ==========================================
-- UI構築 - ターゲットタブ
-- ==========================================
TargetTab:AddSection({Name = "ターゲット選択"})
local mainTargetDropdown = TargetTab:AddDropdown({
    Name = "ターゲット選択", Default = "", Options = getPlayerList(),
    Callback = function(v) Settings.SelectedTarget = getPlayerFromSelection(v) end
})
TargetTab:AddButton({Name = "リスト更新", Callback = function() mainTargetDropdown:Refresh(getPlayerList(), true) end})

TargetTab:AddSection({Name = "TP追従"})
TargetTab:AddToggle({Name = "TP追従", Default = false, Callback = function(v) Settings.TargetFollow.enabled = v end})
TargetTab:AddSlider({Name = "維持距離", Min = 1, Max = 30, Default = 5, Increment = 1, Callback = function(v) Settings.TargetFollow.distance = v end})
TargetTab:AddSlider({Name = "追従スムーズ", Min = 0.1, Max = 1, Default = 0.5, Increment = 0.05, Callback = function(v) Settings.TargetFollow.smoothness = v end})

TargetTab:AddSection({Name = "カメラロック"})
TargetTab:AddToggle({Name = "カメラロック", Default = false, Callback = function(v) Settings.CameraLock.enabled = v end})

TargetTab:AddSection({Name = "観戦モード"})
TargetTab:AddToggle({Name = "観戦モード", Default = false, Callback = function(v) Settings.Spectate.enabled = v end})

-- ==========================================
-- UI構築 - 設定タブ
-- ==========================================
ConfigTab:AddSection({Name = "全停止"})
ConfigTab:AddButton({Name = "全機能停止", Callback = function()
    for k, v in pairs(Settings) do
        if type(v) == "table" then v.enabled = false end
    end
    Lighting.Brightness = 1
    Lighting.GlobalShadows = true
    Lighting.ClockTime = 12
    Workspace.Gravity = 196.2
    LP.CameraMaxZoomDistance = 10
    LP.CameraMinZoomDistance = 0.5
    Camera.FieldOfView = 70
    if LP.Character then
        Camera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid")
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    revertFPSBoost()
    notify("NabeHub", "全機能を停止しました")
end})

ConfigTab:AddButton({Name = "GUIを閉じる", Callback = function() Window:Close() end})

-- ==========================================
-- プレイヤーリスト自動更新
-- ==========================================
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    tpTargetDropdown:Refresh(getPlayerList(), true)
    mainTargetDropdown:Refresh(getPlayerList(), true)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.2)
    tpTargetDropdown:Refresh(getPlayerList(), true)
    mainTargetDropdown:Refresh(getPlayerList(), true)
end)

-- ==========================================
-- 初期化
-- ==========================================
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "NabeHub v1.1",
    Content = "全ゲーム対応汎用Hubがロードされました\nby なべうどん",
    Time = 5
})
