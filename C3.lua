-- ==========================================
-- Player Teleport-Grab Sequence Script
-- XOCU FAKELIBRORY (SolarisUI) 版
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sladkoeshkaogg-svg/XOCU/refs/heads/main/XOCU%20FAKELIBRORY.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- リモート参照
-- ==========================================
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")

local CreateGrabLine    = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyGrabLine   = GrabEvents:WaitForChild("DestroyGrabLine")
local SetNetworkOwner   = GrabEvents:WaitForChild("SetNetworkOwner")

-- ==========================================
-- ユーティリティ
-- ==========================================
local function getHRP(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("HumanoidRootPart")
end

local function getHum(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local hum = getHum(plr)
    return hum and hum.Health > 0
end

local function teleportSelf(cf)
    local hrp = getHRP(LocalPlayer)
    if not hrp then return false end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function takeOwnership(part)
    if not part then return false end
    local ok = pcall(function()
        SetNetworkOwner:FireServer(part, part.CFrame)
    end)
    task.wait(0.05)
    local owner = part:FindFirstChild("PartOwner")
    return ok, owner
end

local function grabOwnership(part, tries)
    tries = tries or 3
    for i = 1, tries do
        takeOwnership(part)
        local owner = part:FindFirstChild("PartOwner")
        if owner and owner.Value == LocalPlayer.Name then
            return true
        end
        local myHrp = getHRP(LocalPlayer)
        if myHrp then
            myHrp.CFrame = part.CFrame * CFrame.new(0, 0, 3)
        end
        task.wait(0.1)
    end
    return false
end

local function grabTarget(targetHRP, lengthStuds)
    lengthStuds = lengthStuds or 5
    local myHrp = getHRP(LocalPlayer)
    if not myHrp or not targetHRP then return false end

    local endCF = myHrp.CFrame * CFrame.new(0, 0, -lengthStuds)

    pcall(function()
        CreateGrabLine:FireServer(
            targetHRP,
            endCF,
            Vector3.zero,
            false
        )
    end)
    task.wait(0.15)
    return true
end

local function releaseTarget(targetHRP)
    if not targetHRP then return end
    pcall(function()
        DestroyGrabLine:FireServer(targetHRP)
    end)
    task.wait(0.1)
end

-- ==========================================
-- メイン処理：1ターゲット
-- ==========================================
local function processOne(target)
    if target == LocalPlayer then return end
    if not isAlive(target) then return end

    local myHrp = getHRP(LocalPlayer)
    local targetHrp = getHRP(target)
    if not myHrp or not targetHrp then return end

    -- 1. 自分の元座標を記憶
    local myOriginCF = myHrp.CFrame

    -- 2. ターゲットの元座標を記憶
    local targetOriginCF = targetHrp.CFrame

    -- 3. 所有権奪取
    local owned = grabOwnership(targetHrp, 3)
    if not owned then
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
        task.wait(0.1)
        owned = grabOwnership(targetHrp, 3)
    end

    -- 4. ターゲットを自分の位置へTP
    local approachCF = myHrp.CFrame * CFrame.new(0, 0, -3)
    targetHrp.CFrame = approachCF
    targetHrp.AssemblyLinearVelocity = Vector3.zero
    targetHrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.05)

    -- 5. グラブ
    grabTarget(targetHrp, 5)
    task.wait(0.15)

    -- 6. 元座標の10上にTP
    local liftedCF = targetOriginCF * CFrame.new(0, 10, 0)
    targetHrp.CFrame = liftedCF
    targetHrp.AssemblyLinearVelocity = Vector3.zero
    targetHrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.15)

    -- 7. グラブ解除
    releaseTarget(targetHrp)

    -- 8. ターゲットを元座標へ戻す
    task.wait(0.05)
    targetHrp.CFrame = targetOriginCF
    targetHrp.AssemblyLinearVelocity = Vector3.zero
    targetHrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.1)

    -- 9. 自分を元座標へ戻す
    teleportSelf(myOriginCF)
end

-- ==========================================
-- キュー処理
-- ==========================================
local processing = false
local queue = {}

local function processQueue()
    if processing then return end
    processing = true
    while #queue > 0 do
        local target = table.remove(queue, 1)
        pcall(function()
            processOne(target)
        end)
        task.wait(0.3)
    end
    processing = false
end

-- ==========================================
-- UI
-- ==========================================
local Window = Library:CreateWindow({
    Title = "Sequence Grab Tool",
    Theme = "Purple",
    ConfigFolder = "SeqGrabTool",
    ShowWatermark = {
        Enabled = true,
        Title = true,
        User = true,
        FPS = true,
        Time = true,
        Ping = true
    }
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local selectedTargets = {}

local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    table.sort(names)
    return names
end

-- ==========================================
-- ドロップダウン（複数選択）
-- ==========================================
local TargetDropdown
TargetDropdown = MainTab:CreateDropdown({
    Name = "Target Player (複数選択可)",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "TargetPlayerDropdown",
    Callback = function(options)
        selectedTargets = {}
        if type(options) == "table" then
            for _, name in ipairs(options) do
                table.insert(selectedTargets, name)
            end
        elseif type(options) == "string" then
            table.insert(selectedTargets, options)
        end
    end
})

-- プレイヤーリスト更新
MainTab:CreateButton({
    Name = "プレイヤーリスト更新",
    Callback = function()
        pcall(function()
            TargetDropdown:Refresh(getPlayerNames(), true)
        end)
        Library:Notify({
            Title = "更新完了",
            Content = "プレイヤーリストを更新しました",
            Duration = 3
        })
    end
})

-- 実行
MainTab:CreateButton({
    Name = "▶ 実行（選択順に処理）",
    Callback = function()
        if #selectedTargets == 0 then
            Library:Notify({
                Title = "エラー",
                Content = "ターゲットが選択されていません",
                Duration = 3
            })
            return
        end

        for _, name in ipairs(selectedTargets) do
            local plr = Players:FindFirstChild(name)
            if plr and plr ~= LocalPlayer then
                table.insert(queue, plr)
            end
        end

        Library:Notify({
            Title = "開始",
            Content = #queue .. " 件のターゲットを処理します",
            Duration = 3
        })

        processQueue()
    end
})

-- 停止
MainTab:CreateButton({
    Name = "⏹ 停止 / キューリセット",
    Callback = function()
        queue = {}
        processing = false
        Library:Notify({
            Title = "停止",
            Content = "キューをクリアしました",
            Duration = 2
        })
    end
})

-- ==========================================
-- プレイヤー入退室時の更新
-- ==========================================
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    pcall(function()
        TargetDropdown:Refresh(getPlayerNames(), true)
    end)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.3)
    pcall(function()
        TargetDropdown:Refresh(getPlayerNames(), true)
    end)
end)
