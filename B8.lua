-- // GrabKick
-- 製作 なべうどん・なべHub
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local PlayerGui = LP:WaitForChild("PlayerGui", 10)

if PlayerGui:FindFirstChild("GrabKickHubGUI") then PlayerGui.GrabKickHubGUI:Destroy() end

-- ===== Grabkick機能の変数 =====
local GrabEvents = RS:WaitForChild("GrabEvents")
local SpawnToyRemote = RS:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local DestroyGrabLine = GrabEvents:FindFirstChild("DestroyGrabLine")
local CreateGrabLine = GrabEvents:FindFirstChild("CreateGrabLine")

local kickEnabled = false
local selectedPlayerName = nil
local selectedPlayerDisplay = ""
local kickDistance = 25
local isSpawningPallet = false
local running = false
local ragdollPallet = nil
local ragdollConnection = nil

local function HRP()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function getPlayerFromDisplay(display)
    for _, p in ipairs(Players:GetPlayers()) do
        local full = p.DisplayName .. " (@" .. p.Name .. ")"
        if full == display then return p end
    end
    return nil
end

-- ===== テレポート機能 =====
local function teleportToTarget(target, myHRP)
    if not target.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local savedCFrame = myHRP.CFrame
    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)

    for i = 1, 15 do
        SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
        task.wait()
    end

    myHRP.CFrame = savedCFrame
end

-- ===== おもちゃスポーン =====
local function findChild(parent, name, timeout)
    return parent:FindFirstChild(name) or parent:WaitForChild(name, timeout or 5)
end

local function setOwner(part)
    if part and part:IsA("BasePart") then
        SetNetworkOwner:FireServer(part, part.CFrame)
        task.wait()
    end
end

local function hasPartOwner(part, name)
    return part:FindFirstChild(name) ~= nil
end

local function spawnToy(toyName)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    local waitCount = 0
    while (LP.InPlot.Value and not LP.InOwnedPlot.Value) and waitCount < 50 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end
    waitCount = 0
    while not LP.CanSpawnToy.Value and waitCount < 50 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end

    local spawnPos = root.CFrame * CFrame.new(0, 14, 20)
    
    local folder = workspace:FindFirstChild(LP.Name.."SpawnedInToys")
    if not folder then
        folder = workspace:FindFirstChild("PlotItems")
        if folder then
            folder = folder:FindFirstChild("Plot1")
        end
    end
    if not folder then
        folder = workspace
    end

    local spawned = nil
    local conn = folder.ChildAdded:Connect(function(child)
        if child.Name == toyName then
            spawned = child
        end
    end)

    task.spawn(function()
        pcall(function()
            SpawnToyRemote:InvokeServer(toyName, spawnPos, Vector3.zero)
        end)
    end)

    local startTime = tick()
    repeat task.wait(0.05) until spawned or (tick() - startTime) > 5
    conn:Disconnect()
    return spawned
end

-- ===== ラグドールパレット作成 =====
local function createRagdollPallet()
    if isSpawningPallet then return nil end
    isSpawningPallet = true

    local pallet = spawnToy("PalletLightBrown")
    if not pallet then
        isSpawningPallet = false
        return nil
    end

    local soundPart = findChild(pallet, "SoundPart", 3)
    if not soundPart then
        pallet:Destroy()
        isSpawningPallet = false
        return nil
    end

    local retryCount = 0
    while retryCount < 10 do
        if not kickEnabled then
            pallet:Destroy()
            isSpawningPallet = false
            return nil
        end
        setOwner(soundPart)
        task.wait()
        if hasPartOwner(soundPart, "PartOwner") then
            break
        end
        retryCount = retryCount + 1
    end

    if not hasPartOwner(soundPart, "PartOwner") then
        pallet:Destroy()
        isSpawningPallet = false
        return nil
    end

    for _, part in pairs(pallet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 0.8
        end
    end
    pallet.Name = "RagdollPalete"

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Velocity = Vector3.new(0, 900, 0)
    bodyVelocity.Parent = soundPart

    isSpawningPallet = false
    return pallet
end

-- ===== ラグスパム =====
local function startLagSpam()
    if running then return end
    if not CreateGrabLine then return end
    running = true

    task.spawn(function()
        while running do
            local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChild("Spawn")
                or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))

            if spawnLocation then
                CreateGrabLine:FireServer(spawnLocation, CFrame.new(
                    math.random(-2010000000, 2000000001),
                    0,
                    math.random(-2008100000, 2000200000)
                ))
            end
            task.wait()
        end
    end)
end

local function stopLagSpam()
    if not running then return end
    running = false
end

-- ===== キックメインループ =====
local function startKick()
    task.spawn(function()
        while kickEnabled do
            local target = getPlayerFromDisplay(selectedPlayerDisplay)
            local myChar = LP.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if target and myHRP then
                local targetChar = target.Character
                local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

                if targetHRP then
                    local distance = (myHRP.Position - targetHRP.Position).Magnitude
                    if distance > kickDistance then
                        teleportToTarget(target, myHRP)
                    end

                    SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
                    if DestroyGrabLine then
                        DestroyGrabLine:FireServer(targetHRP)
                    end

                    targetHRP.AssemblyLinearVelocity = Vector3.zero
                    targetHRP.AssemblyAngularVelocity = Vector3.zero

                    local controlBP = targetHRP:FindFirstChild("ControlBP")
                    if not controlBP then
                        controlBP = Instance.new("BodyPosition")
                        controlBP.Name = "ControlBP"
                        controlBP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        controlBP.P = 800000
                        controlBP.Parent = targetHRP
                    end
                    controlBP.Position = myHRP.Position + Vector3.new(5, 10, 5)
                end
            end
            task.wait()
        end

        -- クリーンアップ
        local target = getPlayerFromDisplay(selectedPlayerDisplay)
        if target and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and targetHRP:FindFirstChild("ControlBP") then
                targetHRP.ControlBP:Destroy()
            end
        end
    end)
end

-- ===== ラグドール監視 =====
local function startRagdollMonitor()
    local folder = workspace:FindFirstChild(LP.Name.."SpawnedInToys")
    local pallet = nil

    ragdollConnection = RunService.RenderStepped:Connect(function()
        if not kickEnabled then return end
        if not selectedPlayerName then return end

        local target = Players:FindFirstChild(selectedPlayerName)
        if not target or not target.Character then return end

        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = target.Character:FindFirstChild("Humanoid")
        if not targetHRP or not targetHum then return end

        if pallet and pallet:IsDescendantOf(workspace) then
            local soundPart = pallet:FindFirstChild("SoundPart")
            if soundPart then
                if not hasPartOwner(soundPart, "PartOwner") then
                    pallet:Destroy()
                    pallet = nil
                end
            else
                pallet:Destroy()
                pallet = nil
            end
        end

        if not isSpawningPallet and (not pallet or not pallet:IsDescendantOf(workspace)) then
            pallet = folder and folder:FindFirstChild("RagdollPalete") or createRagdollPallet()
        end

        if pallet and pallet:FindFirstChild("SoundPart") then
            local ragdolled = targetHum:FindFirstChild("Ragdolled")
            if ragdolled and not ragdolled.Value then
                pallet.SoundPart.Position = targetHRP.Position
            end
        end
    end)
end

-- ===== GUI作成 =====
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "GrabKickHubGUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 300)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, -35, 0, 28)
TitleBar.Text = "GrabKick HUB v1.0"
TitleBar.TextColor3 = Color3.fromRGB(100, 255, 150)
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 12
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 0)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 2
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

local contentElements = {}

-- ===== トグル作成関数 =====
local function makeToggle(name, y, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = "[ ] " .. name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(100, 255, 150)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    table.insert(contentElements, btn)
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = (on and "[X] " or "[ ] ") .. name
        btn.BackgroundColor3 = on and Color3.fromRGB(30, 50, 30) or Color3.fromRGB(25, 25, 25)
        if callback then callback(on) end
    end)
    return btn
end

-- ===== スライダー作成関数 =====
local function makeSlider(name, min, max, def, y, callback, isFloat)
    local label = Instance.new("TextLabel", MainFrame)
    label.Size = UDim2.new(0.9, 0, 0, 14)
    label.Position = UDim2.new(0.05, 0, 0, y)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. def
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Code
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(contentElements, label)

    local bar = Instance.new("Frame", MainFrame)
    bar.Size = UDim2.new(0.9, 0, 0, 5)
    bar.Position = UDim2.new(0.05, 0, 0, y + 16)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    table.insert(contentElements, bar)

    local pct = (def - min) / (max - min)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local btn = Instance.new("TextButton", bar)
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.Position = UDim2.new(pct, -7, -0.5, -4)
    btn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local val = def
    local hold = false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hold = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hold = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hold and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            btn.Position = UDim2.new(p, -7, -0.5, -4)
            fill.Size = UDim2.new(p, 0, 1, 0)
            val = min + p * (max - min)
            if isFloat then
                val = math.floor(val * 100) / 100
            else
                val = math.floor(val)
            end
            label.Text = name .. ": " .. val
            if callback then callback(val) end
        end
    end)
end

-- ===== UI構築 =====

-- プレイヤー選択ドロップダウン
local playerDropdown = Instance.new("TextButton", MainFrame)
playerDropdown.Size = UDim2.new(0.9, 0, 0, 28)
playerDropdown.Position = UDim2.new(0.05, 0, 0, 36)
playerDropdown.Text = "対象プレイヤーを選択"
playerDropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playerDropdown.TextColor3 = Color3.fromRGB(100, 255, 150)
playerDropdown.Font = Enum.Font.Code
playerDropdown.TextSize = 11
playerDropdown.TextXAlignment = Enum.TextXAlignment.Left
playerDropdown.BorderSizePixel = 0
Instance.new("UICorner", playerDropdown).CornerRadius = UDim.new(0, 4)
table.insert(contentElements, playerDropdown)

local playerList = Instance.new("ScrollingFrame", MainFrame)
playerList.Size = UDim2.new(0.9, 0, 0, 0)
playerList.Position = UDim2.new(0.05, 0, 0, 36)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Visible = false
playerList.ZIndex = 10
table.insert(contentElements, playerList)

local function refreshPlayerList()
    for _, c in pairs(playerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    local plist = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(plist, p) end
    end
    
    for i, p in pairs(plist) do
        local b = Instance.new("TextButton", playerList)
        b.Size = UDim2.new(1, 0, 0, 24)
        b.Position = UDim2.new(0, 0, 0, (i-1)*24)
        b.Text = p.DisplayName .. " (@" .. p.Name .. ")"
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.TextColor3 = Color3.fromRGB(200, 200, 200)
        b.Font = Enum.Font.Code
        b.TextSize = 10
        b.BorderSizePixel = 0
        b.ZIndex = 10
        b.MouseButton1Click:Connect(function()
            selectedPlayerDisplay = b.Text
            selectedPlayerName = p.Name
            playerDropdown.Text = b.Text
            playerList.Visible = false
        end)
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, #plist * 24)
    playerList.Size = UDim2.new(0.9, 0, 0, math.min(100, #plist * 24))
end

playerDropdown.MouseButton1Click:Connect(function()
    refreshPlayerList()
    playerList.Visible = not playerList.Visible
end)

-- 距離スライダー
makeSlider("キック距離", 5, 50, 25, 72, function(v) kickDistance = v end)

-- キックトグル
makeToggle("Grab Kick", 108, function(v)
    kickEnabled = v
    
    if v then
        if selectedPlayerName then
            startLagSpam()
            startKick()
            startRagdollMonitor()
        else
            kickEnabled = false
        end
    else
        stopLagSpam()
        if ragdollConnection then
            ragdollConnection:Disconnect()
            ragdollConnection = nil
        end
    end
end)

-- 最小化
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 280, 0, 28)
        MinimizeBtn.Text = "+"
        for _, el in pairs(contentElements) do
            el.Visible = false
        end
    else
        MainFrame.Size = UDim2.new(0, 280, 0, 300)
        MinimizeBtn.Text = "_"
        for _, el in pairs(contentElements) do
            el.Visible = true
        end
    end
end)

-- ドラッグ
local function makeDraggable(gui, handle)
    local dragging, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ds = i.Position
            sp = gui.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            gui.Position = UDim2.new(
                0,
                math.clamp(sp.X.Offset + d.X, 0, Camera.ViewportSize.X - gui.AbsoluteSize.X),
                0,
                math.clamp(sp.Y.Offset + d.Y, 0, Camera.ViewportSize.Y - gui.AbsoluteSize.Y)
            )
        end
    end)
end
makeDraggable(MainFrame, TitleBar)

-- プレイヤーリスト自動更新
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if playerList.Visible then
        refreshPlayerList()
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr and selectedPlayerName == plr.Name then
        selectedPlayerName = nil
        selectedPlayerDisplay = ""
        playerDropdown.Text = "対象プレイヤーを選択"
    end
end)

print("GrabKick")
