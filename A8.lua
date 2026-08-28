-- ==========================================
-- 物人ソースコード v2.0
-- The Survival Game (物人) リファレンス詳細版
-- 起動しても何も起こりません
-- ==========================================

-- ==========================================
-- 1. リモート詳細
-- ==========================================

-- === SpawnToyRemoteFunction ===
-- 型: RemoteFunction
-- 呼び出し: InvokeServer(おもちゃ名, CFrame, Vector3)
-- 引数1: string  → おもちゃの名前
-- 引数2: CFrame  → スポーン位置と向き
-- 引数3: Vector3 → 回転速度（例: Vector3.new(0, 127, 0)でY軸回転）
-- 戻り値: なし
-- 注意: 家の中ではSpawnedInToysではなくPlotItems内にスポーンされる
-- 注意: CanSpawnToyがfalseの間は呼び出せない
-- 注意: スポーン後0.3〜0.5秒待たないとFindFirstChildで見つからない

-- === DestroyToy ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(おもちゃ本体)
-- 引数1: Model  → 削除するおもちゃ
-- 注意: サーバーに反映されるまで0.1秒待つ
-- 注意: 座ってる場合、先にSit=falseにする必要がある

-- === BuyToyRemoteFunction ===
-- 型: RemoteFunction
-- 呼び出し: InvokeServer(おもちゃ名)
-- 引数1: string → 購入するおもちゃ
-- 戻り値: 購入結果

-- === CreateGrabLine ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(起点, 終点CFrame, 引数3, 引数4)
-- 引数1: BasePart → ラインの起点
-- 引数2: CFrame   → ラインの終点
-- 引数3: Vector3  → オフセット（通常Vector3.zero）
-- 引数4: boolean  → 何かのフラグ（通常false）
-- 注意: ラグ用に極端な座標を入れるとサーバーに負荷

-- === DestroyGrabLine ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(対象パーツ)
-- 引数1: BasePart → ラインを消す対象

-- === SetNetworkOwner ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(対象パーツ, CFrame)
-- 引数1: BasePart → 所有権を奪うパーツ
-- 引数2: CFrame   → そのパーツの現在位置
-- 注意: 30スタッド以内でないと効かない場合あり
-- 注意: 所有権を奪うと物理操作が可能になる

-- === ExtendGrabLine ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(引数)
-- 引数1: string → 大量文字列でラグ

-- === RagdollRemote ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(HRP, 強さ)
-- 引数1: BasePart → HumanoidRootPart
-- 引数2: number   → ラグドールの強さ（0で軽い、1で通常、2で強い）

-- === Struggle ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(プレイヤー or 引数なし)
-- 引数1: Player → 掴みから脱出するプレイヤー

-- === StickyPartEvent ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(粘着パーツ, 対象パーツ, CFrame)
-- 引数1: BasePart → 粘着するパーツ
-- 引数2: BasePart → 粘着されるパーツ
-- 引数3: CFrame   → 粘着位置のオフセット

-- === BombExplode ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(テーブル, 位置)
-- 引数1: table  → 爆発設定（Hitbox, PositionPart, Radius等）
-- 引数2: Vector3 → 爆発位置

-- === UpdateLineColorsEvent ===
-- 型: RemoteEvent
-- 呼び出し: FireServer(ColorSequence)
-- 引数1: ColorSequence → ラインの色

-- === StopAllVelocity ===
-- 型: RemoteEvent
-- 呼び出し: FireServer()
-- 引数: なし

-- === CreatureToss ===
-- 型: RemoteEvent
-- 呼び出し: FireServer()
-- 引数: なし
-- 効果: ブロブマンが掴んでるものを投げる

-- ==========================================
-- 2. キャラクター構造（詳細）
-- ==========================================

-- LocalPlayer.Character（Model）
-- ├── Humanoid（Humanoid）
-- │   ├── Health               → 体力
-- │   ├── WalkSpeed            → 歩行速度（デフォルト16）
-- │   ├── JumpPower            → ジャンプ力（デフォルト50）
-- │   ├── HipHeight            → 腰の高さ
-- │   ├── Sit                  → 座り状態
-- │   ├── SeatPart             → 座ってる座席
-- │   ├── PlatformStand        → プラットフォーム立位
-- │   ├── AutoRotate           → 自動回転
-- │   ├── BreakJointsOnDeath   → 死亡時にジョイント破壊
-- │   ├── Ragdolled            → ラグドール状態（BoolValue）
-- │   ├── FireDebounce         → 火傷デバウンス（BoolValue）
-- │   ├── MoveDirection        → 移動方向
-- │   └── ChangeState()        → 状態変更
-- │
-- ├── HumanoidRootPart（Part）
-- │   ├── CFrame               → 位置
-- │   ├── Velocity             → 速度
-- │   ├── RotVelocity          → 回転速度
-- │   ├── AssemblyLinearVelocity  → 線速度
-- │   ├── AssemblyAngularVelocity → 角速度
-- │   ├── FirePlayerPart       → 火傷判定パーツ
-- │   │   └── CanBurn          → 燃えるか（BoolValue）
-- │   ├── RootAttachment       → ルートアタッチメント
-- │   └── WeldHRP              → ルート溶接
-- │
-- ├── Head（Part）
-- │   ├── PartOwner            → 掴んでる人の名前（StringValue）
-- │   │   └── 存在したら掴まれてる
-- │   └── BallSocketConstraint → 首の拘束
-- │
-- ├── Torso（Part）
-- ├── Left Arm（Part）
-- │   └── RagdollLimbPart      → ラグドール肢
-- ├── Right Arm（Part）
-- │   └── RagdollLimbPart
-- ├── Left Leg（Part）
-- │   └── RagdollLimbPart
-- ├── Right Leg（Part）
-- │   └── RagdollLimbPart
-- │
-- └── CamPart（Part）          → カメラ用

-- ==========================================
-- 3. ブロブマン構造（詳細）
-- ==========================================

-- CreatureBlobman（Model）
-- ├── BlobmanSeatAndOwnerScript（Script）
-- │   ├── CreatureGrab（RemoteEvent）    → 掴む
-- │   ├── CreatureDrop（RemoteEvent）    → 離す
-- │   └── CreatureRelease（RemoteEvent） → リリース
-- │
-- ├── VehicleSeat（VehicleSeat）
-- │   └── SeatWeld（Weld）              → 座ってる判定
-- │       └── Part1 = 座ってる人のパーツ
-- │
-- ├── HumanoidRootPart（Part）
-- ├── Head（Part）
-- │   └── PartOwner（StringValue）      → 所有権
-- │
-- ├── LeftDetector（Part）
-- │   ├── LeftWeld（Weld）              → 左手の溶接
-- │   └── AttachPlayer（Part）          → 掴み判定
-- │
-- ├── RightDetector（Part）
-- │   ├── RightWeld（Weld）             → 右手の溶接
-- │   └── AttachPlayer（Part）          → 掴み判定
-- │
-- ├── RightHand（Part）
-- ├── LeftHand（Part）
-- └── GrabbableHitbox（Part）           → 掴める判定

-- ==========================================
-- 4. おもちゃ構造（詳細）
-- ==========================================

-- === 食べ物共通 ===
-- おもちゃ本体（Model）
-- ├── HoldPart（Part）
-- │   ├── HoldItemRemoteFunction（RemoteFunction） → 持つ
-- │   │   引数: InvokeServer(おもちゃ本体, キャラクター)
-- │   └── DropItemRemoteFunction（RemoteFunction） → 離す
-- │       引数: InvokeServer(おもちゃ本体, CFrame, Vector3)
-- ├── EdiblePart（Part）              → 食べられる部分
-- ├── SoundPart（Part）               → 音パーツ
-- └── Main（Part）                    → メインパーツ

-- === キャンプファイヤー ===
-- Campfire（Model）
-- ├── FirePlayerPart（Part）          → 火傷判定
-- │   └── CanBurn（BoolValue）        → 燃えるか
-- ├── Main（Part）
-- └── FireDetector（Part）            → 火検出

-- === 消火器 ===
-- FireExtinguisher（Model）
-- ├── ExtinguishPart（Part）          → 消火パーツ
-- ├── SoundPart（Part）
-- └── Main（Part）

-- === スプレー缶 ===
-- SprayCanWD（Model）
-- ├── StickyRemoverPart（Part）       → 粘着除去
-- ├── SoundPart（Part）
-- └── TouchTransmitter               → タッチ送信

-- === 手裏剣 ===
-- NinjaShuriken（Model）
-- ├── StickyPart（Part）              → 粘着パーツ
-- │   ├── StickyWeld（Weld）          → 粘着溶接
-- │   │   └── Part1 = くっついてる対象
-- │   └── CanTouch（bool）            → 触れるか
-- ├── SoundPart（Part）
-- ├── Pyramid（Part）                 → ピラミッド部分
-- └── Main（Part）

-- === クナイ ===
-- NinjaKunai（Model）
-- ├── StickyPart（Part）
-- │   └── StickyWeld（Weld）
-- ├── SoundPart（Part）
-- └── Main（Part）

-- === 雪玉 ===
-- BallSnowball（Model）
-- ├── SoundPart（Part）               → 音パーツ
-- └── SnowRagdollPart（Part）         → 雪ラグドール判定

-- === パレット ===
-- PalletLightBrown（Model）
-- ├── SoundPart（Part）
-- └── PartHitDetector（Part）         → ヒット判定

-- === 爆発物 ===
-- BombMissile（Model）
-- ├── HitboxBodyTop（Part）           → ヒットボックス
-- ├── PartHitDetector（Part）         → ヒット判定
-- └── Body（Part）

-- BombDarkMatter（Model）
-- ├── PartHitDetector（Part）
-- ├── Spinner（Part）                 → 回転部分
-- └── Pyramid（Part）

-- BombBalloon（Model）
-- └── Balloon（Part）

-- FireworkMissile（Model）
-- └── Hitbox（Part）

-- PresentBig / PresentSmall（Model）
-- └── Box（Part）

-- ==========================================
-- 5. マップ構造（詳細）
-- ==========================================

-- Workspace
-- ├── Map
-- │   ├── Hole
-- │   │   ├── PoisonBigHole
-- │   │   │   ├── PoisonHurtPart（Part）   → 毒判定（触れると毒）
-- │   │   │   └── ExtinguishPart（Part）   → 消火パーツ（触れると火が消える）
-- │   │   └── PoisonSmallHole
-- │   │       └── PoisonHurtPart
-- │   ├── FactoryIsland
-- │   │   └── PoisonContainer
-- │   │       └── PoisonHurtPart
-- │   └── AlwaysHereTweenedObjects
-- │       ├── Train（Model）              → 電車
-- │       │   ├── Object
-- │       │   │   └── ObjectModel
-- │       │   │       └── FollowThisPart
-- │       │   │           ├── AlignPosition
-- │       │   │           └── AlignOrientation
-- │       │   └── Seat（Seat）            → 座席
-- │       ├── OuterUFO（Model）           → 外側UFO
-- │       │   └── Object
-- │       │       └── ObjectModel
-- │       │           ├── FollowThisPart
-- │       │           │   ├── AlignPosition
-- │       │           │   └── AlignOrientation
-- │       │           └── PaintPlayerPart → 放射能判定
-- │       └── InnerUFO（Model）           → 内側UFO
-- │           └── Object
-- │               └── ObjectModel
-- │                   └── FollowThisPart
-- │                       ├── AlignPosition
-- │                       └── AlignOrientation
-- │
-- ├── Plots                                → 家のプロット
-- │   ├── Plot1（普通の家）
-- │   ├── Plot2（木の家）
-- │   ├── Plot3（魔女の家）
-- │   ├── Plot4（アメリカの家）
-- │   └── Plot5（中華の家）
-- │       ├── PlotSign（Part）
-- │       │   ├── ThisPlotsOwners（Folder）→ 所有者リスト
-- │       │   │   └── Value（StringValue） → 所有者名
-- │       │   │       └── TimeRemainingNum（IntValue） → 残り時間
-- │       │   └── Sign（Part）
-- │       │       └── Plus
-- │       │           └── PlusGrabPart    → 購入用パーツ
-- │       ├── PlotArea（Part）             → 敷地
-- │       └── Barrier
-- │           └── PlotBarrier（Part）      → バリア
-- │
-- ├── PlotItems                            → プロット内アイテム
-- │   ├── PlayersInPlots                   → 家の中のプレイヤー
-- │   └── Plot1〜Plot5                     → 各プロットのおもちゃ
-- │
-- ├── Slots                                → スロット
-- │   ├── SlotHandle（Model）
-- │   │   ├── Handle（Part）               → ハンドル
-- │   │   └── LightBall（Part）            → ライトボール
-- │   └── Slots
-- │       └── Screen
-- │           └── SlotGui
-- │               └── TimeLeftFrame
-- │                   └── TimeText         → 残り時間表示
-- │
-- ├── Waypoints                            → ウェイポイント
-- ├── SpawnLocation                        → スポーン地点
-- ├── GrabParts                            → 掴み中のパーツ
-- │   ├── GrabPart
-- │   │   └── WeldConstraint
-- │   │       └── Part1 = 掴んでる対象
-- │   └── DragPart
-- │       ├── AlignPosition
-- │       ├── AlignOrientation
-- │       └── DragAttach
-- │
-- ├── PlayerCharacterLocationDetector（Part）→ PCLD
-- │
-- └── [プレイヤー名]SpawnedInToys（Folder）  → おもちゃ置き場

-- ==========================================
-- 6. 座標一覧（詳細）
-- ==========================================

-- === 家 ===
-- 紫の家（魔女/Plot3）: (255, -8, 449)
-- 緑の家（木/Plot2）: (-534, -8, 93)
-- 青の家（アメリカ/Plot4）: (512, 82, -343)
-- オレンジの家（中華/Plot5）: (548, 122, -73)
-- 赤の家（普通/Plot1）: (-493, -8, -165)

-- === 家の内部 ===
-- 紫の家の内部: (296, -4, 494)
-- 緑の家の内部: (-584, -6, 93)
-- 青の家の内部: (538, 96, -372)
-- オレンジの家の内部: (579, 124, -94)
-- 赤の家の内部: (-516, -6, -162)

-- === マップ地点 ===
-- リス地（スポーン）: (0, -7, 0)
-- 山の緑の家: (-278, 147, 310)
-- 赤い畑の家: (-203, 84, -292)
-- 普通の洞窟: (-261, -7, 533)
-- 秘密の大洞窟: (17, -7, 539)
-- 秘密の列車洞窟: (500, 62, -307)
-- スロットの裏の洞窟: (-34, -7, -299)
-- 毒井戸: (106, -25, 279)
-- 雪山: (-414, 231, 480)

-- === スロット ===
-- Slot1: (54, -7, -115)
-- Slot2: (170, -8, 527)
-- Slot3: (-213, 83, 421)
-- Slot4: (-540, -6, -40)

-- === 特殊座標 ===
-- バリア破壊用オカリナ座標: (184.14, -5.54, 498.13)
-- バリア破壊用テレポート座標: (304.06, 25.77, 488.54)
-- バリア破壊用キャンプファイヤー座標: (257.63, -5.57, 450.10)
-- アンチループキル用座標: (524.70, 93.71, -375.04)

-- ==========================================
-- 7. グリッチ・テクニック
-- ==========================================

-- === バリア破壊 ===
-- 手順:
-- 1. 家の外にいることを確認
-- 2. オカリナを特定座標(184.14, -5.54, 498.13)にスポーン
-- 3. オカリナを持つ
-- 4. (304.06, 25.77, 488.54)にテレポート
-- 5. オカリナを削除
-- 6. 元の位置に戻る
-- 7. キャンプファイヤーを(257.63, -5.57, 450.10)にスポーン
-- 結果: バリアが壊れる

-- === 家の時間維持 ===
-- ThisPlotsOwnersのTimeRemainingNumが20以下になったら
-- PlotAreaにテレポートして時間を維持

-- === スロット自動回転 ===
-- 1. SlotHandleのHandleを触る
-- 2. SetNetworkOwnerで所有権取得
-- 3. 回転させる
-- 4. LightBallのMaterialがNeonになったら当たり

-- === 毒パーツ位置 ===
-- PoisonHurtPartのデフォルト位置: (0, -50, 0) ← マップ外
-- 攻撃時: 対象のHeadに移動させて毒殺

-- ==========================================
-- 8. アンチ機能の仕組み
-- ==========================================

-- === アンチ掴み ===
-- Head.PartOwnerが付いたら検知
-- Struggleを連打して脱出
-- キャラをアンカー固定して動かないようにする

-- === アンチキック ===
-- NinjaShurikenを自分の足にくっつける
-- StickyWeld.Part1が自分の足か監視
-- 外れたら再装着

-- === アンチラグドール ===
-- Ragdolledがtrueになったら即座にfalseに戻す

-- === アンチ火傷 ===
-- FireLightが付いたら検知
-- ExtinguishPartを自分の位置に持ってくる

-- === アンチ爆発 ===
-- Ragdolledがtrueになったら全パーツをアンカー

-- === アンチ雪玉 ===
-- 近くの雪玉のSnowRagdollPartを無効化

-- ==========================================
-- 9. 頻出コードパターン（詳細）
-- ==========================================

-- === ブロブマン取得（座ってるもの） ===
local function getSeatedBlobman()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if seat and seat.Parent and seat.Parent.Name == "CreatureBlobman" then
        return seat.Parent
    end
    return nil
end

-- === ブロブマン取得（自分のおもちゃ） ===
local function getMyBlobman()
    local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if toys then
        return toys:FindFirstChild("CreatureBlobman")
    end
    return nil
end

-- === 掴まれてる判定 ===
local function isGrabbed()
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if head and head:FindFirstChild("PartOwner") then
        return true
    end
    if LocalPlayer.IsHeld and LocalPlayer.IsHeld.Value then
        return true
    end
    return false
end

-- === 家の判定 ===
local function isInHouse()
    return LocalPlayer.InPlot and LocalPlayer.InPlot.Value
end

-- === 自分の家の判定 ===
local function isInOwnHouse()
    return LocalPlayer.InOwnedPlot and LocalPlayer.InOwnedPlot.Value
end

-- === スポーン可能判定 ===
local function canSpawn()
    return LocalPlayer.CanSpawnToy and LocalPlayer.CanSpawnToy.Value
end

-- === 掴み判定（GrabParts） ===
local function getGrabbedPart()
    local grabParts = Workspace:FindFirstChild("GrabParts")
    if grabParts then
        local grabPart = grabParts:FindFirstChild("GrabPart")
        if grabPart and grabPart:FindFirstChild("WeldConstraint") then
            return grabPart.WeldConstraint.Part1
        end
    end
    return nil
end

-- === 所有権チェック ===
local function hasNetworkOwnership(part)
    local partOwner = part and part:FindFirstChild("PartOwner")
    return partOwner and partOwner.Value == LocalPlayer.Name
end

-- === 所有権取得 ===
local function takeNetworkOwnership(part)
    local GE = ReplicatedStorage:FindFirstChild("GrabEvents")
    local setOwner = GE and GE:FindFirstChild("SetNetworkOwner")
    if setOwner and part then
        pcall(function()
            setOwner:FireServer(part, part.CFrame)
        end)
    end
end

-- ==========================================
-- 終了
-- ==========================================
-- このスクリプトは何も実行しません
-- スクリプト開発の参考にしてください
-- v2.0: 詳細情報追加
