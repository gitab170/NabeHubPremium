-- ==========================================
-- 物人ソースコード v1.0
-- The Survival Game (物人) リファレンス
-- 起動しても何も起こりません
-- スクリプト開発用のソースコード集です
-- ==========================================

-- ==========================================
-- 1. サービス
-- ==========================================
-- game:GetService("Players")
-- game:GetService("ReplicatedStorage")
-- game:GetService("Workspace")
-- game:GetService("RunService")
-- game:GetService("UserInputService")
-- game:GetService("TweenService")
-- game:GetService("Debris")
-- game:GetService("Lighting")
-- game:GetService("HttpService")
-- game:GetService("VirtualUser")
-- game:GetService("Stats")

-- ==========================================
-- 2. ローカルプレイヤー情報
-- ==========================================
-- LocalPlayer.Name                    → ユーザー名
-- LocalPlayer.DisplayName             → 表示名
-- LocalPlayer.UserId                  → ユーザーID
-- LocalPlayer.Character               → キャラクター
-- LocalPlayer.CharacterAdded          → リスポーンイベント
-- LocalPlayer.InPlot                  → 家の中にいるか
-- LocalPlayer.InOwnedPlot             → 自分の家か
-- LocalPlayer.CanSpawnToy             → おもちゃ出せるか
-- LocalPlayer.ToysLimitCap            → おもちゃの上限
-- LocalPlayer.IsHeld                  → 掴まれてるか
-- LocalPlayer.PlayerGui               → GUI
-- LocalPlayer.PlayerScripts           → スクリプト

-- ==========================================
-- 3. ReplicatedStorage リモート
-- ==========================================

-- === MenuToys ===
-- MenuToys.SpawnToyRemoteFunction    → おもちゃスポーン
-- MenuToys.DestroyToy                → おもちゃ削除
-- MenuToys.BuyToyRemoteFunction      → おもちゃ購入

-- === GrabEvents ===
-- GrabEvents.CreateGrabLine          → グラブライン作成
-- GrabEvents.DestroyGrabLine         → グラブライン削除
-- GrabEvents.SetNetworkOwner         → ネットワーク所有権設定
-- GrabEvents.ExtendGrabLine          → グラブライン延長

-- === CharacterEvents ===
-- CharacterEvents.RagdollRemote      → ラグドール化
-- CharacterEvents.Struggle           → 掴みからの脱出

-- === PlayerEvents ===
-- PlayerEvents.StickyPartEvent       → 粘着パーツ

-- === BombEvents ===
-- BombEvents.BombExplode             → 爆発

-- === DataEvents ===
-- DataEvents.UpdateLineColorsEvent   → ライン色変更

-- === GameCorrectionEvents ===
-- GameCorrectionEvents.StopAllVelocity           → 速度停止
-- GameCorrectionEvents.GameCorrectionsNotify     → 警告通知

-- === CreatureEvents ===
-- CreatureEvents.CreatureToss        → クリーチャー投げ

-- ==========================================
-- 4. ブロブマン関連
-- ==========================================

-- === ブロブマン本体 ===
-- CreatureBlobman                    → 名前

-- === ブロブマンの子 ===
-- BlobmanSeatAndOwnerScript          → スクリプト本体
--   ├── CreatureGrab                 → 掴む
--   ├── CreatureDrop                 → 離す
--   └── CreatureRelease              → リリース
-- VehicleSeat                        → 座席
-- HumanoidRootPart                   → ルートパーツ
-- Head                               → 頭
-- LeftDetector                       → 左手検出器
--   └── LeftWeld                     → 左手の溶接
-- RightDetector                      → 右手検出器
--   └── RightWeld                    → 右手の溶接
-- RightHand                          → 右手
-- LeftHand                           → 左手

-- === ブロブマンの使い方 ===
-- 1. SpawnToyRemoteFunctionでスポーン
-- 2. VehicleSeatに座る
-- 3. CreatureGrabで掴む
-- 4. CreatureDropで離す

-- ==========================================
-- 5. キャラクターパーツ名
-- ==========================================

-- HumanoidRootPart       → ルート
-- Humanoid              → ヒューマノイド
-- Head                  → 頭
-- Torso                 → 胴体
-- Left Arm              → 左腕
-- Right Arm             → 右腕
-- Left Leg              → 左足
-- Right Leg             → 右足
-- FirePlayerPart        → 火傷判定
-- CamPart               → カメラパーツ
-- RootAttachment        → ルートアタッチメント

-- === ラグドール関連 ===
-- Ragdolled             → ラグドール状態
-- RagdollLimbPart       → ラグドール肢
-- BallSocketConstraint  → ボールソケット拘束
-- WeldHRP               → ルート溶接

-- ==========================================
-- 6. おもちゃ一覧
-- ==========================================

-- === 食べ物 ===
-- FoodHamburger         → ハンバーガー
-- FoodCoconut           → ココナッツ
-- FoodBanana            → バナナ
-- FoodFrenchFries       → フライドポテト
-- FoodMeatStick         → 肉串
-- FoodDonut             → ドーナツ
-- FoodCakePink          → ケーキ
-- FoodPizzaCheese       → ピザ
-- FoodHotdog            → ホットドッグ
-- FoodMushroomPoison    → 毒キノコ
-- FoodBread             → パン
-- FoodDippyEgg          → 目玉焼き
-- FoodMayonnaise        → マヨネーズ

-- === 楽器 ===
-- InstrumentGuitarBanjo      → バンジョー
-- InstrumentGuitarViolin     → バイオリン
-- InstrumentGuitarUkulele    → ウクレレ
-- InstrumentGuitarLyre       → ライアー
-- InstrumentWoodwindSaxophone → サックス
-- InstrumentWoodwindOcarina  → オカリナ
-- InstrumentBrassTrumpet     → トランペット
-- InstrumentBrassVuvuzela    → ブブゼラ
-- InstrumentDrumBongos       → ボンゴ
-- InstrumentDrumSnare        → スネア
-- InstrumentPianoMelodica    → メロディカ
-- InstrumentVoiceMicrophone  → マイク

-- === カップ ===
-- CupMugWhite           → 白マグ
-- CupMugBrown           → 茶マグ

-- === うんち ===
-- PoopPile              → うんち
-- PoopPileSparkle       → キラキラうんち

-- === 爆発系 ===
-- BombMissile           → ミサイル
-- BombDarkMatter        → ダークマター
-- BombBalloon           → バルーン
-- FireworkMissile       → 花火ミサイル
-- PresentBig            → 大きいプレゼント
-- PresentSmall          → 小さいプレゼント

-- === 防具/装備 ===
-- NinjaShuriken         → 手裏剣
-- NinjaKunai            → クナイ
-- PalletLightBrown      → パレット
-- SprayCanWD            → スプレー缶
-- FireExtinguisher      → 消火器
-- Campfire              → キャンプファイヤー

-- === その他 ===
-- BallSnowball          → 雪玉
-- JapaneseLantern       → 提灯
-- SpookyCandle1         → 不気味なキャンドル
-- DiceSmall             → サイコロ
-- TractorGreen          → 緑のトラクター
-- FireworkSparkler      → 線香花火
-- OvenDarkGray          → オーブン
-- OvenMicrowaveWhite    → 電子レンジ
-- PlantPottedCactus     → サボテン

-- ==========================================
-- 7. おもちゃの構造
-- ==========================================

-- === 食べ物 ===
-- HoldPart                      → 持つためのパーツ
--   ├── HoldItemRemoteFunction  → 持つリモート
--   └── DropItemRemoteFunction  → 離すリモート
-- EdiblePart                    → 食べられる部分
-- SoundPart                     → 音パーツ

-- === ブロブマン ===
-- BlobmanSeatAndOwnerScript      → スクリプト
-- VehicleSeat                    → 座席
-- LeftDetector / RightDetector   → 手の検出器
-- LeftWeld / RightWeld           → 手の溶接

-- === キャンプファイヤー ===
-- FirePlayerPart                 → 火傷判定パーツ
--   ├── CanBurn                  → 燃えるかどうか
--   └── FireDebounce             → 火傷デバウンス

-- === スプレー缶 ===
-- StickyRemoverPart              → 粘着除去パーツ

-- === 手裏剣 ===
-- StickyPart                     → 粘着パーツ
--   ├── StickyWeld               → 粘着溶接
--   └── CanTouch                 → 触れるか

-- === 雪玉 ===
-- SoundPart                      → 音パーツ
-- SnowRagdollPart                → 雪ラグドール

-- ==========================================
-- 8. フォルダ構造
-- ==========================================

-- Workspace
-- ├── [プレイヤー名]              → プレイヤーのキャラ
-- ├── [プレイヤー名]SpawnedInToys  → 自分のおもちゃ
-- ├── SpawnLocation               → スポーン地点
-- ├── GrabParts                   → 掴みパーツ
-- ├── PlayerCharacterLocationDetector → PCLD
-- │
-- ├── Map
-- │   ├── Hole
-- │   │   ├── PoisonBigHole
-- │   │   │   ├── PoisonHurtPart  → 毒判定
-- │   │   │   └── ExtinguishPart  → 消火パーツ
-- │   │   └── PoisonSmallHole
-- │   │       └── PoisonHurtPart
-- │   ├── FactoryIsland
-- │   │   └── PoisonContainer
-- │   │       └── PoisonHurtPart
-- │   └── AlwaysHereTweenedObjects
-- │       ├── Train               → 電車
-- │       ├── OuterUFO            → 外側UFO
-- │       └── InnerUFO            → 内側UFO
-- │
-- ├── Plots                        → 家のプロット
-- │   ├── Plot1                    → 普通の家
-- │   ├── Plot2                    → 木の家
-- │   ├── Plot3                    → 魔女の家
-- │   ├── Plot4                    → アメリカの家
-- │   └── Plot5                    → 中華の家
-- │       ├── PlotSign
-- │       │   └── ThisPlotsOwners  → 所有者
-- │       ├── PlotArea             → 敷地
-- │       └── PlotBarrier          → バリア
-- │
-- ├── PlotItems                    → プロットアイテム
-- │   ├── PlayersInPlots           → 家の中のプレイヤー
-- │   ├── Plot1〜Plot5             → 各プロットのアイテム
-- │
-- ├── Slots                        → スロット
-- │   ├── SlotHandle
-- │   │   └── Handle              → スロットハンドル
-- │   └── Slots
-- │       └── Screen
-- │           └── SlotGui
-- │               └── TimeLeftFrame
-- │                   └── TimeText → 残り時間
-- │
-- └── Waypoints                    → ウェイポイント

-- ==========================================
-- 9. 座標一覧
-- ==========================================

-- === 家 ===
-- 紫の家（魔女）: (255, -8, 449)
-- 緑の家（木）: (-534, -8, 93)
-- 青の家（アメリカ）: (512, 82, -343)
-- オレンジの家（中華）: (548, 122, -73)
-- 赤の家（普通）: (-493, -8, -165)

-- === 場所 ===
-- リス地（スポーン）: (0, -7, 0)
-- 山の緑の家: (-278, 147, 310)
-- 赤い畑の家: (-203, 84, -292)
-- 普通の洞窟: (-261, -7, 533)
-- スロットの裏の洞窟: (-34, -7, -299)
-- 毒井戸: (106, -25, 279)
-- 雪山: (-414, 231, 480)
-- Slot1: (54, -7, -115)
-- Slot2: (170, -8, 527)
-- Slot3: (-213, 83, 421)
-- Slot4: (-540, -6, -40)

-- ==========================================
-- 10. リモートの使い方
-- ==========================================

-- === おもちゃスポーン ===
-- SpawnToyRemoteFunction:InvokeServer(
--     "FoodHamburger",          -- おもちゃ名
--     CFrame.new(x, y, z),      -- 位置
--     Vector3.new(0, 0, 0)      -- 回転速度
-- )

-- === おもちゃ削除 ===
-- DestroyToy:FireServer(おもちゃ本体)

-- === おもちゃを持つ ===
-- HoldItemRemoteFunction:InvokeServer(おもちゃ本体, キャラクター)

-- === おもちゃを離す ===
-- DropItemRemoteFunction:InvokeServer(
--     おもちゃ本体,
--     CFrame.new(x, y, z),      -- 置く場所
--     Vector3.new(0, 0, 0)      -- 回転速度
-- )

-- === グラブライン作成 ===
-- CreateGrabLine:FireServer(
--     起点パーツ,
--     CFrame.new(x, y, z),      -- 終点
--     引数3,
--     引数4
-- )

-- === グラブライン削除 ===
-- DestroyGrabLine:FireServer(対象パーツ)

-- === ネットワーク所有権 ===
-- SetNetworkOwner:FireServer(対象パーツ, CFrame)

-- === ラグドール化 ===
-- RagdollRemote:FireServer(HRP, 強さ)

-- === 掴み脱出 ===
-- Struggle:FireServer(プレイヤー or 引数なし)

-- === ブロブマン掴む ===
-- CreatureGrab:FireServer(Detector, 対象HRP, Weld)

-- === ブロブマン離す ===
-- CreatureDrop:FireServer(Weld, 対象HRP)

-- ==========================================
-- 11. 頻出コードパターン
-- ==========================================

-- === HRP取得 ===
-- local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- === Humanoid取得 ===
-- local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

-- === 自分のおもちゃフォルダ ===
-- local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")

-- === ブロブマン取得 ===
-- local blob = toys and toys:FindFirstChild("CreatureBlobman")

-- === ブロブマンに座ってるか ===
-- local seat = hum and hum.SeatPart
-- if seat and seat.Parent and seat.Parent.Name == "CreatureBlobman" then
--     -- 乗ってる
-- end

-- === 家の中か ===
-- if LocalPlayer.InPlot and LocalPlayer.InPlot.Value then
--     -- 家の中
-- end

-- === 掴まれてるか ===
-- if LocalPlayer.IsHeld and LocalPlayer.IsHeld.Value then
--     -- 掴まれてる
-- end

-- ==========================================
-- 12. 注意事項
-- ==========================================

-- 1. SpawnToyは待機時間が必要（0.3〜0.5秒）
-- 2. DestroyToyはサーバーに反映されるまで少し待つ
-- 3. SetNetworkOwnerは近距離（30スタッド以内）でないと効かない
-- 4. 家の中ではおもちゃのスポーン先が変わる
-- 5. CanSpawnToyがfalseの間はスポーンできない
-- 6. ブロブマンの操作は座ってから行う
-- 7. RagdollRemoteは連打すると検知される可能性
-- 8. ラグ系はサーバーに負荷をかけるので注意

-- ==========================================
-- 終了
-- ==========================================
-- このスクリプトは何も実行しません
-- スクリプト開発の参考にしてください
