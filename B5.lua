-- こっちみんな
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() -- Rayfieldの読み込み

local Window = Rayfield:CreateWindow({
    Name = "破壊",
    LoadingTitle = "破壊スクリプト起動中…",
    LoadingSubtitle = "作成者:なべうどん・なべHub",
    Theme = "Red",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "GrabDetector",
        FileName = "PlayerHubConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

local BreakTab = Window:CreateTab("破壊機能", 16570630989) -- タイトルとアイコンID

-- =======================================================
-- 共通のリモートイベント・関数取得
-- =======================================================
local SetNetworkOwner = nil
local SpawnToyRemote = nil
local DestroyToyRemote = nil

for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
    if v:IsA("RemoteEvent") then
        if v.Name == "SetNetworkOwner" then
            SetNetworkOwner = v
        elseif v.Name == "DestroyToy" then
            DestroyToyRemote = v
        end
    elseif v:IsA("RemoteFunction") and v.Name == "SpawnToyRemoteFunction" then
        SpawnToyRemote = v
    end
end

local stickyEvent = game:GetService("ReplicatedStorage"):WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")


-- =======================================================
-- [1] プロット破壊セクション（いただいた元のコードを完全維持）
-- =======================================================
do
    BreakTab:CreateSection("プロット破壊")

    local SelectedPlotsToBreak = {}
    local PlotBreakEnabled = false
    -- プロット破壊専用の手裏剣管理テーブル
    local plotSpawnedShurikens = {}

    -- ドロップダウンの作成
    BreakTab:CreateDropdown({
        Name = "プロットを選択",
        Options = {"プロット1", "プロット2", "プロット3", "プロット4", "プロット5"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "PlotsDropdown",
        Callback = function(Options) 
            SelectedPlotsToBreak = {}
            for _, plot in pairs(Options) do
                local originalName = plot:gsub("プロット", "Plot")
                table.insert(SelectedPlotsToBreak, originalName)
            end
        end,
    })

    -- プロット破壊が生成した手裏剣のみを削除するクリーンアップ関数
    local function cleanupPlotShurikens()
        if DestroyToyRemote then
            for _, shuriken in pairs(plotSpawnedShurikens) do
                if shuriken and shuriken.Parent then
                    pcall(function()
                        DestroyToyRemote:FireServer(shuriken)
                    end)
                end
            end
        end
        plotSpawnedShurikens = {}
    end

    -- トグルの作成
    BreakTab:CreateToggle({
        Name = "プロット破壊を実行",
        CurrentValue = false,
        Flag = "PlotBreakToggle",
        Callback = function(Value)
            PlotBreakEnabled = Value

            if PlotBreakEnabled then
                task.spawn(function()
                    local plr = game.Players.LocalPlayer or game:GetService("Players").LocalPlayer
                    if not plr then return end
                    
                    local canSpawn = plr:WaitForChild("CanSpawnToy")
                    
                    while PlotBreakEnabled do
                        local validPlots = {}
                        for _, plotName in pairs(SelectedPlotsToBreak) do
                            local targetPlot = workspace.Plots:FindFirstChild(plotName)
                            local plotArea = targetPlot and targetPlot:FindFirstChild("PlotArea")
                            if plotArea then
                                table.insert(validPlots, { Name = plotName, Area = plotArea })
                            end
                        end

                        local requiredCount = #validPlots
                        if requiredCount == 0 then
                            task.wait(1)
                            continue
                        end

                        local function getHRP()
                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                return plr.Character.HumanoidRootPart
                            else
                                local character = plr.CharacterAdded:Wait()
                                return character:WaitForChild("HumanoidRootPart")
                            end
                        end

                        local function CheckForHome()
                            if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then 
                                return false
                            end
                            for _, v in pairs(workspace.Plots:GetChildren()) do
                                local sign = v:FindFirstChild("PlotSign")
                                local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                                if owners then
                                    for _, b in pairs(owners:GetChildren()) do
                                        if b.Value == plr.Name then
                                            local folder = workspace.PlotItems:FindFirstChild(v.Name)
                                            if folder then return true, folder end
                                        end
                                    end
                                end
                            end
                            return false
                        end

                        local boolik, house = CheckForHome()
                        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
                        local targetContainer = (boolik and house) or inv

                        -- 自分が過去に生成して生存している手裏剣だけを残す
                        local activeOwnShurikens = {}
                        for _, s in pairs(plotSpawnedShurikens) do
                            if s and s.Parent then
                                table.insert(activeOwnShurikens, s)
                            end
                        end
                        plotSpawnedShurikens = activeOwnShurikens

                        -- 【1個ずつスポーン ＆ 即時オーナー取得 ＆ 即時個別アタッチ】
                        local currentOwnCount = #plotSpawnedShurikens
                        if currentOwnCount < requiredCount then
                            local neededSpawns = requiredCount - currentOwnCount
                            for i = 1, neededSpawns do
                                if not PlotBreakEnabled then break end

                                -- 生成直前のコンテナ状態を記憶
                                local preExisting = {}
                                if targetContainer then
                                    for _, child in pairs(targetContainer:GetChildren()) do
                                        if child.Name == "NinjaShuriken" then
                                            table.insert(preExisting, child)
                                        end
                                    end
                                end

                                local t = tick()
                                while not canSpawn.Value do
                                    if not PlotBreakEnabled then break end
                                    if tick() - t > 3 then break end
                                    task.wait(0.01)
                                end

                                if not PlotBreakEnabled then break end

                                local currentHRP = getHRP()
                                if currentHRP and SpawnToyRemote then
                                    task.spawn(function()
                                        pcall(function()
                                            SpawnToyRemote:InvokeServer("NinjaShuriken", currentHRP.CFrame * CFrame.new(0, 2, 8), Vector3.new(0,0,0))
                                        end)
                                    end)
                                end

                                -- スポーンした手裏剣をコンテナから検知
                                local newShuriken = nil
                                if targetContainer then
                                    local searchStart = tick()
                                    while tick() - searchStart < 2 do
                                        for _, child in pairs(targetContainer:GetChildren()) do
                                            if child.Name == "NinjaShuriken" 
                                               and not table.find(preExisting, child) 
                                               and not table.find(plotSpawnedShurikens, child) then
                                                newShuriken = child
                                                break
                                            end
                                        end
                                        if newShuriken then 
                                            -- 検知した瞬間にネットワークオーナーを取得
                                            if SetNetworkOwner then
                                                local soundPart = newShuriken:FindFirstChild("SoundPart") or newShuriken:WaitForChild("SoundPart", 0.1)
                                                if soundPart then
                                                    task.spawn(function()
                                                        pcall(function()
                                                            SetNetworkOwner:FireServer(soundPart, soundPart.CFrame)
                                                        end)
                                                    end)
                                                end
                                            end
                                            break 
                                        end
                                        task.wait()
                                    end
                                end

                                if newShuriken then
                                    table.insert(plotSpawnedShurikens, newShuriken)
                                    
                                    -- 【この手裏剣を、対応するPlotへ即座にアタッチ】
                                    local targetPlotData = validPlots[#plotSpawnedShurikens]
                                    if targetPlotData and newShuriken:FindFirstChild("StickyPart") then
                                        pcall(function()
                                            stickyEvent:FireServer(
                                                newShuriken.StickyPart,
                                                targetPlotData.Area,
                                                CFrame.new(9.99999996e+11, 9.99999996e+11, 9.99999996e+11, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                                            )
                                        end)
                                    end
                                end

                                -- 次の手裏剣の処理に入る前にわずかな間隔を空ける
                                task.wait(0.02)
                            end
                        end

                        if not PlotBreakEnabled then
                            cleanupPlotShurikens()
                            break
                        end

                        local waitTime = 0.5
                        local elapsed = 0
                        while elapsed < waitTime do
                            if not PlotBreakEnabled then
                                cleanupPlotShurikens()
                                break
                            end
                            task.wait(0.05)
                            elapsed = elapsed + 0.05
                        end
                    end
                end)
            else
                cleanupPlotShurikens()
            end
        end
    })
end

-- =======================================================
-- [2] 地面・パーツ破壊セクション（追加機能）
-- =======================================================
do
    BreakTab:CreateSection("地面・パーツ破壊")

    local AutoGroundBreakEnabled = false
    -- 地面破壊専用の手裏剣管理テーブル
    local groundSpawnedShurikens = {}

    local function cleanupGroundShurikens()
        if DestroyToyRemote then
            for _, shuriken in pairs(groundSpawnedShurikens) do
                if shuriken and shuriken.Parent then
                    pcall(function() DestroyToyRemote:FireServer(shuriken) end)
                end
            end
        end
        groundSpawnedShurikens = {}
    end

    -- 地面・パーツ破壊用の単発手裏剣スポーン関数
    local function spawnAndBreakPart(targetPart)
        if not targetPart or targetPart:IsA("Terrain") then return end
        
        task.spawn(function()
            local plr = game.Players.LocalPlayer
            local canSpawn = plr:WaitForChild("CanSpawnToy")
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local function CheckForHome()
                if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then return false end
                for _, v in pairs(workspace.Plots:GetChildren()) do
                    local sign = v:FindFirstChild("PlotSign")
                    local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                    if owners then
                        for _, b in pairs(owners:GetChildren()) do
                            if b.Value == plr.Name then
                                local folder = workspace.PlotItems:FindFirstChild(v.Name)
                                if folder then return true, folder end
                            end
                        end
                    end
                end
                return false
            end

            local boolik, house = CheckForHome()
            local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
            local targetContainer = (boolik and house) or inv

            local preExisting = {}
            if targetContainer then
                for _, child in pairs(targetContainer:GetChildren()) do
                    if child.Name == "NinjaShuriken" then
                        table.insert(preExisting, child)
                    end
                end
            end

            if canSpawn.Value and SpawnToyRemote then
                pcall(function()
                    SpawnToyRemote:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 2, 8), Vector3.new(0,0,0))
                end)

                local newShuriken = nil
                if targetContainer then
                    local searchStart = tick()
                    while tick() - searchStart < 2 do
                        for _, child in pairs(targetContainer:GetChildren()) do
                            if child.Name == "NinjaShuriken" and not table.find(preExisting, child) then
                                newShuriken = child
                                break
                            end
                        end
                        if newShuriken then 
                            if SetNetworkOwner then
                                local soundPart = newShuriken:FindFirstChild("SoundPart") or newShuriken:WaitForChild("SoundPart", 0.1)
                                if soundPart then
                                    pcall(function() SetNetworkOwner:FireServer(soundPart, soundPart.CFrame) end)
                                end
                            end
                            break 
                        end
                        task.wait()
                    end
                end

                if newShuriken and newShuriken:FindFirstChild("StickyPart") then
                    table.insert(groundSpawnedShurikens, newShuriken)
                    pcall(function()
                        stickyEvent:FireServer(
                            newShuriken.StickyPart,
                            targetPart,
                            CFrame.new(9.99999996e+11, 9.99999996e+11, 9.99999996e+11, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                        )
                    end)
                end
            end
        end)
    end

    -- [追加] 足元の地面判定を消すトグル
    BreakTab:CreateToggle({
        Name = "足元の地面判定を消す (自動)",
        CurrentValue = false,
        Flag = "AutoGroundBreak",
        Callback = function(Value)
            AutoGroundBreakEnabled = Value

            if AutoGroundBreakEnabled then
                task.spawn(function()
                    local plr = game.Players.LocalPlayer
                    while AutoGroundBreakEnabled do
                        local character = plr.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        
                        if hrp then
                            local rayOrigin = hrp.Position
                            local rayDirection = Vector3.new(0, -10, 0)
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {character}
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude

                            local rayResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                            local targetPart = rayResult and rayResult.Instance

                            if targetPart and targetPart:IsA("BasePart") and not targetPart:IsA("Terrain") then
                                spawnAndBreakPart(targetPart)
                            end
                        end
                        task.wait(0.5) -- 次の足元判定までの間隔（少し待つことでスパムを防ぐ）
                    end
                end)
            else
                cleanupGroundShurikens()
            end
        end
    })

    -- クリックしたパーツ/地面を消す（トリプルクリック版）
local clickConnection = nil
local clickCount = 0
local lastClickTime = 0
local CLICK_INTERVAL = 1.5 -- この時間内に3回クリックで発動（秒）

BreakTab:CreateToggle({
    Name = "クリックしたパーツ/地面を消す (3回クリック)",
    CurrentValue = false,
    Flag = "ClickDeleteGround",
    Callback = function(Value)
        local plr = game.Players.LocalPlayer
        local mouse = plr:GetMouse()

        if Value then
            clickConnection = mouse.Button1Down:Connect(function()
                local currentTime = tick()
                
                -- 前回のクリックから時間が経っていたらリセット
                if currentTime - lastClickTime > CLICK_INTERVAL then
                    clickCount = 0
                end
                
                -- クリック回数を増やす
                clickCount += 1
                lastClickTime = currentTime
                
                -- 3回クリックしたら発動
                if clickCount >= 10 then
                    clickCount = 0 -- リセット
                    
                    local targetPart = mouse.Target
                    if targetPart and targetPart:IsA("BasePart") and not targetPart:IsA("Terrain") then
                        spawnAndBreakPart(targetPart)
                    end
                end
            end)
        else
            if clickConnection then
                clickConnection:Disconnect()
                clickConnection = nil
            end
            cleanupGroundShurikens()
        end
    end
})
end
