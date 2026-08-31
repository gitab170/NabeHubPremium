-- ==========================================
-- バリア破壊スクリプト v3.1
-- 作者 なべうどん・なべHub
-- ==========================================

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion'))()

local Window = OrionLib:MakeWindow({
    Name = "バリア破壊",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false,
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

local Tab = Window:MakeTab({
    Name = "バリア破壊",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local executing = false

-- ==========================================
-- キャンプファイヤー削除関数
-- ==========================================

local function deleteCampfire()
    local toyFolder = Workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    if not toyFolder then return end
    
    for _, item in ipairs(toyFolder:GetChildren()) do
        if item.Name == "Campfire" then
            pcall(function()
                ReplicatedStorage.MenuToys.DestroyToy:FireServer(item)
            end)
        end
    end
end

-- ==========================================
-- バリア破壊処理
-- ==========================================

Tab:AddSection({Name = "実行"})

Tab:AddButton({
    Name = "バリア破壊",
    Callback = function()
        if executing then
            OrionLib:MakeNotification({
                Name = "バリア破壊",
                Content = "すでに実行中です",
                Time = 2
            })
            return
        end
        
        executing = true
        
        task.spawn(function()
            -- 家の中チェック
            local plotItems = Workspace:FindFirstChild("PlotItems")
            if plotItems then
                local playersInPlots = plotItems:FindFirstChild("PlayersInPlots")
                if playersInPlots and playersInPlots:FindFirstChild(LP.Name) then
                    OrionLib:MakeNotification({
                        Name = "エラー",
                        Content = "家の外で実行してください",
                        Time = 3
                    })
                    executing = false
                    return
                end
            end
            
            -- キャラチェック
            local char = LP.Character
            if not char then
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "キャラクターがありません",
                    Time = 3
                })
                executing = false
                return
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "HRPまたはHumanoidがありません",
                    Time = 3
                })
                executing = false
                return
            end
            
            -- 元の位置保存
            local originalPos = hrp.CFrame
            local originalWalkSpeed = hum.WalkSpeed
            hum.WalkSpeed = 0
            
            OrionLib:MakeNotification({
                Name = "バリア破壊",
                Content = "実行中...",
                Time = 2
            })
            
            -- ステップ1: オカリナスポーン
            pcall(function()
                ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
                    "InstrumentWoodwindOcarina",
                    CFrame.new(184.148834, -5.54824972, 498.136749),
                    Vector3.new(0, 34, 0)
                )
            end)
            task.wait(0.4)
            
            -- ステップ2: オカリナを持つ
            local toyFolder = Workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
            local ocarina = toyFolder and toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
            
            if not ocarina or not ocarina:FindFirstChild("HoldPart") then
                hrp.CFrame = originalPos
                hum.WalkSpeed = originalWalkSpeed
                executing = false
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "オカリナの取得に失敗しました",
                    Time = 3
                })
                return
            end
            
            pcall(function()
                ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, Workspace[LP.Name])
            end)
            
            -- ステップ3: テレポート
            hrp.CFrame = CFrame.new(304.06, 25.77, 488.54)
            task.wait(0.21)
            
            -- オカリナ削除
            pcall(function()
                ReplicatedStorage.MenuToys.DestroyToy:FireServer(ocarina)
            end)
            
            -- ステップ4: 元の位置に戻る
            hrp.CFrame = originalPos
            task.wait(0.7)
            
            -- ステップ5: キャンプファイヤー
            pcall(function()
                ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
                    "Campfire",
                    CFrame.new(257.638672, -5.57392979, 450.103638),
                    Vector3.new(0, 161.972)
                )
            end)
            
            -- 復元
            task.wait(0.3)
            hrp.CFrame = originalPos
            hum.WalkSpeed = originalWalkSpeed
            executing = false
            
            OrionLib:MakeNotification({
                Name = "成功",
                Content = "バリア破壊を実行しました",
                Time = 3
            })
        end)
    end
})

Tab:AddButton({
    Name = "キャンプファイヤー削除",
    Callback = function()
        deleteCampfire()
        OrionLib:MakeNotification({
            Name = "削除",
            Content = "キャンプファイヤーを削除しました",
            Time = 2
        })
    end
})

Tab:AddButton({
    Name = "状態リセット",
    Callback = function()
        executing = false
        OrionLib:MakeNotification({
            Name = "リセット",
            Content = "状態をリセットしました",
            Time = 2
        })
    end
})

Tab:AddParagraph(
    "使い方",
    "1. 家の外にいることを確認\n2. バリア破壊ボタンを押す\n3. 完了後、キャンプファイヤー削除を押す"
)

OrionLib:Init()
