-- Orion Lib ロード
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion'))()

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "戦闘用v2.5",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "戦闘用v2.5",
    IntroEnabled = true,
    IntroText = "起動中…\nテスト段階なのでエラーが発生する可能性があります",
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
-- タブ作成
-- ==========================================
local AntiTab = Window:MakeTab({Name = "アンチ", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local KickTab = Window:MakeTab({Name = "キック", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local Kick2Tab = Window:MakeTab({Name = "キック2", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local KillTab = Window:MakeTab({Name = "キル", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local BarrierTab = Window:MakeTab({Name = "バリア破壊", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local PlayerTab = Window:MakeTab({Name = "プレイヤー", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local LagTab = Window:MakeTab({Name = "ラグ", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local RagdollTab = Window:MakeTab({Name = "ラグドール", Icon = "rbxassetid://4483362458", PremiumOnly = false})

-- ==========================================
-- 共通変数
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ==========================================
-- ラグタブ
-- ==========================================
-- ==========================================

local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
local lineLagThread = nil
local lineLagEnabled = false

local function startLineLag()
    if lineLagEnabled then return end
    if not GrabEvents then
        OrionLib:MakeNotification({Name = "Error", Content = "GrabEventsが見つかりません", Time = 3})
        return
    end
    local createLine = GrabEvents:FindFirstChild("CreateGrabLine")
    if not createLine then
        OrionLib:MakeNotification({Name = "Error", Content = "CreateGrabLineが見つかりません", Time = 3})
        return
    end
    lineLagEnabled = true
    lineLagThread = coroutine.create(function()
        while lineLagEnabled do
            local spawnLocation = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            if spawnLocation then
                local randomX = math.random(-1e9, 1e9)
                local randomZ = math.random(-1e9, 1e9)
                local directions = {
                    CFrame.new(randomX, 0, randomZ),
                    CFrame.new(-randomX, 0, -randomZ),
                    CFrame.new(randomX, 0, -randomZ),
                    CFrame.new(-randomX, 0, randomZ)
                }
                for _, pos in pairs(directions) do
                    pcall(function()
                        createLine:FireServer(spawnLocation, pos)
                    end)
                end
            end
            task.wait()
        end
    end)
    coroutine.resume(lineLagThread)
    OrionLib:MakeNotification({Name = "Lag", Content = "ラグを開始しました", Time = 2})
end

local function stopLineLag()
    if not lineLagEnabled then
        OrionLib:MakeNotification({Name = "Lag", Content = "既に停止しています", Time = 2})
        return
    end
    lineLagEnabled = false
    if lineLagThread then
        coroutine.close(lineLagThread)
        lineLagThread = nil
    end
    OrionLib:MakeNotification({Name = "Lag", Content = "ラグを停止しました", Time = 2})
end

LagTab:AddSection({Name = "ラインラグサーバー"})
LagTab:AddButton({Name = "Start Lag (ラグ開始)", Callback = function() startLineLag() end})
LagTab:AddButton({Name = "Stop Lag (ラグ停止)", Callback = function() stopLineLag() end})
LagTab:AddParagraph("Information", "このスクリプトはラインラグのみを実行します。\n開始ボタンでラグを開始し、停止ボタンで終了します。")

-- ==========================================
-- ==========================================
-- ラグドールタブ（スパムキック機能）
-- ==========================================
-- ==========================================

local currentRagdollTarget = nil
local currentSpamTask = nil
local currentMainTask = nil
local currentBodyPosition = nil
local currentBodyGyro = nil
local savedPosition = nil
local dragging = false
local grabStartTime = 0
local checkStartTime = 0
local isSpamActive = false
local noclipConnection = nil

-- Grab Events
local GrabEvents2 = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local setNetworkOwnerEvent = GrabEvents2 and GrabEvents2:WaitForChild("SetNetworkOwner", 5)
local destroyGrabLineEvent = GrabEvents2 and GrabEvents2:WaitForChild("DestroyGrabLine", 5)

-- Noclip関数
local function SetNoclipRagdoll(enabled)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ネットワークオーナー取得関数
local function SetNetworkOwnerForTarget(targetRoot)
    if not targetRoot then return end
    pcall(function()
        setNetworkOwnerEvent:FireServer(targetRoot, targetRoot.CFrame)
    end)
end

-- DestroyGrabLine関数
local function DoDestroyGrabLine(targetRoot)
    if not targetRoot then return end
    pcall(function()
        destroyGrabLineEvent:FireServer(targetRoot)
    end)
end

-- BodyPosition作成
local function CreateBodiesRagdoll(targetRoot, pos)
    if currentBodyPosition then
        currentBodyPosition:Destroy()
        currentBodyPosition = nil
    end
    if currentBodyGyro then
        currentBodyGyro:Destroy()
        currentBodyGyro = nil
    end
    currentBodyPosition = Instance.new("BodyPosition")
    currentBodyPosition.MaxForce = Vector3.new(1e10, 1e10, 1e10)
    currentBodyPosition.P = 9999999
    currentBodyPosition.D = 99999
    currentBodyPosition.Position = pos
    currentBodyPosition.Parent = targetRoot
    currentBodyGyro = Instance.new("BodyGyro")
    currentBodyGyro.MaxTorque = Vector3.new(1e10, 1e10, 1e10)
    currentBodyGyro.P = 9999999
    currentBodyGyro.D = 99999
    currentBodyGyro.CFrame = CFrame.new(pos)
    currentBodyGyro.Parent = targetRoot
end

local function CleanupBodiesRagdoll()
    if currentBodyPosition then
        currentBodyPosition:Destroy()
        currentBodyPosition = nil
    end
    if currentBodyGyro then
        currentBodyGyro:Destroy()
        currentBodyGyro = nil
    end
end

-- 全停止関数
local function StopAllRagdoll()
    isSpamActive = false
    if currentSpamTask then
        task.cancel(currentSpamTask)
        currentSpamTask = nil
    end
    if currentMainTask then
        task.cancel(currentMainTask)
        currentMainTask = nil
    end
    CleanupBodiesRagdoll()
    SetNoclipRagdoll(false)
    dragging = false
    grabStartTime = 0
    checkStartTime = 0
end

-- プレイヤー選択
local function GetRagdollPlayerList()
    local opts = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(opts, p.DisplayName .. " (" .. p.Name .. ")")
        end
    end
    return opts
end

local function GetRagdollUserName(displayString)
    if not displayString or displayString == "" then return nil end
    local startPos, endPos = string.find(displayString, "%(")
    if startPos then
        local userName = string.sub(displayString, startPos + 1, -2)
        return userName
    end
    return nil
end

RagdollTab:AddSection({Name = "プレイヤー選択"})

-- プレイヤー選択ドロップダウン
local ragdollPlayerDropdown = RagdollTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = GetRagdollPlayerList(),
    Callback = function(selected)
        if selected then
            local userName = GetRagdollUserName(selected)
            if userName then
                currentRagdollTarget = Players:FindFirstChild(userName)
            end
        end
    end
})

local function UpdateRagdollPlayerList()
    -- 既存のドロップダウンを更新するため、新しく設定
    ragdollPlayerDropdown.Options = GetRagdollPlayerList()
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    UpdateRagdollPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.2)
    UpdateRagdollPlayerList()
end)

task.spawn(function()
    task.wait(1)
    UpdateRagdollPlayerList()
end)

RagdollTab:AddButton({
    Name = "プレイヤーリスト更新",
    Callback = function()
        UpdateRagdollPlayerList()
        OrionLib:MakeNotification({Name = "更新完了", Content = "プレイヤーリストを更新しました", Time = 2})
    end
})

-- 超高速版ラグドールトグル
RagdollTab:AddSection({Name = "ラグドール実行"})

RagdollTab:AddToggle({
    Name = "task.wait() ラグドール",
    Default = false,
    Callback = function(Value)
        if Value then
            StopAllRagdoll()
            
            if not currentRagdollTarget then
                OrionLib:MakeNotification({Name = "エラー", Content = "先にプレイヤーを選択してください", Time = 3})
                return
            end
            
            isSpamActive = true
            SetNoclipRagdoll(true)
            
            currentMainTask = task.spawn(function()
                local target = currentRagdollTarget
                if not target then 
                    StopAllRagdoll()
                    return 
                end
                
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then 
                    StopAllRagdoll()
                    return 
                end
                
                savedPosition = myRoot.CFrame
                dragging = false
                grabStartTime = 0
                checkStartTime = 0
                
                local spamKickRunning = false
                
                while isSpamActive do
                    local currentTargetPlayer = Players:FindFirstChild(target.Name)
                    if not currentTargetPlayer then
                        CleanupBodiesRagdoll()
                        spamKickRunning = false
                        task.wait()
                        continue
                    end
                    
                    myChar = LocalPlayer.Character
                    myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local tChar = currentTargetPlayer.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar and tChar:FindFirstChild("Humanoid")
                    
                    if tRoot and tHum and tHum.Health > 0 and myRoot then
                        if not spamKickRunning then
                            spamKickRunning = true
                            currentSpamTask = task.spawn(function()
                                while isSpamActive and tRoot and tRoot.Parent do
                                    DoDestroyGrabLine(tRoot)
                                    task.wait(0.005)
                                    SetNetworkOwnerForTarget(tRoot)
                                    task.wait(0.005)
                                end
                            end)
                        end
                        
                        if not dragging then
                            myRoot.CFrame = tRoot.CFrame
                            CleanupBodiesRagdoll()
                            checkStartTime = 0
                            
                            pcall(function()
                                SetNetworkOwnerForTarget(tRoot)
                                SetNetworkOwnerForTarget(tRoot)
                                DoDestroyGrabLine(tRoot)
                            end)
                            
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            myRoot.AssemblyAngularVelocity = Vector3.zero
                            
                            if grabStartTime == 0 then grabStartTime = tick() end
                            if tick() - grabStartTime > 0.03 then
                                dragging = true
                                grabStartTime = 0
                                checkStartTime = tick()
                                local lockPos = savedPosition * CFrame.new(0, 100, 0)
                                CreateBodiesRagdoll(tRoot, lockPos.Position)
                            end
                        else
                            myRoot.CFrame = savedPosition
                            local lockPos = savedPosition * CFrame.new(0, 100, 0)
                            
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            myRoot.AssemblyAngularVelocity = Vector3.zero
                            
                            if currentBodyPosition and currentBodyPosition.Parent then
                                currentBodyPosition.Position = lockPos.Position
                                if currentBodyGyro then
                                    currentBodyGyro.CFrame = lockPos
                                end
                            else
                                CreateBodiesRagdoll(tRoot, lockPos.Position)
                            end
                            
                            if checkStartTime > 0 and tick() - checkStartTime > 0.30 then
                                local currentDist = (tRoot.Position - lockPos.Position).Magnitude
                                if currentDist > 10 then
                                    dragging = false
                                    grabStartTime = 0
                                    checkStartTime = 0
                                    CleanupBodiesRagdoll()
                                    myRoot.CFrame = tRoot.CFrame
                                else
                                    checkStartTime = tick()
                                end
                            end
                        end
                    else
                        dragging = false
                        grabStartTime = 0
                        checkStartTime = 0
                        CleanupBodiesRagdoll()
                        spamKickRunning = false
                    end
                    
                    task.wait(0.03)
                end
                
                CleanupBodiesRagdoll()
                SetNoclipRagdoll(false)
            end)
        else
            if isSpamActive then
                StopAllRagdoll()
            end
        end
    end
})

-- ==========================================
-- ==========================================
-- プレイヤータブ
-- ==========================================
-- ==========================================

local PlayerSettings = {Walkspeed = false, WalkspeedValue = 1, InfiniteJump = false, InfiniteJumpPower = 100, Connections = {}}

local function WalkspeedFunc()
    if PlayerSettings.Connections.WS then PlayerSettings.Connections.WS:Disconnect() PlayerSettings.Connections.WS = nil end
    if PlayerSettings.Walkspeed then
        PlayerSettings.Connections.WS = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local moveDir = hum.MoveDirection
                    local speed = 16 * PlayerSettings.WalkspeedValue
                    hrp.CFrame = hrp.CFrame + moveDir * (speed / 10)
                end
            end
        end)
    end
end

local function InfiniteJumpFunc()
    if PlayerSettings.Connections.JP then PlayerSettings.Connections.JP:Disconnect() PlayerSettings.Connections.JP = nil end
    if PlayerSettings.InfiniteJump then
        PlayerSettings.Connections.JP = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    task.wait()
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    if hum.UseJumpPower == false then
                        hum.JumpHeight = math.clamp(PlayerSettings.InfiniteJumpPower / 10, 7.2, 50)
                    else
                        hum.JumpPower = PlayerSettings.InfiniteJumpPower
                    end
                end
            end
        end)
    end
end

PlayerTab:AddSection({Name = "Walkspeed"})
PlayerTab:AddToggle({Name = "Walkspeed", Default = false, Callback = function(Value) PlayerSettings.Walkspeed = Value WalkspeedFunc() end})
PlayerTab:AddSlider({Name = "Speed 倍率", Min = 0.1, Max = 5, Default = 1, Increment = 0.1, ValueName = "x", Callback = function(Value) PlayerSettings.WalkspeedValue = Value end})

PlayerTab:AddSection({Name = "Infinite Jump"})
PlayerTab:AddToggle({Name = "Infinite Jump", Default = false, Callback = function(Value) PlayerSettings.InfiniteJump = Value InfiniteJumpFunc() end})
PlayerTab:AddSlider({Name = "Jump Power", Min = 16, Max = 500, Default = 100, Increment = 1, ValueName = "パワー", Callback = function(Value) PlayerSettings.InfiniteJumpPower = Value end})

PlayerTab:AddSection({Name = "Camera"})
PlayerTab:AddSlider({Name = "FOV", Min = 70, Max = 120, Default = 70, Increment = 1, ValueName = "°", Callback = function(Value) Workspace.CurrentCamera.FieldOfView = Value end})

-- ==========================================
-- ==========================================
-- アンチタブ
-- ==========================================
-- ==========================================

AntiTab:AddSection({Name = "アンチ Grab"})

-- Anti Grab
local antiGrabActive = false
local antiGrabConn = nil
local antiGrabTripConns = {}

local function antiGrabRecover(hum, root)
    if not (hum and root) then return end
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
end

local function antiGrabSetup(char)
    for _, c in pairs(antiGrabTripConns) do c:Disconnect() end
    antiGrabTripConns = {}
    local hum = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not (hum and root) then return end
    local states = {Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.PlatformStanding}
    for _, st in ipairs(states) do pcall(function() hum:SetStateEnabled(st, false) end) end
    table.insert(antiGrabTripConns, hum.StateChanged:Connect(function(_, new)
        if not antiGrabActive and (new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.PlatformStanding) then
            antiGrabRecover(hum, root)
        end
    end))
    table.insert(antiGrabTripConns, RunService.RenderStepped:Connect(function()
        if not antiGrabActive then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.PlatformStanding then
                antiGrabRecover(hum, root)
            end
        end
    end))
end

AntiTab:AddToggle({
    Name = "Anti Grab",
    Default = false,
    Callback = function(Value)
        antiGrabActive = Value
        if antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
        for _, c in pairs(antiGrabTripConns) do c:Disconnect() end
        antiGrabTripConns = {}
        if Value then
            if LocalPlayer.Character then antiGrabSetup(LocalPlayer.Character) end
            table.insert(antiGrabTripConns, LocalPlayer.CharacterAdded:Connect(antiGrabSetup))
            antiGrabConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if not hrp or not hum then return end
                local head = char:FindFirstChild("Head")
                local po = head and head:FindFirstChild("PartOwner")
                local ih = LocalPlayer:FindFirstChild("IsHeld")
                local hasControl = hrp:FindFirstChild("ControlBP") or hrp:FindFirstChild("ControlBG") or char:FindFirstChildOfClass("BodyPosition") or char:FindFirstChildOfClass("BodyGyro")
                if (po or (ih and ih.Value == true) or hasControl) then
                    local oldCF = hrp.CFrame
                    local struggleActive = true
                    task.spawn(function()
                        while struggleActive do
                            if (head:FindFirstChild("PartOwner") or (ih and ih.Value) or hrp:FindFirstChild("ControlBP")) then
                                local grabberName = po and po.Value or ""
                                if grabberName == "" and ih and ih:FindFirstChild("Player") then grabberName = ih.Player.Value end
                                local targetPlayer = Players:FindFirstChild(grabberName)
                                local targetChar = targetPlayer and targetPlayer.Character
                                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                    for i = 1, 15 do
                                        local SG = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
                                        if SG then SG:FireServer() end
                                    end
                                end
                            end
                            task.wait()
                        end
                    end)
                    local startTime = tick()
                    local activeConns = {}
                    local function override()
                        for _, obj in pairs(char:GetDescendants()) do
                            if obj:IsA("BodyMover") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") or obj:IsA("BodyThrust") then obj:Destroy()
                            elseif obj:IsA("Constraint") and not (obj:IsA("Weld") or obj:IsA("Motor6D")) then obj:Destroy() end
                        end
                        if hum then
                            hum.PlatformStand = false
                            hum.WalkSpeed = 16
                            hum.JumpPower = 50
                            pcall(function() hum:ChangeState(Enum.HumanoidStateType.None) end)
                        end
                        hrp.CFrame = oldCF
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                part.AssemblyAngularVelocity = Vector3.new(0,0,0)
                            end
                        end
                        local dist = (hrp.Position - oldCF.Position).Magnitude
                        if not (head:FindFirstChild("PartOwner") or (ih and ih.Value == true) or hrp:FindFirstChild("ControlBP")) and (dist < 0.2 or (tick() - startTime > 1.2)) then
                            struggleActive = false
                            for _, c in pairs(activeConns) do c:Disconnect() end
                            antiGrabRecover(hum, hrp)
                        end
                    end
                    table.insert(activeConns, RunService.RenderStepped:Connect(override))
                    table.insert(activeConns, RunService.Heartbeat:Connect(override))
                    table.insert(activeConns, RunService.Stepped:Connect(override))
                end
            end)
        end
    end
})

-- Anti Kick
AntiTab:AddSection({Name = "アンチ Kick"})

_G.ShurikenAntiKick = false
local antiKickThread = nil

local function ClearKunai()
    local plr = LocalPlayer
    local inv = Workspace:FindFirstChild(plr.Name.."SpawnedInToys")
    local destroyrem = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
    if inv and destroyrem then
        for _, v in pairs(inv:GetChildren()) do
            if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                pcall(function() destroyrem:FireServer(v) end)
            end
        end
    end
end

local function StartAntiKick()
    if antiKickThread then task.cancel(antiKickThread) antiKickThread = nil end
    antiKickThread = task.spawn(function()
        local plr = LocalPlayer
        local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
        local stickyEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
        local spawnRemote = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
        local destroyrem = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
        local canSpawn = plr:WaitForChild("CanSpawnToy")
        
        local function getHRP()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                return plr.Character.HumanoidRootPart
            else
                local character = plr.CharacterAdded:Wait()
                return character:WaitForChild("HumanoidRootPart")
            end
        end
        
        local function CheckForHome()
            if not Workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then return false end
            for _, v in pairs(Workspace.Plots:GetChildren()) do
                local sign = v:FindFirstChild("PlotSign")
                local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                if owners then
                    for _, b in pairs(owners:GetChildren()) do
                        if b.Value == plr.Name then
                            local folder = Workspace.PlotItems:FindFirstChild(v.Name)
                            if folder then return true, folder end
                        end
                    end
                end
            end
            return false
        end
        
        local function StickKunai(kunai)
            if not kunai or not kunai:FindFirstChild("StickyPart") then return end
            local currentHRP = getHRP()
            if not currentHRP then return end
            if kunai:FindFirstChild("SoundPart") then
                if not kunai.SoundPart:FindFirstChild("PartOwner") or kunai.SoundPart.PartOwner.Value ~= plr.Name then 
                    setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
                end
            end
            local firePart = currentHRP:FindFirstChild("FirePlayerPart") or currentHRP:WaitForChild("FirePlayerPart", 5)
            if firePart then
                stickyEvent:FireServer(kunai.StickyPart, firePart, CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(90),math.rad(90)))
            end
            for _, obj in pairs(kunai:GetChildren()) do
                if obj.Name == "Pyramid" then
                    obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                    if not obj:FindFirstChild("Highlight") then
                        local high = Instance.new("Highlight", obj)
                        high.FillColor = Color3.fromRGB(0, 0, 0)
                    end
                elseif obj.Name == "Main" then
                    obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                    if not obj:FindFirstChild("Highlight") then
                        local high = Instance.new("Highlight", obj)
                        high.FillColor = Color3.fromRGB(255, 255, 255)
                    end
                elseif obj:IsA("BasePart") then
                    obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 1
                end
            end
        end
        
        local function SpawnToy(name)
            local t = tick()
            while not canSpawn.Value do
                if not _G.ShurikenAntiKick or tick() - t > 5 then return nil end
                task.wait(0.1)
            end
            local currentHRP = getHRP()
            if currentHRP then
                task.spawn(function()
                    pcall(function()
                        spawnRemote:InvokeServer(name, currentHRP.CFrame * CFrame.new(0, 12, 20), Vector3.new(0,0,0))
                    end)
                end)
            end
            local boolik, house = CheckForHome()
            local inv = Workspace:FindFirstChild(plr.Name.."SpawnedInToys")
            if boolik and house then 
                return house:WaitForChild(name, 2)
            elseif not Workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) and inv then 
                return inv:WaitForChild(name, 2)
            end
            return nil
        end
        
        while _G.ShurikenAntiKick do 
            task.wait(0.005)
            if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then continue end
            local inv = Workspace:FindFirstChild(plr.Name.."SpawnedInToys")
            local kunai = (inv and (inv:FindFirstChild("AntiKick") or inv:FindFirstChild("NinjaShuriken")))
            if Workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then 
                local boolik, house = CheckForHome()
                if boolik and house and Workspace.Plots:FindFirstChild(house.Name) then
                    local sign = Workspace.Plots[house.Name]:FindFirstChild("PlotSign")
                    if sign and sign.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then 
                        if not kunai then
                            kunai = SpawnToy("NinjaShuriken")
                            if kunai == nil then continue end
                            kunai.Name = "AntiKick" 
                            StickKunai(kunai)
                        end
                    end
                end
            end
            if not kunai then
                if Workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then continue end 
                kunai = SpawnToy("NinjaShuriken")
                if kunai == nil then continue end 
                kunai.Name = "AntiKick"
                StickKunai(kunai)
            end
            repeat
                if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch == true then
                    StickKunai(kunai)
                    kunai.Name = "AntiKick"
                end
                task.wait(0.3)
            until not kunai or not _G.ShurikenAntiKick or not kunai:FindFirstChild("StickyPart") or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 or not kunai.StickyPart:FindFirstChild("StickyWeld") or not kunai.StickyPart.StickyWeld.Part1
            if not kunai or not kunai:FindFirstChild("StickyPart") or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 or not kunai.StickyPart:FindFirstChild("StickyWeld") or not kunai.StickyPart.StickyWeld.Part1 then ClearKunai() end
            pcall(function()
                if kunai and kunai:FindFirstChild("StickyPart") then
                    if (plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0) or not kunai["StickyPart"]:FindFirstChild("StickyWeld") or not kunai["StickyPart"].StickyWeld.Part1 then ClearKunai() end
                end
            end)
        end
        ClearKunai()
    end)
end

AntiTab:AddToggle({
    Name = "Anti Kick",
    Default = false,
    Callback = function(Value)
        _G.ShurikenAntiKick = Value
        if Value then StartAntiKick() else if antiKickThread then task.cancel(antiKickThread) antiKickThread = nil end ClearKunai() end
    end
})

-- Anti Ragdoll
AntiTab:AddSection({Name = "アンチ Ragdoll"})

local antiRagdollEnabled = false
local antiRagdollConns = {}

local function clearRagdollConns()
    for _, conn in ipairs(antiRagdollConns) do conn:Disconnect() end
    antiRagdollConns = {}
end

local function protectRagdollHumanoid(humanoid)
    humanoid.BreakJointsOnDeath = false
    humanoid.AutoRotate = true
    humanoid.PlatformStand = false
    table.insert(antiRagdollConns, humanoid.HealthChanged:Connect(function(health)
        if antiRagdollEnabled and health <= 0 then humanoid.Health = 1 end
    end))
    table.insert(antiRagdollConns, humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
        if antiRagdollEnabled and humanoid.AutoRotate == false then humanoid.AutoRotate = true end
    end))
    table.insert(antiRagdollConns, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if antiRagdollEnabled and humanoid.PlatformStand == true then humanoid.PlatformStand = false end
    end))
end

local function onRagdollCharacter(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid and antiRagdollEnabled then protectRagdollHumanoid(humanoid) end
end

LocalPlayer.CharacterAdded:Connect(onRagdollCharacter)
if LocalPlayer.Character then onRagdollCharacter(LocalPlayer.Character) end

AntiTab:AddToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(Value)
        antiRagdollEnabled = Value
        if Value then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then protectRagdollHumanoid(humanoid) end
        else
            clearRagdollConns()
        end
    end
})

-- Anti Blobman Kill
AntiTab:AddSection({Name = "アンチ Blobman Kill"})

local antiBlobmanActive = false
local antiBlobmanTask = nil

local function AntiBlobmanKillLoop()
    while antiBlobmanActive do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                hum.Sit = true
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
                local camera = Workspace.CurrentCamera
                if camera then
                    local lookVec = camera.CFrame.LookVector
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z))
                end
            end
        end
        task.wait()
    end
end

AntiTab:AddToggle({
    Name = "Anti Blobman Kill",
    Default = false,
    Callback = function(Value)
        antiBlobmanActive = Value
        if antiBlobmanTask then task.cancel(antiBlobmanTask) antiBlobmanTask = nil end
        if Value then antiBlobmanTask = task.spawn(AntiBlobmanKillLoop)
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                hum.Sit = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
        end
    end
})

-- Anti Lag
AntiTab:AddSection({Name = "アンチ Lag"})

AntiTab:AddToggle({
    Name = "Anti Lag",
    Default = false,
    Callback = function(Value)
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        local target = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
        if target then target.Disabled = Value end
    end
})

-- Anti Explosion
AntiTab:AddSection({Name = "アンチ Explosion"})

local antiExplosionEnabled = false
local antiExplosionConn = nil

local function setupAntiExplosion(character)
    if not antiExplosionEnabled then return end
    local hum = character:WaitForChild("Humanoid", 5)
    local partOwner = hum and hum:FindFirstChild("Ragdolled")
    if partOwner then
        if antiExplosionConn then antiExplosionConn:Disconnect() end
        antiExplosionConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if not antiExplosionEnabled then return end
            if partOwner.Value then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = true end
                end
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end)
    end
end

AntiTab:AddToggle({
    Name = "Anti Explosion",
    Default = false,
    Callback = function(Value)
        antiExplosionEnabled = Value
        if Value then
            if LocalPlayer.Character then setupAntiExplosion(LocalPlayer.Character) end
            local respawnConn = LocalPlayer.CharacterAdded:Connect(setupAntiExplosion)
            task.spawn(function()
                repeat task.wait() until not antiExplosionEnabled
                respawnConn:Disconnect()
                if antiExplosionConn then antiExplosionConn:Disconnect() end
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.Anchored = false end
                    end
                end
            end)
        else
            if antiExplosionConn then antiExplosionConn:Disconnect() end
        end
    end
})

-- Anti Fire
AntiTab:AddSection({Name = "アンチ Fire"})

local antiFireEnabled = false
local ExtinguishPart = Workspace:WaitForChild("Map"):WaitForChild("Hole"):WaitForChild("PoisonBigHole"):WaitForChild("ExtinguishPart")
local OriginalFirePos = ExtinguishPart.CFrame

local function ExecuteAntiFire()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    local isBurning = RootPart:FindFirstChild("FireLight") or RootPart:FindFirstChild("FireParticleEmitter")
    if isBurning and antiFireEnabled then
        ExtinguishPart.CFrame = RootPart.CFrame
    else
        if ExtinguishPart.CFrame ~= OriginalFirePos then ExtinguishPart.CFrame = OriginalFirePos end
    end
end

RunService.Heartbeat:Connect(function()
    if antiFireEnabled then ExecuteAntiFire() end
end)

AntiTab:AddToggle({
    Name = "Anti Fire",
    Default = false,
    Callback = function(Value)
        antiFireEnabled = Value
        if not Value then ExtinguishPart.CFrame = OriginalFirePos end
    end
})

-- ==========================================
-- ==========================================
-- キックタブ（全機能 - スパムキック削除）
-- ==========================================
-- ==========================================

local selectedKickPlayer = nil
local kickLoopEnabled = false
local kickLoopThread = nil

local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")") end
    end
    return list
end

local function getPlayerFromSelection(selection)
    if not selection then return nil end
    local username = selection:match("%((.-)%)")
    if username then return Players:FindFirstChild(username) end
    return nil
end

local function DebugLog(msg) print("[KickHub] " .. msg) end

local function getBlobmanSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if not seat or not seat.Parent or seat.Parent.Name ~= "CreatureBlobman" then return nil end
    return seat
end

KickTab:AddSection({Name = "プレイヤー選択"})
local kickPlayerDropdown = KickTab:AddDropdown({
    Name = "プレイヤー選択",
    Default = "",
    Options = getPlayerList(),
    Callback = function(Value)
        selectedKickPlayer = getPlayerFromSelection(Value)
        if selectedKickPlayer then DebugLog("ターゲット選択: " .. selectedKickPlayer.Name) end
    end
})
KickTab:AddButton({Name = "プレイヤーリスト更新", Callback = function() OrionLib:MakeNotification({Name = "更新完了", Content = "ドロップダウンを開き直してください", Time = 2}) end})

-- ==========================================
-- 1. 高速キック
-- ==========================================
KickTab:AddSection({Name = "高速キック"})
local kick67Enabled = false
local kick67Thread = nil

KickTab:AddToggle({
    Name = "高速キック (ON/OFF)",
    Default = false,
    Callback = function(on)
        if kick67Thread then task.cancel(kick67Thread) kick67Thread = nil end
        kick67Enabled = on
        if on and not selectedKickPlayer then OrionLib:MakeNotification({Name = "エラー", Content = "先にプレイヤーを選択してください", Time = 3}) kick67Enabled = false return end
        local seat = getBlobmanSeat()
        if on and not seat then OrionLib:MakeNotification({Name = "エラー", Content = "ブロブマンに座ってください", Time = 3}) kick67Enabled = false return end
        if not on then return end
        local target = selectedKickPlayer
        kick67Thread = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local seat2 = getBlobmanSeat()
            if not seat2 then kick67Enabled = false return end
            local blob = seat2.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local L_Det = blob:FindFirstChild("LeftDetector")
            local L_Weld = L_Det and (L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot.CFrame
            local rightHandPos = SavedPos * CFrame.new(5, 18, -3)
            local leftHandPos = SavedPos * CFrame.new(-5, 18, -3)
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot and blobRoot then
                local bringStart = tick()
                while tick() - bringStart < 0.35 do
                    if not kick67Enabled then break end
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    pcall(function()
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                task.wait(0.05)
            end
            local teleportIndex = 0
            local packetTimer = 0
            while kick67Enabled do
                if not target or not target.Parent or not target.Character then break end
                if not blobRoot or not blobRoot.Parent then break end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                    teleportIndex = (teleportIndex + 1) % 2
                    local targetPos, currentDet, currentWeld
                    if teleportIndex == 0 then targetPos = rightHandPos currentDet = R_Det currentWeld = R_Weld
                    else targetPos = leftHandPos currentDet = L_Det currentWeld = L_Weld end
                    tRoot.CFrame = targetPos
                    tRoot.Velocity = Vector3.zero
                    tRoot.RotVelocity = Vector3.zero
                    if tick() - packetTimer > 0.01 then
                        packetTimer = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, targetPos)
                            if R_Det then local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld") if weld then CD:FireServer(weld) end end
                            if L_Det then local weld = L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld") if weld then CD:FireServer(weld) end end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if CG and currentDet then CG:FireServer(currentDet, tRoot, currentWeld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            for i = 1, 3 do
                                if CG and currentDet then CG:FireServer(currentDet, tRoot, currentWeld) end
                                task.wait(0.002)
                            end
                        end)
                    end
                else
                    if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
                    break
                end
                RunService.Heartbeat:Wait()
            end
            if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
            DebugLog("高速キック終了")
        end)
    end
})

-- ==========================================
-- 2. 上下キック
-- ==========================================
KickTab:AddSection({Name = "上下キック"})
local updownEnabled = false
local updownThread = nil

KickTab:AddToggle({
    Name = "上下キック (ON/OFF)",
    Default = false,
    Callback = function(on)
        if updownThread then task.cancel(updownThread) updownThread = nil end
        updownEnabled = on
        if on and not selectedKickPlayer then OrionLib:MakeNotification({Name = "エラー", Content = "先にプレイヤーを選択してください", Time = 3}) updownEnabled = false return end
        local seat = getBlobmanSeat()
        if on and not seat then OrionLib:MakeNotification({Name = "エラー", Content = "ブロブマンに座ってください", Time = 3}) updownEnabled = false return end
        if not on then return end
        local target = selectedKickPlayer
        updownThread = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local seat2 = getBlobmanSeat()
            if not seat2 then updownEnabled = false return end
            local blob = seat2.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot.CFrame
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot and blobRoot then
                local bringStart = tick()
                while tick() - bringStart < 0.15 do
                    if not updownEnabled then break end
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    pcall(function()
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                task.wait(0.05)
            end
            local packetTimer = 0
            local cycleTime = 0.05
            while updownEnabled do
                if not target or not target.Parent or not target.Character then break end
                if not blobRoot or not blobRoot.Parent then break end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                    local phase = math.floor(tick() / cycleTime) % 2
                    local offsetY = (phase == 0) and 12 or -5
                    local lockPos = SavedPos * CFrame.new(0, offsetY, -5)
                    tRoot.CFrame = lockPos
                    tRoot.Velocity = Vector3.zero
                    tRoot.RotVelocity = Vector3.zero
                    if tick() - packetTimer > 0.05 then
                        packetTimer = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                            if R_Det then local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld") if weld then CD:FireServer(weld) end end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
                end
                RunService.Heartbeat:Wait()
            end
            if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
            DebugLog("上下キック終了")
        end)
    end
})

-- ==========================================
-- 3. スピンキック
-- ==========================================
KickTab:AddSection({Name = "スピンキック"})
local spinAngle = 0
local spinSpeed = 15

KickTab:AddSlider({Name = "回転速度", Min = 1, Max = 50, Default = 15, Increment = 1, ValueName = "速度", Callback = function(Value) spinSpeed = Value end})

local spinKickEnabled = false
local spinKickThread = nil

KickTab:AddToggle({
    Name = "スピンキック (ON/OFF)",
    Default = false,
    Callback = function(on)
        if spinKickThread then task.cancel(spinKickThread) spinKickThread = nil end
        spinKickEnabled = on
        if on and not selectedKickPlayer then OrionLib:MakeNotification({Name = "エラー", Content = "先にプレイヤーを選択してください", Time = 3}) spinKickEnabled = false return end
        local seat = getBlobmanSeat()
        if on and not seat then OrionLib:MakeNotification({Name = "エラー", Content = "ブロブマンに座ってください", Time = 3}) spinKickEnabled = false return end
        if not on then spinAngle = 0 return end
        local target = selectedKickPlayer
        spinKickThread = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local seat2 = getBlobmanSeat()
            if not seat2 then spinKickEnabled = false return end
            local blob = seat2.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot.CFrame
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot and blobRoot then
                local bringStart = tick()
                while tick() - bringStart < 0.35 do
                    if not spinKickEnabled then break end
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    pcall(function()
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                task.wait(0.05)
            end
            local packetTimer = 0
            while spinKickEnabled do
                if not target or not target.Parent or not target.Character then break end
                if not blobRoot or not blobRoot.Parent then break end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    spinAngle = spinAngle + (math.rad(spinSpeed) * 2)
                    if spinAngle > math.pi * 2 then spinAngle = spinAngle - math.pi * 2 end
                    blobRoot.CFrame = CFrame.new(SavedPos.Position) * CFrame.Angles(0, spinAngle, 0)
                    blobRoot.Velocity = Vector3.zero
                    local distance = 8
                    local targetPos = SavedPos.Position + Vector3.new(math.sin(spinAngle) * distance, 0, math.cos(spinAngle) * distance)
                    tRoot.CFrame = CFrame.new(targetPos)
                    tRoot.Velocity = Vector3.zero
                    tRoot.RotVelocity = Vector3.zero
                    if tick() - packetTimer > 0.05 then
                        packetTimer = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, tRoot.CFrame)
                            if R_Det then local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld") if weld then CD:FireServer(weld) end end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
                end
                RunService.Heartbeat:Wait()
            end
            spinAngle = 0
            if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
            DebugLog("スピンキック終了")
        end)
    end
})

-- ==========================================
-- 4. ドリフトキック
-- ==========================================
KickTab:AddSection({Name = "ドリフトキック"})
local orbitRadius = 15
local orbitSpeed2 = 2
local orbitAngle = 0

KickTab:AddSlider({Name = "周回半径", Min = 5, Max = 30, Default = 15, Increment = 1, ValueName = "m", Callback = function(Value) orbitRadius = Value end})
KickTab:AddSlider({Name = "周回速度", Min = 1, Max = 10, Default = 2, Increment = 1, ValueName = "速度", Callback = function(Value) orbitSpeed2 = Value end})

local driftKickEnabled = false
local driftKickThread = nil

KickTab:AddToggle({
    Name = "ドリフトキック (ON/OFF)",
    Default = false,
    Callback = function(on)
        if driftKickThread then task.cancel(driftKickThread) driftKickThread = nil end
        driftKickEnabled = on
        if on and not selectedKickPlayer then OrionLib:MakeNotification({Name = "エラー", Content = "先にプレイヤーを選択してください", Time = 3}) driftKickEnabled = false return end
        local seat = getBlobmanSeat()
        if on and not seat then OrionLib:MakeNotification({Name = "エラー", Content = "ブロブマンに座ってください", Time = 3}) driftKickEnabled = false return end
        if not on then orbitAngle = 0 return end
        local target = selectedKickPlayer
        driftKickThread = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local seat2 = getBlobmanSeat()
            if not seat2 then driftKickEnabled = false return end
            local blob = seat2.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot.CFrame
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot and blobRoot then
                local bringStart = tick()
                while tick() - bringStart < 0.35 do
                    if not driftKickEnabled then break end
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    pcall(function()
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                task.wait(0.05)
            end
            local packetTimer = 0
            while driftKickEnabled do
                if not target or not target.Parent or not target.Character then break end
                if not blobRoot or not blobRoot.Parent then break end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    local lockPos = SavedPos * CFrame.new(0, 23, 0)
                    tRoot.CFrame = lockPos
                    tRoot.Velocity = Vector3.zero
                    tRoot.RotVelocity = Vector3.zero
                    local dt = RunService.Heartbeat:Wait()
                    orbitAngle = orbitAngle + (dt * orbitSpeed2)
                    local orbitX = math.cos(orbitAngle) * orbitRadius
                    local orbitZ = math.sin(orbitAngle) * orbitRadius
                    local orbitCFrame = lockPos * CFrame.new(orbitX, 0, orbitZ)
                    local lookAtCFrame = CFrame.lookAt(orbitCFrame.Position, lockPos.Position)
                    blobRoot.CFrame = lookAtCFrame
                    blobRoot.Velocity = Vector3.zero
                    if tick() - packetTimer > 0.05 then
                        packetTimer = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                            if R_Det then local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld") if weld then CD:FireServer(weld) end end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
                end
                RunService.Heartbeat:Wait()
            end
            orbitAngle = 0
            if blobRoot and blobRoot.Parent then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
            DebugLog("ドリフトキック終了")
        end)
    end
})

-- ==========================================
-- 5. ブロブキック（右手→左手→上）【新規追加】
-- ==========================================
KickTab:AddSection({Name = "ブロブキック (右手→左手→上)"})

local selectedKickPlayer2 = nil
local kickLoopEnabled2 = false

local function getKickPlayerList2()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")")
        end
    end
    return list
end

local function getKickPlayerFromSelection2(selection)
    if not selection then return nil end
    local username = selection:match("%((.-)%)")
    if username then
        return Players:FindFirstChild(username)
    end
    return nil
end

-- 手の位置を取得する関数
local function getHandPosition(blob, hand)
    local pos = nil
    if hand == "right" then
        local rHand = blob:FindFirstChild("RightHand")
        if rHand then
            pos = rHand.Position
        end
    elseif hand == "left" then
        local lHand = blob:FindFirstChild("LeftHand")
        if lHand then
            pos = lHand.Position
        end
    end
    return pos
end

-- プレイヤー選択
local kickPlayerDropdown2 = KickTab:AddDropdown({
    Name = "プレイヤー選択",
    Default = "",
    Options = getKickPlayerList2(),
    Callback = function(Value)
        selectedKickPlayer2 = getKickPlayerFromSelection2(Value)
    end
})

KickTab:AddButton({
    Name = "プレイヤーリスト更新",
    Callback = function()
        local newList = getKickPlayerList2()
        kickPlayerDropdown2.Options = newList
        OrionLib:MakeNotification({Name = "更新完了", Content = "ドロップダウンを開き直してください", Time = 2})
    end
})

KickTab:AddToggle({
    Name = "ブロブキック (右手→左手→上)",
    Default = false,
    Callback = function(on)
        if kickLoopThread2 then task.cancel(kickLoopThread2) kickLoopThread2 = nil end
        kickLoopEnabled2 = on

        if on and not selectedKickPlayer2 then
            OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
            kickLoopEnabled2 = false
            return
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local seat = hum and hum.SeatPart

        if on and (not seat or seat.Parent.Name ~= "CreatureBlobman") then
            OrionLib:MakeNotification({Name = "エラー", Content = "ブロブマンに座っている必要があります", Time = 3})
            kickLoopEnabled2 = false
            return
        end

        if not on then
            kickLoopEnabled2 = false
            return
        end

        local target = selectedKickPlayer2
        local kickLoopThread2 = nil

        kickLoopThread2 = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local blob = seat.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))

            -- 初期位置を保存
            local SavedPos = blobRoot.CFrame

            -- ターゲットに近づいて掴む
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

            if tRoot and blobRoot then
                local bringStart = tick()
                while tick() - bringStart < 0.35 do
                    if not kickLoopEnabled2 then break end
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    pcall(function()
                        if CG and R_Det then
                            CG:FireServer(R_Det, tRoot, R_Weld)
                        end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                task.wait(0.05)
            end

            -- キックループ: 右手→左手→上の順でターゲットを移動
            local movePatterns = {"right", "left", "up"}
            local patternIndex = 1
            local moveTimer = 0
            local moveInterval = 0.08

            while kickLoopEnabled2 do
                if not target or not target.Parent or not target.Character then
                    break
                end
                if not blobRoot or not blobRoot.Parent then
                    break
                end

                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")

                if tRoot and tHum and tHum.Health > 0 then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero

                    local targetPos = nil
                    local currentPattern = movePatterns[patternIndex]

                    if currentPattern == "right" then
                        local handPos = getHandPosition(blob, "right")
                        if handPos then
                            targetPos = CFrame.new(handPos + Vector3.new(0, 2, 0))
                        end
                    elseif currentPattern == "left" then
                        local handPos = getHandPosition(blob, "left")
                        if handPos then
                            targetPos = CFrame.new(handPos + Vector3.new(0, 2, 0))
                        end
                    elseif currentPattern == "up" then
                        targetPos = CFrame.new(
                            SavedPos.X + math.random(-2, 2),
                            50 + math.random(0, 20),
                            SavedPos.Z + math.random(-2, 2)
                        )
                    end

                    if targetPos then
                        tRoot.CFrame = targetPos
                        tRoot.Velocity = Vector3.zero
                        tRoot.RotVelocity = Vector3.zero

                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, targetPos)
                            if R_Det then
                                local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                                if weld then
                                    CD:FireServer(weld)
                                end
                            end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if CG and R_Det then
                                CG:FireServer(R_Det, tRoot, R_Weld)
                            end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end

                    moveTimer = moveTimer + 0.05
                    if moveTimer >= moveInterval then
                        moveTimer = 0
                        patternIndex = patternIndex % 3 + 1
                    end
                else
                    if blobRoot and blobRoot.Parent then
                        blobRoot.CFrame = SavedPos
                        blobRoot.Velocity = Vector3.zero
                    end
                end

                RunService.Heartbeat:Wait()
            end

            kickLoopEnabled2 = false
            if blobRoot and blobRoot.Parent then
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
            end
        end)
    end
})

-- ==========================================
-- 緊急停止（キックタブ）
-- ==========================================
KickTab:AddSection({Name = "緊急停止"})
KickTab:AddButton({
    Name = "全機能緊急停止",
    Callback = function()
        kick67Enabled = false
        updownEnabled = false
        spinKickEnabled = false
        driftKickEnabled = false
        kickLoopEnabled2 = false
        if kick67Thread then task.cancel(kick67Thread) kick67Thread = nil end
        if updownThread then task.cancel(updownThread) updownThread = nil end
        if spinKickThread then task.cancel(spinKickThread) spinKickThread = nil end
        if driftKickThread then task.cancel(driftKickThread) driftKickThread = nil end
        if kickLoopThread2 then task.cancel(kickLoopThread2) kickLoopThread2 = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.Health = 0 end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = false part.Velocity = Vector3.zero end
            end
        end
        OrionLib:MakeNotification({Name = "緊急停止", Content = "全機能を停止しました", Time = 3})
        DebugLog("緊急停止実行")
    end
})

-- ==========================================
-- ==========================================
-- キック2タブ（ブロブキックv1 / v2）
-- ==========================================
-- ==========================================

local selectedKick2Player = nil
local kick2V1Enabled = false
local kick2V2Enabled = false
local whitelistFriends = false

local function getKick2PlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")") end
    end
    return list
end

local function getKick2PlayerFromSelection(selection)
    if not selection then return nil end
    local username = selection:match("%((.-)%)")
    if username then return Players:FindFirstChild(username) end
    return nil
end

Kick2Tab:AddSection({Name = "プレイヤー選択"})
local kick2PlayerDropdown = Kick2Tab:AddDropdown({
    Name = "人選択",
    Default = "",
    Options = getKick2PlayerList(),
    Callback = function(Value)
        selectedKick2Player = getKick2PlayerFromSelection(Value)
    end
})
Kick2Tab:AddButton({Name = "プレイヤーリスト更新", Callback = function() OrionLib:MakeNotification({Name = "更新完了", Content = "ドロップダウンを開き直してください", Time = 2}) end})
Kick2Tab:AddToggle({Name = "ホワイトリスト（フレンド除外）", Default = false, Callback = function(Value) whitelistFriends = Value end})

-- ブロブキックv1
Kick2Tab:AddSection({Name = "ブロブキックv1"})
local kick2V1Thread = nil

Kick2Tab:AddToggle({
    Name = "ブロブキックv1 (ON/OFF)",
    Default = false,
    Callback = function(on)
        if kick2V1Thread then task.cancel(kick2V1Thread) kick2V1Thread = nil end
        kick2V1Enabled = on
        if on and not selectedKick2Player then OrionLib:MakeNotification({Name = "エラー", Content = "ターゲットを選択してください", Time = 3}) kick2V1Enabled = false return end
        if on and selectedKick2Player and whitelistFriends then
            local isFriend = false
            pcall(function() isFriend = LocalPlayer:IsFriendsWith(selectedKick2Player.UserId) end)
            if isFriend then OrionLib:MakeNotification({Name = "エラー", Content = "フレンドは除外されています", Time = 3}) kick2V1Enabled = false return end
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local seat = hum and hum.SeatPart
        if on and (not seat or seat.Parent.Name ~= "CreatureBlobman") then OrionLib:MakeNotification({Name = "エラー", Content = "Blobmanに乗ってください", Time = 3}) kick2V1Enabled = false return end
        if not on then return end
        local target = selectedKick2Player
        kick2V1Thread = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local blob = seat.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot.CFrame
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot and blobRoot then
                local bringStart = tick()
                while tick() - bringStart < 0.35 and kick2V1Enabled do
                    blobRoot.CFrame = tRoot.CFrame
                    pcall(function()
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
            end
            while kick2V1Enabled do
                if not target or not target.Parent or not target.Character then break end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    blobRoot.CFrame = SavedPos
                    local lockPos = SavedPos * CFrame.new(0, 23, 0)
                    tRoot.CFrame = lockPos
                    pcall(function()
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                        if R_Det then CD:FireServer(R_Det:FindFirstChildWhichIsA("Weld")) end
                        GE.DestroyGrabLine:FireServer(tRoot)
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    end)
                end
                RunService.Heartbeat:Wait()
            end
            blobRoot.CFrame = SavedPos
        end)
    end
})

-- ブロブキックv2
Kick2Tab:AddSection({Name = "ブロブキックv2"})
local kick2V2Thread = nil

Kick2Tab:AddToggle({
    Name = "ブロブキックv2 (ON/OFF)",
    Default = false,
    Callback = function(on)
        if kick2V2Thread then task.cancel(kick2V2Thread) kick2V2Thread = nil end
        kick2V2Enabled = on
        if on and not selectedKick2Player then OrionLib:MakeNotification({Name = "エラー", Content = "ターゲットを選択してください", Time = 3}) kick2V2Enabled = false return end
        if on and selectedKick2Player and whitelistFriends then
            local isFriend = false
            pcall(function() isFriend = LocalPlayer:IsFriendsWith(selectedKick2Player.UserId) end)
            if isFriend then OrionLib:MakeNotification({Name = "エラー", Content = "フレンドは除外されています", Time = 3}) kick2V2Enabled = false return end
        end
        if not on then return end
        local targetName = selectedKick2Player.Name
        local GE = ReplicatedStorage:WaitForChild("GrabEvents")
        local REMOTE_DELAY = 0.002
        local lastRemote = 0
        kick2V2Thread = task.spawn(function()
            local target = Players:FindFirstChild(targetName)
            if not target then return end
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local seat = hum.SeatPart
            if not seat or seat.Parent.Name ~= "CreatureBlobman" then
                OrionLib:MakeNotification({Name = "ブロブキックv2", Content = "CreatureBlobmanに乗ってからONにしてください", Time = 5})
                kick2V2Enabled = false
                return
            end
            local blob = seat.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:WaitForChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj:WaitForChild("CreatureGrab")
            local CD = scriptObj:WaitForChild("CreatureDrop")
            local R_Det = blob:WaitForChild("RightDetector")
            local savedPos = blobRoot.CFrame
            local dragging = false
            local grabStartTime = 0
            while kick2V2Enabled do
                local currentTarget = Players:FindFirstChild(targetName)
                if not currentTarget then break end
                char = LocalPlayer.Character
                hum = char and char:FindFirstChild("Humanoid")
                seat = hum and hum.SeatPart
                if not seat or seat.Parent.Name ~= "CreatureBlobman" then
                    OrionLib:MakeNotification({Name = "ブロブキックv2", Content = "Blobから降りました。停止します。", Time = 4})
                    break
                end
                blob = seat.Parent
                blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
                local tChar = currentTarget.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 and blobRoot then
                    tRoot.Velocity = Vector3.zero
                    if not dragging then
                        blobRoot.CFrame = tRoot.CFrame
                        blobRoot.Velocity = Vector3.zero
                        if tick() - lastRemote >= REMOTE_DELAY then
                            lastRemote = tick()
                            pcall(function()
                                tHum.PlatformStand = true
                                tHum.Sit = true
                                GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                                GE.DestroyGrabLine:FireServer(tRoot)
                            end)
                        end
                        if grabStartTime == 0 then grabStartTime = tick() end
                        if tick() - grabStartTime > 0.35 then
                            dragging = true
                            grabStartTime = 0
                            blobRoot.CFrame = savedPos
                            blobRoot.Velocity = Vector3.zero
                        end
                    else
                        blobRoot.CFrame = savedPos
                        blobRoot.Velocity = Vector3.zero
                        local lockPos = savedPos * CFrame.new(0, 23, 0)
                        tRoot.CFrame = lockPos
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        if tick() - lastRemote >= REMOTE_DELAY then
                            lastRemote = tick()
                            pcall(function()
                                GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                                GE.DestroyGrabLine:FireServer(tRoot)
                                local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                                if weld then
                                    CD:FireServer(weld)
                                    CG:FireServer(R_Det, tRoot, weld)
                                end
                            end)
                        end
                    end
                else
                    dragging, grabStartTime = false, 0
                end
                RunService.Heartbeat:Wait()
            end
            if blobRoot then blobRoot.CFrame = savedPos blobRoot.Velocity = Vector3.zero end
        end)
    end
})

-- ==========================================
-- ==========================================
-- キルタブ
-- ==========================================
-- ==========================================

local selectedKillPlayer = nil
local isSelectedKill = false
local selectedKillThread = nil

local TP_WAIT = 0.02
local GRAB_WAIT = 0.01
local RETRY_WAIT = 0.01
local MAX_RETRIES = 5
local MAX_BLOBMAN_DISTANCE = 500
local currentBlobman = nil

local function getKillPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")") end
    end
    return list
end

local function getKillPlayerFromSelection(selection)
    if not selection then return nil end
    local username = selection:match("%((.-)%)")
    if username then return Players:FindFirstChild(username) end
    return nil
end

local function GetSeatedBlobman()
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seat = humanoid.SeatPart
    if not seat or not seat:IsA("VehicleSeat") then return nil end
    local obj = seat
    while obj do
        if obj:IsA("Model") and obj.Name == "CreatureBlobman" then return obj end
        obj = obj.Parent
    end
    return nil
end

local function SpawnBlobmanForKill()
    local seatedBlobman = GetSeatedBlobman()
    if seatedBlobman then currentBlobman = seatedBlobman return seatedBlobman end
    if currentBlobman and currentBlobman.Parent then
        local blobmanPos = nil
        if currentBlobman.PrimaryPart then blobmanPos = currentBlobman.PrimaryPart.Position
        else
            local part = currentBlobman:FindFirstChildWhichIsA("BasePart")
            if part then blobmanPos = part.Position end
        end
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local localPos = rootPart and rootPart.Position
        if blobmanPos and localPos and (blobmanPos - localPos).Magnitude < MAX_BLOBMAN_DISTANCE then
            local seat = currentBlobman:FindFirstChild("VehicleSeat")
            if seat then
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then seat:Sit(humanoid) task.wait(0.08) end
            end
            return currentBlobman
        else
            pcall(function() currentBlobman:Destroy() end)
            currentBlobman = nil
        end
    end
    local character = LocalPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
    local success, err = pcall(function()
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
    end)
    if not success then warn("SpawnBlobman remote failed: " .. err) return nil end
    local toyFolderName = LocalPlayer.Name .. "SpawnedInToys"
    local blobman = nil
    local startTime = tick()
    repeat
        local toyFolder = Workspace:FindFirstChild(toyFolderName)
        if toyFolder then blobman = toyFolder:FindFirstChild("CreatureBlobman") end
        if blobman then break end
        task.wait()
    until tick() - startTime > 2
    if not blobman then return nil end
    currentBlobman = blobman
    local seat = blobman:FindFirstChild("VehicleSeat")
    if seat then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then seat:Sit(humanoid) end
    end
    task.wait(0.08)
    return blobman
end

local function KillPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    for _ = 1, MAX_RETRIES do
        local success, err = pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
        if success and humanoid.Health <= 0 then return true end
        task.wait(RETRY_WAIT)
    end
    return false
end

local function GrabRelease(blobman, targetRoot)
    if not blobman or not targetRoot then return end
    pcall(function()
        local script = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script then
            script.CreatureGrab:FireServer(blobman.LeftDetector, targetRoot, blobman.LeftDetector.LeftWeld)
            script.CreatureRelease:FireServer(blobman.LeftDetector.LeftWeld)
        end
    end)
end

local function ProcessPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local blobman = SpawnBlobmanForKill()
    if not blobman then return false end
    local localChar = LocalPlayer.Character
    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
        localChar.HumanoidRootPart.CFrame = targetRoot.CFrame
        task.wait(TP_WAIT)
    end
    KillPlayer(targetPlayer)
    for _ = 1, 3 do
        GrabRelease(blobman, targetRoot)
        task.wait(GRAB_WAIT)
    end
    return true
end

local function StartSelectedKillLoop()
    while isSelectedKill do
        if selectedKillPlayer then
            local success, err = pcall(ProcessPlayer, selectedKillPlayer)
            if not success then warn("選択プレイヤーキルエラー: " .. tostring(err)) end
        end
        task.wait(0.05)
    end
    selectedKillThread = nil
end

KillTab:AddSection({Name = "選択プレイヤーキル"})
local killPlayerDropdown = KillTab:AddDropdown({
    Name = "プレイヤー選択",
    Default = "",
    Options = getKillPlayerList(),
    Callback = function(Value)
        selectedKillPlayer = getKillPlayerFromSelection(Value)
    end
})
KillTab:AddButton({Name = "プレイヤーリスト更新", Callback = function() OrionLib:MakeNotification({Name = "更新完了", Content = "ドロップダウンを開き直してください", Time = 2}) end})

KillTab:AddToggle({
    Name = "選択プレイヤー永続キル",
    Default = false,
    Callback = function(Value)
        isSelectedKill = Value
        if Value then
            if not selectedKillPlayer then OrionLib:MakeNotification({Name = "エラー", Content = "先にプレイヤーを選択してください", Time = 3}) isSelectedKill = false return end
            if selectedKillThread then isSelectedKill = false task.wait(0.1) isSelectedKill = true end
            selectedKillThread = task.spawn(StartSelectedKillLoop)
            OrionLib:MakeNotification({Name = "永続キル開始", Content = selectedKillPlayer.DisplayName .. " をキルし続けます", Time = 3})
        else
            if selectedKillThread then task.cancel(selectedKillThread) selectedKillThread = nil end
            OrionLib:MakeNotification({Name = "永続キル停止", Content = "キルを停止しました", Time = 2})
        end
    end
})

-- キルオーラ
KillTab:AddSection({Name = "キルオーラ"})

local bmkAuraEnabled = false
local auraConn = nil
local auraInRange = {}
local AURA_RADIUS = 35
local playerThreads = {}

local cachedCG, cachedCD, cachedCR = nil, nil, nil
local cachedR_Det, cachedR_Weld = nil, nil
local cachedL_Det, cachedL_Weld = nil, nil
local cachedBlobman = nil

local function HRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function refreshBlobman()
    local found = nil
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local seat = v.VehicleSeat
            local weld = seat and seat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(LocalPlayer.Character) then
                found = v; break
            end
        end
    end
    cachedBlobman = found
    if not found then
        cachedCG, cachedCD, cachedCR = nil, nil, nil
        cachedR_Det, cachedR_Weld, cachedL_Det, cachedL_Weld = nil, nil, nil, nil
        return
    end
    local s1 = found:FindFirstChild("BlobmanSeatAndOwnerScript")
    local s2 = found:FindFirstChild("BlobmanSeatAndOwnerScript[old]")
    cachedCG = (s1 and s1:FindFirstChild("CreatureGrab")) or (s2 and s2:FindFirstChild("CreatureGrab")) or found:FindFirstChild("CreatureGrab", true)
    cachedCD = (s1 and s1:FindFirstChild("CreatureDrop")) or (s2 and s2:FindFirstChild("CreatureDrop")) or found:FindFirstChild("CreatureDrop", true)
    cachedCR = (s1 and s1:FindFirstChild("CreatureRelease")) or (s2 and s2:FindFirstChild("CreatureRelease")) or found:FindFirstChild("CreatureRelease", true)
    cachedR_Det = found:FindFirstChild("RightDetector")
    cachedR_Weld = cachedR_Det and (cachedR_Det:FindFirstChild("RightWeld") or cachedR_Det:FindFirstChildWhichIsA("Weld"))
    cachedL_Det = found:FindFirstChild("LeftDetector")
    cachedL_Weld = cachedL_Det and (cachedL_Det:FindFirstChild("LeftWeld") or cachedL_Det:FindFirstChildWhichIsA("Weld"))
end

pcall(refreshBlobman)
Workspace.DescendantAdded:Connect(function(d)
    if d.Name == "CreatureBlobman" or d.Name == "SeatWeld" then task.defer(refreshBlobman) end
end)
Workspace.DescendantRemoving:Connect(function(d)
    if d == cachedBlobman or d.Name == "SeatWeld" then task.defer(refreshBlobman) end
end)

local function stopThreads(userId)
    local st = playerThreads[userId]
    if st then st.active = false; playerThreads[userId] = nil end
end

local function startThreads(player, userId)
    stopThreads(userId)
    local state = { active = true }
    playerThreads[userId] = state
    local grabConn = RunService.Heartbeat:Connect(function()
        if not state.active then grabConn:Disconnect() return end
        if not cachedCG then return end
        local char = player.Character
        if not char then return end
        local pHRP = char:FindFirstChild("HumanoidRootPart")
        if not pHRP then return end
        pcall(function()
            if cachedR_Det then
                cachedCG:FireServer(cachedR_Det, pHRP, cachedR_Weld)
                cachedR_Weld = cachedR_Det:FindFirstChild("RightWeld") or cachedR_Det:FindFirstChildWhichIsA("Weld")
                if cachedCR and cachedR_Weld then cachedCR:FireServer(cachedR_Weld) end
                if cachedCD and cachedR_Weld then cachedCD:FireServer(cachedR_Weld) end
            end
            if cachedL_Det then
                cachedCG:FireServer(cachedL_Det, pHRP, cachedL_Weld)
                cachedL_Weld = cachedL_Det:FindFirstChild("LeftWeld") or cachedL_Det:FindFirstChildWhichIsA("Weld")
                if cachedCR and cachedL_Weld then cachedCR:FireServer(cachedL_Weld) end
                if cachedCD and cachedL_Weld then cachedCD:FireServer(cachedL_Weld) end
            end
        end)
    end)
    local killConn = RunService.Heartbeat:Connect(function()
        if not state.active then killConn:Disconnect() return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        pcall(function()
            hum.Health = 0
            hum:ChangeState(Enum.HumanoidStateType.Dead)
        end)
    end)
end

local function autoSitOnBlobman()
    local blobman = nil
    local spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
    if not blobman then
        local mt = ReplicatedStorage:FindFirstChild("MenuToys")
        local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction")
        if st then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local spawnCF = myRoot and (myRoot.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 50, 0)
            st:InvokeServer("CreatureBlobman", spawnCF, Vector3.zero)
            task.wait(0.5)
            spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
        end
    end
    if blobman then
        local seat = blobman:FindFirstChild("VehicleSeat")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if seat and hum then
            if seat.Occupant ~= hum then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.1)
                end
                seat:Sit(hum)
                task.wait(0.3)
            end
        end
    end
end

local function stopAura()
    bmkAuraEnabled = false
    if auraConn then auraConn:Disconnect() auraConn = nil end
    for uid in pairs(auraInRange) do stopThreads(uid) end
    auraInRange = {}
end

local function startAura()
    if auraConn then auraConn:Disconnect() auraConn = nil end
    auraInRange = {}
    task.spawn(autoSitOnBlobman)
    auraConn = RunService.Heartbeat:Connect(function()
        if not bmkAuraEnabled then stopAura() return end
        local myHRP = HRP()
        if not myHRP then return end
        local myPos = myHRP.Position
        local nowInRange = {}
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and not hum.Sit then task.spawn(autoSitOnBlobman) end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            local pHRP = char and char:FindFirstChild("HumanoidRootPart")
            if pHRP then
                if (myPos - pHRP.Position).Magnitude > AURA_RADIUS then
                    if auraInRange[p.UserId] then stopThreads(p.UserId) end
                    continue
                end
            elseif not auraInRange[p.UserId] then continue end
            nowInRange[p.UserId] = true
            if not auraInRange[p.UserId] then startThreads(p, p.UserId) end
        end
        for uid in pairs(auraInRange) do
            if not nowInRange[uid] then stopThreads(uid) end
        end
        auraInRange = nowInRange
    end)
end

KillTab:AddToggle({
    Name = "キルオーラ (ON/OFF)",
    Default = false,
    Callback = function(Value)
        bmkAuraEnabled = Value
        if Value then
            startAura()
            OrionLib:MakeNotification({Name = "キルオーラ", Content = "ON（自動乗車付き）", Time = 2})
        else
            stopAura()
            OrionLib:MakeNotification({Name = "キルオーラ", Content = "OFF", Time = 2})
        end
    end
})

KillTab:AddSlider({Name = "オーラ範囲", Min = 10, Max = 100, Default = 35, Increment = 1, ValueName = "スタッド", Callback = function(Value) AURA_RADIUS = Value end})

KillTab:AddSection({Name = "緊急停止"})
KillTab:AddButton({
    Name = "キル機能緊急停止",
    Callback = function()
        isSelectedKill = false
        if selectedKillThread then task.cancel(selectedKillThread) selectedKillThread = nil end
        bmkAuraEnabled = false
        stopAura()
        for uid in pairs(playerThreads) do stopThreads(uid) end
        playerThreads = {}
        auraInRange = {}
        OrionLib:MakeNotification({Name = "緊急停止", Content = "全キル機能を停止しました", Time = 3})
    end
})

-- ==========================================
-- ==========================================
-- バリア破壊タブ
-- ==========================================
-- ==========================================

BarrierTab:AddSection({Name = "バリア破壊"})

BarrierTab:AddButton({
    Name = "バリア破壊",
    Callback = function()
        local plotItems = Workspace:FindFirstChild("PlotItems")
        if plotItems then
            local playersInPlots = plotItems:FindFirstChild("PlayersInPlots")
            if playersInPlots and playersInPlots:FindFirstChild(LocalPlayer.Name) then
                OrionLib:MakeNotification({Name = "エラー", Content = "家の外で実行してください", Time = 3})
                return
            end
        end
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "エラー", Content = "キャラクターが見つかりません", Time = 3})
            return
        end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            OrionLib:MakeNotification({Name = "エラー", Content = "Humanoidが見つかりません", Time = 3})
            return
        end
        if not ReplicatedStorage:FindFirstChild("MenuToys") then
            OrionLib:MakeNotification({Name = "エラー", Content = "MenuToysが見つかりません", Time = 3})
            return
        end
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local originalPos = hrp.CFrame
            local originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 0
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina", 
                CFrame.new(184.148834, -5.54824972, 498.136749), Vector3.new(0, 34, 0))
            task.wait(0.4)
            local toyFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            local ocarina = toyFolder and toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
            if ocarina and ocarina:FindFirstChild("HoldPart") then
                ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, Workspace[LocalPlayer.Name])
                hrp.CFrame = CFrame.new(304.06, 25.77, 488.54)
                task.wait(0.21)
                ReplicatedStorage.MenuToys.DestroyToy:FireServer(ocarina)
                hrp.CFrame = originalPos
                task.wait(0.7)
                ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire", 
                    CFrame.new(257.638672, -5.57392979, 450.103638), Vector3.new(0, 161.972))
                humanoid.WalkSpeed = originalWalkSpeed
                OrionLib:MakeNotification({Name = "成功", Content = "バリア破壊を実行しました", Time = 3})
            end
        end)
    end
})
BarrierTab:AddParagraph("使い方", "・家の外で実行してください\n・1回だけ実行されます")

-- ==========================================
-- 初期化
-- ==========================================
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "起動完了！",
    Content = "戦闘用v2.5が正常にロードされました\nbyなべうどん・なべHub",
    Time = 7
})
