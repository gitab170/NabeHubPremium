-- ============================================================================
-- 
-- ============================================================================

-- ============================================================================
-- ブロック1: OrionLib読み込み
-- ============================================================================
do
    local OrionLib = nil
    local loadSuccess, loadErr = pcall(function()
        OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
    end)

    if not OrionLib then
        local backupSuccess, backupErr = pcall(function()
            OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/oryonhub/Orion/main/source"))()
        end)
        if not OrionLib then
            local backup2Success, backup2Err = pcall(function()
                OrionLib = loadstring(game:HttpGet("https://pastefy.app/OrionLib/raw"))()
            end)
            if not OrionLib then
                error("OrionLibの読み込みに失敗しました")
            end
        end
    end

    _G.OrionLib = OrionLib
end

-- ============================================================================
-- ブロック2: 基本サービスと設定
-- ============================================================================
do
    local OrionLib = _G.OrionLib
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local PhysicsService = game:GetService("PhysicsService")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local Theme = {
        BackgroundColor = Color3.fromRGB(139, 69, 19),
        SliderColor = Color3.fromRGB(255, 105, 180),
        TextColor = Color3.fromRGB(255, 255, 255),
    }

    _G.SakuraHub = _G.SakuraHub or {}
    local SH = _G.SakuraHub
    _G.SH = SH
    _G.Theme = Theme
    _G.LocalPlayer = LocalPlayer
    _G.Camera = Camera
    _G.Workspace = Workspace
    _G.RunService = RunService
    _G.ReplicatedStorage = ReplicatedStorage
    _G.PhysicsService = PhysicsService
    _G.HttpService = HttpService
    _G.UserInputService = UserInputService
    _G.Players = Players
end

-- ============================================================================
-- ブロック3: UIウィンドウ作成
-- ============================================================================
do
    local OrionLib = _G.OrionLib
    local Theme = _G.Theme

    local Window = OrionLib:MakeWindow({
        Name = "なべHub さくら",
        HidePremium = false,
        SaveConfig = false,
        IntroEnabled = true,
        IntroText = "なべHub 読み込み中...",
        ThemeColor = Theme.BackgroundColor,
        BackgroundColor = Theme.BackgroundColor,
        TextColor = Theme.TextColor
    })

    _G.Window = Window
end

-- ============================================================================
-- ブロック4: ピンクグラデーション
-- ============================================================================
do
    local RunService = _G.RunService
    local Players = _G.Players
    local LocalPlayer = _G.LocalPlayer

    local function applyPinkGradientEffect()
        local CoreGui = game:GetService("CoreGui")
        local time = 0
        local strokes = {}
        local function register(obj) if obj:IsA("UIStroke") then table.insert(strokes, obj) end end
        local function scan(gui) for _, v in ipairs(gui:GetDescendants()) do register(v) end; gui.DescendantAdded:Connect(register) end
        local player = LocalPlayer
        if player then local playerGui = player:WaitForChild("PlayerGui"); scan(CoreGui); scan(playerGui) end
        local function getPinkGradientColor(t)
            local pinkColors = { Color3.fromRGB(255, 182, 193), Color3.fromRGB(255, 105, 180), Color3.fromRGB(219, 112, 147) }
            local position = (math.sin(t * 2) + 1) / 2
            if position < 0.5 then return pinkColors[1]:Lerp(pinkColors[2], position * 2)
            else return pinkColors[2]:Lerp(pinkColors[3], (position - 0.5) * 2) end
        end
        RunService.RenderStepped:Connect(function(dt) time = time + dt * 0.5; for i = #strokes, 1, -1 do local stroke = strokes[i]; if stroke and stroke.Parent then stroke.Color = getPinkGradientColor(time + i * 0.01) else table.remove(strokes, i) end end end)
    end
    pcall(applyPinkGradientEffect)
end

-- ============================================================================
-- ブロック5: オブジェクトID設定
-- ============================================================================
do
    local SH = _G.SH

    SH.ObjectIDConfig = {
        CurrentObjectID = "FireworkSparkler",
        AvailableObjects = {
            "FireworkSparkler", "PalletLightBrown", "GlassBoxGray", "MusicKeyboard",
            "SpookyCandle1", "Tetracube1", "NinjaKatana", "YouDecoy", "BombMissile", 
            "LadderLightBrown", "CreatureBlobman", "DiscoColorBall", "MineralCrystalPink",
            "FloatingIsland", "FlyingToyUfo", "JukeboxBlue", "JukeboxOrange", "CouchBlue",
            "CouchPink", "CouchWhite", "Boombox", "FireworkMissile", "Snowflake",
            "SpookyCandle5", "MineralDiamond", "TractorGreen", "TractorOrange", "TractorRed"
        }
    }
end

-- ============================================================================
-- ブロック6: 各機能の設定
-- ============================================================================
do
    local SH = _G.SH

    SH.FeatherConfig = { Enabled = false, spacing = 3, heightOffset = 2, backwardOffset = 3, maxSparklers = 20, tiltAngle = 45, waveSpeed = 2, baseAmplitude = 1 }
    SH.MagicCircleConfig = { Enabled = false, Height = 5.0, Diameter = 5.0, ObjectCount = 10, RotationSpeed = 20.0, SymbolType = "Ring", GlowEffect = true }
    SH.HeartConfig = { Enabled = false, Height = 5.0, Size = 5.0, ObjectCount = 12, RotationSpeed = 1.0, PulseSpeed = 2.0, PulseAmplitude = 0.5, FollowPlayer = true }
    SH.BigHeartConfig = { Enabled = false, Height = 8.0, Size = 10.0, ObjectCount = 20, RotationSpeed = 0.5, RotationSpeedMax = 10.0, PulseSpeed = 1.0, PulseSpeedMax = 10.0, PulseAmplitude = 1.0, FollowPlayer = true, HeartScale = 2.0, VerticalStretch = 1.2 }
    SH.StarOfDavidConfig = { Enabled = false, Height = 5.0, Size = 5.0, ObjectCount = 12, RotationSpeed = 1.0, PulseSpeed = 1.5, FollowPlayer = true, TriangleHeight = 0.5 }
    SH.StarConfig = { Enabled = false, Height = 5.0, ObjectCount = 10, RotationSpeed = 1.0, TwinkleSpeed = 2.0, FollowPlayer = true, OuterRadius = 5.0, InnerRadius = 2.0 }
    SH.Star2Config = { Enabled = false, Height = 10.0, Size = 15.0, ObjectCount = 24, RotationSpeed = 5.0, RotationSpeedMax = 30.0, PulseSpeed = 8.0, PulseSpeedMax = 20.0, PulseAmplitude = 2.0, FollowPlayer = true, RayCount = 12, RayLength = 3.0, RayLengthMax = 10.0, JitterSpeed = 5.0, JitterAmount = 1.0, MaxDistance = 50.0 }
    SH.SphereConfig = { Enabled = false, BaseHeight = 0, Radius = 5.0, ObjectCount = 20, HorizontalRotationSpeed = 2.0, VerticalRotationSpeed = 1.0, FollowPlayer = true, Latitudes = 3, Longitudes = 6, PulseSpeed = 1.0, PulseAmplitude = 0.5 }
    SH.FerrisWheelConfig = { Enabled = false, Height = 15.0, Radius = 10.0, ObjectCount = 12, RotationSpeed = 1.0, RotationSpeedMax = 5.0, FollowPlayer = true, VerticalCircle = true, FixedDirection = true, FixedYaw = 0, FixedPitch = 0, FixedRoll = 0 }
    SH.AnimN1Config = { Enabled = false, Height = 10.0, Radius = 15.0, ObjectCount = 50, RotationSpeed = 20.0, PulseSpeed = 5.0, PulseAmount = 10.0, FollowPlayer = true }
    SH.AnimN2Config = { Enabled = false, BaseHeight = 5.0, TopHeight = 30.0, Radius = 8.0, ObjectCount = 60, RotationSpeed = 15.0, RiseSpeed = 2.0, ChaosFactor = 3.0, FollowPlayer = true }
    SH.AnimN3Config = { Enabled = false, Height = 8.0, ExplosionRadius = 25.0, ObjectCount = 80, CycleSpeed = 2.0, Randomness = 5.0, FollowPlayer = true }

    SH.WingConfig = {
        Enabled = false,
        VerticalOffset = 2.0,
        Spread = 5.0,
        ObjectCount = 10,
        FlapShape = 2.0,
        FlapSpeed = 1.0,
        FlapAmount = 3.0,
        ChainDelay = 0.01
    }

    SH.SaturnConfig = {
        Enabled = false,
        Mode = "saturn",
        MaxVel = 700,
        Strength = 16,
        BaseHeight = 6,
        RingRadius = 12,
        RingSpeed = 1.5,
        SphereRadius = 5,
        SphereSpeed = 1,
        SphereLayers = 5,
        PlotRadius = 15,
        PlotHeight = 0.5,
        ModelName = "FireworkSparkler"
    }

    SH.PianoConfig = {
        Enabled = false,
        FollowPlayer = true,
        SongData = nil,
        IsPlaying = false,
        Keyboard = nil,
        UpdateConnection = nil,
        OriginalCollisions = {},
        KeyMap = {
            ["1"] = "Key1C", ["2"] = "Key1D", ["3"] = "Key1E", ["4"] = "Key1F", 
            ["5"] = "Key1G", ["6"] = "Key1A", ["7"] = "Key1B", ["8"] = "Key2C",
            ["9"] = "Key2D", ["0"] = "Key2E", ["q"] = "Key2F", ["w"] = "Key2G",
            ["e"] = "Key2A", ["r"] = "Key2B", ["t"] = "Key3C",
            ["f"] = "Key1Csharp", ["g"] = "Key1Dsharp", ["h"] = "Key1Fsharp",
            ["j"] = "Key1Gsharp", ["k"] = "Key1Asharp", ["l"] = "Key2Csharp",
            ["z"] = "Key2Dsharp", ["x"] = "Key2Fsharp", ["c"] = "Key2Gsharp",
            ["v"] = "Key2Asharp"
        }
    }

    -- 縦型ハート設定（XY平面でハートを描く）
    SH.VerticalHeartConfig = {
        Enabled = false,
        Height = 5.0,
        Size = 5.0,
        ObjectCount = 12,
        RotationSpeed = 1.0,
        PulseSpeed = 2.0,
        PulseAmplitude = 0.5,
        FollowPlayer = true
    }

    -- 縦型ビッグハート設定（XY平面でハートを描く）
    SH.VerticalBigHeartConfig = {
        Enabled = false,
        Height = 8.0,
        Size = 10.0,
        ObjectCount = 20,
        RotationSpeed = 0.5,
        RotationSpeedMax = 10.0,
        PulseSpeed = 1.0,
        PulseSpeedMax = 10.0,
        PulseAmplitude = 1.0,
        FollowPlayer = true,
        HeartScale = 2.0
    }
end

-- ============================================================================
-- ブロック7: 土星用設定
-- ============================================================================
do
    local SH = _G.SH
    local PhysicsService = _G.PhysicsService

    local SATURN_GROUP_NAME = "SparklerGroup"
    pcall(function()
        PhysicsService:RegisterCollisionGroup(SATURN_GROUP_NAME)
        PhysicsService:CollisionGroupSetCollidable(SATURN_GROUP_NAME, SATURN_GROUP_NAME, false)
    end)
    _G.SATURN_GROUP_NAME = SATURN_GROUP_NAME
end

-- ============================================================================
-- ブロック8: 状態変数
-- ============================================================================
do
    local SH = _G.SH

    SH.featherToys = {}; SH.featherRowPoints = {}; SH.featherAssignedToys = {}; SH.featherLoopConn = nil; SH.featherTime = 0
    SH.magicCircleList = {}; SH.magicCircleLoopConn = nil; SH.magicCircleTAccum = 0
    SH.heartToys = {}; SH.heartPoints = {}; SH.heartAssignedToys = {}; SH.heartLoopConn = nil; SH.heartTime = 0
    SH.bigHeartToys = {}; SH.bigHeartPoints = {}; SH.bigHeartAssignedToys = {}; SH.bigHeartLoopConn = nil; SH.bigHeartTime = 0
    SH.starOfDavidToys = {}; SH.starOfDavidPoints = {}; SH.starOfDavidAssignedToys = {}; SH.starOfDavidLoopConn = nil; SH.starOfDavidTime = 0
    SH.starToys = {}; SH.starPoints = {}; SH.starAssignedToys = {}; SH.starLoopConn = nil; SH.starTime = 0
    SH.star2Toys = {}; SH.star2Points = {}; SH.star2AssignedToys = {}; SH.star2LoopConn = nil; SH.star2Time = 0
    SH.sphereToys = {}; SH.spherePoints = {}; SH.sphereAssignedToys = {}; SH.sphereLoopConn = nil; SH.sphereTime = 0
    SH.ferrisWheelToys = {}; SH.ferrisWheelPoints = {}; SH.ferrisWheelAssignedToys = {}; SH.ferrisWheelLoopConn = nil; SH.ferrisWheelTime = 0
    SH.animN1Toys = {}; SH.animN1Points = {}; SH.animN1AssignedToys = {}; SH.animN1LoopConn = nil; SH.animN1Time = 0
    SH.animN2Toys = {}; SH.animN2Points = {}; SH.animN2AssignedToys = {}; SH.animN2LoopConn = nil; SH.animN2Time = 0
    SH.animN3Toys = {}; SH.animN3Points = {}; SH.animN3AssignedToys = {}; SH.animN3LoopConn = nil; SH.animN3Time = 0
    SH.wingList = {}; SH.wingLoopConn = nil; SH.wingTime = 0
    SH.saturnList = {}; SH.saturnLoopConn = nil; SH.saturnCachedHRP = nil; SH.saturnTAccum = 0
    SH.verticalHeartToys = {}; SH.verticalHeartPoints = {}; SH.verticalHeartAssignedToys = {}; SH.verticalHeartLoopConn = nil; SH.verticalHeartTime = 0
    SH.verticalBigHeartToys = {}; SH.verticalBigHeartPoints = {}; SH.verticalBigHeartAssignedToys = {}; SH.verticalBigHeartLoopConn = nil; SH.verticalBigHeartTime = 0
end

-- ============================================================================
-- ブロック9: ピアノ用イベント
-- ============================================================================
do
    local ReplicatedStorage = _G.ReplicatedStorage
    local SH = _G.SH

    local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
    local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
    _G.SetNetworkOwner = SetNetworkOwner
end

-- ============================================================================
-- ブロック10: 共通関数
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local OrionLib = _G.OrionLib

    function findObjects()
        local toys = {}
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Model") and item.Name == SH.ObjectIDConfig.CurrentObjectID then
                local alreadyAdded = false
                for _, existingToy in ipairs(toys) do if existingToy == item then alreadyAdded = true; break end end
                if not alreadyAdded then table.insert(toys, item) end
            end
        end
        table.sort(toys, function(a, b) return a.Name < b.Name end)
        return toys
    end
    _G.findObjects = findObjects

    function getPrimaryPart(model)
        if model.PrimaryPart then return model.PrimaryPart end
        local potentialParts = {"Handle", "Main", "Part", "Base", "Sparkler", "Firework", "Blade", "Candle", "Keyboard", "Box", "Decoy", "Missile", "Ladder", "Blob", "Ball", "Crystal", "Island", "Ufo", "Jukebox", "Couch", "Boombox", "Snowflake", "Diamond", "Tractor"}
        for _, partName in ipairs(potentialParts) do
            local part = model:FindFirstChild(partName)
            if part and part:IsA("BasePart") then return part end
        end
        for _, child in ipairs(model:GetChildren()) do if child:IsA("BasePart") then return child end end
        return nil
    end
    _G.getPrimaryPart = getPrimaryPart

    function attachPhysics(part, pValue, dValue)
        if not part then return nil, nil end
        local existingBG = part:FindFirstChildOfClass("BodyGyro")
        local existingBP = part:FindFirstChildOfClass("BodyPosition")
        if existingBG and existingBP then return existingBG, existingBP end
        if existingBG then existingBG:Destroy() end
        if existingBP then existingBP:Destroy() end
        local BP = Instance.new("BodyPosition"); local BG = Instance.new("BodyGyro")
        BP.P = pValue or 15000; BP.D = dValue or 200; BP.MaxForce = Vector3.new(1, 1, 1) * 1e10; BP.Parent = part
        BG.P = pValue or 15000; BG.D = dValue or 200; BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10; BG.Parent = part
        return BG, BP
    end
    _G.attachPhysics = attachPhysics

    function changeObjectID(id)
        if id == SH.ObjectIDConfig.CurrentObjectID then return end
        SH.ObjectIDConfig.CurrentObjectID = id
        local activeFunctions = {}
        if SH.FeatherConfig.Enabled then table.insert(activeFunctions, _G.toggleFeather) end
        if SH.MagicCircleConfig.Enabled then table.insert(activeFunctions, _G.toggleMagicCircle) end
        if SH.HeartConfig.Enabled then table.insert(activeFunctions, _G.toggleHeart) end
        if SH.BigHeartConfig.Enabled then table.insert(activeFunctions, _G.toggleBigHeart) end
        if SH.StarOfDavidConfig.Enabled then table.insert(activeFunctions, _G.toggleStarOfDavid) end
        if SH.StarConfig.Enabled then table.insert(activeFunctions, _G.toggleStar) end
        if SH.Star2Config.Enabled then table.insert(activeFunctions, _G.toggleStar2) end
        if SH.SphereConfig.Enabled then table.insert(activeFunctions, _G.toggleSphere) end
        if SH.FerrisWheelConfig.Enabled then table.insert(activeFunctions, _G.toggleFerrisWheel) end
        if SH.AnimN1Config.Enabled then table.insert(activeFunctions, _G.toggleAnimN1) end
        if SH.AnimN2Config.Enabled then table.insert(activeFunctions, _G.toggleAnimN2) end
        if SH.AnimN3Config.Enabled then table.insert(activeFunctions, _G.toggleAnimN3) end
        if SH.WingConfig.Enabled then table.insert(activeFunctions, _G.toggleWing) end
        if SH.SaturnConfig.Enabled then table.insert(activeFunctions, _G.toggleSaturn) end
        if SH.PianoConfig.Enabled then table.insert(activeFunctions, _G.togglePiano) end
        if SH.VerticalHeartConfig.Enabled then table.insert(activeFunctions, _G.toggleVerticalHeart) end
        if SH.VerticalBigHeartConfig.Enabled then table.insert(activeFunctions, _G.toggleVerticalBigHeart) end
        for _, func in ipairs(activeFunctions) do if func then func(false) end end
        task.wait(0.5)
        for _, func in ipairs(activeFunctions) do if func then func(true) end end
        OrionLib:MakeNotification({ Name = "オブジェクトID変更", Content = id .. " に切り替えました", Time = 3 })
    end
    _G.changeObjectID = changeObjectID
end

-- ============================================================================
-- ブロック11: ピアノ関数
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local SetNetworkOwner = _G.SetNetworkOwner
    local HttpService = _G.HttpService
    local OrionLib = _G.OrionLib

    function getMusicKeyboard()
        local myName = LocalPlayer.Name
        
        local spawnedToys = Workspace:FindFirstChild(myName .. "SpawnedInToys")
        if spawnedToys then
            local kb = spawnedToys:FindFirstChild("MusicKeyboard")
            if kb then return kb end
        end

        local plots = Workspace:FindFirstChild("Plots")
        local plotItems = Workspace:FindFirstChild("PlotItems")

        if plots and plotItems then
            for _, plot in ipairs(plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                local ownerObj = sign and (sign:FindFirstChild("ThisPlotsOwners") or sign:FindFirstChild("Owner"))
                if ownerObj then
                    local val = ownerObj:FindFirstChild("Value") or ownerObj
                    local data = val:FindFirstChild("Data") or val
                    if (data:IsA("StringValue") and data.Value == myName) then
                        local myPlotItems = plotItems:FindFirstChild(plot.Name)
                        if myPlotItems then
                            local kb = myPlotItems:FindFirstChild("MusicKeyboard")
                            if kb then return kb end
                        end
                        local build = plot:FindFirstChild("Build")
                        local kb = build and build:FindFirstChild("MusicKeyboard")
                        if kb then return kb end
                    end
                end
            end
        end

        for _, item in ipairs(Workspace:GetChildren()) do
            if item.Name == "MusicKeyboard" and item:IsA("Model") then
                local ownerValue = item:FindFirstChild("Owner") or item:FindFirstChild("PartOwner")
                if ownerValue and ownerValue:IsA("StringValue") and ownerValue.Value == myName then
                    return item
                end
            end
        end

        return nil
    end
    _G.getMusicKeyboard = getMusicKeyboard

    function stopPiano()
        if SH.PianoConfig.UpdateConnection then
            SH.PianoConfig.UpdateConnection:Disconnect()
            SH.PianoConfig.UpdateConnection = nil
        end
        if SH.PianoConfig.Keyboard and SH.PianoConfig.Keyboard.Parent then
            local pp = SH.PianoConfig.Keyboard:FindFirstChild("Main", true) or SH.PianoConfig.Keyboard.PrimaryPart
            if pp then
                for _, child in ipairs(pp:GetChildren()) do
                    if child:IsA("Attachment") or child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
                        child:Destroy()
                    end
                end
            end
        end
        
        for part, canCollide in pairs(SH.PianoConfig.OriginalCollisions) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
        end
        SH.PianoConfig.OriginalCollisions = {} 
    end
    _G.stopPiano = stopPiano

    function setupPianoFollow()
        if not SH.PianoConfig.Keyboard then 
            SH.PianoConfig.Keyboard = getMusicKeyboard() 
        end
        if not SH.PianoConfig.Keyboard then return end
        
        if SH.PianoConfig.UpdateConnection then return end

        local mainPart = SH.PianoConfig.Keyboard:FindFirstChild("Main", true) or SH.PianoConfig.Keyboard.PrimaryPart
        if not mainPart then 
            warn("NabeHub: ピアノのMainパーツが見つかりません")
            return 
        end
        
        for _, part in ipairs(SH.PianoConfig.Keyboard:GetDescendants()) do
            if part:IsA("BasePart") then
                if SH.PianoConfig.OriginalCollisions[part] == nil then
                    SH.PianoConfig.OriginalCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = false
                part.Anchored = false
                part.Massless = true
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                pcall(function() part:SetNetworkOwner(LocalPlayer) end)
            end
        end
        
        local pp = mainPart
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local offset = CFrame.new(0, -1.5, -2) * CFrame.Angles(0, math.rad(180), 0)
            pp.CFrame = root.CFrame * offset
        end
        
        local a0 = Instance.new("Attachment", pp)
        local ap = Instance.new("AlignPosition", pp)
        ap.Attachment0 = a0
        ap.Mode = Enum.PositionAlignmentMode.OneAttachment
        ap.MaxForce = 1e9
        ap.Responsiveness = 200
        local ao = Instance.new("AlignOrientation", pp)
        ao.Attachment0 = a0
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.MaxTorque = 1e9
        ao.Responsiveness = 200
        
        SH.PianoConfig.UpdateConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            if not SH.PianoConfig.Keyboard or not SH.PianoConfig.Keyboard.Parent then 
                stopPiano()
                return 
            end

            if math.random() < 0.05 then
                pcall(function() pp:SetNetworkOwner(LocalPlayer) end)
            end

            local baseCF = root.CFrame
            local offset = CFrame.new(0, -1.5, -2) * CFrame.Angles(0, math.rad(180), 0)
            local targetCF = baseCF * offset
            ap.Position = targetCF.Position
            ao.CFrame = targetCF
        end)
    end
    _G.setupPianoFollow = setupPianoFollow

    function pressPianoKey(keyName)
        local targetKeyboard = getMusicKeyboard()
        if not targetKeyboard then 
            SH.PianoConfig.Keyboard = nil
            targetKeyboard = getMusicKeyboard()
            if not targetKeyboard then return end
        end

        local key = targetKeyboard:FindFirstChild(keyName, true)
        if key and key:IsA("BasePart") then
            SetNetworkOwner:FireServer(key, key.CFrame)
            task.wait(0.15)
        end
    end
    _G.pressPianoKey = pressPianoKey

    function playSongFromJSONString(jsonString)
        if SH.PianoConfig.IsPlaying then return end
        
        local songData
        local success, err = pcall(function()
            return HttpService:JSONDecode(jsonString)
        end)
        
        if not success or type(err) ~= "table" then
            warn("JSONデータの読み込みに失敗しました")
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "JSON形式が正しくありません",
                Time = 5
            })
            return
        end
        songData = err

        SH.PianoConfig.IsPlaying = true
        
        task.spawn(function()
            if not SH.PianoConfig.Keyboard then 
                SH.PianoConfig.Keyboard = getMusicKeyboard() 
            end
            
            for i, note in ipairs(songData) do
                if not SH.PianoConfig.IsPlaying then break end
                
                local rawKey = tostring(note.key)
                local keyName = rawKey
                if not string.match(rawKey, "^Key") then
                    keyName = SH.PianoConfig.KeyMap[rawKey] or rawKey
                end
                
                local delayTime = note.delay or 0.1
                
                task.spawn(function()
                    pressPianoKey(keyName)
                end)
                
                task.wait(delayTime)
            end
            
            SH.PianoConfig.IsPlaying = false
            OrionLib:MakeNotification({
                Name = "完了",
                Content = "演奏が終了しました",
                Time = 3
            })
        end)
    end
    _G.playSongFromJSONString = playSongFromJSONString

    function stopSong()
        SH.PianoConfig.IsPlaying = false
    end
    _G.stopSong = stopSong
end

-- ============================================================================
-- ブロック12: フェザー機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleFeather(state)
        SH.FeatherConfig.Enabled = state
        if state then
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.featherToys = findObjects()
            local count = math.min(#SH.featherToys, SH.FeatherConfig.maxSparklers)
            SH.featherRowPoints = {}
            local halfCount = math.floor(count / 2)
            local isOdd = count % 2 == 1
            for i = 1, count do
                local x = isOdd and (i - math.ceil(count / 2)) * SH.FeatherConfig.spacing or (i - halfCount - 0.5) * SH.FeatherConfig.spacing
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.featherRowPoints[i] = { offsetX = x, part = part, assignedToy = nil }
            end
            
            local distanceGroups = {}
            for i, point in ipairs(SH.featherRowPoints) do
                local absDistance = math.abs(point.offsetX)
                if not distanceGroups[absDistance] then distanceGroups[absDistance] = {} end
                table.insert(distanceGroups[absDistance], i)
            end
            local sortedDistances = {}
            for distance, _ in pairs(distanceGroups) do table.insert(sortedDistances, distance) end
            table.sort(sortedDistances)
            for rank, distance in ipairs(sortedDistances) do
                for _, pointIndex in ipairs(distanceGroups[distance]) do SH.featherRowPoints[pointIndex].distanceRank = rank end
            end
            
            SH.featherAssignedToys = {}
            for i = 1, math.min(#SH.featherToys, #SH.featherRowPoints) do
                local toy = SH.featherToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do
                            if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end
                        end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, RowIndex = i, offsetX = SH.featherRowPoints[i].offsetX, distanceRank = SH.featherRowPoints[i].distanceRank }
                        SH.featherRowPoints[i].assignedToy = toyTable
                        table.insert(SH.featherAssignedToys, toyTable)
                    end
                end
            end
            
            SH.featherTime = 0
            if SH.featherLoopConn then SH.featherLoopConn:Disconnect() end
            SH.featherLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.FeatherConfig.Enabled or not LocalPlayer.Character then return end
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not hrp or not torso then return end
                SH.featherTime = SH.featherTime + dt * SH.FeatherConfig.waveSpeed
                local rightVector = hrp.CFrame.RightVector
                local lookVector = hrp.CFrame.LookVector
                local backVector = -lookVector
                local basePosition = torso.Position + Vector3.new(0, SH.FeatherConfig.heightOffset, 0) + (backVector * SH.FeatherConfig.backwardOffset)
                for _, point in ipairs(SH.featherRowPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local targetPosition = basePosition + (rightVector * toy.offsetX)
                        local amplitude = SH.FeatherConfig.baseAmplitude * toy.distanceRank
                        local finalPosition = targetPosition + Vector3.new(0, math.sin(SH.featherTime) * amplitude, 0)
                        if point.part then point.part.Position = finalPosition end
                        toy.BP.Position = finalPosition
                        local backYRotation = math.atan2(-lookVector.X, -lookVector.Z)
                        local baseCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, backYRotation, 0)
                        toy.BG.CFrame = toy.BG.CFrame:Lerp(baseCFrame * CFrame.Angles(math.rad(-SH.FeatherConfig.tiltAngle), 0, 0), 0.3)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "フェザー開始", Content = "オブジェクト数: " .. #SH.featherAssignedToys, Time = 3 })
        else
            if SH.featherLoopConn then SH.featherLoopConn:Disconnect(); SH.featherLoopConn = nil end
            for _, point in ipairs(SH.featherRowPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.featherRowPoints = {}; SH.featherAssignedToys = {}
            OrionLib:MakeNotification({ Name = "フェザー停止", Content = "フェザー配置を解除", Time = 2 })
        end
    end
    _G.toggleFeather = toggleFeather
end

-- ============================================================================
-- ブロック13: 魔法陣機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local getPrimaryPart = _G.getPrimaryPart

    function toggleMagicCircle(state)
        SH.MagicCircleConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            for _, r in ipairs(SH.magicCircleList) do
                if r.part then
                    local bv = r.part:FindFirstChild("MagicCircleBodyVelocity"); if bv then bv:Destroy() end
                    local bg = r.part:FindFirstChild("MagicCircleBodyGyro"); if bg then bg:Destroy() end
                    if r.model then for _, p in ipairs(r.model:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true; p.CanTouch = true; p.Material = Enum.Material.Plastic; pcall(function() p:SetNetworkOwner(nil) end) end end end
                end
            end
            SH.magicCircleList = {}
            
            local foundCount = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                if foundCount >= SH.MagicCircleConfig.ObjectCount then break end
                if d:IsA("Model") and d.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local part = getPrimaryPart(d)
                    if part and not part.Anchored then
                        for _, p in ipairs(d:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(LocalPlayer) end); p.CanCollide = false; p.CanTouch = false; if SH.MagicCircleConfig.GlowEffect then p.Material = Enum.Material.Neon end end end
                        if not part:FindFirstChild("MagicCircleBodyVelocity") then local bv = Instance.new("BodyVelocity"); bv.Name = "MagicCircleBodyVelocity"; bv.MaxForce = Vector3.new(1e8, 1e8, 1e8); bv.Velocity = Vector3.new(); bv.P = 1e6; bv.Parent = part end
                        if not part:FindFirstChild("MagicCircleBodyGyro") then local bg = Instance.new("BodyGyro"); bg.Name = "MagicCircleBodyGyro"; bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8); bg.CFrame = part.CFrame; bg.P = 1e6; bg.Parent = part end
                        table.insert(SH.magicCircleList, { model = d, part = part })
                        foundCount = foundCount + 1
                    end
                end
            end
            
            SH.magicCircleTAccum = 0
            if SH.magicCircleLoopConn then SH.magicCircleLoopConn:Disconnect() end
            SH.magicCircleLoopConn = RunService.Heartbeat:Connect(function(dt)
                if not SH.MagicCircleConfig.Enabled then return end
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root or #SH.magicCircleList == 0 then return end
                SH.magicCircleTAccum = SH.magicCircleTAccum + dt * (SH.MagicCircleConfig.RotationSpeed / 10)
                local radius = SH.MagicCircleConfig.Diameter / 2
                local angleIncrement = 360 / #SH.magicCircleList
                local rootVelocity = root.AssemblyLinearVelocity or root.Velocity or Vector3.new()
                for i, rec in ipairs(SH.magicCircleList) do
                    local part = rec.part
                    if not part or not part.Parent then continue end
                    local angle = math.rad(i * angleIncrement + SH.magicCircleTAccum * 50)
                    local localPos = Vector3.new(radius * math.cos(angle), SH.MagicCircleConfig.Height, radius * math.sin(angle))
                    if SH.MagicCircleConfig.SymbolType == "Hexagram" then
                        local heightOffset = ((i - 1) % 6 + 1) <= 3 and 0.5 * math.sin(angle * 3) or -0.5 * math.sin(angle * 3)
                        localPos = Vector3.new(radius * math.cos(angle), SH.MagicCircleConfig.Height + heightOffset, radius * math.sin(angle))
                    elseif SH.MagicCircleConfig.SymbolType == "Circle" then
                        localPos = Vector3.new(radius * math.cos(angle), SH.MagicCircleConfig.Height + math.sin(angle * 4) * 0.3, radius * math.sin(angle))
                    end
                    local targetPos = root.Position + localPos
                    local dir = targetPos - part.Position
                    local bv = part:FindFirstChild("MagicCircleBodyVelocity")
                    if bv then bv.Velocity = (dir.Magnitude > 0.1 and dir.Unit * math.min(3000, dir.Magnitude * 50) or Vector3.new()) + rootVelocity end
                    local bg = part:FindFirstChild("MagicCircleBodyGyro")
                    if bg then bg.CFrame = CFrame.lookAt(targetPos, root.Position) * CFrame.Angles(0, math.pi, 0) end
                end
            end)
            OrionLib:MakeNotification({ Name = "魔法陣開始", Content = "高さ: " .. SH.MagicCircleConfig.Height, Time = 3 })
        else
            if SH.magicCircleLoopConn then SH.magicCircleLoopConn:Disconnect(); SH.magicCircleLoopConn = nil end
            for _, rec in ipairs(SH.magicCircleList) do
                if rec.part then
                    local bv = rec.part:FindFirstChild("MagicCircleBodyVelocity"); if bv then bv:Destroy() end
                    local bg = rec.part:FindFirstChild("MagicCircleBodyGyro"); if bg then bg:Destroy() end
                    if rec.model then for _, p in ipairs(rec.model:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true; p.CanTouch = true; p.Material = Enum.Material.Plastic; pcall(function() p:SetNetworkOwner(nil) end) end end end
                end
            end
            SH.magicCircleList = {}
            OrionLib:MakeNotification({ Name = "魔法陣停止", Content = "魔法陣を解除", Time = 2 })
        end
    end
    _G.toggleMagicCircle = toggleMagicCircle
end

-- ============================================================================
-- ブロック14: ハート機能（横方向・地面に水平 / XZ平面）
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleHeart(state)
        SH.HeartConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.heartToys = findObjects()
            local count = math.min(#SH.heartToys, SH.HeartConfig.ObjectCount)
            SH.heartPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.heartPoints[i] = { angle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil }
            end
            
            SH.heartAssignedToys = {}
            for i = 1, math.min(#SH.heartToys, #SH.heartPoints) do
                local toy = SH.heartToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.heartPoints[i].angle }
                        SH.heartPoints[i].assignedToy = toyTable
                        table.insert(SH.heartAssignedToys, toyTable)
                    end
                end
            end
            
            SH.heartTime = 0
            if SH.heartLoopConn then SH.heartLoopConn:Disconnect() end
            SH.heartLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.HeartConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.heartTime = SH.heartTime + dt
                local basePosition = SH.HeartConfig.FollowPlayer and torso.Position or torso.Position
                local pulseEffect = (SH.HeartConfig.PulseSpeed > 0) and math.sin(SH.heartTime * SH.HeartConfig.PulseSpeed) * SH.HeartConfig.PulseAmplitude or 0
                for _, point in ipairs(SH.heartPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = toy.baseAngle + (SH.heartTime * SH.HeartConfig.RotationSpeed)
                        local baseScale = SH.HeartConfig.Size / 20
                        local x = 16 * (math.sin(currentAngle) ^ 3) * baseScale
                        local y = (13 * math.cos(currentAngle) - 5 * math.cos(2*currentAngle) - 2 * math.cos(3*currentAngle) - math.cos(4*currentAngle)) * baseScale
                        if pulseEffect > 0 then local pf = 1 + (pulseEffect * 0.1); x = x * pf; y = y * pf end
                        -- 横ハート: XZ平面（地面に水平）
                        local targetPosition = basePosition + Vector3.new(x, SH.HeartConfig.Height + math.sin(currentAngle * 2) * 0.5, y)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "ハート開始", Content = "サイズ: " .. SH.HeartConfig.Size, Time = 3 })
        else
            if SH.heartLoopConn then SH.heartLoopConn:Disconnect(); SH.heartLoopConn = nil end
            for _, point in ipairs(SH.heartPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.heartPoints = {}; SH.heartAssignedToys = {}
            OrionLib:MakeNotification({ Name = "ハート停止", Content = "ハート配置を解除", Time = 2 })
        end
    end
    _G.toggleHeart = toggleHeart
end

-- ============================================================================
-- ブロック15: ビッグハート機能（横方向・地面に水平 / XZ平面）
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleBigHeart(state)
        SH.BigHeartConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.bigHeartToys = findObjects()
            local count = math.min(#SH.bigHeartToys, SH.BigHeartConfig.ObjectCount)
            SH.bigHeartPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.bigHeartPoints[i] = { angle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil }
            end
            
            SH.bigHeartAssignedToys = {}
            for i = 1, math.min(#SH.bigHeartToys, #SH.bigHeartPoints) do
                local toy = SH.bigHeartToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.bigHeartPoints[i].angle }
                        SH.bigHeartPoints[i].assignedToy = toyTable
                        table.insert(SH.bigHeartAssignedToys, toyTable)
                    end
                end
            end
            
            SH.bigHeartTime = 0
            if SH.bigHeartLoopConn then SH.bigHeartLoopConn:Disconnect() end
            SH.bigHeartLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.BigHeartConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.bigHeartTime = SH.bigHeartTime + dt
                local basePosition = SH.BigHeartConfig.FollowPlayer and torso.Position or torso.Position
                local pulseEffect = (SH.BigHeartConfig.PulseSpeed > 0) and math.sin(SH.bigHeartTime * SH.BigHeartConfig.PulseSpeed) * SH.BigHeartConfig.PulseAmplitude or 0
                for _, point in ipairs(SH.bigHeartPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = toy.baseAngle + (SH.bigHeartTime * SH.BigHeartConfig.RotationSpeed)
                        local baseScale = SH.BigHeartConfig.Size / 20
                        local x = 16 * (math.sin(currentAngle) ^ 3) * baseScale * SH.BigHeartConfig.HeartScale
                        local y = (13 * math.cos(currentAngle) - 5 * math.cos(2*currentAngle) - 2 * math.cos(3*currentAngle) - math.cos(4*currentAngle)) * baseScale * SH.BigHeartConfig.HeartScale * SH.BigHeartConfig.VerticalStretch
                        if pulseEffect > 0 then local pf = 1 + (pulseEffect * 0.1); x = x * pf; y = y * pf end
                        -- 横ビッグハート: XZ平面（地面に水平）
                        local targetPosition = basePosition + Vector3.new(x, SH.BigHeartConfig.Height + math.sin(currentAngle * 2) * 1.0, y)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "ビッグハート開始", Content = "サイズ: " .. SH.BigHeartConfig.Size, Time = 3 })
        else
            if SH.bigHeartLoopConn then SH.bigHeartLoopConn:Disconnect(); SH.bigHeartLoopConn = nil end
            for _, point in ipairs(SH.bigHeartPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.bigHeartPoints = {}; SH.bigHeartAssignedToys = {}
            OrionLib:MakeNotification({ Name = "ビッグハート停止", Content = "ビッグハート配置を解除", Time = 2 })
        end
    end
    _G.toggleBigHeart = toggleBigHeart
end

-- ============================================================================
-- ブロック16: ダビデの星機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleStarOfDavid(state)
        SH.StarOfDavidConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.starOfDavidToys = findObjects()
            local count = math.min(#SH.starOfDavidToys, SH.StarOfDavidConfig.ObjectCount)
            SH.starOfDavidPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.starOfDavidPoints[i] = { angle = (i - 1) * (2 * math.pi / 6), part = part, assignedToy = nil, triangleIndex = math.floor((i - 1) / 2) + 1 }
            end
            
            SH.starOfDavidAssignedToys = {}
            for i = 1, math.min(#SH.starOfDavidToys, #SH.starOfDavidPoints) do
                local toy = SH.starOfDavidToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.starOfDavidPoints[i].angle }
                        SH.starOfDavidPoints[i].assignedToy = toyTable
                        table.insert(SH.starOfDavidAssignedToys, toyTable)
                    end
                end
            end
            
            SH.starOfDavidTime = 0
            if SH.starOfDavidLoopConn then SH.starOfDavidLoopConn:Disconnect() end
            SH.starOfDavidLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.StarOfDavidConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.starOfDavidTime = SH.starOfDavidTime + dt
                local basePosition = SH.StarOfDavidConfig.FollowPlayer and torso.Position or torso.Position
                for i, point in ipairs(SH.starOfDavidPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = toy.baseAngle + (SH.starOfDavidTime * SH.StarOfDavidConfig.RotationSpeed)
                        local scale = SH.StarOfDavidConfig.Size / 10
                        local x = math.cos(currentAngle) * scale
                        local z = math.sin(currentAngle) * scale
                        local heightOffset = (i % 2 == 0) and SH.StarOfDavidConfig.TriangleHeight or -SH.StarOfDavidConfig.TriangleHeight
                        local targetPosition = basePosition + Vector3.new(x, SH.StarOfDavidConfig.Height + heightOffset + math.sin(SH.starOfDavidTime * SH.StarOfDavidConfig.PulseSpeed) * 0.1, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        local direction = (targetPosition - basePosition).Unit
                        if direction.Magnitude > 0 then toy.BG.CFrame = CFrame.lookAt(targetPosition, targetPosition + direction) end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "ダビデの星開始", Content = "サイズ: " .. SH.StarOfDavidConfig.Size, Time = 3 })
        else
            if SH.starOfDavidLoopConn then SH.starOfDavidLoopConn:Disconnect(); SH.starOfDavidLoopConn = nil end
            for _, point in ipairs(SH.starOfDavidPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.starOfDavidPoints = {}; SH.starOfDavidAssignedToys = {}
            OrionLib:MakeNotification({ Name = "ダビデの星停止", Content = "ダビデの星配置を解除", Time = 2 })
        end
    end
    _G.toggleStarOfDavid = toggleStarOfDavid
end

-- ============================================================================
-- ブロック17: スター機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleStar(state)
        SH.StarConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.starToys = findObjects()
            local count = math.min(#SH.starToys, SH.StarConfig.ObjectCount)
            SH.starPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                local starIndex = (i - 1) % 10
                SH.starPoints[i] = { starIndex = starIndex, isOuter = starIndex % 2 == 0, part = part, assignedToy = nil }
            end
            
            SH.starAssignedToys = {}
            for i = 1, math.min(#SH.starToys, #SH.starPoints) do
                local toy = SH.starToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, starIndex = SH.starPoints[i].starIndex, isOuter = SH.starPoints[i].isOuter }
                        SH.starPoints[i].assignedToy = toyTable
                        table.insert(SH.starAssignedToys, toyTable)
                    end
                end
            end
            
            SH.starTime = 0
            if SH.starLoopConn then SH.starLoopConn:Disconnect() end
            SH.starLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.StarConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.starTime = SH.starTime + dt
                local basePosition = SH.StarConfig.FollowPlayer and torso.Position or torso.Position
                for _, point in ipairs(SH.starPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local anglePerPoint = 2 * math.pi / 5
                        local pointAngle = toy.starIndex * (anglePerPoint / 2)
                        local radius = (toy.isOuter and SH.StarConfig.OuterRadius or SH.StarConfig.InnerRadius) * (1 + math.sin(SH.starTime * SH.StarConfig.TwinkleSpeed + toy.starIndex) * 0.2)
                        local x = math.cos(pointAngle + SH.starTime * SH.StarConfig.RotationSpeed) * radius
                        local z = math.sin(pointAngle + SH.starTime * SH.StarConfig.RotationSpeed) * radius
                        local targetPosition = basePosition + Vector3.new(x, SH.StarConfig.Height + math.sin(pointAngle * 3) * 0.5, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        local direction = (targetPosition - basePosition).Unit
                        if direction.Magnitude > 0 then toy.BG.CFrame = CFrame.lookAt(targetPosition, targetPosition + direction) end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "スター開始", Content = "外側半径: " .. SH.StarConfig.OuterRadius, Time = 3 })
        else
            if SH.starLoopConn then SH.starLoopConn:Disconnect(); SH.starLoopConn = nil end
            for _, point in ipairs(SH.starPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.starPoints = {}; SH.starAssignedToys = {}
            OrionLib:MakeNotification({ Name = "スター停止", Content = "スター配置を解除", Time = 2 })
        end
    end
    _G.toggleStar = toggleStar
end

-- ============================================================================
-- ブロック18: スター2機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleStar2(state)
        SH.Star2Config.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.star2Toys = findObjects()
            local count = math.min(#SH.star2Toys, SH.Star2Config.ObjectCount)
            SH.star2Points = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.star2Points[i] = { angle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil, rayIndex = (i - 1) % SH.Star2Config.RayCount }
            end
            
            SH.star2AssignedToys = {}
            for i = 1, math.min(#SH.star2Toys, #SH.star2Points) do
                local toy = SH.star2Toys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart, 20000, 300)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.star2Points[i].angle, rayIndex = SH.star2Points[i].rayIndex }
                        SH.star2Points[i].assignedToy = toyTable
                        table.insert(SH.star2AssignedToys, toyTable)
                    end
                end
            end
            
            SH.star2Time = 0
            if SH.star2LoopConn then SH.star2LoopConn:Disconnect() end
            SH.star2LoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.Star2Config.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.star2Time = SH.star2Time + dt
                local basePosition = SH.Star2Config.FollowPlayer and torso.Position or torso.Position
                local pulseEffect = (SH.Star2Config.PulseSpeed > 0) and math.sin(SH.star2Time * SH.Star2Config.PulseSpeed) * SH.Star2Config.PulseAmplitude or 0
                for _, point in ipairs(SH.star2Points) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = toy.baseAngle + (SH.star2Time * SH.Star2Config.RotationSpeed)
                        local scale = SH.Star2Config.Size / 10
                        local baseRadius = scale
                        local rayFactor = 0
                        local anglePerRay = 2 * math.pi / SH.Star2Config.RayCount
                        local rayAngle = toy.rayIndex * anglePerRay
                        local angleDiff = math.abs(currentAngle - rayAngle)
                        if angleDiff > math.pi then angleDiff = 2 * math.pi - angleDiff end
                        if angleDiff < (anglePerRay / 4) then
                            rayFactor = (1 - (angleDiff / (anglePerRay / 4))) * SH.Star2Config.RayLength * (1 + math.sin(SH.star2Time * SH.Star2Config.JitterSpeed + toy.rayIndex) * SH.Star2Config.JitterAmount * 0.1)
                        end
                        local finalRadius = (baseRadius + rayFactor) * (1 + (pulseEffect * 0.1))
                        local x = math.cos(currentAngle) * math.min(finalRadius, SH.Star2Config.MaxDistance)
                        local z = math.sin(currentAngle) * math.min(finalRadius, SH.Star2Config.MaxDistance)
                        local targetPosition = basePosition + Vector3.new(x, SH.Star2Config.Height + math.sin(SH.star2Time * 3 + toy.rayIndex) * 0.5, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        local direction = (targetPosition - basePosition).Unit
                        if direction.Magnitude > 0 then toy.BG.CFrame = toy.BG.CFrame:Lerp(CFrame.lookAt(targetPosition, targetPosition + direction), 0.5) end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "スター2開始", Content = "サイズ: " .. SH.Star2Config.Size, Time = 3 })
        else
            if SH.star2LoopConn then SH.star2LoopConn:Disconnect(); SH.star2LoopConn = nil end
            for _, point in ipairs(SH.star2Points) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.star2Points = {}; SH.star2AssignedToys = {}
            OrionLib:MakeNotification({ Name = "スター2停止", Content = "スター2解除", Time = 2 })
        end
    end
    _G.toggleStar2 = toggleStar2
end

-- ============================================================================
-- ブロック19: 球体機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleSphere(state)
        SH.SphereConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.sphereToys = findObjects()
            local count = math.min(#SH.sphereToys, SH.SphereConfig.ObjectCount)
            SH.spherePoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                local latIndex = math.floor((i - 1) / SH.SphereConfig.Longitudes) + 1
                local lonIndex = ((i - 1) % SH.SphereConfig.Longitudes) + 1
                SH.spherePoints[i] = { latitudeIndex = latIndex, longitudeIndex = lonIndex, part = part, assignedToy = nil }
            end
            
            SH.sphereAssignedToys = {}
            for i = 1, math.min(#SH.sphereToys, #SH.spherePoints) do
                local toy = SH.sphereToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart, 20000, 300)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, latitudeIndex = SH.spherePoints[i].latitudeIndex, longitudeIndex = SH.spherePoints[i].longitudeIndex }
                        SH.spherePoints[i].assignedToy = toyTable
                        table.insert(SH.sphereAssignedToys, toyTable)
                    end
                end
            end
            
            SH.sphereTime = 0
            if SH.sphereLoopConn then SH.sphereLoopConn:Disconnect() end
            SH.sphereLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.SphereConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.sphereTime = SH.sphereTime + dt
                local basePosition = SH.SphereConfig.FollowPlayer and torso.Position or torso.Position
                for _, point in ipairs(SH.spherePoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local latAngle = ((toy.latitudeIndex - 1) / (SH.SphereConfig.Latitudes - 1) - 0.5) * math.pi
                        local lonAngle = ((toy.longitudeIndex - 1) / SH.SphereConfig.Longitudes) * 2 * math.pi
                        local rotatedLon = lonAngle + (SH.sphereTime * SH.SphereConfig.HorizontalRotationSpeed)
                        local rotatedLat = latAngle + (SH.sphereTime * SH.SphereConfig.VerticalRotationSpeed * 0.5)
                        local pulse = (SH.SphereConfig.PulseSpeed > 0) and 1 + math.sin(SH.sphereTime * SH.SphereConfig.PulseSpeed) * SH.SphereConfig.PulseAmplitude or 1
                        local finalRadius = SH.SphereConfig.Radius * pulse
                        local x = finalRadius * math.cos(rotatedLat) * math.cos(rotatedLon)
                        local y = finalRadius * math.sin(rotatedLat)
                        local z = finalRadius * math.cos(rotatedLat) * math.sin(rotatedLon)
                        local targetPosition = basePosition + Vector3.new(x, SH.SphereConfig.BaseHeight + y, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        local direction = (targetPosition - basePosition).Unit
                        if direction.Magnitude > 0 then toy.BG.CFrame = toy.BG.CFrame:Lerp(CFrame.lookAt(targetPosition, targetPosition + direction), 0.4) end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "球体開始", Content = "半径: " .. SH.SphereConfig.Radius, Time = 3 })
        else
            if SH.sphereLoopConn then SH.sphereLoopConn:Disconnect(); SH.sphereLoopConn = nil end
            for _, point in ipairs(SH.spherePoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.spherePoints = {}; SH.sphereAssignedToys = {}
            OrionLib:MakeNotification({ Name = "球体停止", Content = "球体解除", Time = 2 })
        end
    end
    _G.toggleSphere = toggleSphere
end

-- ============================================================================
-- ブロック20: 観覧車機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleFerrisWheel(state)
        SH.FerrisWheelConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.ferrisWheelToys = findObjects()
            local count = math.min(#SH.ferrisWheelToys, SH.FerrisWheelConfig.ObjectCount)
            local angleStep = (2 * math.pi) / count
            SH.ferrisWheelPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.ferrisWheelPoints[i] = { baseAngle = (i - 1) * angleStep, part = part, assignedToy = nil }
            end
            
            SH.ferrisWheelAssignedToys = {}
            for i = 1, math.min(#SH.ferrisWheelToys, #SH.ferrisWheelPoints) do
                local toy = SH.ferrisWheelToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart, 20000, 300)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.ferrisWheelPoints[i].baseAngle }
                        SH.ferrisWheelPoints[i].assignedToy = toyTable
                        table.insert(SH.ferrisWheelAssignedToys, toyTable)
                    end
                end
            end
            
            SH.ferrisWheelTime = 0
            if SH.ferrisWheelLoopConn then SH.ferrisWheelLoopConn:Disconnect() end
            SH.ferrisWheelLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.FerrisWheelConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.ferrisWheelTime = SH.ferrisWheelTime + dt
                local basePosition = SH.FerrisWheelConfig.FollowPlayer and torso.Position or torso.Position
                local fixedCFrame = SH.FerrisWheelConfig.FixedDirection and CFrame.Angles(math.rad(SH.FerrisWheelConfig.FixedPitch), math.rad(SH.FerrisWheelConfig.FixedYaw), math.rad(SH.FerrisWheelConfig.FixedRoll)) or nil
                for _, point in ipairs(SH.ferrisWheelPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = (toy.baseAngle + SH.ferrisWheelTime * SH.FerrisWheelConfig.RotationSpeed) % (2 * math.pi)
                        local x, y, z
                        if SH.FerrisWheelConfig.VerticalCircle then
                            x = math.cos(currentAngle) * SH.FerrisWheelConfig.Radius
                            y = math.sin(currentAngle) * SH.FerrisWheelConfig.Radius + SH.FerrisWheelConfig.Height
                            z = 0
                        else
                            x = math.cos(currentAngle) * SH.FerrisWheelConfig.Radius
                            y = SH.FerrisWheelConfig.Height
                            z = math.sin(currentAngle) * SH.FerrisWheelConfig.Radius
                        end
                        local targetPosition = basePosition + Vector3.new(x, y, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        if fixedCFrame then
                            toy.BG.CFrame = CFrame.new(targetPosition) * fixedCFrame
                        else
                            toy.BG.CFrame = CFrame.lookAt(targetPosition, basePosition)
                        end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "観覧車開始", Content = "半径: " .. SH.FerrisWheelConfig.Radius, Time = 3 })
        else
            if SH.ferrisWheelLoopConn then SH.ferrisWheelLoopConn:Disconnect(); SH.ferrisWheelLoopConn = nil end
            for _, point in ipairs(SH.ferrisWheelPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.ferrisWheelPoints = {}; SH.ferrisWheelAssignedToys = {}
            OrionLib:MakeNotification({ Name = "観覧車停止", Content = "観覧車解除", Time = 2 })
        end
    end
    _G.toggleFerrisWheel = toggleFerrisWheel
end

-- ============================================================================
-- ブロック21: アニメーションN1,N2,N3
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleAnimN1(state)
        SH.AnimN1Config.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.animN1Toys = findObjects()
            local count = math.min(#SH.animN1Toys, SH.AnimN1Config.ObjectCount)
            SH.animN1Points = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.animN1Points[i] = { baseAngle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil }
            end
            
            SH.animN1AssignedToys = {}
            for i = 1, math.min(#SH.animN1Toys, #SH.animN1Points) do
                local toy = SH.animN1Toys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false; child.Material = Enum.Material.Neon end end
                        local BG, BP = attachPhysics(primaryPart, 30000, 500)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.animN1Points[i].baseAngle }
                        SH.animN1Points[i].assignedToy = toyTable
                        table.insert(SH.animN1AssignedToys, toyTable)
                    end
                end
            end
            
            SH.animN1Time = 0
            if SH.animN1LoopConn then SH.animN1LoopConn:Disconnect() end
            SH.animN1LoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.AnimN1Config.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.animN1Time = SH.animN1Time + dt
                local basePosition = SH.AnimN1Config.FollowPlayer and torso.Position or torso.Position
                for i, point in ipairs(SH.animN1Points) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local rotationAngle = toy.baseAngle + (SH.animN1Time * SH.AnimN1Config.RotationSpeed)
                        local pulse = math.sin(SH.animN1Time * SH.AnimN1Config.PulseSpeed) * SH.AnimN1Config.PulseAmount
                        local currentRadius = SH.AnimN1Config.Radius + pulse
                        local currentHeight = SH.AnimN1Config.Height + math.sin(SH.animN1Time * 3 + i) * 5
                        local chaosX = math.sin(SH.animN1Time * 2 + i) * 2
                        local chaosY = math.cos(SH.animN1Time * 2.5 + i) * 2
                        local chaosZ = math.sin(SH.animN1Time * 3 + i) * 2
                        local x = math.cos(rotationAngle) * currentRadius + chaosX
                        local z = math.sin(rotationAngle) * currentRadius + chaosZ
                        local y = currentHeight + chaosY
                        local targetPosition = basePosition + Vector3.new(x, y, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "N1開始", Content = "オブジェクト数: " .. #SH.animN1AssignedToys, Time = 3 })
        else
            if SH.animN1LoopConn then SH.animN1LoopConn:Disconnect(); SH.animN1LoopConn = nil end
            for _, point in ipairs(SH.animN1Points) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                    for _, child in ipairs(point.assignedToy.Model:GetDescendants()) do if child:IsA("BasePart") then child.Material = Enum.Material.Plastic end end
                end
            end
            SH.animN1Points = {}; SH.animN1AssignedToys = {}
            OrionLib:MakeNotification({ Name = "N1停止", Content = "アニメーション解除", Time = 2 })
        end
    end
    _G.toggleAnimN1 = toggleAnimN1

    function toggleAnimN2(state)
        SH.AnimN2Config.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.animN2Toys = findObjects()
            local count = math.min(#SH.animN2Toys, SH.AnimN2Config.ObjectCount)
            SH.animN2Points = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.animN2Points[i] = { baseAngle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil }
            end
            
            SH.animN2AssignedToys = {}
            for i = 1, math.min(#SH.animN2Toys, #SH.animN2Points) do
                local toy = SH.animN2Toys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false; child.Material = Enum.Material.Neon end end
                        local BG, BP = attachPhysics(primaryPart, 25000, 400)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.animN2Points[i].baseAngle }
                        SH.animN2Points[i].assignedToy = toyTable
                        table.insert(SH.animN2AssignedToys, toyTable)
                    end
                end
            end
            
            SH.animN2Time = 0
            if SH.animN2LoopConn then SH.animN2LoopConn:Disconnect() end
            SH.animN2LoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.AnimN2Config.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.animN2Time = SH.animN2Time + dt
                local basePosition = SH.AnimN2Config.FollowPlayer and torso.Position or torso.Position
                for i, point in ipairs(SH.animN2Points) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local rotationAngle = toy.baseAngle + (SH.animN2Time * SH.AnimN2Config.RotationSpeed)
                        local rise = (SH.animN2Time * SH.AnimN2Config.RiseSpeed) % (SH.AnimN2Config.TopHeight - SH.AnimN2Config.BaseHeight)
                        local currentHeight = SH.AnimN2Config.BaseHeight + rise
                        local chaos = math.sin(SH.animN2Time * SH.AnimN2Config.ChaosFactor + i) * 2
                        local currentRadius = SH.AnimN2Config.Radius + chaos
                        local x = math.cos(rotationAngle) * currentRadius + math.sin(SH.animN2Time * 5 + i) * 1.5
                        local z = math.sin(rotationAngle) * currentRadius + math.cos(SH.animN2Time * 5 + i) * 1.5
                        local targetPosition = basePosition + Vector3.new(x, currentHeight, z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "N2開始", Content = "オブジェクト数: " .. #SH.animN2AssignedToys, Time = 3 })
        else
            if SH.animN2LoopConn then SH.animN2LoopConn:Disconnect(); SH.animN2LoopConn = nil end
            for _, point in ipairs(SH.animN2Points) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                    for _, child in ipairs(point.assignedToy.Model:GetDescendants()) do if child:IsA("BasePart") then child.Material = Enum.Material.Plastic end end
                end
            end
            SH.animN2Points = {}; SH.animN2AssignedToys = {}
            OrionLib:MakeNotification({ Name = "N2停止", Content = "アニメーション解除", Time = 2 })
        end
    end
    _G.toggleAnimN2 = toggleAnimN2

    function toggleAnimN3(state)
        SH.AnimN3Config.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.animN3Toys = findObjects()
            local count = math.min(#SH.animN3Toys, SH.AnimN3Config.ObjectCount)
            SH.animN3Points = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.animN3Points[i] = { part = part, assignedToy = nil, seed = i }
            end
            
            SH.animN3AssignedToys = {}
            for i = 1, math.min(#SH.animN3Toys, #SH.animN3Points) do
                local toy = SH.animN3Toys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false; child.Material = Enum.Material.Neon end end
                        local BG, BP = attachPhysics(primaryPart, 20000, 300)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, seed = i }
                        SH.animN3Points[i].assignedToy = toyTable
                        table.insert(SH.animN3AssignedToys, toyTable)
                    end
                end
            end
            
            SH.animN3Time = 0
            if SH.animN3LoopConn then SH.animN3LoopConn:Disconnect() end
            SH.animN3LoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.AnimN3Config.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.animN3Time = SH.animN3Time + dt
                local basePosition = SH.AnimN3Config.FollowPlayer and torso.Position or torso.Position
                local explosionFactor = (math.sin(SH.animN3Time * SH.AnimN3Config.CycleSpeed) + 1) / 2
                for i, point in ipairs(SH.animN3Points) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local direction = Vector3.new(math.sin(SH.animN3Time * 2 + toy.seed), math.cos(SH.animN3Time * 3 + toy.seed), math.sin(SH.animN3Time * 4 + toy.seed)).Unit
                        local distance = explosionFactor * SH.AnimN3Config.ExplosionRadius + math.sin(SH.animN3Time * 5 + toy.seed) * SH.AnimN3Config.Randomness
                        local heightOffset = math.sin(SH.animN3Time * 3 + toy.seed) * 5 + SH.AnimN3Config.Height
                        local targetPosition = basePosition + direction * distance
                        targetPosition = Vector3.new(targetPosition.X, heightOffset, targetPosition.Z)
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "N3開始", Content = "オブジェクト数: " .. #SH.animN3AssignedToys, Time = 3 })
        else
            if SH.animN3LoopConn then SH.animN3LoopConn:Disconnect(); SH.animN3LoopConn = nil end
            for _, point in ipairs(SH.animN3Points) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                    for _, child in ipairs(point.assignedToy.Model:GetDescendants()) do if child:IsA("BasePart") then child.Material = Enum.Material.Plastic end end
                end
            end
            SH.animN3Points = {}; SH.animN3AssignedToys = {}
            OrionLib:MakeNotification({ Name = "N3停止", Content = "アニメーション解除", Time = 2 })
        end
    end
    _G.toggleAnimN3 = toggleAnimN3
end

-- ============================================================================
-- ブロック22: 羽V2機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local getPrimaryPart = _G.getPrimaryPart

    function toggleWing(state)
        SH.WingConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.wingList = {}
            local maxObjects = SH.WingConfig.ObjectCount * 2
            local foundCount = 0
            for _, d in ipairs(Workspace:GetDescendants()) do
                if foundCount >= maxObjects then break end
                if d:IsA("Model") and d.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local part = getPrimaryPart(d)
                    if part and not part.Anchored then
                        for _, p in ipairs(d:GetDescendants()) do
                            if p:IsA("BasePart") then
                                pcall(function() p:SetNetworkOwner(LocalPlayer) end)
                                p.CanCollide = false
                                p.CanTouch = false
                            end
                        end
                        if not part:FindFirstChild("WingBodyVelocity") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "WingBodyVelocity"
                            bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                            bv.Velocity = Vector3.new()
                            bv.P = 1e6
                            bv.Parent = part
                        end
                        if not part:FindFirstChild("WingBodyGyro") then
                            local bg = Instance.new("BodyGyro")
                            bg.Name = "WingBodyGyro"
                            bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                            bg.CFrame = part.CFrame
                            bg.P = 1e6
                            bg.Parent = part
                        end
                        table.insert(SH.wingList, { model = d, part = part, index = foundCount + 1, targetPos = part.Position, targetCF = part.CFrame })
                        foundCount = foundCount + 1
                    end
                end
            end
            
            SH.wingTime = 0
            if SH.wingLoopConn then SH.wingLoopConn:Disconnect() end
            
            local function getWingPosition(index, total, time)
                local halfTotal = total / 2
                local isLeftWing = index <= halfTotal
                local wingIndex = isLeftWing and index or (index - halfTotal)
                local t = (wingIndex - 1) / (halfTotal - 1)
                local phase = (time * SH.WingConfig.FlapSpeed - wingIndex * 0.05) * SH.WingConfig.FlapShape
                local sinValue = math.sin(phase)
                local actualFlapAmount = sinValue > 0 and SH.WingConfig.FlapAmount * 0.6 or SH.WingConfig.FlapAmount
                local flapAngle = sinValue * math.rad(actualFlapAmount)
                local baseX = t * SH.WingConfig.Spread
                local rotatedY = baseX * math.sin(flapAngle)
                local rotatedX = baseX * math.cos(flapAngle)
                local sideOffset = isLeftWing and -(3 + rotatedX) or (3 + rotatedX)
                return Vector3.new(sideOffset, SH.WingConfig.VerticalOffset + rotatedY, 0), isLeftWing, wingIndex
            end
            
            SH.wingLoopConn = RunService.Heartbeat:Connect(function(dt)
                if not SH.WingConfig.Enabled then return end
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root or #SH.wingList == 0 then return end
                SH.wingTime = SH.wingTime + dt
                local rootVelocity = root.AssemblyLinearVelocity or root.Velocity or Vector3.new()
                local total = #SH.wingList
                for i, rec in ipairs(SH.wingList) do
                    local part = rec.part
                    if not part or not part.Parent then continue end
                    local localPos, _, wingIndex = getWingPosition(i, total, SH.wingTime)
                    local targetCF = root.CFrame
                    local idealPos = targetCF.Position + (targetCF - targetCF.Position):VectorToWorldSpace(localPos)
                    local idealRotation = targetCF * CFrame.Angles(0, -math.pi/2, 0)
                    local delayMultiplier = 1 + (wingIndex - 1) * 2
                    local actualDelay = SH.WingConfig.ChainDelay * delayMultiplier
                    local delayFactor = math.min(1, dt / actualDelay)
                    rec.targetPos = rec.targetPos:Lerp(idealPos, delayFactor)
                    rec.targetCF = rec.targetCF:Lerp(idealRotation, delayFactor)
                    local targetPos = rec.targetPos
                    local targetRot = rec.targetCF
                    local dir = targetPos - part.Position
                    local distance = dir.Magnitude
                    local bv = part:FindFirstChild("WingBodyVelocity")
                    if bv then
                        if distance > 0.1 then
                            local moveVelocity = dir.Unit * math.min(3000, distance * 50)
                            bv.Velocity = moveVelocity + rootVelocity
                        else
                            bv.Velocity = rootVelocity
                        end
                        bv.P = 1e6
                    end
                    local bg = part:FindFirstChild("WingBodyGyro")
                    if bg then
                        bg.CFrame = targetRot
                        bg.P = 1e6
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "羽V2開始", Content = "オブジェクト数: " .. #SH.wingList, Time = 3 })
        else
            if SH.wingLoopConn then SH.wingLoopConn:Disconnect(); SH.wingLoopConn = nil end
            for _, rec in ipairs(SH.wingList) do
                if rec.part then
                    local bv = rec.part:FindFirstChild("WingBodyVelocity"); if bv then bv:Destroy() end
                    local bg = rec.part:FindFirstChild("WingBodyGyro"); if bg then bg:Destroy() end
                    if rec.model then
                        for _, p in ipairs(rec.model:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = true
                                p.CanTouch = true
                                pcall(function() p:SetNetworkOwner(nil) end)
                            end
                        end
                    end
                end
            end
            SH.wingList = {}
            OrionLib:MakeNotification({ Name = "羽V2停止", Content = "羽V2を解除", Time = 2 })
        end
    end
    _G.toggleWing = toggleWing
end

-- ============================================================================
-- ブロック23: 土星スパークラー機能
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local PhysicsService = _G.PhysicsService
    local SATURN_GROUP_NAME = _G.SATURN_GROUP_NAME

    local function getSaturnHRP()
        if SH.saturnCachedHRP and SH.saturnCachedHRP.Parent then return SH.saturnCachedHRP end
        local c = LocalPlayer.Character
        if c then
            SH.saturnCachedHRP = c:FindFirstChild("HumanoidRootPart")
            return SH.saturnCachedHRP
        end
        return nil
    end

    local function getSaturnPartFromModel(m)
        if m.PrimaryPart then return m.PrimaryPart end
        return m:FindFirstChildWhichIsA("BasePart")
    end

    local function attachSaturnPhysics(p)
        if not p or not p.Parent then return end
        pcall(function() p:SetNetworkOwner(LocalPlayer) end)
        p.CanCollide = false
        p.CanTouch = false
        pcall(function() PhysicsService:SetPartCollisionGroup(p, SATURN_GROUP_NAME) end)
        if not p:FindFirstChild("SaturnBodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "SaturnBodyVelocity"
            bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
            bv.P = 1e6
            bv.Velocity = Vector3.new()
            bv.Parent = p
        end
        if not p:FindFirstChild("SaturnBodyGyro") then
            local bg = Instance.new("BodyGyro")
            bg.Name = "SaturnBodyGyro"
            bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
            bg.P = 1e6
            bg.CFrame = p.CFrame
            bg.Parent = p
        end
    end

    local function detachSaturnPhysics(p)
        if not p then return end
        local bv = p:FindFirstChild("SaturnBodyVelocity")
        if bv then bv:Destroy() end
        local bg = p:FindFirstChild("SaturnBodyGyro")
        if bg then bg:Destroy() end
        p.CanCollide = true
        p.CanTouch = true
        pcall(function() p:SetNetworkOwner(nil) end)
    end

    function rescanSaturn()
        for _, r in ipairs(SH.saturnList) do
            if r.part then detachSaturnPhysics(r.part) end
        end
        SH.saturnList = {}
        local modelName = SH.SaturnConfig.ModelName or "FireworkSparkler"
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("Model") and d.Name == modelName then
                local part = getSaturnPartFromModel(d)
                if part and not part.Anchored then
                    table.insert(SH.saturnList, { model = d, part = part })
                end
            end
        end
        for i = 1, #SH.saturnList do
            attachSaturnPhysics(SH.saturnList[i].part)
        end
    end

    local function saturnTarget(i, count, t, rootCf)
        local center = rootCf.Position + Vector3.new(0, SH.SaturnConfig.BaseHeight, 0)
        local mode = SH.SaturnConfig.Mode or "saturn"

        if mode == "sphere" then
            local LAYERS = SH.SaturnConfig.SphereLayers or 5
            local perLayer = math.floor(count / LAYERS)
            local layer = math.min(math.floor((i - 1) / math.max(perLayer, 1)), LAYERS - 1)
            local indexInLayer = (i - 1) - layer * perLayer
            local countInLayer = (layer == LAYERS - 1) and (count - layer * perLayer) or perLayer

            local yFrac = layer / (LAYERS - 1)
            local y = (yFrac - 0.5) * SH.SaturnConfig.SphereRadius * 2
            local layerRadius = SH.SaturnConfig.SphereRadius * math.sin(math.acos(math.clamp(1 - 2 * yFrac, -1, 1)))

            local baseAngle = (indexInLayer / math.max(countInLayer, 1)) * math.pi * 2
            local rotAngle = (layer == 0) and baseAngle or (baseAngle + t * SH.SaturnConfig.SphereSpeed)

            return Vector3.new(
                layerRadius * 1.3 * math.cos(rotAngle),
                y,
                layerRadius * 1.3 * math.sin(rotAngle)
            )

        elseif mode == "ring" then
            local angle = (i / count) * math.pi * 2 + t * SH.SaturnConfig.RingSpeed
            return Vector3.new(
                SH.SaturnConfig.RingRadius * math.cos(angle),
                0,
                SH.SaturnConfig.RingRadius * math.sin(angle)
            )

        elseif mode == "plot" then
            local angle = (i / count) * math.pi * 2 + t * SH.SaturnConfig.RingSpeed
            local radius = SH.SaturnConfig.PlotRadius * math.sqrt((i - 1) / count)
            local x = radius * math.cos(angle)
            local z = radius * math.sin(angle)
            local wave = math.sin(angle * 3 + t * 2) * 1.5
            return Vector3.new(x, SH.SaturnConfig.PlotHeight + wave, z)

        else -- "saturn"
            local sphereCount = math.floor(count * 0.6)
            local ringCount = count - sphereCount
            if i <= sphereCount then
                local theta = (i / sphereCount) * math.pi * 2
                local phi = math.acos(1 - 2 * (i / sphereCount))
                local r = SH.SaturnConfig.SphereRadius
                local x = r * math.sin(phi) * math.cos(theta + t * SH.SaturnConfig.SphereSpeed)
                local y = r * math.cos(phi)
                local z = r * math.sin(phi) * math.sin(theta + t * SH.SaturnConfig.SphereSpeed)
                return Vector3.new(x, y, z)
            else
                local ringIdx = i - sphereCount
                local angle = (ringIdx / ringCount) * math.pi * 2 + t * SH.SaturnConfig.RingSpeed
                local tilt = math.rad(20)
                local x = SH.SaturnConfig.RingRadius * math.cos(angle)
                local y = SH.SaturnConfig.RingRadius * math.sin(angle) * math.sin(tilt)
                local z = SH.SaturnConfig.RingRadius * math.sin(angle) * math.cos(tilt)
                return Vector3.new(x, y, z)
            end
        end
    end

    function toggleSaturn(state)
        SH.SaturnConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end

            rescanSaturn()

            if SH.saturnLoopConn then SH.saturnLoopConn:Disconnect(); SH.saturnLoopConn = nil end
            SH.saturnTAccum = 0

            SH.saturnLoopConn = RunService.Heartbeat:Connect(function(dt)
                if not SH.SaturnConfig.Enabled then return end

                for i = #SH.saturnList, 1, -1 do
                    if not SH.saturnList[i].part or not SH.saturnList[i].part.Parent then
                        table.remove(SH.saturnList, i)
                    end
                end

                if #SH.saturnList == 0 then return end

                local root = getSaturnHRP()
                if not root then return end

                SH.saturnTAccum = SH.saturnTAccum + dt
                local rootCf = root.CFrame
                local center = rootCf.Position + Vector3.new(0, SH.SaturnConfig.BaseHeight, 0)
                local listCount = #SH.saturnList

                local targets = table.create(listCount)
                for i = 1, listCount do
                    targets[i] = center + saturnTarget(i, listCount, SH.saturnTAccum, rootCf)
                end

                for i = 1, listCount do
                    local rec = SH.saturnList[i]
                    local p = rec.part
                    if p and p.Parent then
                        local target = targets[i]
                        local dir = target - p.Position
                        local d = dir.Magnitude

                        local bv = p:FindFirstChild("SaturnBodyVelocity")
                        if bv then
                            if d > 0.05 then
                                local speed = math.min(SH.SaturnConfig.MaxVel or 700, d * (SH.SaturnConfig.Strength or 16) + d * d * 2)
                                bv.Velocity = dir.Unit * speed
                            else
                                bv.Velocity = Vector3.new()
                            end
                        end

                        local bg = p:FindFirstChild("SaturnBodyGyro")
                        if bg then
                            local nextTarget = targets[(i % listCount) + 1]
                            local lookDir = nextTarget - target
                            if lookDir.Magnitude > 0.01 then
                                local goalCF = CFrame.lookAt(p.Position, p.Position + lookDir)
                                bg.CFrame = bg.CFrame:Lerp(goalCF, 0.15)
                            end
                        end
                    end
                end
            end)

            OrionLib:MakeNotification({
                Name = "土星スパークラー",
                Content = "有効化 - オブジェクト数: " .. #SH.saturnList,
                Time = 3
            })
        else
            if SH.saturnLoopConn then SH.saturnLoopConn:Disconnect(); SH.saturnLoopConn = nil end

            for _, rec in ipairs(SH.saturnList) do
                local p = rec.part
                if p and p.Parent then
                    local bv = p:FindFirstChild("SaturnBodyVelocity")
                    if bv then bv.Velocity = Vector3.new() end
                    detachSaturnPhysics(p)
                end
            end

            SH.saturnList = {}
            OrionLib:MakeNotification({
                Name = "土星スパークラー",
                Content = "無効化",
                Time = 2
            })
        end
    end
    _G.toggleSaturn = toggleSaturn

    Workspace.DescendantAdded:Connect(function(inst)
        if inst:IsA("Model") and inst.Name == (SH.SaturnConfig.ModelName or "FireworkSparkler") then
            task.wait(0.1)
            if SH.SaturnConfig.Enabled then rescanSaturn() end
        end
    end)

    Workspace.DescendantRemoving:Connect(function(inst)
        if inst:IsA("Model") and inst.Name == (SH.SaturnConfig.ModelName or "FireworkSparkler") then
            task.defer(function()
                if SH.SaturnConfig.Enabled then rescanSaturn() end
            end)
        end
    end)
end

-- ============================================================================
-- ブロック24: ピアノ機能トグル
-- ============================================================================
do
    local SH = _G.SH
    local OrionLib = _G.OrionLib
    local getMusicKeyboard = _G.getMusicKeyboard
    local setupPianoFollow = _G.setupPianoFollow
    local stopPiano = _G.stopPiano
    local stopSong = _G.stopSong

    function togglePiano(state)
        SH.PianoConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.PianoConfig.Keyboard = getMusicKeyboard()
            
            if SH.PianoConfig.Keyboard then
                if SH.PianoConfig.FollowPlayer then setupPianoFollow() end
                OrionLib:MakeNotification({
                    Name = "ピアノ機能",
                    Content = "MusicKeyboardを検出しました",
                    Time = 3
                })
            else
                SH.PianoConfig.Enabled = false
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "MusicKeyboardが見つかりません",
                    Time = 5
                })
            end
        else
            stopSong()
            stopPiano()
            OrionLib:MakeNotification({ Name = "ピアノ機能停止", Content = "ピアノ機能を無効化しました", Time = 2 })
        end
    end
    _G.togglePiano = togglePiano
end

-- ============================================================================
-- ブロック25: アンチタブ (掴まれても脱出 + Anti Grab V2 + Anti Gucci + Anti Void)
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local ReplicatedStorage = _G.ReplicatedStorage
    local Players = _G.Players
    local Workspace = _G.Workspace

    local AntiTab = Window:MakeTab({ 
        Name = "アンチ", 
        Icon = "rbxassetid://4483362458", 
        PremiumOnly = false 
    })

    -- ================================================================
    -- サービスとリモート
    -- ================================================================
    local RS = ReplicatedStorage
    local GE = RS:FindFirstChild("GrabEvents") or RS:WaitForChild("GrabEvents", 5)
    local SetNetworkOwner = GE and GE:FindFirstChild("SetNetworkOwner")
    local DestroyGrabLine = GE and GE:FindFirstChild("DestroyGrabLine")
    local StruggleEvent = RS:FindFirstChild("CharacterEvents") and RS.CharacterEvents:FindFirstChild("Struggle")
    local RagdollRemote = RS:FindFirstChild("CharacterEvents") and RS.CharacterEvents:FindFirstChild("RagdollRemote")
    local SpawnToyRemote = RS:FindFirstChild("MenuToys") and RS.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
    local DestroyToy = RS:FindFirstChild("MenuToys") and RS.MenuToys:FindFirstChild("DestroyToy")
    local isHeldValue = LocalPlayer:FindFirstChild("IsHeld") or LocalPlayer:WaitForChild("IsHeld", 5)

    AntiTab:AddSection({ Name = "防衛機能" })

    -- ================================================================
    -- 1. 掴まれても脱出 (シンプル版)
    -- ================================================================
    local AntiGrabEnabled = false
    AntiTab:AddToggle({
        Name = "掴まれても脱出 (シンプル)",
        Default = false,
        Callback = function(Value)
            AntiGrabEnabled = Value
        end
    })

    RunService.Heartbeat:Connect(function()
        if not AntiGrabEnabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        if isHeldValue and isHeldValue.Value == true then
            pcall(function()
                if StruggleEvent then StruggleEvent:FireServer(LocalPlayer) end
            end)
            humanoidRootPart.Velocity = Vector3.new()
            humanoidRootPart.Anchored = true
        else
            humanoidRootPart.Anchored = false
        end
    end)

    -- ================================================================
    -- 2. Anti Grab V2 (強化版)
    -- ================================================================
    local antiGrabV2Enabled = false
    local heldConnectionV2 = nil

    local function StopAntiGrabV2()
        antiGrabV2Enabled = false
        if heldConnectionV2 then heldConnectionV2:Disconnect() heldConnectionV2 = nil end
        local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root then Root.Anchored = false end
    end

    local function StartAntiGrabV2()
        if heldConnectionV2 then heldConnectionV2:Disconnect() end
        local isHeld = LocalPlayer:FindFirstChild("IsHeld")
        if not isHeld then return end
        
        heldConnectionV2 = isHeld:GetPropertyChangedSignal("Value"):Connect(function()
            if not antiGrabV2Enabled or not isHeld.Value then return end
            local Char = LocalPlayer.Character
            if not Char then return end
            
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if not (Root and Hum) then return end

            -- コリジョンオフ
            for _, part in pairs(Char:GetDescendants()) do 
                if part:IsA("BasePart") then part.CanCollide = false end 
            end

            -- サーバー防御ループ
            task.spawn(function()
                while antiGrabV2Enabled and isHeld.Value do
                    pcall(function()
                        if StruggleEvent then StruggleEvent:FireServer() end
                        if RagdollRemote then RagdollRemote:FireServer(Root, 0) end
                        if SetNetworkOwner then SetNetworkOwner:FireServer(Root, Root.CFrame) end
                    end)
                    task.wait(0.03)
                end
            end)

            -- 物理状態強制
            task.spawn(function()
                while antiGrabV2Enabled and isHeld.Value do
                    pcall(function()
                        Hum.Sit = false
                        Hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        Hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        if Root then
                            Root.Anchored = true
                            Root.AssemblyLinearVelocity = Vector3.zero
                            Root.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                    task.wait(0.03)
                end
                if Root then Root.Anchored = false end
            end)
        end)
        
        -- 既に掴まれている場合
        if isHeld.Value then
            local Char = LocalPlayer.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            if Root then Root.Anchored = true end
            task.spawn(function()
                while antiGrabV2Enabled and isHeld.Value do
                    if StruggleEvent then StruggleEvent:FireServer() end
                    task.wait(0.05)
                end
                if Root then Root.Anchored = false end
            end)
        end
    end

    AntiTab:AddToggle({
        Name = "Anti Grab V2 (強化)",
        Default = false,
        Callback = function(Value)
            antiGrabV2Enabled = Value
            if Value then
                StartAntiGrabV2()
                OrionLib:MakeNotification({ Name = "Anti Grab V2", Content = "有効化されました", Time = 3 })
            else
                StopAntiGrabV2()
                OrionLib:MakeNotification({ Name = "Anti Grab V2", Content = "無効化されました", Time = 3 })
            end
        end
    })

    -- キャラクター再出現時のウォッチドッグ (V2)
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if antiGrabV2Enabled then StartAntiGrabV2() end
    end)

    AntiTab:AddParagraph("説明", 
        "掴まれても脱出(シンプル): Struggle連打 + アンカー\n" ..
        "Anti Grab V2(強化): コリジョンオフ + Ragdoll解除 + 物理ロック"
    )

    -- ================================================================
    -- 3. Anti Gucci (トラクター防御)
    -- ================================================================
    AntiTab:AddSection({ Name = "Anti Gucci" })

    local autoGucciActive = false
    local autoGucciConn = nil
    local autoGucciSpamTask = nil

    local function cleanupGucciTasks()
        if autoGucciSpamTask then
            task.cancel(autoGucciSpamTask)
            autoGucciSpamTask = nil
        end
    end

    local function SpawnGucciToy(toyName, hrp)
        if not SpawnToyRemote then return nil end
        local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if not inv then return nil end
        
        local spawnCF = hrp.CFrame * CFrame.new(0, 14, 20)
        task.spawn(function()
            pcall(function() SpawnToyRemote:InvokeServer(toyName, spawnCF, Vector3.zero) end)
        end)

        local t = tick()
        local spawnedToy = nil
        repeat
            task.wait(0.1)
            spawnedToy = inv:FindFirstChild(toyName)
        until spawnedToy or (tick() - t > 3)
        return spawnedToy
    end

    local function StartGucci()
        if autoGucciConn then autoGucciConn:Disconnect() end
        
        local GucciThing = nil
        local isActive = false
        
        local function gucci()
            if not autoGucciActive then return end
            isActive = true
            
            local char = LocalPlayer.Character
            if not char then isActive = false return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            
            if not (hrp and hum and inv) then isActive = false return end

            cleanupGucciTasks()
            
            if DestroyToy then
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AutoGucci" or v.Name == "TractorGreen" then
                        pcall(function() DestroyToy:FireServer(v) end)
                    end
                end
            end
            
            local isHeld = LocalPlayer:FindFirstChild("IsHeld")
            while isHeld and isHeld.Value do task.wait() end
            
            hum.Sit = false
            task.wait(0.1)
            
            GucciThing = SpawnGucciToy("TractorGreen", hrp)
            while not GucciThing and autoGucciActive do
                task.wait(0.25)
                GucciThing = SpawnGucciToy("TractorGreen", hrp)
            end
            
            if not GucciThing then isActive = false return end
            GucciThing.Name = "AutoGucci"
            
            local seat = GucciThing:FindFirstChild("VehicleSeat")
            if not seat then isActive = false return end
            
            autoGucciSpamTask = task.spawn(function()
                while isActive and autoGucciActive do
                    if RagdollRemote then pcall(function() RagdollRemote:FireServer(hrp, 0) end) end
                    if StruggleEvent then pcall(function() StruggleEvent:FireServer(LocalPlayer) end) end
                    task.wait(0.05)
                end
            end)
            
            local t0 = tick()
            while not hum.SeatPart and autoGucciActive and tick() - t0 < 3 do
                seat:Sit(hum)
                task.wait(0.1)
            end
            
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.Anchored = true
            
            task.spawn(function()
                task.wait(0.3)
                GucciThing:PivotTo(CFrame.new(0, 1e6, 0))
                for _, p in pairs(GucciThing:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Anchored = true
                    end
                end
            end)
            
            hrp.Anchored = false
            isActive = false
        end
        
        gucci()
        
        autoGucciConn = RunService.Heartbeat:Connect(function()
            if not autoGucciActive then return end
            if isActive then return end
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            local isHeld = LocalPlayer:FindFirstChild("IsHeld")
            
            if not (hrp and hum) or hum.Health <= 0 then
                isActive = true
                LocalPlayer.CharacterAdded:Wait()
                task.wait(0.5)
                gucci()
                return
            end
            
            if (isHeld and isHeld.Value) or hum.Sit then
                gucci()
            end
        end)
    end

    AntiTab:AddToggle({
        Name = "Anti Gucci",
        Default = false,
        Callback = function(Value)
            autoGucciActive = Value
            if Value then
                StartGucci()
                OrionLib:MakeNotification({ Name = "Anti Gucci", Content = "有効化されました", Time = 3 })
            else
                cleanupGucciTasks()
                if autoGucciConn then autoGucciConn:Disconnect() autoGucciConn = nil end
                local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                if inv and DestroyToy then
                    for _, v in pairs(inv:GetChildren()) do
                        if v.Name == "AutoGucci" or v.Name == "TractorGreen" then
                            pcall(function() DestroyToy:FireServer(v) end)
                        end
                    end
                end
                OrionLib:MakeNotification({ Name = "Anti Gucci", Content = "無効化されました", Time = 3 })
            end
        end
    })

    -- ================================================================
    -- 4. Anti Void (ボイド落下防止)
    -- ================================================================
    AntiTab:AddSection({ Name = "Anti Void" })
    AntiTab:AddToggle({
        Name = "Anti Void",
        Default = false,
        Callback = function(Value)
            if Value then
                Workspace.FallenPartsDestroyHeight = 0/0
                OrionLib:MakeNotification({ Name = "Anti Void", Content = "有効化されました", Time = 3 })
            else
                Workspace.FallenPartsDestroyHeight = -100
                OrionLib:MakeNotification({ Name = "Anti Void", Content = "無効化されました", Time = 3 })
            end
        end
    })

    AntiTab:AddParagraph("注意", "Anti Voidはボイド落下を防ぎます")
end

-- ============================================================================
-- ブロック26: Mi(=^・^=)タブ (ユーティリティ + 三人称視点)
-- ※「掴まれても脱出」は削除し、アンチタブに移動済み
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local LocalPlayer = _G.LocalPlayer
    local Camera = _G.Camera
    local RunService = _G.RunService
    local UserInputService = _G.UserInputService
    local Players = _G.Players
    local Theme = _G.Theme
    local SH = _G.SH

    local MITab = Window:MakeTab({ 
        Name = "Mi(=^・^=)", 
        Icon = "rbxassetid://4483362458", 
        PremiumOnly = false 
    })

    -- ================================================================
    -- 防衛機能 (削除 - アンチタブに移動済み)
    -- ================================================================

    -- ================================================================
    -- 移動機能 (維持)
    -- ================================================================
    MITab:AddSection({ Name = "移動機能" })

    local UtilityConfig = {
        InfiniteJump = false,
        Noclip = false,
        TPWalk = false,
        TPWalkSpeed = 50,
        ESP = false,
        FOV = 70,
        OriginalFOV = 70,
        ThirdPerson = false
    }

    local NoclipConnection = nil
    local OriginalCollision = {}
    local TPWalkConnection = nil
    local OriginalWalkSpeed = 16
    local ESPConnection = nil
    local ESPLabels = {}

    -- 無限ジャンプ
    local function toggleInfiniteJump(state)
        UtilityConfig.InfiniteJump = state
        if state then
            UserInputService.JumpRequest:Connect(function()
                if UtilityConfig.InfiniteJump and LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:ChangeState("Jumping") end
                end
            end)
        end
        OrionLib:MakeNotification({ Name = "無限ジャンプ", Content = state and "有効" or "無効", Time = 2 })
    end

    -- ノークリップ
    local function enableNoclip()
        if NoclipConnection then NoclipConnection:Disconnect(); NoclipConnection = nil end
        OriginalCollision = {}
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then OriginalCollision[part] = part.CanCollide end
            end
        end
        NoclipConnection = RunService.Stepped:Connect(function()
            if UtilityConfig.Noclip and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end

    local function disableNoclip()
        if NoclipConnection then NoclipConnection:Disconnect(); NoclipConnection = nil end
        if LocalPlayer.Character then
            for part, canCollide in pairs(OriginalCollision) do
                if part and part.Parent then part.CanCollide = canCollide end
            end
            OriginalCollision = {}
        end
    end

    local function toggleNoclip(state)
        UtilityConfig.Noclip = state
        if state then enableNoclip() else disableNoclip() end
        OrionLib:MakeNotification({ Name = "ノークリップ", Content = state and "有効" or "無効", Time = 2 })
    end

    -- TPWalk
    local function enableTPWalk()
        if TPWalkConnection then TPWalkConnection:Disconnect(); TPWalkConnection = nil end
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then OriginalWalkSpeed = humanoid.WalkSpeed end
        end

        TPWalkConnection = RunService.RenderStepped:Connect(function(dt)
            if not UtilityConfig.TPWalk or not LocalPlayer.Character then return end

            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoidRootPart then
                humanoid.WalkSpeed = UtilityConfig.TPWalkSpeed

                local moveDirection = Vector3.new(0, 0, 0)
                local moveVector = humanoid.MoveDirection

                if moveVector.Magnitude > 0 then
                    moveDirection = moveVector
                else
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + humanoidRootPart.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - humanoidRootPart.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - humanoidRootPart.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + humanoidRootPart.CFrame.RightVector
                    end
                end

                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit
                    humanoidRootPart.Velocity = Vector3.new(
                        moveDirection.X * UtilityConfig.TPWalkSpeed,
                        humanoidRootPart.Velocity.Y,
                        moveDirection.Z * UtilityConfig.TPWalkSpeed
                    )
                else
                    humanoidRootPart.Velocity = Vector3.new(0, humanoidRootPart.Velocity.Y, 0)
                end
            end
        end)
    end

    local function disableTPWalk()
        if TPWalkConnection then TPWalkConnection:Disconnect(); TPWalkConnection = nil end
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = OriginalWalkSpeed end
        end
    end

    local function toggleTPWalk(state)
        UtilityConfig.TPWalk = state
        if state then enableTPWalk() else disableTPWalk() end
        OrionLib:MakeNotification({ Name = "TPWalk", Content = state and "有効" or "無効", Time = 2 })
    end

    -- ESP
    local function enableESP()
        if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
        for _, label in pairs(ESPLabels) do if label then label:Destroy() end end
        ESPLabels = {}

        ESPConnection = RunService.RenderStepped:Connect(function()
            if not UtilityConfig.ESP then return end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        if not ESPLabels[player] then
                            local label = Instance.new("BillboardGui")
                            label.Name = "ESP_" .. player.Name
                            label.Adornee = humanoidRootPart
                            label.AlwaysOnTop = true
                            label.Size = UDim2.new(0, 200, 0, 50)
                            label.StudsOffset = Vector3.new(0, 3, 0)

                            local textLabel = Instance.new("TextLabel")
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Text = player.Name
                            textLabel.TextColor3 = Color3.new(1, 1, 1)
                            textLabel.TextStrokeTransparency = 0
                            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                            textLabel.Font = Enum.Font.SourceSansBold
                            textLabel.TextSize = 20
                            textLabel.Parent = label

                            label.Parent = humanoidRootPart
                            ESPLabels[player] = label
                        end

                        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and
                            (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0

                        local label = ESPLabels[player]
                        if label and label:FindFirstChildOfClass("TextLabel") then
                            label:FindFirstChildOfClass("TextLabel").Text = string.format("%s\n[%.1f studs]", player.Name, distance)
                        end
                    end
                end
            end

            for player, label in pairs(ESPLabels) do
                if not Players:FindFirstChild(player.Name) then
                    label:Destroy()
                    ESPLabels[player] = nil
                end
            end
        end)
    end

    local function disableESP()
        if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
        for _, label in pairs(ESPLabels) do if label then label:Destroy() end end
        ESPLabels = {}
    end

    local function toggleESP(state)
        UtilityConfig.ESP = state
        if state then enableESP() else disableESP() end
        OrionLib:MakeNotification({ Name = "ESP", Content = state and "有効" or "無効", Time = 2 })
    end

    -- 三人称視点
    local function toggleThirdPerson(state)
        UtilityConfig.ThirdPerson = state
        if state then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 1000
            LocalPlayer.CameraMinZoomDistance = 0.5
        else
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end

    -- UI作成
    MITab:AddSection({ Name = "移動機能" })
    MITab:AddToggle({ Name = "無限ジャンプ", Default = false, Callback = toggleInfiniteJump })
    MITab:AddToggle({ Name = "ノークリップ", Default = false, Callback = toggleNoclip })
    MITab:AddToggle({ Name = "TPWalk", Default = false, Callback = toggleTPWalk })
    MITab:AddSlider({
        Name = "TPWalk速度",
        Min = 16,
        Max = 5000,
        Default = UtilityConfig.TPWalkSpeed,
        Color = Theme.SliderColor,
        Increment = 5,
        ValueName = "速度",
        Callback = function(v) UtilityConfig.TPWalkSpeed = v end
    })

    MITab:AddSection({ Name = "視覚機能" })
    MITab:AddToggle({ Name = "ESP", Default = false, Callback = toggleESP })
    MITab:AddToggle({ Name = "三人称視点", Default = false, Callback = toggleThirdPerson })
    MITab:AddSlider({
        Name = "FOV",
        Min = -5,
        Max = 180,
        Default = UtilityConfig.FOV,
        Color = Theme.SliderColor,
        Increment = 1,
        ValueName = "度",
        Callback = function(v)
            UtilityConfig.FOV = v
            if Camera then Camera.FieldOfView = v end
        end
    })
    MITab:AddButton({
        Name = "FOVリセット",
        Callback = function()
            if Camera then
                Camera.FieldOfView = UtilityConfig.OriginalFOV
                UtilityConfig.FOV = UtilityConfig.OriginalFOV
            end
        end
    })

    MITab:AddSection({ Name = "制御" })
    MITab:AddButton({
        Name = "全機能停止",
        Callback = function()
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            if UtilityConfig.TPWalk then toggleTPWalk(false) end
            if UtilityConfig.Noclip then toggleNoclip(false) end
            if UtilityConfig.ESP then toggleESP(false) end
            if Camera then
                Camera.FieldOfView = UtilityConfig.OriginalFOV
                UtilityConfig.FOV = UtilityConfig.OriginalFOV
            end
            OrionLib:MakeNotification({ Name = "全機能停止", Content = "すべての機能を停止しました", Time = 3 })
        end
    })
end

-- ============================================================================
-- ブロック27: 攻撃系タブ (旧KICK)
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local Players = _G.Players
    local LocalPlayer = _G.LocalPlayer
    local ReplicatedStorage = _G.ReplicatedStorage
    local RunService = _G.RunService
    local Workspace = _G.Workspace
    local UserInputService = _G.UserInputService

    local AttackTab = Window:MakeTab({ Name = "攻撃系", Icon = "rbxassetid://4483345998", PremiumOnly = false })
    
    -- 注意書き
    AttackTab:AddParagraph("注意！", "悪用厳禁！")
    
    -- ================================================================
    -- セクション1: KICK V1 (旧セレクトKick)
    -- ================================================================
    AttackTab:AddSection({ Name = "KICK V1 (Blob Grab)" })
    
    local kickLoopEnabled = false
    local selectedKickPlayer = nil

    local function getPlayerTable()
        local players = {}
        for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer then table.insert(players, player.Name) end end
        return players
    end

    local playerDropdown = AttackTab:AddDropdown({
        Name = "Target Player",
        Default = "",
        Options = getPlayerTable(),
        Callback = function(value)
            selectedKickPlayer = Players:FindFirstChild(value)
            OrionLib:MakeNotification({ Name = "Player Selected", Content = "Target: " .. value, Time = 2 })
        end
    })

    AttackTab:AddButton({
        Name = "Refresh Player List",
        Callback = function()
            playerDropdown:Refresh(getPlayerTable())
            OrionLib:MakeNotification({ Name = "Player List", Content = "Player list updated!", Time = 1 })
        end
    })

    local kickToggle = AttackTab:AddToggle({
        Name = "Loop Kick V1 (grab + blob)",
        Default = false,
        Callback = function(on)
            kickLoopEnabled = on
            if on and not selectedKickPlayer then
                OrionLib:MakeNotification({ Name = "Error", Content = "Please select a target player first!", Time = 2 })
                kickToggle:SetValue(false)
                return
            end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local seat = hum and hum.SeatPart
            if on and (not seat or seat.Parent.Name ~= "CreatureBlobman") then
                OrionLib:MakeNotification({ Name = "Error", Content = "You must be sitting on a blob creature!", Time = 2 })
                kickToggle:SetValue(false)
                return
            end
            if not on then
                kickLoopEnabled = false
                OrionLib:MakeNotification({ Name = "Loop Kick V1", Content = "Loop Kick stopped", Time = 1.5 })
                return
            end

            OrionLib:MakeNotification({ Name = "Loop Kick V1", Content = "Started on: " .. selectedKickPlayer.Name, Time = 2 })

            task.spawn(function()
                local RS = ReplicatedStorage
                local GE = RS:WaitForChild("GrabEvents")
                local RunServiceLocal = RunService

                local blob = seat.Parent
                local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
                local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")

                local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")

                local R_Det = blob:FindFirstChild("RightDetector")
                local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))

                local SavedPos = blobRoot.CFrame

                local tChar = selectedKickPlayer.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

                if tRoot and blobRoot then
                    local bringStart = tick()
                    while tick() - bringStart < 0.35 do
                        if not kickLoopEnabled then break end
                        blobRoot.CFrame = tRoot.CFrame
                        blobRoot.Velocity = Vector3.zero
                        pcall(function()
                            if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                        end)
                        RunServiceLocal.Heartbeat:Wait()
                    end
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                    task.wait(0.05)
                end

                local packetTimer = 0

                while kickLoopEnabled do
                    if not selectedKickPlayer or not selectedKickPlayer.Parent or not selectedKickPlayer.Character then break end

                    tChar = selectedKickPlayer.Character
                    tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar and tChar:FindFirstChild("Humanoid")

                    if tRoot and tHum and tHum.Health > 0 and blobRoot then
                        blobRoot.CFrame = SavedPos
                        blobRoot.Velocity = Vector3.zero
                        local lockPos = SavedPos * CFrame.new(0, 23, 0)
                        tRoot.CFrame = lockPos
                        tRoot.Velocity = Vector3.zero
                        tRoot.RotVelocity = Vector3.zero

                        if tick() - packetTimer > 0.05 then
                            packetTimer = tick()
                            pcall(function()
                                tHum.PlatformStand = true
                                tHum.Sit = true
                                GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                                if R_Det then
                                    local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                                    if weld then CD:FireServer(weld) end
                                end
                                GE.DestroyGrabLine:FireServer(tRoot)
                                if R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                                GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            end)
                        end
                    else
                        blobRoot.CFrame = SavedPos
                        blobRoot.Velocity = Vector3.zero
                    end

                    if not kickLoopEnabled then break end
                    RunServiceLocal.Heartbeat:Wait()
                end

                kickLoopEnabled = false
                kickToggle:SetValue(false)

                if blobRoot then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                end

                OrionLib:MakeNotification({ Name = "Loop Kick V1", Content = "Stopped", Time = 1.5 })
            end)
        end
    })

    -- ================================================================
    -- セクション2: KICK V2 (Orbit & Grab)
    -- ================================================================
    AttackTab:AddSection({ Name = "KICK V2 (Orbit & Grab)" })

    local orbitRunning = false
    local selectedOrbitTargetName = ""
    local orbitRadius = 5
    local orbitSpeed = 10
    local orbitHeightOffset = 10
    local orbitAngle = 0
    local orbitCurrentLoopId = 0
    local orbitPlayerMap = {}

    local function getOrbitPlayerNames()
        local names = {}
        orbitPlayerMap = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local displayStr = player.DisplayName .. " (@ " .. player.Name .. ")"
                table.insert(names, displayStr)
                orbitPlayerMap[displayStr] = player.Name
            end
        end
        return names
    end

    local OrbitTargetDropdown = AttackTab:AddDropdown({
        Name = "ターゲットを選択",
        Default = "",
        Options = getOrbitPlayerNames(),
        Callback = function(Value)
            selectedOrbitTargetName = orbitPlayerMap[Value] or ""
        end
    })

    AttackTab:AddButton({
        Name = "プレイヤーリストを更新",
        Callback = function()
            OrbitTargetDropdown:Refresh(getOrbitPlayerNames(), true)
        end
    })

    AttackTab:AddToggle({
        Name = "drift kick V2",
        Default = false,
        Callback = function(v)
            orbitRunning = v
            orbitCurrentLoopId = orbitCurrentLoopId + 1
            local myLoopId = orbitCurrentLoopId

            if not v then return end

            local target = Players:FindFirstChild(selectedOrbitTargetName)
            
            if target and target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local blobman = nil
                local spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
                
                if not blobman then
                    local mt = ReplicatedStorage:FindFirstChild("MenuToys")
                    local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction")
                    if st then
                        local myRoot = LocalPlayer.Character.HumanoidRootPart
                        local spawnCF = myRoot and (myRoot.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 50, 0)
                        st:InvokeServer("CreatureBlobman", spawnCF, Vector3.zero)
                        task.wait(0.8)
                        spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                        if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
                    end
                end

                if not blobman then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj.Name == "CreatureBlobman" and obj:FindFirstChild("VehicleSeat") then
                            blobman = obj
                            break
                        end
                    end
                end
                
                if blobman then
                    local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
                    local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                    local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop")

                    local lDet = blobman:FindFirstChild("LeftDetector")
                    local rDet = blobman:FindFirstChild("RightDetector")
                    local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChild("RigidConstraint"))
                    local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChild("RigidConstraint"))
                    
                    local seat = blobman:FindFirstChild("VehicleSeat")
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    
                    if seat and hum then
                        if seat.Occupant ~= hum then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.2)
                            seat:Sit(hum)
                            task.wait(0.5)
                        end
                    end
                    
                    local GE = ReplicatedStorage:FindFirstChild("GrabEvents")
                    
                    if GE and grabRemote and dropRemote and ((lDet and lWeld) or (rDet and rWeld)) then
                        OrionLib:MakeNotification({
                            Name = "実行",
                            Content = "drift kick V2 を開始します",
                            Time = 3
                        })

                        task.spawn(function()
                            local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
                            local Det = rDet or lDet
                            local Weld = rWeld or lWeld
                            
                            local bringStart = tick()
                            while tick() - bringStart < 0.35 do
                                if myLoopId ~= orbitCurrentLoopId or not orbitRunning or not blobman or not blobman.Parent then return end
                                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                    local tRoot = target.Character.HumanoidRootPart
                                    blobRoot.CFrame = tRoot.CFrame
                                    blobRoot.AssemblyLinearVelocity = Vector3.zero
                                    
                                    pcall(function()
                                        if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                                    end)
                                end
                                RunService.Heartbeat:Wait()
                            end
                            
                            if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
                            
                            local SavedPos = target.Character.HumanoidRootPart.CFrame
                            local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
                            
                            local lastTime = tick()
                            local lastDropTime = tick()
                            local dropCount = 0
                            
                            while orbitRunning and blobman and blobman.Parent do
                                if myLoopId ~= orbitCurrentLoopId then break end
                                if not target or not target.Parent or not target.Character then break end
                                
                                local tChar = target.Character
                                local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                                local tHum = tChar:FindFirstChild("Humanoid")
                                
                                if dropCount < 2 and (tick() - lastDropTime) > 0.8 then
                                    dropCount = dropCount + 1
                                    
                                    pcall(function()
                                        local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                                        if currentWeld then
                                            dropRemote:FireServer(currentWeld)
                                        end
                                        GE.DestroyGrabLine:FireServer(tRoot)
                                    end)
                                    
                                    blobRoot.CFrame = SavedPos
                                    blobRoot.AssemblyLinearVelocity = Vector3.zero
                                    
                                    task.wait(0.1)
                                    
                                    local reCaptureStart = tick()
                                    while tick() - reCaptureStart < 0.35 do
                                        if myLoopId ~= orbitCurrentLoopId or not orbitRunning or not blobman or not blobman.Parent then break end
                                        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                            local currentTRoot = target.Character.HumanoidRootPart
                                            blobRoot.CFrame = currentTRoot.CFrame
                                            blobRoot.AssemblyLinearVelocity = Vector3.zero
                                            
                                            pcall(function()
                                                if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end
                                                GE.CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false)
                                                GE.SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame)
                                            end)
                                        end
                                        RunService.Heartbeat:Wait()
                                    end
                                    
                                    lastTime = tick()
                                    lastDropTime = tick()
                                end

                                if tRoot and tHum and tHum.Health > 0 and blobRoot then
                                    local currentTime = tick()
                                    local dt = currentTime - lastTime
                                    lastTime = currentTime

                                    orbitAngle = orbitAngle + (orbitSpeed * dt)
                                    local offsetX = math.cos(orbitAngle) * orbitRadius
                                    local offsetZ = math.sin(orbitAngle) * orbitRadius
                                    
                                    local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, orbitHeightOffset, offsetZ)
                                    blobRoot.CFrame = CFrame.new(blobPos, targetCenterCFrame.Position)
                                    blobRoot.AssemblyLinearVelocity = Vector3.zero
                                    blobRoot.AssemblyAngularVelocity = Vector3.zero
                                    
                                    tRoot.CFrame = targetCenterCFrame
                                    tRoot.AssemblyLinearVelocity = Vector3.zero
                                    tRoot.AssemblyAngularVelocity = Vector3.zero

                                    pcall(function()
                                        tHum.PlatformStand = true
                                        tHum.Sit = true
                                        GE.SetNetworkOwner:FireServer(tRoot, targetCenterCFrame)
                                        
                                        local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                                        if currentWeld then
                                            dropRemote:FireServer(currentWeld)
                                        end
                                        
                                        GE.DestroyGrabLine:FireServer(tRoot)
                                        if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false)
                                    end)
                                else
                                    break
                                end
                                RunService.Heartbeat:Wait()
                            end
                            
                            if blobRoot and SavedPos then
                                pcall(function()
                                    local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                                    if currentWeld then dropRemote:FireServer(currentWeld) end
                                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                        GE.DestroyGrabLine:FireServer(target.Character.HumanoidRootPart)
                                    end
                                end)
                                blobRoot.CFrame = SavedPos
                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                            end
                        end)
                    else
                        OrionLib:MakeNotification({
                            Name = "エラー",
                            Content = "必要なRemoteEventやDetectorが見つかりません",
                            Time = 5
                        })
                        orbitRunning = false
                    end
                else
                    OrionLib:MakeNotification({
                        Name = "エラー",
                        Content = "Blobmanの取得・生成に失敗しました",
                        Time = 3
                    })
                    orbitRunning = false
                end
            else
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "ターゲットが無効です",
                    Time = 3
                })
                orbitRunning = false
            end
        end
    })

    -- ================================================================
    -- セクション3: ふっとばす (旧KICK V3)
    -- ================================================================
    AttackTab:AddSection({ Name = "ふっとばす" })

    local BlobmanBeta = {}

    function BlobmanBeta.getLocalChar() return LocalPlayer.Character end
    function BlobmanBeta.getLocalRoot()
        local char = BlobmanBeta.getLocalChar()
        return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    end
    function BlobmanBeta.getLocalHum()
        local char = BlobmanBeta.getLocalChar()
        return char and char:FindFirstChildOfClass("Humanoid")
    end
    function BlobmanBeta.getInv()
        return Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    end

    function BlobmanBeta.SetNetworkOwner(part)
        ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, BlobmanBeta.getLocalRoot().CFrame)
    end

    function BlobmanBeta.ungrab(part)
        ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part)
    end

    function BlobmanBeta.getBlobman()
        local inv = BlobmanBeta.getInv()
        if inv then
            local v = inv:FindFirstChild("CreatureBlobman")
            if v and v:FindFirstChild("VehicleSeat") then return v end
        end
        for _, p in Workspace.PlotItems:GetChildren() do
            local m = p:FindFirstChild("CreatureBlobman")
            if m and m:FindFirstChild("PlayerValue") and m.PlayerValue.Value == LocalPlayer.Name then
                return m
            end
        end
        return nil
    end

    function BlobmanBeta.spawnBlobman()
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", BlobmanBeta.getLocalRoot().CFrame, Vector3.zero)
        task.wait(1.0)
        return BlobmanBeta.getBlobman()
    end

    function BlobmanBeta.destroyBlobman()
        local blob = BlobmanBeta.getBlobman()
        if blob then
            ReplicatedStorage.MenuToys.DestroyToy:FireServer(blob)
        end
    end

    function BlobmanBeta.isSittingOnBlobman()
        local hum = BlobmanBeta.getLocalHum()
        if not hum then return false end
        local blob = BlobmanBeta.getBlobman()
        if not blob or not blob:FindFirstChild("VehicleSeat") then return false end
        return hum.Sit and hum.SeatPart == blob.VehicleSeat
    end

    function BlobmanBeta.ensureSitBlobman()
        local blob = BlobmanBeta.getBlobman()
        if not blob or not blob:FindFirstChild("VehicleSeat") then return false end
        local seat = blob.VehicleSeat
        local hum = BlobmanBeta.getLocalHum()
        if hum and not hum.Sit then
            seat:Sit(hum)
            task.wait(0.6)
        end
        return BlobmanBeta.isSittingOnBlobman()
    end

    function BlobmanBeta.blobGrab(blob, target, side)
        if not blob then return end
        local detector = blob:FindFirstChild(side .. "Detector")
        if not detector then return end
        local weld = detector:FindFirstChild(side .. "Weld")
        if not weld then return end
        local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript", true)
        if not script then return end
        local remote = script:FindFirstChild("CreatureGrab")
        if remote then
            pcall(function() remote:FireServer(detector, target, weld) end)
        end
    end

    function BlobmanBeta.blobDrop(blob, target, side)
        if not blob then return end
        local detector = blob:FindFirstChild(side .. "Detector")
        if not detector then return end
        local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript", true)
        if not script then return end
        local remote = script:FindFirstChild("CreatureDrop")
        if remote then
            pcall(function() remote:FireServer(detector, target) end)
        end
    end

    function BlobmanBeta.blobKick(blob, targetRoot, side)
        BlobmanBeta.blobGrab(blob, BlobmanBeta.getLocalRoot(), side)
        task.wait(0.08)
        BlobmanBeta.SetNetworkOwner(targetRoot)
        task.wait(0.08)
        targetRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 16, 0)
        task.wait(0.08)
        BlobmanBeta.ungrab(targetRoot)
        task.wait(0.08)
        BlobmanBeta.blobGrab(blob, targetRoot, side)
        task.wait(0.08)
        BlobmanBeta.blobDrop(blob, targetRoot, side)
        task.wait(0.08)
        BlobmanBeta.ungrab(targetRoot)
    end

    local isExecuting = false
    local selectedV3Player = nil

    local function UpdateV3PlayerList(Dropdown)
        local playerNames = {}
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer then
                table.insert(playerNames, plr.Name)
            end
        end
        Dropdown:Refresh(playerNames, true)
    end

    local function KickSelectedV3Player()
        if isExecuting then
            OrionLib:MakeNotification({Name = "Error", Content = "Already executing...", Time = 3})
            return
        end
        
        if not selectedV3Player then
            OrionLib:MakeNotification({Name = "Error", Content = "Please select a player first", Time = 3})
            return
        end
        
        local targetPlayer = Players:FindFirstChild(selectedV3Player)
        if not targetPlayer then
            OrionLib:MakeNotification({Name = "Error", Content = "Player not found", Time = 3})
            return
        end
        
        local targetChar = targetPlayer.Character
        if not targetChar then
            OrionLib:MakeNotification({Name = "Error", Content = "Target has no character", Time = 3})
            return
        end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            OrionLib:MakeNotification({Name = "Error", Content = "Target has no HumanoidRootPart", Time = 3})
            return
        end
        
        isExecuting = true
        
        local function doKick()
            local blob = BlobmanBeta.getBlobman()
            if not blob then
                blob = BlobmanBeta.spawnBlobman()
                if not blob then
                    OrionLib:MakeNotification({Name = "Error", Content = "Failed to spawn Blobman", Time = 5})
                    return false
                end
            end
            
            if not BlobmanBeta.isSittingOnBlobman() then
                BlobmanBeta.ensureSitBlobman()
                if not BlobmanBeta.isSittingOnBlobman() then
                    OrionLib:MakeNotification({Name = "Error", Content = "Not sitting on Blobman", Time = 4})
                    return false
                end
            end
            
            local myRoot = BlobmanBeta.getLocalRoot()
            if myRoot and targetRoot then
                local oldPos = myRoot.CFrame
                myRoot.CFrame = targetRoot.CFrame
                task.wait(0.07)
                BlobmanBeta.blobKick(blob, targetRoot, "Left")
                task.wait(0.25)
                myRoot.CFrame = oldPos
            end
            
            BlobmanBeta.destroyBlobman()
            OrionLib:MakeNotification({Name = "Success", Content = "Kicked " .. targetPlayer.Name .. "!", Time = 5})
            return true
        end
        
        doKick()
        isExecuting = false
    end

    local V3PlayerDropdown = AttackTab:AddDropdown({
        Name = "Select Player",
        Options = {},
        Callback = function(value)
            selectedV3Player = value
        end
    })

    AttackTab:AddButton({
        Name = "プレイヤーリスト更新",
        Callback = function()
            UpdateV3PlayerList(V3PlayerDropdown)
        end
    })

    AttackTab:AddButton({
        Name = "ふっとばす！",
        Callback = KickSelectedV3Player
    })

    -- ================================================================
    -- セクション4: ふっとばす 追加機能
    -- ================================================================
    AttackTab:AddSection({ Name = "ふっとばす 追加機能" })
    
    local InfiniteJumpV3Enabled = false
    UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpV3Enabled then
            local hum = BlobmanBeta.getLocalHum()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    AttackTab:AddToggle({
        Name = "無限ジャンプ",
        Default = false,
        Callback = function(Value)
            InfiniteJumpV3Enabled = Value
        end
    })

    AttackTab:AddToggle({
        Name = "3人称視点",
        Default = false,
        Callback = function(Value)
            if Value then
                LocalPlayer.CameraMaxZoomDistance = 100
                LocalPlayer.CameraMinZoomDistance = 10
            else
                LocalPlayer.CameraMaxZoomDistance = 12.5
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
        end
    })

    -- ================================================================
    -- セクション5: Kick All（退出通知なし）
    -- ================================================================
    AttackTab:AddSection({ Name = "Kick All" })

    local currentBlob = nil
    local isKickAllActive = false
    local playerStatus = {}
    local whitelistFriends = false

    local function GetAllPlayers()
        local players = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local isFriend = false
                if whitelistFriends then
                    pcall(function()
                        isFriend = LocalPlayer:IsFriendsWith(player.UserId)
                    end)
                end
                if not isFriend then
                    table.insert(players, player)
                end
            end
        end
        return players
    end

    local function GetMyRoot()
        return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end

    local function ResetTargets()
        for id, status in pairs(playerStatus) do
            if status == "Targeting" then playerStatus[id] = nil end
        end
    end

    local function KickAll()
        if isKickAllActive then return end
        isKickAllActive = true
        
        local allPlayers = GetAllPlayers()
        if #allPlayers == 0 then 
            OrionLib:MakeNotification({
                Name = "対象がいません",
                Content = "キックできるプレイヤーがいません。",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            isKickAllActive = false
            return 
        end

        for _, targetPlayer in ipairs(allPlayers) do
            playerStatus[targetPlayer.UserId] = "Targeting"
        end
        
        local rootPart = GetMyRoot()
        if rootPart then
            local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
        end
        task.wait(0.5)
        
        local toyFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        currentBlob = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
        if not currentBlob then 
            ResetTargets()
            isKickAllActive = false
            return 
        end
        
        local vehicleSeat = currentBlob:FindFirstChild("VehicleSeat")
        if vehicleSeat and LocalPlayer.Character then
            vehicleSeat:Sit(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
        end
        task.wait(0.3)
        
        local myRoot = GetMyRoot()
        if not myRoot then 
            ResetTargets()
            isKickAllActive = false
            return 
        end
        
        for _, targetPlayer in ipairs(allPlayers) do
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                myRoot.CFrame = targetRoot.CFrame
                task.wait(0.02)
                
                for i = 1, 5 do
                    pcall(function()
                        currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld
                        )
                        currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(currentBlob.LeftDetector.LeftWeld)
                    end)
                    if i < 5 then task.wait(0.08) end
                end
            end
        end
        
        myRoot.CFrame = CFrame.new(0, 100, 0)
        task.wait(0.1)
        
        for _, part in ipairs(currentBlob:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.Anchored = true end) end
        end
        task.wait(0.1)
        
        local radius = 15
        for i, targetPlayer in ipairs(allPlayers) do
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local angle = math.rad((i - 1) * (360 / #allPlayers))
                local x = radius * math.cos(angle)
                local z = radius * math.sin(angle)
                targetRoot.CFrame = CFrame.new(x, 110, z)
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

        myRoot.CFrame = CFrame.new(0, -50000, 0)
        
        for _, part in ipairs(currentBlob:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.Anchored = false end) end
        end
        
        task.wait(1)
        isKickAllActive = false
    end

    AttackTab:AddButton({
        Name = "Kick All",
        Callback = KickAll
    })

    AttackTab:AddToggle({
        Name = "Whitelist Friends",
        Default = false,
        Callback = function(Value)
            whitelistFriends = Value
        end    
    })

    -- ================================================================
    -- ステータス表示
    -- ================================================================
    AttackTab:AddParagraph("Status", "Current status information")
    local statusTargetLabel = AttackTab:AddLabel("Current Target V1: None")
    local statusRunningLabel = AttackTab:AddLabel("Status V1: Stopped")

    task.spawn(function()
        while task.wait(1) do
            if selectedKickPlayer then
                statusTargetLabel:Set("Current Target V1: " .. selectedKickPlayer.Name)
            else
                statusTargetLabel:Set("Current Target V1: None")
            end
            statusRunningLabel:Set(kickLoopEnabled and "Status V1: Running" or "Status V1: Stopped")
        end
    end)
end

-- ============================================================================
-- ブロック28: スクリプトhubタブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib

    local ScriptHubTab = Window:MakeTab({ Name = "スクリプトhub", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    
    -- 注意書き
    ScriptHubTab:AddParagraph("注意", "一部外部スクリプトはNabehub外の開発です 保証なし")
    
    ScriptHubTab:AddSection({ Name = "外部スクリプト読み込み" })

    local function executeScript(url, name)
        local success, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if success then
            OrionLib:MakeNotification({ Name = name, Content = "読み込み成功！", Time = 3 })
        else
            OrionLib:MakeNotification({ Name = name, Content = "読み込み失敗: " .. tostring(err), Time = 5 })
        end
    end

    ScriptHubTab:AddButton({ Name = "シェーダー", Callback = function() executeScript("https://rawscripts.net/raw/Universal-Script-Shader-77482", "シェーダー") end })
    ScriptHubTab:AddButton({ Name = "空変え", Callback = function() executeScript("https://rawscripts.net/raw/Universal-Script-SkyBoxinjectHUB-80671", "空変え") end })
    ScriptHubTab:AddButton({ Name = "テトリス", Callback = function() executeScript("https://rawscripts.net/raw/Universal-Script-RTetris-76191", "テトリス") end })
    ScriptHubTab:AddButton({ Name = "クロスケ作v式飛行", Callback = function() executeScript("https://rawscripts.net/raw/Universal-Script-VFly-gui-and-noclip-78112", "クロスケ作v式飛行") end })
    ScriptHubTab:AddButton({ Name = "Hokuto hub", Callback = function() executeScript("https://pastefy.app/tQtNET9U/raw", "Hokuto hub") end })
    ScriptHubTab:AddButton({ Name = "uiを日本語に翻訳", Callback = function() 
        executeScript("https://pastefy.app/HCUekFMV/raw", "uiを日本語に翻訳") 
    end })
    ScriptHubTab:AddButton({ Name = "FTAP TP", Callback = function() 
        executeScript("https://pastefy.app/pAbXnxgr/raw", "FTAP TP") 
    end })
end

-- ============================================================================
-- ブロック29: バリア破壊タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local LocalPlayer = _G.LocalPlayer
    local ReplicatedStorage = _G.ReplicatedStorage
    local Workspace = _G.Workspace

    local BarrierBreakTab = Window:MakeTab({ Name = "バリア破壊", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    BarrierBreakTab:AddSection({ Name = "バリア破壊機能" })
    BarrierBreakTab:AddButton({
        Name = "Barrier Break(BETA)",
        Callback = function()
            local player = LocalPlayer
            if not player then OrionLib:MakeNotification({ Name = "Error", Content = "Player not found", Time = 4 }) return end
            if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                OrionLib:MakeNotification({ Name = "Error", Content = "Character not ready", Time = 4 })
                return
            end

            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            local originalWalkSpeed, originalJumpPower
            if humanoid then
                originalWalkSpeed = humanoid.WalkSpeed
                originalJumpPower = humanoid.JumpPower
                pcall(function()
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end)
            end

            local success, err = pcall(function()
                local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
                local hrp = player.Character.HumanoidRootPart
                local originalCFrame = hrp.CFrame

                hrp.CFrame = CFrame.new(246.052, -7.35, 431.821)
                task.wait(0.05)

                MenuToys.SpawnToyRemoteFunction:InvokeServer(
                    "InstrumentWoodwindOcarina",
                    CFrame.new(184.148834, -5.54824972, 498.136749,
                        0.829037189, -0.214714944, 0.516328275,
                        0, 0.923344612, 0.383972496,
                        -0.559193552, -0.318327487, 0.765486956),
                    Vector3.new(0, 34, 0)
                )
                task.wait(0.2)

                local toyFolder = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
                if not toyFolder then error("SpawnedInToys folder not found") end

                local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
                if not ocarina then error("InstrumentWoodwindOcarina not found") end

                if ocarina:FindFirstChild("HoldPart") and ocarina.HoldPart:FindFirstChild("HoldItemRemoteFunction") then
                    pcall(function()
                        ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, player.Character)
                    end)
                    task.wait(0.2)
                end

                player.Character.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
                task.wait(0.05)

                local destroyEv = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
                if destroyEv then
                    destroyEv:FireServer(ocarina)
                else
                    error("DestroyToy event not found")
                end
                task.wait(0.05)

                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = originalCFrame
                end

                OrionLib:MakeNotification({ Name = "Success", Content = "Barrier break executed", Time = 3 })
            end)

            if humanoid then
                pcall(function()
                    if originalWalkSpeed then humanoid.WalkSpeed = originalWalkSpeed end
                    if originalJumpPower then humanoid.JumpPower = originalJumpPower end
                end)
            end

            if not success then
                OrionLib:MakeNotification({ Name = "Error", Content = tostring(err), Time = 6 })
            end
        end
    })
end

-- ============================================================================
-- ブロック30: GUIタブ（固定GUI + TTP GUI + SaluraHUB-keyboard.GUI）
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local LocalPlayer = _G.LocalPlayer
    local Camera = _G.Camera
    local RunService = _G.RunService
    local UserInputService = _G.UserInputService
    local Workspace = _G.Workspace

    local GUITab = Window:MakeTab({ Name = "GUI", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    
    -- ================================================================
    -- 固定GUI (既存)
    -- ================================================================
    GUITab:AddSection({ Name = "固定GUI" })
    GUITab:AddButton({
        Name = "固定gui",
        Callback = function()
            local Player = LocalPlayer
            local Camera = Camera
            local RunService = RunService
            local UserInputService = UserInputService

            local targetPart = nil
            local fixedPart = nil

            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "MobileFixerUI"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.Parent = game:GetService("CoreGui")

            local MainFrame = Instance.new("Frame")
            MainFrame.Size = UDim2.new(0, 180, 0, 160)
            MainFrame.Position = UDim2.new(0.7, 0, 0.4, 0)
            MainFrame.BackgroundTransparency = 1
            MainFrame.Parent = ScreenGui
            MainFrame.Visible = false

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 80, 0, 40)
            ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
            ToggleButton.Text = "MENU"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.Parent = ScreenGui
            local CornerT = Instance.new("UICorner")
            CornerT.Parent = ToggleButton

            local FixButton = Instance.new("TextButton")
            FixButton.Size = UDim2.new(1, 0, 0.45, 0)
            FixButton.Position = UDim2.new(0, 0, 0, 0)
            FixButton.Text = "持ってる物を固定"
            FixButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            FixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            FixButton.Font = Enum.Font.GothamBold
            FixButton.Parent = MainFrame
            local Corner1 = Instance.new("UICorner")
            Corner1.Parent = FixButton

            local UnfixButton = Instance.new("TextButton")
            UnfixButton.Size = UDim2.new(1, 0, 0.45, 0)
            UnfixButton.Position = UDim2.new(0, 0, 0.55, 0)
            UnfixButton.Text = "固定解除"
            UnfixButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            UnfixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            UnfixButton.Font = Enum.Font.GothamBold
            UnfixButton.Parent = MainFrame
            local Corner2 = Instance.new("UICorner")
            Corner2.Parent = UnfixButton

            ToggleButton.MouseButton1Click:Connect(function()
                MainFrame.Visible = not MainFrame.Visible
                if MainFrame.Visible then
                    ToggleButton.Text = "CLOSE"
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                else
                    ToggleButton.Text = "MENU"
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end)

            local dragging, dragStart, startPos
            MainFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = MainFrame.Position
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            RunService.RenderStepped:Connect(function()
                local viewportCenter = Camera.ViewportSize / 2
                local unitRay = Camera:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.FilterDescendantsInstances = {Player.Character}

                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams)

                if result and result.Instance:IsA("BasePart") then
                    local obj = result.Instance
                    if obj.Size.X < 100 and obj.Size.Z < 100 and obj ~= fixedPart then
                        targetPart = obj
                        highlight.Adornee = targetPart
                        highlight.Parent = targetPart
                        highlight.FillColor = (targetPart.Anchored) and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 0)
                    end
                else
                    if not fixedPart then
                        highlight.Parent = nil
                        targetPart = nil
                    end
                end
            end)

            FixButton.MouseButton1Click:Connect(function()
                if targetPart then
                    targetPart.Anchored = true
                    fixedPart = targetPart
                    highlight.FillColor = Color3.fromRGB(0, 255, 255)
                end
            end)

            UnfixButton.MouseButton1Click:Connect(function()
                if fixedPart then
                    fixedPart.Anchored = false
                    fixedPart = nil
                    highlight.Parent = nil
                    targetPart = nil
                end
            end)

            OrionLib:MakeNotification({
                Name = "固定gui",
                Content = "起動しました（MENUボタンを押して表示）",
                Time = 3
            })
        end
    })

    -- ================================================================
    -- TP GUI (既存)
    -- ================================================================
    GUITab:AddSection({ Name = "TP GUI" })
    GUITab:AddButton({
        Name = "TTP GUI",
        Callback = function()
            loadstring(game:HttpGet("https://pastefy.app/h6uDbIIz/raw"))()
            OrionLib:MakeNotification({
                Name = "TTP GUI",
                Content = "読み込み完了！\\キーでTP / 固定機能付き",
                Time = 3
            })
        end
    })

    -- ================================================================
    -- NabeHUB-keyboard.GUI (新規追加)
    -- ================================================================
    GUITab:AddSection({ Name = "Keyboard GUI" })
    GUITab:AddButton({
        Name = "NabeHUB-keyboard.GUI",
        Callback = function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://pastefy.app/LYB56LOl/raw"))()
            end)
            if success then
                OrionLib:MakeNotification({
                    Name = "NabeHUB-keyboard.GUI",
                    Content = "読み込み成功！",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "NabeHUB-keyboard.GUI",
                    Content = "読み込み失敗: " .. tostring(err),
                    Time = 5
                })
            end
        end
    })
end

-- ============================================================================
-- ブロック31: オブジェクト設定タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme
    local changeObjectID = _G.changeObjectID

    local ObjectIDTab = Window:MakeTab({ Name = "オブジェクト設定", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    ObjectIDTab:AddLabel("全オブジェクトID (28種類):")
    local rows = {{1,7}, {8,14}, {15,21}, {22,28}}
    for _, row in ipairs(rows) do
        ObjectIDTab:AddLabel("【" .. row[1] .. "-" .. row[2] .. "行目】")
        for i = row[1], row[2] do
            local id = SH.ObjectIDConfig.AvailableObjects[i]
            ObjectIDTab:AddButton({ Name = id, Callback = function() changeObjectID(id) end })
        end
    end
    ObjectIDTab:AddLabel("対応オブジェクト数: 28種類")
end

-- ============================================================================
-- ブロック32: フェザータブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local FeatherTab = Window:MakeTab({ Name = "フェザー[羽]", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    FeatherTab:AddToggle({ Name = "フェザー起動", Default = false, Callback = _G.toggleFeather })
    FeatherTab:AddSlider({ Name = "最大オブジェクト数", Min = 2, Max = 100, Default = SH.FeatherConfig.maxSparklers, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.FeatherConfig.maxSparklers = v end })
    FeatherTab:AddSlider({ Name = "オブジェクト間隔", Min = 1, Max = 20, Default = SH.FeatherConfig.spacing, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.FeatherConfig.spacing = v end })
    FeatherTab:AddSlider({ Name = "高さオフセット", Min = -10, Max = 30, Default = SH.FeatherConfig.heightOffset, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.FeatherConfig.heightOffset = v end })
    FeatherTab:AddSlider({ Name = "背面オフセット", Min = 0, Max = 30, Default = SH.FeatherConfig.backwardOffset, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.FeatherConfig.backwardOffset = v end })
    FeatherTab:AddSlider({ Name = "傾き角度", Min = 0, Max = 90, Default = SH.FeatherConfig.tiltAngle, Color = Theme.SliderColor, Increment = 5, ValueName = "度", Callback = function(v) SH.FeatherConfig.tiltAngle = v end })
    FeatherTab:AddSlider({ Name = "上下動速度", Min = 0, Max = 20, Default = SH.FeatherConfig.waveSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.FeatherConfig.waveSpeed = v end })
    FeatherTab:AddSlider({ Name = "基本振幅", Min = 0, Max = 20, Default = SH.FeatherConfig.baseAmplitude, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.FeatherConfig.baseAmplitude = v end })
end

-- ============================================================================
-- ブロック33: 魔法陣タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local MagicCircleTab = Window:MakeTab({ Name = "魔法陣", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    MagicCircleTab:AddToggle({ Name = "魔法陣起動", Default = false, Callback = _G.toggleMagicCircle })
    MagicCircleTab:AddDropdown({ Name = "シンボルタイプ", Default = SH.MagicCircleConfig.SymbolType, Options = {"Ring", "Circle", "Hexagram"}, Callback = function(v) SH.MagicCircleConfig.SymbolType = v end })
    MagicCircleTab:AddToggle({ Name = "発光効果", Default = SH.MagicCircleConfig.GlowEffect, Callback = function(v) SH.MagicCircleConfig.GlowEffect = v; if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false); task.wait(0.1); _G.toggleMagicCircle(true) end end })
    MagicCircleTab:AddSlider({ Name = "高さ", Min = 0, Max = 50, Default = SH.MagicCircleConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.MagicCircleConfig.Height = v end })
    MagicCircleTab:AddSlider({ Name = "直径", Min = 5, Max = 50, Default = SH.MagicCircleConfig.Diameter, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.MagicCircleConfig.Diameter = v end })
    MagicCircleTab:AddSlider({ Name = "オブジェクト数", Min = 3, Max = 100, Default = SH.MagicCircleConfig.ObjectCount, Color = Theme.SliderColor, Increment = 1, ValueName = "個", Callback = function(v) SH.MagicCircleConfig.ObjectCount = v end })
    MagicCircleTab:AddSlider({ Name = "回転速度", Min = 1, Max = 100, Default = SH.MagicCircleConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 1, ValueName = "速度", Callback = function(v) SH.MagicCircleConfig.RotationSpeed = v end })
end

-- ============================================================================
-- ブロック34: ハートタブ（横方向・地面に水平 / XZ平面）
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local HeartTab = Window:MakeTab({ Name = "♡ハート//", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    HeartTab:AddToggle({ Name = "ハート起動", Default = false, Callback = _G.toggleHeart })
    HeartTab:AddToggle({ Name = "プレイヤー追従", Default = SH.HeartConfig.FollowPlayer, Callback = function(v) SH.HeartConfig.FollowPlayer = v end })
    HeartTab:AddSlider({ Name = "ハートサイズ", Min = 2, Max = 50, Default = SH.HeartConfig.Size, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.HeartConfig.Size = v end })
    HeartTab:AddSlider({ Name = "基本高さ", Min = 0, Max = 50, Default = SH.HeartConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.HeartConfig.Height = v end })
    HeartTab:AddSlider({ Name = "オブジェクト数", Min = 6, Max = 100, Default = SH.HeartConfig.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.HeartConfig.ObjectCount = v end })
    HeartTab:AddSlider({ Name = "回転速度", Min = 0, Max = 10, Default = SH.HeartConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.HeartConfig.RotationSpeed = v end })
    HeartTab:AddSlider({ Name = "脈動速度", Min = 0, Max = 10, Default = SH.HeartConfig.PulseSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.HeartConfig.PulseSpeed = v end })
    HeartTab:AddSlider({ Name = "脈動振幅", Min = 0, Max = 10, Default = SH.HeartConfig.PulseAmplitude, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.HeartConfig.PulseAmplitude = v end })
end

-- ============================================================================
-- ブロック35: ビッグハートタブ（横方向・地面に水平 / XZ平面）
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local BigHeartTab = Window:MakeTab({ Name = "おっきぃ♡", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    BigHeartTab:AddToggle({ Name = "おっきぃハート起動", Default = false, Callback = _G.toggleBigHeart })
    BigHeartTab:AddToggle({ Name = "プレイヤー追従", Default = SH.BigHeartConfig.FollowPlayer, Callback = function(v) SH.BigHeartConfig.FollowPlayer = v end })
    BigHeartTab:AddSlider({ Name = "基本サイズ", Min = 5, Max = 50, Default = SH.BigHeartConfig.Size, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.BigHeartConfig.Size = v end })
    BigHeartTab:AddSlider({ Name = "拡大率", Min = 1.0, Max = 10.0, Default = SH.BigHeartConfig.HeartScale, Color = Theme.SliderColor, Increment = 0.1, ValueName = "倍", Callback = function(v) SH.BigHeartConfig.HeartScale = v end })
    BigHeartTab:AddSlider({ Name = "縦方向引き伸ばし", Min = 1.0, Max = 5.0, Default = SH.BigHeartConfig.VerticalStretch, Color = Theme.SliderColor, Increment = 0.1, ValueName = "倍", Callback = function(v) SH.BigHeartConfig.VerticalStretch = v end })
    BigHeartTab:AddSlider({ Name = "基本高さ", Min = 5, Max = 50, Default = SH.BigHeartConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.BigHeartConfig.Height = v end })
    BigHeartTab:AddSlider({ Name = "オブジェクト数", Min = 12, Max = 100, Default = SH.BigHeartConfig.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.BigHeartConfig.ObjectCount = v end })
    BigHeartTab:AddSlider({ Name = "回転速度", Min = 0, Max = SH.BigHeartConfig.RotationSpeedMax, Default = SH.BigHeartConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.BigHeartConfig.RotationSpeed = v end })
    BigHeartTab:AddSlider({ Name = "脈動速度", Min = 0, Max = SH.BigHeartConfig.PulseSpeedMax, Default = SH.BigHeartConfig.PulseSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.BigHeartConfig.PulseSpeed = v end })
    BigHeartTab:AddSlider({ Name = "脈動振幅", Min = 0, Max = 10, Default = SH.BigHeartConfig.PulseAmplitude, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.BigHeartConfig.PulseAmplitude = v end })
end

-- ============================================================================
-- ブロック36: ダビデの星タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local StarOfDavidTab = Window:MakeTab({ Name = "ダビデの星✡", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    StarOfDavidTab:AddToggle({ Name = "ダビデの星起動", Default = false, Callback = _G.toggleStarOfDavid })
    StarOfDavidTab:AddToggle({ Name = "プレイヤー追従", Default = SH.StarOfDavidConfig.FollowPlayer, Callback = function(v) SH.StarOfDavidConfig.FollowPlayer = v end })
    StarOfDavidTab:AddSlider({ Name = "星のサイズ", Min = 2, Max = 50, Default = SH.StarOfDavidConfig.Size, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.StarOfDavidConfig.Size = v end })
    StarOfDavidTab:AddSlider({ Name = "基本高さ", Min = 0, Max = 50, Default = SH.StarOfDavidConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.StarOfDavidConfig.Height = v end })
    StarOfDavidTab:AddSlider({ Name = "三角形の高さ", Min = 0, Max = 20, Default = SH.StarOfDavidConfig.TriangleHeight, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.StarOfDavidConfig.TriangleHeight = v end })
    StarOfDavidTab:AddSlider({ Name = "オブジェクト数", Min = 6, Max = 100, Default = SH.StarOfDavidConfig.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.StarOfDavidConfig.ObjectCount = v end })
    StarOfDavidTab:AddSlider({ Name = "回転速度", Min = 0, Max = 10, Default = SH.StarOfDavidConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.StarOfDavidConfig.RotationSpeed = v end })
    StarOfDavidTab:AddSlider({ Name = "脈動速度", Min = 0, Max = 10, Default = SH.StarOfDavidConfig.PulseSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.StarOfDavidConfig.PulseSpeed = v end })
end

-- ============================================================================
-- ブロック37: スタータブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local StarTab = Window:MakeTab({ Name = "スター★", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    StarTab:AddToggle({ Name = "スター起動", Default = false, Callback = _G.toggleStar })
    StarTab:AddToggle({ Name = "プレイヤー追従", Default = SH.StarConfig.FollowPlayer, Callback = function(v) SH.StarConfig.FollowPlayer = v end })
    StarTab:AddSlider({ Name = "外側半径", Min = 2, Max = 50, Default = SH.StarConfig.OuterRadius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.StarConfig.OuterRadius = v end })
    StarTab:AddSlider({ Name = "内側半径", Min = 1, Max = 30, Default = SH.StarConfig.InnerRadius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.StarConfig.InnerRadius = v end })
    StarTab:AddSlider({ Name = "基本高さ", Min = 0, Max = 50, Default = SH.StarConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.StarConfig.Height = v end })
    StarTab:AddSlider({ Name = "オブジェクト数", Min = 5, Max = 100, Default = SH.StarConfig.ObjectCount, Color = Theme.SliderColor, Increment = 1, ValueName = "個", Callback = function(v) SH.StarConfig.ObjectCount = v end })
    StarTab:AddSlider({ Name = "回転速度", Min = 0, Max = 10, Default = SH.StarConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.StarConfig.RotationSpeed = v end })
    StarTab:AddSlider({ Name = "きらめき速度", Min = 0, Max = 10, Default = SH.StarConfig.TwinkleSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.StarConfig.TwinkleSpeed = v end })
end

-- ============================================================================
-- ブロック38: スター2タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local Star2Tab = Window:MakeTab({ Name = "スター2✫", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    Star2Tab:AddToggle({ Name = "スター2起動", Default = false, Callback = _G.toggleStar2 })
    Star2Tab:AddToggle({ Name = "プレイヤー追従", Default = SH.Star2Config.FollowPlayer, Callback = function(v) SH.Star2Config.FollowPlayer = v end })
    Star2Tab:AddSlider({ Name = "基本サイズ", Min = 5, Max = 30, Default = SH.Star2Config.Size, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.Star2Config.Size = v end })
    Star2Tab:AddSlider({ Name = "光線の長さ", Min = 1, Max = 10, Default = SH.Star2Config.RayLength, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.Star2Config.RayLength = v end })
    Star2Tab:AddSlider({ Name = "基本高さ", Min = 5, Max = 50, Default = SH.Star2Config.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.Star2Config.Height = v end })
    Star2Tab:AddSlider({ Name = "光線の数", Min = 6, Max = 36, Default = SH.Star2Config.RayCount, Color = Theme.SliderColor, Increment = 2, ValueName = "本", Callback = function(v) SH.Star2Config.RayCount = v end })
    Star2Tab:AddSlider({ Name = "オブジェクト数", Min = 12, Max = 100, Default = SH.Star2Config.ObjectCount, Color = Theme.SliderColor, Increment = 4, ValueName = "個", Callback = function(v) SH.Star2Config.ObjectCount = v end })
    Star2Tab:AddSlider({ Name = "回転速度", Min = 0, Max = 30, Default = SH.Star2Config.RotationSpeed, Color = Theme.SliderColor, Increment = 1, ValueName = "速度", Callback = function(v) SH.Star2Config.RotationSpeed = v end })
    Star2Tab:AddSlider({ Name = "脈動速度", Min = 0, Max = 20, Default = SH.Star2Config.PulseSpeed, Color = Theme.SliderColor, Increment = 1, ValueName = "速度", Callback = function(v) SH.Star2Config.PulseSpeed = v end })
    Star2Tab:AddSlider({ Name = "脈動振幅", Min = 0, Max = 10, Default = SH.Star2Config.PulseAmplitude, Color = Theme.SliderColor, Increment = 0.2, ValueName = "スタッド", Callback = function(v) SH.Star2Config.PulseAmplitude = v end })
    Star2Tab:AddSlider({ Name = "ギザギザ速度", Min = 0, Max = 20, Default = SH.Star2Config.JitterSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.Star2Config.JitterSpeed = v end })
    Star2Tab:AddSlider({ Name = "ギザギザ量", Min = 0, Max = 10, Default = SH.Star2Config.JitterAmount, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.Star2Config.JitterAmount = v end })
end

-- ============================================================================
-- ブロック39: 球体タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local SphereTab = Window:MakeTab({ Name = "球体◯", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    SphereTab:AddToggle({ Name = "球体起動", Default = false, Callback = _G.toggleSphere })
    SphereTab:AddToggle({ Name = "プレイヤー追従", Default = SH.SphereConfig.FollowPlayer, Callback = function(v) SH.SphereConfig.FollowPlayer = v end })
    SphereTab:AddSlider({ Name = "球体半径", Min = 2, Max = 50, Default = SH.SphereConfig.Radius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.SphereConfig.Radius = v end })
    SphereTab:AddSlider({ Name = "緯度線の数", Min = 2, Max = 16, Default = SH.SphereConfig.Latitudes, Color = Theme.SliderColor, Increment = 1, ValueName = "本", Callback = function(v) SH.SphereConfig.Latitudes = v end })
    SphereTab:AddSlider({ Name = "経度線の数", Min = 4, Max = 24, Default = SH.SphereConfig.Longitudes, Color = Theme.SliderColor, Increment = 2, ValueName = "本", Callback = function(v) SH.SphereConfig.Longitudes = v end })
    SphereTab:AddSlider({ Name = "オブジェクト数", Min = 8, Max = 100, Default = SH.SphereConfig.ObjectCount, Color = Theme.SliderColor, Increment = 4, ValueName = "個", Callback = function(v) SH.SphereConfig.ObjectCount = v end })
    SphereTab:AddSlider({ Name = "水平回転速度", Min = 0, Max = 10, Default = SH.SphereConfig.HorizontalRotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.SphereConfig.HorizontalRotationSpeed = v end })
    SphereTab:AddSlider({ Name = "垂直回転速度", Min = 0, Max = 10, Default = SH.SphereConfig.VerticalRotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.SphereConfig.VerticalRotationSpeed = v end })
    SphereTab:AddSlider({ Name = "脈動速度", Min = 0, Max = 10, Default = SH.SphereConfig.PulseSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.SphereConfig.PulseSpeed = v end })
    SphereTab:AddSlider({ Name = "脈動振幅", Min = 0, Max = 5, Default = SH.SphereConfig.PulseAmplitude, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.SphereConfig.PulseAmplitude = v end })
end

-- ============================================================================
-- ブロック40: 観覧車タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local FerrisWheelTab = Window:MakeTab({ Name = "観覧車", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    FerrisWheelTab:AddToggle({ Name = "観覧車起動", Default = false, Callback = _G.toggleFerrisWheel })
    FerrisWheelTab:AddToggle({ Name = "プレイヤー追従", Default = SH.FerrisWheelConfig.FollowPlayer, Callback = function(v) SH.FerrisWheelConfig.FollowPlayer = v end })
    FerrisWheelTab:AddToggle({ Name = "縦方向円", Default = SH.FerrisWheelConfig.VerticalCircle, Callback = function(v) SH.FerrisWheelConfig.VerticalCircle = v end })
    FerrisWheelTab:AddToggle({ Name = "固定方向を使用", Default = SH.FerrisWheelConfig.FixedDirection, Callback = function(v) SH.FerrisWheelConfig.FixedDirection = v end })
    FerrisWheelTab:AddSlider({ Name = "固定ヨー角", Min = -180, Max = 180, Default = SH.FerrisWheelConfig.FixedYaw, Color = Theme.SliderColor, Increment = 5, ValueName = "度", Callback = function(v) SH.FerrisWheelConfig.FixedYaw = v end })
    FerrisWheelTab:AddSlider({ Name = "固定ピッチ角", Min = -90, Max = 90, Default = SH.FerrisWheelConfig.FixedPitch, Color = Theme.SliderColor, Increment = 5, ValueName = "度", Callback = function(v) SH.FerrisWheelConfig.FixedPitch = v end })
    FerrisWheelTab:AddSlider({ Name = "固定ロール角", Min = -180, Max = 180, Default = SH.FerrisWheelConfig.FixedRoll, Color = Theme.SliderColor, Increment = 5, ValueName = "度", Callback = function(v) SH.FerrisWheelConfig.FixedRoll = v end })
    FerrisWheelTab:AddSlider({ Name = "半径", Min = 5, Max = 50, Default = SH.FerrisWheelConfig.Radius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.FerrisWheelConfig.Radius = v end })
    FerrisWheelTab:AddSlider({ Name = "中心高さ", Min = 5, Max = 50, Default = SH.FerrisWheelConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.FerrisWheelConfig.Height = v end })
    FerrisWheelTab:AddSlider({ Name = "オブジェクト数", Min = 6, Max = 100, Default = SH.FerrisWheelConfig.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.FerrisWheelConfig.ObjectCount = v end })
    FerrisWheelTab:AddSlider({ Name = "回転速度", Min = 0, Max = 5, Default = SH.FerrisWheelConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.FerrisWheelConfig.RotationSpeed = v end })
end

-- ============================================================================
-- ブロック41: N1,N2,N3タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local AnimN1Tab = Window:MakeTab({ Name = "N1: カオス・サークル", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    AnimN1Tab:AddToggle({ Name = "N1起動", Default = false, Callback = _G.toggleAnimN1 })
    AnimN1Tab:AddToggle({ Name = "プレイヤー追従", Default = SH.AnimN1Config.FollowPlayer, Callback = function(v) SH.AnimN1Config.FollowPlayer = v end })
    AnimN1Tab:AddSlider({ Name = "半径", Min = 5, Max = 50, Default = SH.AnimN1Config.Radius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.AnimN1Config.Radius = v end })
    AnimN1Tab:AddSlider({ Name = "基本高さ", Min = 0, Max = 50, Default = SH.AnimN1Config.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.AnimN1Config.Height = v end })
    AnimN1Tab:AddSlider({ Name = "オブジェクト数", Min = 10, Max = 100, Default = SH.AnimN1Config.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.AnimN1Config.ObjectCount = v end })
    AnimN1Tab:AddSlider({ Name = "回転速度", Min = 0, Max = 50, Default = SH.AnimN1Config.RotationSpeed, Color = Theme.SliderColor, Increment = 1, ValueName = "速度", Callback = function(v) SH.AnimN1Config.RotationSpeed = v end })
    AnimN1Tab:AddSlider({ Name = "脈動速度", Min = 0, Max = 20, Default = SH.AnimN1Config.PulseSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.AnimN1Config.PulseSpeed = v end })
    AnimN1Tab:AddSlider({ Name = "脈動量", Min = 0, Max = 30, Default = SH.AnimN1Config.PulseAmount, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.AnimN1Config.PulseAmount = v end })

    local AnimN2Tab = Window:MakeTab({ Name = "N2: トルネード・スパイラル", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    AnimN2Tab:AddToggle({ Name = "N2起動", Default = false, Callback = _G.toggleAnimN2 })
    AnimN2Tab:AddToggle({ Name = "プレイヤー追従", Default = SH.AnimN2Config.FollowPlayer, Callback = function(v) SH.AnimN2Config.FollowPlayer = v end })
    AnimN2Tab:AddSlider({ Name = "半径", Min = 3, Max = 30, Default = SH.AnimN2Config.Radius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.AnimN2Config.Radius = v end })
    AnimN2Tab:AddSlider({ Name = "最高高さ", Min = 10, Max = 100, Default = SH.AnimN2Config.TopHeight, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.AnimN2Config.TopHeight = v end })
    AnimN2Tab:AddSlider({ Name = "オブジェクト数", Min = 10, Max = 100, Default = SH.AnimN2Config.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.AnimN2Config.ObjectCount = v end })
    AnimN2Tab:AddSlider({ Name = "回転速度", Min = 0, Max = 50, Default = SH.AnimN2Config.RotationSpeed, Color = Theme.SliderColor, Increment = 1, ValueName = "速度", Callback = function(v) SH.AnimN2Config.RotationSpeed = v end })
    AnimN2Tab:AddSlider({ Name = "上昇速度", Min = 0, Max = 10, Default = SH.AnimN2Config.RiseSpeed, Color = Theme.SliderColor, Increment = 0.2, ValueName = "速度", Callback = function(v) SH.AnimN2Config.RiseSpeed = v end })
    AnimN2Tab:AddSlider({ Name = "カオス要素", Min = 0, Max = 10, Default = SH.AnimN2Config.ChaosFactor, Color = Theme.SliderColor, Increment = 0.2, ValueName = "強さ", Callback = function(v) SH.AnimN2Config.ChaosFactor = v end })

    local AnimN3Tab = Window:MakeTab({ Name = "N3: ハイパー・エクスプロージョン", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    AnimN3Tab:AddToggle({ Name = "N3起動", Default = false, Callback = _G.toggleAnimN3 })
    AnimN3Tab:AddToggle({ Name = "プレイヤー追従", Default = SH.AnimN3Config.FollowPlayer, Callback = function(v) SH.AnimN3Config.FollowPlayer = v end })
    AnimN3Tab:AddSlider({ Name = "爆発半径", Min = 5, Max = 100, Default = SH.AnimN3Config.ExplosionRadius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.AnimN3Config.ExplosionRadius = v end })
    AnimN3Tab:AddSlider({ Name = "オブジェクト数", Min = 10, Max = 100, Default = SH.AnimN3Config.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.AnimN3Config.ObjectCount = v end })
    AnimN3Tab:AddSlider({ Name = "サイクル速度", Min = 0, Max = 5, Default = SH.AnimN3Config.CycleSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.AnimN3Config.CycleSpeed = v end })
    AnimN3Tab:AddSlider({ Name = "ランダム性", Min = 0, Max = 20, Default = SH.AnimN3Config.Randomness, Color = Theme.SliderColor, Increment = 0.5, ValueName = "強さ", Callback = function(v) SH.AnimN3Config.Randomness = v end })
end

-- ============================================================================
-- ブロック42: 羽V2タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local WingTab = Window:MakeTab({ Name = "羽V2", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    WingTab:AddSection({ Name = "羽V2 (FireworkSparkler Wing)" })
    WingTab:AddToggle({ Name = "羽V2起動", Default = false, Callback = _G.toggleWing })
    WingTab:AddSlider({ Name = "翼の高さ位置", Min = -10.0, Max = 20.0, Default = SH.WingConfig.VerticalOffset, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.WingConfig.VerticalOffset = v end })
    WingTab:AddSlider({ Name = "翼の広がり", Min = 3.0, Max = 30.0, Default = SH.WingConfig.Spread, Color = Theme.SliderColor, Increment = 1.0, ValueName = "スタッド", Callback = function(v) SH.WingConfig.Spread = v end })
    WingTab:AddSlider({ Name = "羽ばたき形状", Min = 0.5, Max = 10.0, Default = SH.WingConfig.FlapShape, Color = Theme.SliderColor, Increment = 0.5, ValueName = "形状", Callback = function(v) SH.WingConfig.FlapShape = v end })
    WingTab:AddSlider({ Name = "羽ばたく速さ", Min = 0.1, Max = 5.0, Default = SH.WingConfig.FlapSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.WingConfig.FlapSpeed = v end })
    WingTab:AddSlider({ Name = "羽ばたく可動域", Min = 0.0, Max = 100.0, Default = SH.WingConfig.FlapAmount, Color = Theme.SliderColor, Increment = 1.0, ValueName = "度", Callback = function(v) SH.WingConfig.FlapAmount = v end })
    WingTab:AddSlider({ Name = "片翼オブジェクト数", Min = 3, Max = 30, Default = SH.WingConfig.ObjectCount, Color = Theme.SliderColor, Increment = 1, ValueName = "個", Callback = function(v) SH.WingConfig.ObjectCount = v end })
    WingTab:AddSlider({ Name = "チェーン遅延", Min = 0.001, Max = 0.1, Default = SH.WingConfig.ChainDelay, Color = Theme.SliderColor, Increment = 0.001, ValueName = "秒", Callback = function(v) SH.WingConfig.ChainDelay = v end })
end

-- ============================================================================
-- ブロック43: 土星スパークラータブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local SaturnTab = Window:MakeTab({ Name = "土星スパークラー", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    SaturnTab:AddSection({ Name = "土星型スパークラーコントローラー" })
    SaturnTab:AddToggle({ Name = "有効化", Default = false, Callback = _G.toggleSaturn })
    SaturnTab:AddDropdown({
        Name = "配置モード",
        Default = "土星（球体＋リング）",
        Options = {"土星（球体＋リング）", "球体（立体）", "リング（平面）", "Plot（地面展開）"},
        Callback = function(Value)
            if Value == "土星（球体＋リング）" then SH.SaturnConfig.Mode = "saturn"
            elseif Value == "球体（立体）" then SH.SaturnConfig.Mode = "sphere"
            elseif Value == "リング（平面）" then SH.SaturnConfig.Mode = "ring"
            elseif Value == "Plot（地面展開）" then SH.SaturnConfig.Mode = "plot" end
        end
    })
    SaturnTab:AddSlider({ Name = "ベース高さ", Min = 0, Max = 20, Default = SH.SaturnConfig.BaseHeight, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.SaturnConfig.BaseHeight = v end })
    SaturnTab:AddSlider({ Name = "追従速度", Min = 5, Max = 40, Default = SH.SaturnConfig.Strength, Color = Theme.SliderColor, Increment = 1, ValueName = "強さ", Callback = function(v) SH.SaturnConfig.Strength = v end })
    SaturnTab:AddSection({ Name = "リング設定" })
    SaturnTab:AddSlider({ Name = "リング半径", Min = 5, Max = 25, Default = SH.SaturnConfig.RingRadius, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.SaturnConfig.RingRadius = v end })
    SaturnTab:AddSlider({ Name = "リング速度", Min = 0.1, Max = 5, Default = SH.SaturnConfig.RingSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "x", Callback = function(v) SH.SaturnConfig.RingSpeed = v end })
    SaturnTab:AddSection({ Name = "球体設定" })
    SaturnTab:AddSlider({ Name = "球体半径", Min = 2, Max = 12, Default = SH.SaturnConfig.SphereRadius, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.SaturnConfig.SphereRadius = v end })
    SaturnTab:AddSlider({ Name = "球体速度", Min = 0.1, Max = 20, Default = SH.SaturnConfig.SphereSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "x", Callback = function(v) SH.SaturnConfig.SphereSpeed = v end })
    SaturnTab:AddSlider({ Name = "球体レイヤー数", Min = 3, Max = 10, Default = SH.SaturnConfig.SphereLayers, Color = Theme.SliderColor, Increment = 1, ValueName = "層", Callback = function(v) SH.SaturnConfig.SphereLayers = v end })
    SaturnTab:AddSection({ Name = "Plot設定" })
    SaturnTab:AddSlider({ Name = "Plot展開半径", Min = 5, Max = 50, Default = SH.SaturnConfig.PlotRadius, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.SaturnConfig.PlotRadius = v end })
    SaturnTab:AddSlider({ Name = "浮遊高さ", Min = 0, Max = 10, Default = SH.SaturnConfig.PlotHeight, Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド", Callback = function(v) SH.SaturnConfig.PlotHeight = v end })
    SaturnTab:AddSection({ Name = "ユーティリティ" })
    SaturnTab:AddButton({ Name = "再スキャン", Callback = function() if _G.rescanSaturn then _G.rescanSaturn(); OrionLib:MakeNotification({ Name = "再スキャン完了", Content = string.format("スパークラーを%d個検出しました", #SH.saturnList), Time = 2 }) end end })
end

-- ============================================================================
-- ブロック44: 楽譜演奏タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH

    local PianoTab = Window:MakeTab({ Name = "楽譜演奏", Icon = "rbxassetid://4483362458", PremiumOnly = false })

    local PianoControlSec = PianoTab:AddSection({ Name = "ピアノ制御" })
    PianoControlSec:AddToggle({ Name = "ピアノ機能を有効化", Default = false, Callback = _G.togglePiano })
    PianoControlSec:AddToggle({ Name = "プレイヤー追従", Default = true, Callback = function(v)
        SH.PianoConfig.FollowPlayer = v
        if SH.PianoConfig.Enabled and SH.PianoConfig.Keyboard and SH.PianoConfig.Keyboard.Parent then
            if v then _G.setupPianoFollow() else _G.stopPiano() end
        elseif SH.PianoConfig.Enabled and v then
            SH.PianoConfig.Keyboard = _G.getMusicKeyboard()
            if SH.PianoConfig.Keyboard then _G.setupPianoFollow() end
        end
    end })

    local PianoSongSec = PianoTab:AddSection({ Name = "曲の再生（テキスト入力）" })
    PianoSongSec:AddTextbox({ Name = "JSONデータを入力", Default = "", TextDisappear = false, Callback = function(text)
        if text and text ~= "" then SH.PianoConfig.SongData = text; OrionLib:MakeNotification({ Name = "読み込み完了", Content = "JSONテキストを設定しました", Time = 3 }) end
    end })
    PianoSongSec:AddButton({ Name = "入力した曲を再生", Callback = function()
        if not SH.PianoConfig.Keyboard then SH.PianoConfig.Keyboard = _G.getMusicKeyboard() end
        if not SH.PianoConfig.Keyboard then OrionLib:MakeNotification({Name = "エラー", Content = "MusicKeyboardが見つかりません", Time = 5}) return end
        if not SH.PianoConfig.SongData or SH.PianoConfig.SongData == "" then OrionLib:MakeNotification({Name = "エラー", Content = "JSONデータを入力してください", Time = 5}) return end
        _G.playSongFromJSONString(SH.PianoConfig.SongData)
        OrionLib:MakeNotification({ Name = "自動演奏", Content = "再生を開始しました", Time = 3 })
    end })
    PianoSongSec:AddButton({ Name = "再生を停止", Callback = function() _G.stopSong(); OrionLib:MakeNotification({ Name = "停止", Content = "曲の再生を停止しました", Time = 3 }) end })

    local ConverterSec = PianoTab:AddSection({ Name = "MIDI→JSON コンバーター" })
    ConverterSec:AddButton({ Name = "コンバーターを開く (ブラウザ)", Callback = function()
        local url = "https://saturngroup02.github.io/piano-MIDI-or-key/"
        local success, err = pcall(function()
            if syn and syn.open_url then syn.open_url(url)
            else setclipboard(url); OrionLib:MakeNotification({ Name = "URLをコピーしました", Content = "ブラウザで開いてください: " .. url, Time = 8 }) end
        end)
        if not success then setclipboard(url); OrionLib:MakeNotification({ Name = "URLをコピーしました", Content = "ブラウザで開いてください: " .. url, Time = 8 }) end
    end })
    ConverterSec:AddButton({ Name = "URLをコピー", Callback = function()
        setclipboard("https://saturngroup02.github.io/piano-MIDI-or-key/")
        OrionLib:MakeNotification({ Name = "URLをコピーしました", Content = "クリップボードにコピーしました", Time = 4 })
    end })
    ConverterSec:AddParagraph("使い方", "1.「コンバーターを開く」でMIDI→JSON変換ページを開く\n2. MIDIファイルをアップロードして変換\n3. 生成されたJSONをコピー\n4. 上の「JSONデータを入力」に貼り付けて再生")
    ConverterSec:AddLabel("対応音域: C4〜C6 (2オクターブ)")
end

-- ============================================================================
-- ブロック45: 汽車を乗っ取るタブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local ReplicatedStorage = _G.ReplicatedStorage or game:GetService("ReplicatedStorage")
    local Players = _G.Players or game:GetService("Players")
    local Workspace = _G.Workspace or game:GetService("Workspace")
    local UserInputService = _G.UserInputService or game:GetService("UserInputService")
    local LocalPlayer = _G.LocalPlayer or Players.LocalPlayer

    local TrainTab = Window:MakeTab({
        Name = "汽車を乗っ取る",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local AutomationEnabled = false
    local AutomationConnection = nil
    local TargetItemName = "InstrumentWoodwindOcarina"
    local SecondItemName = "FoodMayonnaise"

    local occupiedSeats = {}
    local seatConnections = {}
    local firstTimeRiders = {}
    local allSeats = {}

    local function getAllItemsWithRemote()
        local items = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("RemoteFunction") and obj.Name == "HoldItemRemoteFunction" then
                local holdPart = obj.Parent
                if holdPart and holdPart.Name == "HoldPart" then
                    local item = holdPart.Parent
                    if item then
                        local dropRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
                        table.insert(items, {
                            Name = item.Name,
                            Object = item,
                            RemoteFunction = obj,
                            DropRemoteFunction = dropRemote,
                        })
                    end
                end
            end
        end
        return items
    end

    local function getPlayerCharacter()
        return Workspace:FindFirstChild(LocalPlayer.Name .. "_sub") or
               Workspace:FindFirstChild(LocalPlayer.Name) or
               LocalPlayer.Character
    end

    local function holdItem(itemData)
        local char = getPlayerCharacter()
        if char and itemData and itemData.RemoteFunction then
            pcall(function()
                itemData.RemoteFunction:InvokeServer(itemData.Object, char)
            end)
        end
    end

    local function useItem(itemData)
        pcall(function()
            local UseRemote = ReplicatedStorage:FindFirstChild("HoldEvents")
            if UseRemote then
                local Use = UseRemote:FindFirstChild("Use")
                if Use then
                    Use:FireServer(itemData.Object)
                end
            end
        end)
    end

    local function dropItemHigh(itemData)
        local char = getPlayerCharacter()
        if char and itemData and itemData.DropRemoteFunction then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                pcall(function()
                    itemData.DropRemoteFunction:InvokeServer(
                        itemData.Object,
                        root.CFrame * CFrame.new(0, 900, 0),
                        Vector3.new(0, 900, 0)
                    )
                end)
            end
        end
    end

    local function spawnItem(itemName)
        local char = getPlayerCharacter()
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        pcall(function()
            local SpawnToyRemote = ReplicatedStorage:FindFirstChild("MenuToys")
            if SpawnToyRemote then
                local SpawnFunc = SpawnToyRemote:FindFirstChild("SpawnToyRemoteFunction")
                if SpawnFunc then
                    SpawnFunc:InvokeServer(
                        itemName,
                        CFrame.new(root.Position + Vector3.new(0, 900, 0)),
                        Vector3.new(0, 0, 0)
                    )
                end
            end
        end)
    end

    local function findTargetItem()
        for _, item in pairs(getAllItemsWithRemote()) do
            if item.Name == TargetItemName then return item end
        end
        return nil
    end

    local function findSecondItem()
        for _, item in pairs(getAllItemsWithRemote()) do
            if item.Name == SecondItemName then return item end
        end
        return nil
    end

    local function performAutoAction(isFirstTime)
        if isFirstTime then
            if not findTargetItem() then spawnItem(TargetItemName) end
            if not findSecondItem() then spawnItem(SecondItemName) end
            task.wait(1.0)

            local target = findTargetItem()
            local second = findSecondItem()

            if target then holdItem(target) task.wait(0.1) end
            if second then holdItem(second) task.wait(0.1) end
            if target then useItem(target) task.wait(0.1) end
            if target then dropItemHigh(target) task.wait(0.1) end
            if second then dropItemHigh(second) end
        else
            local target = findTargetItem()
            if not target then
                spawnItem(TargetItemName)
                task.wait(1.0)
                target = findTargetItem()
            end
            if target then
                holdItem(target)
                task.wait(0.3)
                dropItemHigh(target)
            end
        end
    end

    local function setupSeat(seat)
        local conn = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
            local humanoid = seat.Occupant
            if humanoid then
                local player = Players:GetPlayerFromCharacter(humanoid.Parent)
                if player then
                    occupiedSeats[seat] = player
                    if AutomationEnabled then
                        local isFirst = not firstTimeRiders[player.UserId]
                        if isFirst then
                            firstTimeRiders[player.UserId] = true
                        end
                        performAutoAction(isFirst)
                    end
                end
                local sitConn
                sitConn = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
                    if not humanoid.Sit and player then
                        occupiedSeats[seat] = nil
                        if AutomationEnabled then
                            performAutoAction(false)
                        end
                        if sitConn then sitConn:Disconnect() end
                    end
                end)
            end
        end)
        seatConnections[seat] = conn
        table.insert(allSeats, seat)
    end

    local function startSeatDetection()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Seat") and obj.Name == "Seat" then
                setupSeat(obj)
            end
        end
        Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("Seat") and obj.Name == "Seat" then
                setupSeat(obj)
            end
        end)
    end

    local function sitOnRandomEmptySeat()
        local empty = {}
        for _, seat in pairs(allSeats) do
            if seat and seat.Parent and seat:IsA("Seat") and not seat.Occupant then
                table.insert(empty, seat)
            end
        end
        if #empty == 0 then
            OrionLib:MakeNotification({
                Name = "座席なし",
                Content = "空いている座席がありません",
                Time = 2
            })
            return
        end

        local seat = empty[math.random(1, #empty)]
        local char = getPlayerCharacter()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                hum.Sit = false
                task.wait(0.2)
                root.CFrame = seat.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
                seat:Sit(hum)
                OrionLib:MakeNotification({
                    Name = "着席",
                    Content = "ランダムな空席に座りました",
                    Time = 2
                })
            end
        end
    end

    local function startAutomation()
        if AutomationConnection then AutomationConnection:Disconnect() end
        local char = getPlayerCharacter()
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        AutomationConnection = hum.Seated:Connect(function(active, seat)
            if AutomationEnabled then
                task.wait(0.1)
                performAutoAction(active)
            end
        end)

        if AutomationEnabled and hum.SeatPart then
            performAutoAction(true)
        end
    end

    local function stopAutomation()
        if AutomationConnection then
            AutomationConnection:Disconnect()
            AutomationConnection = nil
        end
    end

    TrainTab:AddSection({ Name = "座席操作" })
    TrainTab:AddButton({ Name = "ランダムな空席に座る", Callback = sitOnRandomEmptySeat })

    TrainTab:AddSection({ Name = "自動化設定" })
    TrainTab:AddToggle({
        Name = "自動化を有効化",
        Default = false,
        Callback = function(value)
            AutomationEnabled = value
            if value then
                startAutomation()
                startSeatDetection()
                OrionLib:MakeNotification({
                    Name = "自動化ON",
                    Content = "乗車/降車時に" .. TargetItemName .. "を自動操作",
                    Time = 3
                })
            else
                stopAutomation()
                OrionLib:MakeNotification({
                    Name = "自動化OFF",
                    Content = "停止しました",
                    Time = 2
                })
            end
        end
    })

    TrainTab:AddParagraph("自動化の動作", "乗車/降車時に " .. TargetItemName .. " を出現→保持→使用→廃棄。初回のみ " .. SecondItemName .. " も出現。")

    TrainTab:AddSection({ Name = "PC用 便利機能" })
    TrainTab:AddButton({
        Name = "vFly GUI起動",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/makkurokurosukescript/VFly-gui/refs/heads/main/VFly%20gui'))()
            end)
        end
    })
    TrainTab:AddParagraph("vFly GUI", "WASD+QE飛行、Noclip機能付き。")

    local antiExplosionConn
    local function setupAntiExplosion(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local ragdolled = hum:FindFirstChild("Ragdolled")
        if ragdolled and ragdolled:IsA("BoolValue") then
            if antiExplosionConn then antiExplosionConn:Disconnect() end
            antiExplosionConn = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
                local anchored = ragdolled.Value
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = anchored
                    end
                end
            end)
        end
    end

    task.spawn(function()
        task.wait(1)
        startSeatDetection()
        if AutomationEnabled then startAutomation() end
        if LocalPlayer.Character then setupAntiExplosion(LocalPlayer.Character) end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if AutomationEnabled then startAutomation() end
        setupAntiExplosion(char)
    end)
end

-- ============================================================================
-- ブロック46: SRBM (ToyMod) タブ + HUD表示
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local Players = _G.Players
    local ReplicatedStorage = _G.ReplicatedStorage
    local Debris = _G.Debris
    local UserInputService = _G.UserInputService
    local LocalPlayer = _G.LocalPlayer
    local Workspace = _G.Workspace
    local RunService = _G.RunService

    local SRBMTab = Window:MakeTab({
        Name = "SRBM",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    SRBMTab:AddParagraph("注意", "SRBM機能は自分のオブジェクトしか取得できません！")

    -- ================================================================
    -- HUD表示機能 (新規追加)
    -- ================================================================
    SRBMTab:AddSection({ Name = "HUD表示" })
    
    local hudActive = false
    local hudScreenGui = nil
    local hudImageLabel = nil
    local hudCoordLabel = nil
    local hudCoordGui = nil
    local hudVisible = true

    local function CreateHUD()
        if hudScreenGui then
            hudScreenGui:Destroy()
            hudScreenGui = nil
        end
        if hudCoordGui then
            hudCoordGui:Destroy()
            hudCoordGui = nil
        end

        -- メイン画像（中央）
        hudScreenGui = Instance.new("ScreenGui")
        hudScreenGui.Name = "SRBM_HUD"
        hudScreenGui.Parent = LocalPlayer.PlayerGui

        hudImageLabel = Instance.new("ImageLabel")
        hudImageLabel.Size = UDim2.new(0, 200, 0, 200)
        hudImageLabel.Position = UDim2.new(0.5, -100, 0.5, -100)
        hudImageLabel.BackgroundTransparency = 1
        hudImageLabel.Image = "rbxassetid://133111892922392"
        hudImageLabel.Parent = hudScreenGui

        -- 座標表示（左上）
        hudCoordGui = Instance.new("ScreenGui")
        hudCoordGui.Name = "SRBM_Coord"
        hudCoordGui.Parent = LocalPlayer.PlayerGui

        hudCoordLabel = Instance.new("TextLabel")
        hudCoordLabel.Size = UDim2.new(0, 250, 0, 30)
        hudCoordLabel.Position = UDim2.new(0, 10, 0, 10)
        hudCoordLabel.BackgroundTransparency = 1
        hudCoordLabel.Text = "座標: 0, 0, 0"
        hudCoordLabel.TextColor3 = Color3.new(0, 1, 0)
        hudCoordLabel.TextScaled = true
        hudCoordLabel.Font = Enum.Font.GothamBold
        hudCoordLabel.TextXAlignment = Enum.TextXAlignment.Left
        hudCoordLabel.Parent = hudCoordGui

        hudVisible = true
    end

    local function ToggleHUDVisibility()
        hudVisible = not hudVisible
        if hudScreenGui then hudScreenGui.Enabled = hudVisible end
        if hudCoordGui then hudCoordGui.Enabled = hudVisible end
    end

    local coordUpdateConnection = nil

    local function StartHUD()
        if hudActive then return end
        hudActive = true

        CreateHUD()

        -- 座標更新ループ
        if coordUpdateConnection then coordUpdateConnection:Disconnect() end
        coordUpdateConnection = RunService.Heartbeat:Connect(function()
            if not hudActive then return end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                if hudCoordLabel then
                    hudCoordLabel.Text = string.format("座標: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
                end
            else
                if hudCoordLabel then
                    hudCoordLabel.Text = "座標: 取得中..."
                end
            end
        end)

        -- Pキーで表示切替
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.P then
                ToggleHUDVisibility()
                OrionLib:MakeNotification({
                    Name = "HUD",
                    Content = hudVisible and "表示" or "非表示",
                    Time = 1
                })
            end
        end)

        OrionLib:MakeNotification({
            Name = "HUD表示",
            Content = "有効化 (Pキーで表示切替)",
            Time = 3
        })
    end

    local function StopHUD()
        hudActive = false
        if coordUpdateConnection then
            coordUpdateConnection:Disconnect()
            coordUpdateConnection = nil
        end
        if hudScreenGui then
            hudScreenGui:Destroy()
            hudScreenGui = nil
        end
        if hudCoordGui then
            hudCoordGui:Destroy()
            hudCoordGui = nil
        end
        hudImageLabel = nil
        hudCoordLabel = nil
        OrionLib:MakeNotification({
            Name = "HUD表示",
            Content = "無効化",
            Time = 2
        })
    end

    SRBMTab:AddToggle({
        Name = "HUD表示 (画像+座標)",
        Default = false,
        Callback = function(Value)
            if Value then
                StartHUD()
            else
                StopHUD()
            end
        end
    })

    SRBMTab:AddButton({
        Name = "Pキーで表示切替 (説明)",
        Callback = function()
            OrionLib:MakeNotification({
                Name = "操作方法",
                Content = "Pキーで画像と座標の表示/非表示を切り替え",
                Time = 4
            })
        end
    })

    -- ================================================================
    -- 元のSRBM機能 (そのまま)
    -- ================================================================
    local originalCollides = {}
    local activeToys = {}
    local selectedTarget = "meobject"
    local bombMissileStartTime = nil
    local originalCameraSubject = nil
    local originalCameraType = nil
    local keysDown = {}
    local effectCoroutine = nil

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        keysDown[input.KeyCode] = true
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        keysDown[input.KeyCode] = false
    end)

    local toys = {
        missileRotationOffset = -135,
        mod = nil,
        isMoving = false
    }

    local function createBodyMovers(part)
        local bp = part:FindFirstChild("BP") or Instance.new("BodyPosition")
        bp.Name = "BP"
        bp.P = 20000
        bp.D = 200
        bp.MaxForce = Vector3.new(5e6, 5e6, 5e6)
        bp.Position = part.Position
        bp.Parent = part

        local bg = part:FindFirstChild("BG") or Instance.new("BodyGyro")
        bg.Name = "BG"
        bg.P = 20000
        bg.D = 200
        bg.MaxTorque = Vector3.new(5e6, 5e6, 5e6)
        bg.CFrame = part.CFrame
        bg.Parent = part

        part.Anchored = false
    end

    local function enableCollision(model)
        for _, p in pairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                if originalCollides[p] == nil then
                    originalCollides[p] = p.CanCollide
                end
                p.CanCollide = originalCollides[p]
            end
        end
    end

    local function collectModelsInFolder(folder)
        for _, toy in ipairs(folder:GetDescendants()) do
            if toy:IsA("Model") then
                local part = toy:FindFirstChildWhichIsA("BasePart")
                if part and not activeToys[toy] then
                    activeToys[toy] = {
                        part = part,
                        index = math.random(1, 1000)
                    }
                    enableCollision(toy)
                    createBodyMovers(part)
                end
            end
        end
    end

    local function addToysToAura(target)
        if target == "meobject" then
            local meFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if meFolder then
                collectModelsInFolder(meFolder)
            end

            local plotsFolder = workspace:FindFirstChild("Plots")
            if plotsFolder then
                for i = 1, 5 do
                    local plot = plotsFolder:FindFirstChild("Plot" .. i)
                    if plot then
                        local ownersFolder = plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("ThisPlotsOwners")
                        if ownersFolder then
                            for _, v in ipairs(ownersFolder:GetChildren()) do
                                if v:IsA("ValueBase") and v.Value == LocalPlayer.Name then
                                    local plotItemsFolder = workspace:FindFirstChild("PlotItems")
                                    if plotItemsFolder and plotItemsFolder:FindFirstChild(plot.Name) then
                                        collectModelsInFolder(plotItemsFolder:FindFirstChild(plot.Name))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    function clearEffects()
        for toy, _ in pairs(activeToys) do
            for _, child in ipairs(toy:GetDescendants()) do
                if child:IsA("BodyMover") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            enableCollision(toy)
        end
        activeToys = {}
    end

    local function bombMissileEffect()
        local camera = workspace.CurrentCamera
        
        local missile = nil
        for toy, data in pairs(activeToys) do
            if toy.Name == "BombMissile" then
                missile = toy
                break
            end
        end
        
        if not missile then
            if originalCameraSubject then
                camera.CameraSubject = originalCameraSubject
                camera.CameraType = originalCameraType
                originalCameraSubject = nil
                bombMissileStartTime = nil
            end
            return
        end
        
        local part = missile:FindFirstChildWhichIsA("BasePart")
        if not part or not part:FindFirstChild("BP") or not part:FindFirstChild("BG") then return end
        
        if not bombMissileStartTime then
            bombMissileStartTime = os.clock()
            originalCameraSubject = camera.CameraSubject
            originalCameraType = camera.CameraType
            camera.CameraSubject = part
        end
        
        local elapsed = os.clock() - bombMissileStartTime
        local speed = 2

        if elapsed < 5 then
            part.BP.Position = part.Position + Vector3.new(0, speed, 0)
        else
            part.BP.Position = part.Position + camera.CFrame.LookVector * speed
            part.BG.CFrame = camera.CFrame * CFrame.Angles(math.rad(toys.missileRotationOffset), 0, 0)
        end
    end

    local function helicopterEffect()
        local camera = workspace.CurrentCamera
        local heli = nil
        for toy, data in pairs(activeToys) do
            if toy.Name == "FlyingToyHelicopter" then
                heli = toy
                break
            end
        end

        if not heli then
            if originalCameraSubject then
                camera.CameraSubject = originalCameraSubject
                camera.CameraType = originalCameraType
                originalCameraSubject = nil
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.Anchored = false
                end
            end
            return
        end

        local part = heli:FindFirstChildWhichIsA("BasePart")
        if not part or not part:FindFirstChild("BP") or not part:FindFirstChild("BG") then return end

        if not originalCameraSubject then
            originalCameraSubject = camera.CameraSubject
            originalCameraType = camera.CameraType
            
            local cameraTarget = heli:FindFirstChild("Body") or part
            camera.CameraSubject = cameraTarget
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
            end
        end

        local moveSpeed = 0.3
        local rotateSpeed = 1.5
        local verticalSpeed = 0.3

        local moveDir = Vector3.new(0, 0, 0)
        local rotationChange = 0

        if keysDown[Enum.KeyCode.W] then
            moveDir = moveDir - part.CFrame.LookVector * moveSpeed
        end
        if keysDown[Enum.KeyCode.S] then
            moveDir = moveDir + part.CFrame.LookVector * moveSpeed
        end
        if keysDown[Enum.KeyCode.A] then
            rotationChange = rotationChange + rotateSpeed
        end
        if keysDown[Enum.KeyCode.D] then
            rotationChange = rotationChange - rotateSpeed
        end
        if keysDown[Enum.KeyCode.Z] then
            moveDir = moveDir + Vector3.new(0, verticalSpeed, 0)
        end
        if keysDown[Enum.KeyCode.X] then
            moveDir = moveDir - Vector3.new(0, verticalSpeed, 0)
        end

        if moveDir.Magnitude > 0 then
            part.BP.Position = part.Position + moveDir
        end

        if rotationChange ~= 0 then
            local x, y, z = part.BG.CFrame:ToEulerAnglesYXZ()
            part.BG.CFrame = CFrame.fromEulerAnglesYXZ(x, y + math.rad(rotationChange), z)
        end
    end

    local function combinedEffect()
        if toys.mod == "BombMissile" then
            bombMissileEffect()
        elseif toys.mod == "Helicopter" then
            helicopterEffect()
        end
    end

    function toggleEffect()
        if toys.isMoving then
            addToysToAura(selectedTarget)

            if effectCoroutine then
                coroutine.close(effectCoroutine)
            end

            effectCoroutine = coroutine.create(function()
                while toys.isMoving do
                    combinedEffect()
                    task.wait()
                end
            end)
            coroutine.resume(effectCoroutine)
        else
            if effectCoroutine then
                coroutine.close(effectCoroutine)
                effectCoroutine = nil
            end
            clearEffects()
            
            if originalCameraSubject then
                local camera = workspace.CurrentCamera
                camera.CameraSubject = originalCameraSubject
                camera.CameraType = originalCameraType
                originalCameraSubject = nil
                bombMissileStartTime = nil
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end

    SRBMTab:AddToggle({
        Name = "ICBM",
        Default = false,
        Save = true,
        Callback = function(state)
            toys.isMoving = state
            toys.mod = state and "BombMissile" or nil
            toggleEffect()
        end
    })

    SRBMTab:AddToggle({
        Name = "Third Person",
        Default = false,
        Callback = function(state)
            if state then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMaxZoomDistance = 100
                LocalPlayer.CameraMinZoomDistance = 0.5
            else
                LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                LocalPlayer.CameraMaxZoomDistance = 0.5
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
        end    
    })

    SRBMTab:AddToggle({
        Name = "Helicopter Control",
        Default = false,
        Save = true,
        Callback = function(state)
            toys.isMoving = state
            toys.mod = state and "Helicopter" or nil
            toggleEffect()
        end
    })

    SRBMTab:AddDropdown({
        Name = "Toy Mode",
        Default = selectedTarget,
        Options = {"meobject"},
        Callback = function(sel)
            selectedTarget = sel
            addToysToAura(selectedTarget)
        end
    })
end

-- ============================================================================
-- ブロック47: 縦型ハート機能 (縦ハート//) - 壁に垂直 / XY平面
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleVerticalHeart(state)
        SH.VerticalHeartConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalBigHeartConfig.Enabled then _G.toggleVerticalBigHeart(false) end
            
            SH.verticalHeartToys = findObjects()
            local count = math.min(#SH.verticalHeartToys, SH.VerticalHeartConfig.ObjectCount)
            SH.verticalHeartPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.verticalHeartPoints[i] = { angle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil }
            end
            
            SH.verticalHeartAssignedToys = {}
            for i = 1, math.min(#SH.verticalHeartToys, #SH.verticalHeartPoints) do
                local toy = SH.verticalHeartToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.verticalHeartPoints[i].angle }
                        SH.verticalHeartPoints[i].assignedToy = toyTable
                        table.insert(SH.verticalHeartAssignedToys, toyTable)
                    end
                end
            end
            
            SH.verticalHeartTime = 0
            if SH.verticalHeartLoopConn then SH.verticalHeartLoopConn:Disconnect() end
            SH.verticalHeartLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.VerticalHeartConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.verticalHeartTime = SH.verticalHeartTime + dt
                local basePosition = SH.VerticalHeartConfig.FollowPlayer and torso.Position or torso.Position
                local pulseEffect = (SH.VerticalHeartConfig.PulseSpeed > 0) and math.sin(SH.verticalHeartTime * SH.VerticalHeartConfig.PulseSpeed) * SH.VerticalHeartConfig.PulseAmplitude or 0
                for _, point in ipairs(SH.verticalHeartPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = toy.baseAngle + (SH.verticalHeartTime * SH.VerticalHeartConfig.RotationSpeed)
                        local baseScale = SH.VerticalHeartConfig.Size / 20
                        local x = 16 * (math.sin(currentAngle) ^ 3) * baseScale
                        local y = (13 * math.cos(currentAngle) - 5 * math.cos(2*currentAngle) - 2 * math.cos(3*currentAngle) - math.cos(4*currentAngle)) * baseScale
                        if pulseEffect > 0 then local pf = 1 + (pulseEffect * 0.1); x = x * pf; y = y * pf end
                        -- 縦ハート: XY平面（壁に垂直/立っている）
                        -- X=左右, Y=上下, Z=奥行き（薄さ）
                        local targetPosition = basePosition + Vector3.new(
                            x,
                            SH.VerticalHeartConfig.Height + y,
                            math.sin(currentAngle * 2) * 0.5
                        )
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "縦ハート// 開始", Content = "サイズ: " .. SH.VerticalHeartConfig.Size, Time = 3 })
        else
            if SH.verticalHeartLoopConn then SH.verticalHeartLoopConn:Disconnect(); SH.verticalHeartLoopConn = nil end
            for _, point in ipairs(SH.verticalHeartPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.verticalHeartPoints = {}; SH.verticalHeartAssignedToys = {}
            OrionLib:MakeNotification({ Name = "縦ハート// 停止", Content = "縦ハート配置を解除", Time = 2 })
        end
    end
    _G.toggleVerticalHeart = toggleVerticalHeart
end

-- ============================================================================
-- ブロック48: 縦型ビッグハート機能 (縦おっきぃ♡) - 壁に垂直 / XY平面
-- ============================================================================
do
    local SH = _G.SH
    local Workspace = _G.Workspace
    local LocalPlayer = _G.LocalPlayer
    local RunService = _G.RunService
    local OrionLib = _G.OrionLib
    local findObjects = _G.findObjects
    local getPrimaryPart = _G.getPrimaryPart
    local attachPhysics = _G.attachPhysics

    function toggleVerticalBigHeart(state)
        SH.VerticalBigHeartConfig.Enabled = state
        if state then
            if SH.FeatherConfig.Enabled then _G.toggleFeather(false) end
            if SH.MagicCircleConfig.Enabled then _G.toggleMagicCircle(false) end
            if SH.HeartConfig.Enabled then _G.toggleHeart(false) end
            if SH.BigHeartConfig.Enabled then _G.toggleBigHeart(false) end
            if SH.StarOfDavidConfig.Enabled then _G.toggleStarOfDavid(false) end
            if SH.StarConfig.Enabled then _G.toggleStar(false) end
            if SH.Star2Config.Enabled then _G.toggleStar2(false) end
            if SH.SphereConfig.Enabled then _G.toggleSphere(false) end
            if SH.FerrisWheelConfig.Enabled then _G.toggleFerrisWheel(false) end
            if SH.AnimN1Config.Enabled then _G.toggleAnimN1(false) end
            if SH.AnimN2Config.Enabled then _G.toggleAnimN2(false) end
            if SH.AnimN3Config.Enabled then _G.toggleAnimN3(false) end
            if SH.WingConfig.Enabled then _G.toggleWing(false) end
            if SH.SaturnConfig.Enabled then _G.toggleSaturn(false) end
            if SH.PianoConfig.Enabled then _G.togglePiano(false) end
            if SH.VerticalHeartConfig.Enabled then _G.toggleVerticalHeart(false) end
            
            SH.verticalBigHeartToys = findObjects()
            local count = math.min(#SH.verticalBigHeartToys, SH.VerticalBigHeartConfig.ObjectCount)
            SH.verticalBigHeartPoints = {}
            for i = 1, count do
                local part = Instance.new("Part")
                part.CanCollide = false; part.Anchored = true; part.Transparency = 1
                part.Size = Vector3.new(4, 1, 4); part.Parent = workspace
                SH.verticalBigHeartPoints[i] = { angle = (i - 1) * (2 * math.pi / count), part = part, assignedToy = nil }
            end
            
            SH.verticalBigHeartAssignedToys = {}
            for i = 1, math.min(#SH.verticalBigHeartToys, #SH.verticalBigHeartPoints) do
                local toy = SH.verticalBigHeartToys[i]
                if toy and toy:IsA("Model") and toy.Name == SH.ObjectIDConfig.CurrentObjectID then
                    local primaryPart = getPrimaryPart(toy)
                    if primaryPart then
                        for _, child in ipairs(toy:GetChildren()) do if child:IsA("BasePart") then child.CanCollide = false; child.CanTouch = false; child.Anchored = false end end
                        local BG, BP = attachPhysics(primaryPart)
                        local toyTable = { BG = BG, BP = BP, Pallet = primaryPart, Model = toy, PointIndex = i, baseAngle = SH.verticalBigHeartPoints[i].angle }
                        SH.verticalBigHeartPoints[i].assignedToy = toyTable
                        table.insert(SH.verticalBigHeartAssignedToys, toyTable)
                    end
                end
            end
            
            SH.verticalBigHeartTime = 0
            if SH.verticalBigHeartLoopConn then SH.verticalBigHeartLoopConn:Disconnect() end
            SH.verticalBigHeartLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not SH.VerticalBigHeartConfig.Enabled or not LocalPlayer.Character then return end
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if not torso then return end
                SH.verticalBigHeartTime = SH.verticalBigHeartTime + dt
                local basePosition = SH.VerticalBigHeartConfig.FollowPlayer and torso.Position or torso.Position
                local pulseEffect = (SH.VerticalBigHeartConfig.PulseSpeed > 0) and math.sin(SH.verticalBigHeartTime * SH.VerticalBigHeartConfig.PulseSpeed) * SH.VerticalBigHeartConfig.PulseAmplitude or 0
                for _, point in ipairs(SH.verticalBigHeartPoints) do
                    if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                        local toy = point.assignedToy
                        local currentAngle = toy.baseAngle + (SH.verticalBigHeartTime * SH.VerticalBigHeartConfig.RotationSpeed)
                        local baseScale = SH.VerticalBigHeartConfig.Size / 20
                        local x = 16 * (math.sin(currentAngle) ^ 3) * baseScale * SH.VerticalBigHeartConfig.HeartScale
                        local y = (13 * math.cos(currentAngle) - 5 * math.cos(2*currentAngle) - 2 * math.cos(3*currentAngle) - math.cos(4*currentAngle)) * baseScale * SH.VerticalBigHeartConfig.HeartScale
                        if pulseEffect > 0 then local pf = 1 + (pulseEffect * 0.1); x = x * pf; y = y * pf end
                        -- 縦ビッグハート: XY平面（壁に垂直/立っている）
                        -- X=左右, Y=上下, Z=奥行き（薄さ）
                        local targetPosition = basePosition + Vector3.new(
                            x,
                            SH.VerticalBigHeartConfig.Height + y,
                            math.sin(currentAngle * 2) * 1.0
                        )
                        if point.part then point.part.Position = targetPosition end
                        toy.BP.Position = targetPosition
                        toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "縦おっきぃ♡ 開始", Content = "サイズ: " .. SH.VerticalBigHeartConfig.Size, Time = 3 })
        else
            if SH.verticalBigHeartLoopConn then SH.verticalBigHeartLoopConn:Disconnect(); SH.verticalBigHeartLoopConn = nil end
            for _, point in ipairs(SH.verticalBigHeartPoints) do
                if point.part then point.part:Destroy() end
                if point.assignedToy then
                    if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
                    if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
                end
            end
            SH.verticalBigHeartPoints = {}; SH.verticalBigHeartAssignedToys = {}
            OrionLib:MakeNotification({ Name = "縦おっきぃ♡ 停止", Content = "縦おっきぃ♡配置を解除", Time = 2 })
        end
    end
    _G.toggleVerticalBigHeart = toggleVerticalBigHeart
end

-- ============================================================================
-- ブロック49: 縦ハートタブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local VerticalHeartTab = Window:MakeTab({ Name = "縦ハート//", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    VerticalHeartTab:AddToggle({ Name = "縦ハート起動", Default = false, Callback = _G.toggleVerticalHeart })
    VerticalHeartTab:AddToggle({ Name = "プレイヤー追従", Default = SH.VerticalHeartConfig.FollowPlayer, Callback = function(v) SH.VerticalHeartConfig.FollowPlayer = v end })
    VerticalHeartTab:AddSlider({ Name = "ハートサイズ", Min = 2, Max = 50, Default = SH.VerticalHeartConfig.Size, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.VerticalHeartConfig.Size = v end })
    VerticalHeartTab:AddSlider({ Name = "基本高さ", Min = 0, Max = 50, Default = SH.VerticalHeartConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.VerticalHeartConfig.Height = v end })
    VerticalHeartTab:AddSlider({ Name = "オブジェクト数", Min = 6, Max = 100, Default = SH.VerticalHeartConfig.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.VerticalHeartConfig.ObjectCount = v end })
    VerticalHeartTab:AddSlider({ Name = "回転速度", Min = 0, Max = 10, Default = SH.VerticalHeartConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.VerticalHeartConfig.RotationSpeed = v end })
    VerticalHeartTab:AddSlider({ Name = "脈動速度", Min = 0, Max = 10, Default = SH.VerticalHeartConfig.PulseSpeed, Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度", Callback = function(v) SH.VerticalHeartConfig.PulseSpeed = v end })
    VerticalHeartTab:AddSlider({ Name = "脈動振幅", Min = 0, Max = 10, Default = SH.VerticalHeartConfig.PulseAmplitude, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.VerticalHeartConfig.PulseAmplitude = v end })
end

-- ============================================================================
-- ブロック50: 縦おっきぃ♡タブ
-- ============================================================================
do
    local Window = _G.Window
    local OrionLib = _G.OrionLib
    local SH = _G.SH
    local Theme = _G.Theme

    local VerticalBigHeartTab = Window:MakeTab({ Name = "縦おっきぃ♡", Icon = "rbxassetid://4483362458", PremiumOnly = false })
    VerticalBigHeartTab:AddToggle({ Name = "縦おっきぃ♡起動", Default = false, Callback = _G.toggleVerticalBigHeart })
    VerticalBigHeartTab:AddToggle({ Name = "プレイヤー追従", Default = SH.VerticalBigHeartConfig.FollowPlayer, Callback = function(v) SH.VerticalBigHeartConfig.FollowPlayer = v end })
    VerticalBigHeartTab:AddSlider({ Name = "基本サイズ", Min = 5, Max = 50, Default = SH.VerticalBigHeartConfig.Size, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.VerticalBigHeartConfig.Size = v end })
    VerticalBigHeartTab:AddSlider({ Name = "拡大率", Min = 1.0, Max = 10.0, Default = SH.VerticalBigHeartConfig.HeartScale, Color = Theme.SliderColor, Increment = 0.1, ValueName = "倍", Callback = function(v) SH.VerticalBigHeartConfig.HeartScale = v end })
    VerticalBigHeartTab:AddSlider({ Name = "基本高さ", Min = 5, Max = 50, Default = SH.VerticalBigHeartConfig.Height, Color = Theme.SliderColor, Increment = 1, ValueName = "スタッド", Callback = function(v) SH.VerticalBigHeartConfig.Height = v end })
    VerticalBigHeartTab:AddSlider({ Name = "オブジェクト数", Min = 12, Max = 100, Default = SH.VerticalBigHeartConfig.ObjectCount, Color = Theme.SliderColor, Increment = 2, ValueName = "個", Callback = function(v) SH.VerticalBigHeartConfig.ObjectCount = v end })
    VerticalBigHeartTab:AddSlider({ Name = "回転速度", Min = 0, Max = SH.VerticalBigHeartConfig.RotationSpeedMax, Default = SH.VerticalBigHeartConfig.RotationSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.VerticalBigHeartConfig.RotationSpeed = v end })
    VerticalBigHeartTab:AddSlider({ Name = "脈動速度", Min = 0, Max = SH.VerticalBigHeartConfig.PulseSpeedMax, Default = SH.VerticalBigHeartConfig.PulseSpeed, Color = Theme.SliderColor, Increment = 0.5, ValueName = "速度", Callback = function(v) SH.VerticalBigHeartConfig.PulseSpeed = v end })
    VerticalBigHeartTab:AddSlider({ Name = "脈動振幅", Min = 0, Max = 10, Default = SH.VerticalBigHeartConfig.PulseAmplitude, Color = Theme.SliderColor, Increment = 0.1, ValueName = "スタッド", Callback = function(v) SH.VerticalBigHeartConfig.PulseAmplitude = v end })
end

-- ============================================================================
-- ブロック51: 空欄
-- ============================================================================

-- ============================================================================
-- ブロック52: 完了通知
-- ============================================================================
do
    local OrionLib = _G.OrionLib

    task.wait(1)
    OrionLib:MakeNotification({
        Name = "NabeHub 起動完了",
        Content = "完全版 - 全機能正常動作",
        Image = "rbxassetid://4483362458",
        Time = 5
    })

    print("==========================================")
    print("NabeHub 完全版")
    print("==========================================")
end
