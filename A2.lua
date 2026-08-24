-- // なべHub ロガー検知 v3.0 カテゴリ別トグル版
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui", 10)

if PlayerGui:FindFirstChild("NabeAntiLogger") then PlayerGui.NabeAntiLogger:Destroy() end

-- ===== 変数 =====
local detectorActive = true
local minimized = false
local detectionLogs = {}
local maxLogs = 200
local blockedCount = 0
local spamEnabled = true

-- ===== カテゴリ別トグル状態 =====
local CategoryStates = {
    DiscordWebhook = true,  -- Discord Webhook
    IPCollection = true,    -- IP取得系
    WebhookAlternative = true, -- Webhook代替サービス
    PasteService = true,    -- ペースト系
    HTTPTest = true,        -- HTTPテスト
    RobloxAPI = true,       -- Roblox API
    LocalNetwork = true,    -- ローカルネットワーク
}

-- ===== リクエスト関数の取得 =====
local requestFunc = request or http_request or (syn and syn.request)

-- ===== カテゴリ別ブロックパターン =====
local BLOCKED_PATTERNS = {
    DiscordWebhook = {
        name = "Discord Webhook",
        patterns = {
            "discord.com/api",
            "discordapp.com/api",
            "canary.discord.com",
            "ptb.discord.com",
            "webhook",
        }
    },
    IPCollection = {
        name = "IP取得系",
        patterns = {
            "api.ipify.org",
            "api64.ipify.org",
            "icanhazip.com",
            "ipinfo.io",
            "ip-api.com",
            "api.ip.sb",
            "ipapi.co",
            "ipapi.is",
            "ipwho.is",
            "ipgeolocation.io",
            "ip2location.io",
            "freeipapi.com",
            "ipapi.com",
            "ipaddress.sh",
            "checkip.amazonaws.com",
            "ifconfig.me",
            "ipecho.net",
            "ipinfo.info",
            "myip.com",
            "whatismyip.com",
            "ip.sb",
            "ip.cn",
            "ip.tool.chinaz.com",
        }
    },
    WebhookAlternative = {
        name = "Webhook代替",
        patterns = {
            "webhook.site",
            "hookbin.com",
            "requestbin.com",
            "requestbin.net",
            "webhook.town",
            "webhook.cool",
            "ntfy.sh",
            "webhookinbox.com",
            "webhookrelay.com",
        }
    },
    PasteService = {
        name = "ペースト系",
        patterns = {
            "pastefy.app",
            "pastebin.com",
            "paste.ee",
            "pst.moe",
            "dpaste.org",
            "hastebin.com",
            "controlc.com",
            "rentry.co",
            "justpaste.it",
            "0bin.net",
            "ix.io",
            "sprunge.us",
        }
    },
    HTTPTest = {
        name = "HTTPテスト",
        patterns = {
            "httpbin.org",
            "postman-echo.com",
            "mocky.io",
            "jsonplaceholder.typicode.com",
            "webhook-test.com",
            "httpstat.us",
            "echo.hoppscotch.io",
            "beeceptor.com",
            "mockapi.io",
        }
    },
    RobloxAPI = {
        name = "Roblox API",
        patterns = {
            "roblox.com/games",
            "roblox.com/users",
            "users.roblox.com",
            "games.roblox.com",
            "inventory.roblox.com",
            "friends.roblox.com",
            "presence.roblox.com",
            "avatar.roblox.com",
            "thumbnails.roblox.com",
            "badges.roblox.com",
            "catalog.roblox.com",
            "economy.roblox.com",
            "groups.roblox.com",
            "develop.roblox.com",
            "auth.roblox.com",
            "accountinformation.roblox.com",
        }
    },
    LocalNetwork = {
        name = "ローカルネットワーク",
        patterns = {
            "localhost",
            "127.0.0.1",
            "0.0.0.0",
            "192.168.",
            "10.0.",
            "172.16.",
            "ngrok.io",
            "ngrok.com",
            "localtunnel.me",
            "lhr.life",
            "cloudflare-ipfs.com",
        }
    },
}

-- ===== スパム用メッセージ =====
local SPAM_MESSAGES = {
    '@here@everyone ロガー検知されました',
    'https://tenor.com/view/yajuu-gif-25210528',
    'https://tenor.com/view/inm-gif-14238283865225816154',
    'ロガーを仕込むなよ',
    'https://tenor.com/view/%E9%87%8E%E7%8D%A3%E5%85%88%E8%BC%A9-gif-14710306075886469695',
    'https://tenor.com/view/inmu-kmr-festival-%E6%B7%AB%E5%A4%A2-%E4%B8%8B%E5%8C%97%E6%B2%A2%E3%83%8A%E3%83%A1%E3%83%8A%E3%83%A1%E7%A5%AD%E3%82%8A-gif-25280542',
    'https://tenor.com/view/%E9%87%8E%E7%8D%A3-%E9%87%8E%E7%8D%A3%E5%85%88%E8%BC%A9-gif-1590969839232724060',
}

-- ===== ログ更新関数 =====
local logFrame = nil
local logLabels = {}
local statusLabel = nil

local function updateLogDisplay()
    if not logFrame then return end
    
    for _, lbl in pairs(logLabels) do
        if lbl.Parent then lbl:Destroy() end
    end
    logLabels = {}

    for idx, log in pairs(detectionLogs) do
        local lbl = Instance.new("TextLabel", logFrame)
        lbl.Size = UDim2.new(1, -10, 0, 34)
        lbl.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
        
        if log.type == "BLOCK" then
            lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif log.type == "SPAM" then
            lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
        elseif log.type == "CATEGORY" then
            lbl.TextColor3 = Color3.fromRGB(100, 200, 255)
        else
            lbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
        
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 9
        lbl.Text = string.format("[%s] %s | %s\n%s", log.time, log.type, log.category or "-", log.content:sub(1, 50))
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.LayoutOrder = idx - 1
        lbl.ZIndex = 4
        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 3)
        table.insert(logLabels, lbl)
    end

    logFrame.CanvasSize = UDim2.new(0, 0, 0, #detectionLogs * 36 + 10)
end

-- ===== ログ追加関数 =====
local function addLog(logType, content, category)
    table.insert(detectionLogs, 1, {
        type = logType,
        content = content,
        category = category,
        time = os.date("%H:%M:%S"),
    })
    while #detectionLogs > maxLogs do
        table.remove(detectionLogs)
    end
    updateLogDisplay()
end

-- ===== URLチェック（カテゴリ別） =====
local function checkBlocked(url)
    if type(url) ~= "string" then return false, nil end
    local lowerURL = url:lower()
    
    for categoryKey, categoryData in pairs(BLOCKED_PATTERNS) do
        if CategoryStates[categoryKey] then
            for _, pattern in pairs(categoryData.patterns) do
                if lowerURL:find(pattern, 1, true) then
                    return true, categoryData.name
                end
            end
        end
    end
    
    return false, nil
end

-- ===== Webhookスパム送信 =====
local function sendSpamToWebhook(url)
    if not spamEnabled then return end
    local http = game:GetService("HttpService")
    
    task.spawn(function()
        local msgIndex = 1
        local spamCount = 0
        while spamEnabled and spamCount < 50 do
            local msg = SPAM_MESSAGES[msgIndex]
            local body = http:JSONEncode({
                content = msg,
                username = "ロガー検知Bot",
            })
            
            local success = pcall(function()
                if not requestFunc then return end
                return requestFunc({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = body
                })
            end)
            
            if not success then break end
            msgIndex = msgIndex % #SPAM_MESSAGES + 1
            spamCount = spamCount + 1
            task.wait(1.5)
        end
        addLog("SPAM", "スパム送信完了 (" .. spamCount .. "回)", url)
    end)
end

-- ===== フック関数 =====
local function makeHookedRequest(originalFunc)
    return function(option)
        local url = ""
        local method = "POST"
        
        if type(option) == "table" then
            url = tostring(option.Url or option.url or "")
            method = tostring(option.Method or option.method or "POST")
        elseif type(option) == "string" then
            url = option
        end
        
        if detectorActive then
            local blocked, category = checkBlocked(url)
            if blocked then
                blockedCount = blockedCount + 1
                addLog("BLOCK", method .. " " .. url, category)
                
                if url:find("discord", 1, true) or url:find("webhook", 1, true) then
                    addLog("SPAM", "スパム送信開始: " .. url, category)
                    sendSpamToWebhook(url)
                end
                
                if statusLabel then
                    statusLabel.Text = string.format("ブロック数: %d | 状態: %s", blockedCount, detectorActive and "稼働中" or "停止中")
                end
                
                return {
                    Success = false,
                    StatusCode = 403,
                    Body = "Blocked by NabeAntiLogger"
                }
            end
        end
        
        if originalFunc then
            return originalFunc(option)
        end
    end
end

-- ===== フック設定 =====
local function setupHooks()
    getgenv().request = makeHookedRequest(requestFunc)
    getgenv().http_request = makeHookedRequest(http_request)
    
    if syn then
        syn.request = makeHookedRequest(syn.request)
    end
    
    if request then
        request = makeHookedRequest(request)
    end
    
    if http_request then
        http_request = makeHookedRequest(http_request)
    end
end

-- ===== GUI構築 =====
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "NabeAntiLogger"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 520)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, -35, 0, 28)
TitleBar.Text = "なべHub ロガー検知 v3.0"
TitleBar.TextColor3 = Color3.fromRGB(200, 0, 0)
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 11
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 28)
MinBtn.Position = UDim2.new(1, -32, 0, 0)
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(200, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 2
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local contentElements = {}

-- メイン検知トグル
local DetectToggle = Instance.new("TextButton", MainFrame)
DetectToggle.Size = UDim2.new(0.9, 0, 0, 30)
DetectToggle.Position = UDim2.new(0.05, 0, 0, 35)
DetectToggle.Text = "[X] ロガー検知を有効化"
DetectToggle.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
DetectToggle.TextColor3 = Color3.fromRGB(200, 0, 0)
DetectToggle.Font = Enum.Font.Code
DetectToggle.TextSize = 11
DetectToggle.TextXAlignment = Enum.TextXAlignment.Left
DetectToggle.BorderSizePixel = 1
DetectToggle.BorderColor3 = Color3.fromRGB(100, 0, 0)
DetectToggle.AutoButtonColor = false
Instance.new("UICorner", DetectToggle).CornerRadius = UDim.new(0, 4)
table.insert(contentElements, DetectToggle)

local detectorOn = true
DetectToggle.MouseButton1Click:Connect(function()
    detectorOn = not detectorOn
    detectorActive = detectorOn
    DetectToggle.Text = (detectorOn and "[X] " or "[ ] ") .. "ロガー検知を有効化"
    DetectToggle.BackgroundColor3 = detectorOn and Color3.fromRGB(60, 10, 10) or Color3.fromRGB(20, 5, 5)
    addLog("SYSTEM", detectorOn and "検知を開始しました" or "検知を停止しました")
end)

-- スパムトグル
local SpamToggle = Instance.new("TextButton", MainFrame)
SpamToggle.Size = UDim2.new(0.9, 0, 0, 30)
SpamToggle.Position = UDim2.new(0.05, 0, 0, 70)
SpamToggle.Text = "[X] スパム送信を有効化"
SpamToggle.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
SpamToggle.TextColor3 = Color3.fromRGB(200, 0, 0)
SpamToggle.Font = Enum.Font.Code
SpamToggle.TextSize = 11
SpamToggle.TextXAlignment = Enum.TextXAlignment.Left
SpamToggle.BorderSizePixel = 1
SpamToggle.BorderColor3 = Color3.fromRGB(100, 0, 0)
SpamToggle.AutoButtonColor = false
Instance.new("UICorner", SpamToggle).CornerRadius = UDim.new(0, 4)
table.insert(contentElements, SpamToggle)

SpamToggle.MouseButton1Click:Connect(function()
    spamEnabled = not spamEnabled
    SpamToggle.Text = (spamEnabled and "[X] " or "[ ] ") .. "スパム送信を有効化"
    SpamToggle.BackgroundColor3 = spamEnabled and Color3.fromRGB(60, 10, 10) or Color3.fromRGB(20, 5, 5)
end)

-- カテゴリトグル
local categoryToggles = {}
local categoryY = 110

for categoryKey, categoryData in pairs(BLOCKED_PATTERNS) do
    local toggle = Instance.new("TextButton", MainFrame)
    toggle.Size = UDim2.new(0.9, 0, 0, 26)
    toggle.Position = UDim2.new(0.05, 0, 0, categoryY)
    toggle.Text = "[X] " .. categoryData.name .. " (" .. #categoryData.patterns .. "個)"
    toggle.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
    toggle.TextColor3 = Color3.fromRGB(200, 0, 0)
    toggle.Font = Enum.Font.Code
    toggle.TextSize = 10
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    toggle.BorderSizePixel = 1
    toggle.BorderColor3 = Color3.fromRGB(100, 0, 0)
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
    table.insert(contentElements, toggle)
    
    toggle.MouseButton1Click:Connect(function()
        CategoryStates[categoryKey] = not CategoryStates[categoryKey]
        toggle.Text = (CategoryStates[categoryKey] and "[X] " or "[ ] ") .. categoryData.name .. " (" .. #categoryData.patterns .. "個)"
        toggle.BackgroundColor3 = CategoryStates[categoryKey] and Color3.fromRGB(60, 10, 10) or Color3.fromRGB(20, 5, 5)
        addLog("CATEGORY", categoryData.name .. " を" .. (CategoryStates[categoryKey] and "有効化" or "無効化"), categoryData.name)
    end)
    
    categoryToggles[categoryKey] = toggle
    categoryY = categoryY + 30
end

-- ステータス表示
statusLabel = Instance.new("TextLabel", MainFrame)
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, categoryY + 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ブロック数: 0 | 状態: 稼働中"
statusLabel.TextColor3 = Color3.fromRGB(150, 80, 80)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(contentElements, statusLabel)

-- ログ表示エリア
logFrame = Instance.new("ScrollingFrame", MainFrame)
logFrame.Size = UDim2.new(0.9, 0, 0, 180)
logFrame.Position = UDim2.new(0.05, 0, 0, categoryY + 30)
logFrame.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
logFrame.BorderSizePixel = 1
logFrame.BorderColor3 = Color3.fromRGB(100, 0, 0)
logFrame.ScrollBarThickness = 3
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.ZIndex = 3
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 4)
table.insert(contentElements, logFrame)

local logList = Instance.new("UIListLayout", logFrame)
logList.SortOrder = Enum.SortOrder.LayoutOrder
logList.Padding = UDim.new(0, 2)

-- ログクリアボタン
local clearBtn = Instance.new("TextButton", MainFrame)
clearBtn.Size = UDim2.new(0.9, 0, 0, 26)
clearBtn.Position = UDim2.new(0.05, 0, 0, categoryY + 215)
clearBtn.Text = "ログクリア"
clearBtn.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
clearBtn.TextColor3 = Color3.fromRGB(200, 0, 0)
clearBtn.Font = Enum.Font.Code
clearBtn.TextSize = 10
clearBtn.BorderSizePixel = 1
clearBtn.BorderColor3 = Color3.fromRGB(100, 0, 0)
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)
table.insert(contentElements, clearBtn)
clearBtn.MouseButton1Click:Connect(function()
    detectionLogs = {}
    blockedCount = 0
    updateLogDisplay()
    addLog("SYSTEM", "ログをクリアしました")
end)

-- ステータス更新ループ
task.spawn(function()
    while true do
        if statusLabel then
            statusLabel.Text = string.format("ブロック数: %d | 状態: %s", blockedCount, detectorActive and "稼働中" or "停止中")
        end
        task.wait(0.3)
    end
end)

-- 最小化
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 340, 0, 28)
        MinBtn.Text = "+"
        for _, el in pairs(contentElements) do el.Visible = false end
    else
        MainFrame.Size = UDim2.new(0, 340, 0, 520)
        MinBtn.Text = "_"
        for _, el in pairs(contentElements) do el.Visible = true end
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            gui.Position = UDim2.new(0, math.clamp(sp.X.Offset + d.X, 0, Camera.ViewportSize.X - gui.AbsoluteSize.X), 0, math.clamp(sp.Y.Offset + d.Y, 0, Camera.ViewportSize.Y - gui.AbsoluteSize.Y))
        end
    end)
end
makeDraggable(MainFrame, TitleBar)

-- ===== 初期化 =====
setupHooks()
addLog("SYSTEM", "ロガー検知v3.0をロードしました")
addLog("SYSTEM", "全パターン数: " .. (function() local total = 0 for _, cat in pairs(BLOCKED_PATTERNS) do total = total + #cat.patterns end return total end)() .. "個")
print("なべHub ロガー検知 v3.0 ロード完了")
