-- ==========================================
-- ハンバーガーループ v3.0 完全版
-- 自分専用・自動スポーン・通常/円形ドロップ・ハイライト付き
-- ==========================================

-- Orion Lib ロード
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion'))()

local Window = OrionLib:MakeWindow({
    Name = "ハンバーガーループ",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HamburgerLoop",
    IntroEnabled = true,
    IntroText = "ハンバーガーループ v3.0",
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

local Tab = Window:MakeTab({Name = "ハンバーガー", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- ==========================================
-- 変数
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local loopEnabled = false
local loopThread = nil

-- ループ設定
local dropHeight = 10
local holdTime = 0.05
local dropTime = 0.05
local spawnWait = 0.3

-- 円形ドロップ設定
local circleMode = false
local circleRadius = 5
local circleStep = 45
local circleAngle = 0
local circleLayer = 0

-- ハイライト設定
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 200, 100)
local highlightFillTransparency = 0.3
local currentHighlight = nil

-- ==========================================
-- 関数
-- ==========================================

local function HRP()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

local function getMyToysFolder()
    return Workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
end

local function findMyHamburger()
    local folder = getMyToysFolder()
    if not folder then return nil end
    return folder:FindFirstChild("FoodHamburger")
end

local function spawnHamburger()
    local hrp = HRP()
    if not hrp then return nil end
    
    pcall(function()
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
            "FoodHamburger",
            hrp.CFrame * CFrame.new(0, 5, 5),
            Vector3.zero
        )
    end)
    
    task.wait(spawnWait)
    
    local folder = getMyToysFolder()
    if folder then
        return folder:FindFirstChild("FoodHamburger")
    end
    
    return nil
end

local function holdHamburger(burger)
    if not burger or not burger.Parent then return false end
    local holdPart = burger:FindFirstChild("HoldPart")
    if not holdPart then return false end
    local holdRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
    if not holdRemote then return false end
    local char = LP.Character
    if not char then return false end
    pcall(function() holdRemote:InvokeServer(burger, char) end)
    return true
end

local function dropHamburgerAbove(burger)
    if not burger or not burger.Parent then return false end
    local holdPart = burger:FindFirstChild("HoldPart")
    if not holdPart then return false end
    local dropRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
    if not dropRemote then return false end
    local hrp = HRP()
    if not hrp then return false end
    local dropPos = hrp.CFrame * CFrame.new(0, dropHeight, 0)
    pcall(function() dropRemote:InvokeServer(burger, dropPos, Vector3.zero) end)
    return true
end

local function dropHamburgerCircle(burger)
    if not burger or not burger.Parent then return false end
    local holdPart = burger:FindFirstChild("HoldPart")
    if not holdPart then return false end
    local dropRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
    if not dropRemote then return false end
    local hrp = HRP()
    if not hrp then return false end
    
    local angleRad = math.rad(circleAngle)
    local radius = circleRadius + (circleLayer * 3)
    local x = math.cos(angleRad) * radius
    local z = math.sin(angleRad) * radius
    
    local dropPos = hrp.CFrame * CFrame.new(x, dropHeight, z)
    
    pcall(function() dropRemote:InvokeServer(burger, dropPos, Vector3.zero) end)
    
    circleAngle = circleAngle + circleStep
    if circleAngle >= 360 then
        circleAngle = 0
        circleLayer = circleLayer + 1
        if circleLayer > 5 then circleLayer = 0 end
    end
    
    return true
end

local function updateHighlight(burger)
    if highlightEnabled and burger and burger.Parent then
        if not currentHighlight or currentHighlight.Parent ~= burger then
            if currentHighlight then currentHighlight:Destroy() end
            currentHighlight = Instance.new("Highlight", burger)
            currentHighlight.Name = "NabeBurgerHighlight"
        end
        currentHighlight.FillColor = highlightColor
        currentHighlight.FillTransparency = highlightFillTransparency
        currentHighlight.OutlineColor = highlightColor
        currentHighlight.OutlineTransparency = 0
    else
        if currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
    end
end

-- ==========================================
-- メインループ
-- ==========================================

local function startLoop()
    if loopEnabled then return end
    loopEnabled = true
    circleAngle = 0
    circleLayer = 0
    
    loopThread = task.spawn(function()
        while loopEnabled do
            local burger = findMyHamburger()
            
            if not burger or not burger.Parent then
                burger = spawnHamburger()
                if not burger then
                    task.wait(0.5)
                    continue
                end
            end
            
            updateHighlight(burger)
            
            -- 持つ → ドロップ（1回目）
            holdHamburger(burger)
            task.wait(holdTime)
            
            if circleMode then
                dropHamburgerCircle(burger)
            else
                dropHamburgerAbove(burger)
            end
            task.wait(dropTime)
            
            updateHighlight(burger)
            
            -- 持つ → ドロップ（2回目）
            holdHamburger(burger)
            task.wait(holdTime)
            
            if circleMode then
                dropHamburgerCircle(burger)
            else
                dropHamburgerAbove(burger)
            end
            task.wait(dropTime)
        end
        
        -- 停止時にハイライト削除
        if currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
        
        loopThread = nil
        OrionLib:MakeNotification({Name = "ハンバーガーループ", Content = "停止しました", Time = 2})
    end)
    
    OrionLib:MakeNotification({Name = "ハンバーガーループ", Content = "開始しました", Time = 2})
end

local function stopLoop()
    loopEnabled = false
    if loopThread then
        task.cancel(loopThread)
        loopThread = nil
    end
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

-- ==========================================
-- UI構築
-- ==========================================

Tab:AddSection({Name = "ループ制御"})

Tab:AddToggle({
    Name = "ループ実行",
    Default = false,
    Callback = function(v)
        if v then startLoop() else stopLoop() end
    end
})

Tab:AddButton({
    Name = "強制停止",
    Callback = stopLoop
})

Tab:AddSection({Name = "基本設定"})

Tab:AddSlider({
    Name = "ドロップ高さ",
    Min = 1, Max = 50, Default = 10, Increment = 1,
    Callback = function(v) dropHeight = v end
})

Tab:AddSlider({
    Name = "持つ時間",
    Min = 0.01, Max = 0.5, Default = 0.05, Increment = 0.01,
    Callback = function(v) holdTime = v end
})

Tab:AddSlider({
    Name = "ドロップ間隔",
    Min = 0.01, Max = 0.5, Default = 0.05, Increment = 0.01,
    Callback = function(v) dropTime = v end
})

Tab:AddSlider({
    Name = "スポーン待機",
    Min = 0.1, Max = 2, Default = 0.3, Increment = 0.1,
    Callback = function(v) spawnWait = v end
})

Tab:AddSection({Name = "円形ドロップ"})

Tab:AddToggle({
    Name = "円形ドロップモード",
    Default = false,
    Callback = function(v)
        circleMode = v
        if v then
            circleAngle = 0
            circleLayer = 0
        end
    end
})

Tab:AddSlider({
    Name = "円の半径",
    Min = 1, Max = 30, Default = 5, Increment = 1,
    Callback = function(v) circleRadius = v end
})

Tab:AddSlider({
    Name = "角度ステップ",
    Min = 5, Max = 180, Default = 45, Increment = 5,
    Callback = function(v) circleStep = v end
})

Tab:AddSection({Name = "ハイライト"})

Tab:AddToggle({
    Name = "ハイライト表示",
    Default = false,
    Callback = function(v)
        highlightEnabled = v
        if not v and currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
    end
})

Tab:AddSlider({
    Name = "透過度",
    Min = 0, Max = 1, Default = 0.3, Increment = 0.05,
    Callback = function(v)
        highlightFillTransparency = v
        if currentHighlight then
            currentHighlight.FillTransparency = v
        end
    end
})

-- ==========================================
-- 退出時に自動停止
-- ==========================================
Players.PlayerRemoving:Connect(function(p)
    if p == LP then stopLoop() end
end)

-- ==========================================
-- 初期化
-- ==========================================
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "ハンバーガーループ v3.0",
    Content = "ロード完了！",
    Time = 5
})
