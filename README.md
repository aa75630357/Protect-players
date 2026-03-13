Protect Players (保護球員) 2D
這是一款使用 Godot Engine 開發的 2D 橫向捲軸防護遊戲。玩家需要精確操作防護機制（如防護罩），在複雜且具備多重物理判定的環境中，保護移動中的目標球員，避免其受到障礙物的碰撞與傷害。

📂 專案核心目錄導覽
本專案已完成目錄結構重組，將核心檔案「解放」至根目錄，確保程式碼的可讀性與 Git 管理的標準化：

Assets/: 包含所有遊戲使用的 2D 像素美術素材與音效。

Scenes/:

Main.tscn: 遊戲主關卡場景，整合所有核心系統。

Player.tscn: 受保護的球員物件場景。

Scripts/ ⬅️ 【核心邏輯】面試官請點此檢視代碼

PlayerProtection.gd: 處理球員受傷判定、防護機制互動邏輯。

EnemySpawner.gd: 動態生成系統，依時間或條件生成不同類型障礙物。

project.godot: Godot 專案核心設定檔。

🛠 關鍵技術實現
在這個 Godot 專案中，我重點開發了以下技術模組：

1. 碰撞與防護系統 (Collision & Protection)
技術：熟練運用 Godot 的 Area2D 與 KinematicBody2D 節點。

實現：實作了「防護罩」與「球員」間的物理優先級，確保防護罩能完美阻擋障礙物，而不與球員產生衝突。

2. 動態生成與難度管理
技術：使用 Timer 與物件池 (Object Pooling) 的概念。

實現：建立障礙物生成器 (EnemySpawner.gd)，可根據遊戲進行時間動態調整生成頻率與速度。
