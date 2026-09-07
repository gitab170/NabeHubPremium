-- ============================================
-- Rag Kick Premium - ブラックホールUI + 召喚エフェクト版
-- ============================================

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "rag kick Premium",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "RagHUB"
})

-- ============================================
-- ブラックホール背景カスタマイズ
-- ============================================
task.wait(0.5)

local coreGui = game:GetService("CoreGui")
local playerGui = LP:WaitForChild("PlayerGui")

local function getRealImageId(decalId)
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. decalId)[1].Texture
    end)
    if success and result then
        return result
    end
    return "rbxassetid://" .. decalId
end

local function applyBlackHoleStyle()
    local orionGui = coreGui:FindFirstChild("OrionUI") or playerGui:FindFirstChild("OrionUI")
                 or coreGui:FindFirstChild("Orion") or playerGui:FindFirstChild("Orion")

    if not orionGui then return end

    local mainFrame = nil
    local maxArea = 0

    for _, obj in ipairs(orionGui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("CanvasGroup") then
            local size = obj.AbsoluteSize
            local area = size.X * size.Y
            if area > maxArea then
                maxArea = area
                mainFrame = obj
            end
        end
    end

    if mainFrame then
        mainFrame.ClipsDescendants = true

        for _, bg in ipairs(mainFrame:GetChildren()) do
            if bg.Name == "CustomBG" or bg.Name == "DarkOverlay" then
                bg:Destroy()
            end
        end

        local targetImage = getRealImageId(5436396988)

        local darkOverlay = Instance.new("Frame")
        darkOverlay.Name = "DarkOverlay"
        darkOverlay.Size = UDim2.new(1, 0, 1, 0)
        darkOverlay.Position = UDim2.new(0, 0, 0, 0)
        darkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        darkOverlay.BackgroundTransparency = 0.55
        darkOverlay.ZIndex = 0
        darkOverlay.Parent = mainFrame

        Instance.new("UICorner", darkOverlay).CornerRadius = UDim.new(0, 10)

        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "CustomBG"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.Position = UDim2.new(0, 0, 0, 0)
        bgImage.Image = targetImage
        bgImage.BackgroundTransparency = 1
        bgImage.ImageTransparency = 0.05
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.ZIndex = 1
        bgImage.Parent = mainFrame

        Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 10)

        mainFrame.BackgroundTransparency = 1

        for _, child in ipairs(mainFrame:GetDescendants()) do
            if child ~= bgImage and child ~= darkOverlay and not child:IsDescendantOf(bgImage) then
                if child:IsA("ImageLabel") then
                    if child.AbsoluteSize.X > 80 or child.AbsoluteSize.Y > 80 then
                        child.ImageTransparency = 1
                        child.BackgroundTransparency = 1
                    end
                end

                if child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("CanvasGroup") then
                    child.BackgroundTransparency = 1
                    child.ZIndex = math.max(child.ZIndex, 2)
                end

                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageButton") then
                    child.ZIndex = math.max(child.ZIndex, 5)
                    
                    if child:IsA("TextLabel") then
                        child.TextTransparency = 0
                        
                        local existingStroke = child:FindFirstChildOfClass("UIStroke")
                        if not existingStroke then
                            local stroke = Instance.new("UIStroke")
                            stroke.Color = Color3.fromRGB(0, 0, 0)
                            stroke.Thickness = 1.5
                            stroke.Transparency = 0.1
                            stroke.Parent = child
                        else
                            existingStroke.Color = Color3.fromRGB(0, 0, 0)
                            existingStroke.Thickness = 1.5
                            existingStroke.Transparency = 0.1
                        end
                    end
                end
            end
        end

        print("ブラックホールUIの適用に成功！")
    end
end

applyBlackHoleStyle()

-- ============================================
-- ブラックホール召喚エフェクト
-- ============================================
local function spawnBlackHoleEffect(position)
    -- ブラックホールのコア（黒い球体）
    local core = Instance.new("Part")
    core.Name = "BlackHoleCore"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(3, 3, 3)
    core.Position = position
    core.Anchored = true
    core.CanCollide = false
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(0, 0, 0)
    core.Parent = Workspace

    -- 光のリング
    local ring = Instance.new("Part")
    ring.Name = "BlackHoleRing"
    ring.Shape = Enum.PartType.Ball
    ring.Size = Vector3.new(6, 6, 6)
    ring.Position = position
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(150, 0, 255)
    ring.Transparency = 0.6
    ring.Parent = Workspace

    -- パーティクル
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = core
    particleEmitter.Texture = "rbxassetid://243098098"
    particleEmitter.Rate = 100
    particleEmitter.Lifetime = NumberRange.new(0.5, 1)
    particleEmitter.Speed = NumberRange.new(5, 15)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Color = ColorSequence.new(
        Color3.fromRGB(150, 0, 255),
        Color3.fromRGB(0, 0, 0)
    )
    particleEmitter.Size = NumberSequence.new(0.5, 0.1)

    -- 光のビーム
    local beam = Instance.new("Beam")
    beam.Parent = core
    beam.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255))
    beam.Width0 = 0.5
    beam.Width1 = 1
    beam.Transparency = NumberSequence.new(0.3, 0.8)

    local attach0 = Instance.new("Attachment", core)
    local attach1 = Instance.new("Attachment", ring)
    beam.Attachment0 = attach0
    beam.Attachment1 = attach1

    -- サウンド
    local sound = Instance.new("Sound")
    sound.Parent = core
    sound.SoundId = "rbxassetid://9116149587"
    sound.Volume = 2
    sound:Play()

    -- アニメーション
    task.spawn(function()
        local tweenService = game:GetService("TweenService")
        
        -- 拡大アニメーション
        local growTween = tweenService:Create(core, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(8, 8, 8)
        })
        growTween:Play()

        local ringGrow = tweenService:Create(ring, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(15, 15, 15),
            Transparency = 0.9
        })
        ringGrow:Play()

        -- 回転アニメーション
        local rotation = 0
        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
            if not core.Parent then
                conn:Disconnect()
                return
            end
            rotation += dt * 360
            core.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)
            ring.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rotation), 0, 0)
        end)

        -- 消滅
        task.wait(2)
        conn:Disconnect()
        
        local shrinkTween = tweenService:Create(core, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = Vector3.new(0.1, 0.1, 0.1)
        })
        shrinkTween:Play()

        local ringShrink = tweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = Vector3.new(0.1, 0.1, 0.1),
            Transparency = 1
        })
        ringShrink:Play()

        task.wait(0.5)
        core:Destroy()
        ring:Destroy()
    end)
end

-- ============================================
-- ラグ機能
-- ============================================
local lineLagThread = nil
local lineLagEnabled = false
local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")

local function startLineLag()
    if lineLagEnabled then return end
    lineLagEnabled = true
    lineLagThread = task.spawn(function()
        if not GrabEvents then return end
        local createLine = GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end

        while lineLagEnabled do
            local target = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
            if target then
                for i = 1, 10 do
                    local randomX = math.random(-1e9, 1e9)
                    local randomZ = math.random(-1e9, 1e9)
                    pcall(function()
                        createLine:FireServer(target, CFrame.new(randomX, 0, randomZ))
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopLineLag()
    lineLagEnabled = false
    if lineLagThread then
        task.cancel(lineLagThread)
        lineLagThread = nil
    end
end

-- ============================================
-- Kick All 機能
-- ============================================
local currentBlob = nil
local isActive = false
local playerStatus = {}

local function GetAllPlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            table.insert(players, player)
        end
    end
    return players
end

local function GetMyRoot()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

local function ResetTargets()
    for id, status in pairs(playerStatus) do
        if status == "Targeting" then
            playerStatus[id] = nil
        end
    end
end

local function KickAll()
    if isActive then return end
    isActive = true

    local allPlayers = GetAllPlayers()
    if #allPlayers == 0 then
        isActive = false
        return
    end

    for _, targetPlayer in ipairs(allPlayers) do
        playerStatus[targetPlayer.UserId] = "Targeting"
    end

    -- ブラックホール召喚（キック開始時）
    local myRoot = GetMyRoot()
    if myRoot then
        spawnBlackHoleEffect(myRoot.Position)
    end

    local rootPart = GetMyRoot()
    if rootPart then
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
        pcall(function()
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
        end)
    end
    task.wait(0.5)

    local toyFolder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    currentBlob = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
    if not currentBlob then
        ResetTargets()
        isActive = false
        return
    end

    local vehicleSeat = currentBlob:FindFirstChild("VehicleSeat")
    if vehicleSeat and LP.Character then
        local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            vehicleSeat:Sit(humanoid)
        end
    end
    task.wait(0.3)

    myRoot = GetMyRoot()
    if not myRoot then
        ResetTargets()
        isActive = false
        return
    end

    local tpWait = 0.025

    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            myRoot.CFrame = targetRoot.CFrame
            myRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(tpWait)

            -- 各ターゲットにも小さなブラックホール召喚
            spawnBlackHoleEffect(targetRoot.Position + Vector3.new(0, 5, 0))

            local distance = (myRoot.Position - targetRoot.Position).Magnitude
            if distance <= 35 then
                for i = 1, 8 do
                    if not targetRoot.Parent or not currentBlob.Parent then break end
                    pcall(function()
                        currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld
                        )
                        currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(currentBlob.LeftDetector.LeftWeld)
                    end)
                    task.wait()
                end
            end
        end
    end

    myRoot.CFrame = CFrame.new(0, 0, 0)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)

    for _, part in ipairs(currentBlob:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.Anchored = true end)
        end
    end
    task.wait(0.1)

    local radius = 13
    local centerX, centerY, centerZ = 0, 10, 0

    for i, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local angle = math.rad((i - 1) * (360 / #allPlayers))
            local x = centerX + radius * math.cos(angle)
            local z = centerZ + radius * math.sin(angle)

            pcall(function()
                targetRoot.CFrame = CFrame.new(x, centerY, z)
                targetRoot.AssemblyLinearVelocity = Vector3.zero
                targetRoot.AssemblyAngularVelocity = Vector3.zero
            end)

            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P = 4000
            bp.Position = Vector3.new(x, centerY, z)
            bp.Parent = targetRoot
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
        end
    end
    task.wait(0.1)

    for _ = 1, 2 do
        for _, targetPlayer in ipairs(allPlayers) do
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(targetRoot, CFrame.new(targetRoot.Position))
                        ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(targetRoot)
                    end)
                end)
            end
        end
        task.wait(0.1)
    end

    task.wait(0.3)

    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            task.spawn(function()
                pcall(function()
                    currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld
                    )
                    currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        currentBlob.RightDetector, targetRoot, currentBlob.RightDetector.RightWeld
                    )
                end)
            end)
        end
    end

    task.wait(0.1)

    for _, targetPlayer in ipairs(allPlayers) do
        if targetPlayer and targetPlayer.Parent == Players then
            playerStatus[targetPlayer.UserId] = "Kicked"
        end
    end

    for _, part in ipairs(currentBlob:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.Anchored = false end)
        end
    end

    task.wait(1)
    isActive = false
end

-- ============================================
-- UI作成
-- ============================================
local MainTab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddButton({
    Name = "ラグ＆Kick All 開始 (20秒)",
    Callback = function()
        if lineLagEnabled then
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "すでにラグ処理が実行中です",
                Time = 2
            })
            return
        end

        startLineLag()

        task.spawn(function()
            pcall(function()
                KickAll()
            end)
        end)

        OrionLib:MakeNotification({
            Name = "hub",
            Content = "20秒間のラグとKick Allを開始しました",
            Time = 2
        })

        task.delay(20, function()
            if lineLagEnabled then
                stopLineLag()
                OrionLib:MakeNotification({
                    Name = "Rag HUB",
                    Content = "20秒経過したためラグ処理を停止しました",
                    Time = 2
                })
            end
        end)
    end
})

local InfoTab = Window:MakeTab({
    Name = "情報",
    Icon = "rbxassetid://4370211644",
    PremiumOnly = false
})

InfoTab:AddParagraph("使い方", "「ラグ＆Kick All 開始」ボタンを押すと\n全員に対してラグ攻撃 + 強制キックを実行します。\n処理は約20秒間続きます。\n\nキック時にはブラックホールが召喚されます！")

InfoTab:AddParagraph("hub", "制作者無し")

OrionLib:Init()
