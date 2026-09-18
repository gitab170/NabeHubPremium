-- ==========================================
-- Player Teleport-Grab Sequence Script
-- OrionLib UI + 物人ロジック
-- ==========================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- リモート参照
-- ==========================================
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")

local CreateGrabLine    = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyGrabLine   = GrabEvents:WaitForChild("DestroyGrabLine")
local SetNetworkOwner   = GrabEvents:WaitForChild("SetNetworkOwner")
local ExtendGrabLine    = GrabEvents:WaitForChild("ExtendGrabLine")
local RagdollRemote     = CharacterEvents:WaitForChild("RagdollRemote")
local Struggle          = CharacterEvents:WaitForChild("Struggle")

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

-- 自分のHRPを安全にTP（クライアント側）
local function teleportSelf(cf)
    local hrp = getHRP(LocalPlayer)
    if not hrp then return false end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

-- ネットワーク所有権を奪う（30スタッド制限あり）
local function takeOwnership(part)
    if not part then return false end
    local ok = pcall(function()
        SetNetworkOwner:FireServer(part, part.CFrame)
    end)
    task.wait(0.05)
    local owner = part:FindFirstChild("PartOwner")
    return ok
end

-- 所有権を狙って複数回試す
local function grabOwnership(part, tries)
    tries = tries or 3
    for i = 1, tries do
        takeOwnership(part)
        local ok = part:FindFirstChild("PartOwner")
        if ok and ok.Value == LocalPlayer.Name then
            return true
        end
        -- 自分が近づいてから再試行
        local myHrp = getHRP(LocalPlayer)
        if myHrp then
            myHrp.CFrame = part.CFrame * CFrame.new(0, 0, 3)
        end
        task.wait(0.1)
    end
    return false
end

-- グラブライン生成（掴み）
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

-- グラブライン破棄（掴み解除）
local function releaseTarget(targetHRP)
    if not targetHRP then return end
    pcall(function()
        DestroyGrabLine:FireServer(targetHRP)
    end)
    task.wait(0.1)
end

-- ==========================================
-- メイン処理：1ターゲットに対して実行
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

    -- 3. 自分の近く（少し前）にターゲットをテレポートさせる
    --    → まず所有権を奪う
    local owned = grabOwnership(targetHrp, 3)
    if not owned then
        -- 近づいてから再試行
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
        task.wait(0.1)
        owned = grabOwnership(targetHrp, 3)
    end

    -- 4. ターゲットを自分の位置にTP
    local approachCF = myHrp.CFrame * CFrame.new(0, 0, -3)
    targetHrp.CFrame = approachCF
    targetHrp.AssemblyLinearVelocity = Vector3.zero
    targetHrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.05)

    -- 5. グラブ
    grabTarget(targetHrp, 5)
    task.wait(0.15)

    -- 6. 元座標の10上にターゲットをTP
    local liftedCF = targetOriginCF * CFrame.new(0, 10, 0)
    targetHrp.CFrame = liftedCF
    targetHrp.AssemblyLinearVelocity = Vector3.zero
    targetHrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.15)

    -- 7. グラブ解除
    releaseTarget(targetHrp)

    -- 8. ターゲットを元の座標に戻す
    task.wait(0.05)
    targetHrp.CFrame = targetOriginCF
    targetHrp.AssemblyLinearVelocity = Vector3.zero
    targetHrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.1)

    -- 9. 自分を元の座標へ戻す
    teleportSelf(myOriginCF)
end

-- ==========================================
-- キュー処理（複数ターゲットを順番に）
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
local Window = OrionLib:MakeWindow({
    Name = "Sequence Grab Tool",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "SeqGrabTool"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local selectedTargets = {}

-- 全プレイヤーの名前リストを取得する関数
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

-- ドロップダウン（単一選択・複数追加型）
local TargetDropdown
TargetDropdown = MainTab:CreateDropdown({
    Name = "Target Player (追加で複数選択可)",
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

-- プレイヤーリスト更新ボタン
MainTab:CreateButton({
    Name = "プレイヤーリスト更新",
    Callback = function()
        TargetDropdown:Refresh(getPlayerNames(), true)
    end
})

-- 実行ボタン
MainTab:CreateButton({
    Name = "▶ 実行（選択順に処理）",
    Callback = function()
        if #selectedTargets == 0 then
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "ターゲットが選択されていません",
                Time = 3
            })
            return
        end

        -- 選択順にキューへ積む
        for _, name in ipairs(selectedTargets) do
            local plr = Players:FindFirstChild(name)
            if plr and plr ~= LocalPlayer then
                table.insert(queue, plr)
            end
        end

        OrionLib:MakeNotification({
            Name = "開始",
            Content = #queue .. " 件のターゲットを処理します",
            Time = 3
        })

        processQueue()
    end
})

-- 停止ボタン
MainTab:CreateButton({
    Name = "停止 / キューリセット",
    Callback = function()
        queue = {}
        processing = false
        OrionLib:MakeNotification({
            Name = "停止",
            Content = "キューをクリアしました",
            Time = 2
        })
    end
})

-- ==========================================
-- プレイヤー入退室時のドロップダウン更新
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

OrionLib:Init()
