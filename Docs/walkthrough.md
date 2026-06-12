# 專案整理、自動部署與美術/筆記本系統套用驗證紀錄

本文件紀錄了本次更新的完整實作與驗證結果，包含專案遺留檔案整理、GitHub Pages 自動部署更新、2D 透明美術素材套用，以及玩家學習筆記本系統的實作。

---

## 實作內容與變更說明

### 1. 專案目錄整理與封存
- **建立目錄**：建立了 `Archive/`、`Archive/Scenes/` 與 `Archive/Scripts/` 資料夾。
- **移動檔案**：
  - 將根目錄中不再使用的 Phase 1 場景 `main.tscn`、`npc.tscn`、`player.tscn` 移動至 `Archive/`。
  - 將舊版氣泡 UI `Scenes/BubbleUI.tscn` 移動至 `Archive/Scenes/`。
  - 將舊版相關腳本 `Scripts/BubbleUI.gd`、`Scripts/NPC.gd`、`Scripts/Player.gd`（及對應的 `.uid` 檔案）移動至 `Archive/Scripts/`。
- **清理效果**：專案根目錄目前僅剩核心設定檔及作用中的程式碼目錄，結構清晰，降低了開發者的認知負荷。

### 2. GitHub Pages 自動部署修復與升級
- **版本對齊**：將 `.github/workflows/deploy.yml` 中的 Godot CI 映像檔版本從 `4.3` 升級為 **`4.6.3`**，完全對齊本機運行的 Godot 4.6.3 版本，成功修復了因引擎版本不一致導致的匯出失敗。
- **部署方式升級**：將原先需要手動推送到 `gh-pages` 分支的 peaceiris 套件，修改為使用 GitHub 官方推薦的 **GitHub Actions Pages 部署 API**（`actions/upload-pages-artifact` & `actions/deploy-pages`）。
- **優勢**：無需污染 Git 分支，部署流程更安全且高效。

### 3. 美術素材套用與自適應縮放
為了在不破壞任何運作邏輯的前題下提升遊戲畫面質感，我們進行了以下動態套用設計：
- **玩家 (Player)**：
  - 在 `Player.tscn` 中隱藏 placeholder Polygon2D，新增 `Sprite2D` 節點。
  - 在 `PlayerController.gd` 載入 `res://Assets/Sprites/player.png`。並在 `_ready()` 中根據圖片的原始高度，**自動將其等比例縮放至高度 48 像素**，保存在遊戲畫面中的完美尺寸。
- **非玩家角色 (NPC)**：
  - 在 `NPC.tscn` 中隱藏 placeholder Polygon2D，新增 `Sprite2D` 節點。
  - 修改 `NPCController.gd`，新增 `@export var sprite_texture: Texture2D`。並在 `_ready()` 中進行高度 48 像素的等比例自適應縮放。
  - 在 `GroceryStore.gd` 初始化時，讀取並指派對應的美術圖（`shop_owner.png`, `assistant.png`, `customer_a.png`, `customer_b.png`, `customer_c.png`）給對應的 NPC。
- **貨架與物品 (Shelves & Items)**：
  - 在 `Shelf.tscn` 中新增 `Sprite2D`（貨架底圖）與 `ItemSprite`（上方代表的物品小圖示，位置置頂偏移 `Vector2(0, -12)`）。
  - 修改 `Shelf.gd`，新增對應的 `@export` 紋理欄位，並在 `_ready()` 中完成自動縮放（貨架寬度自動縮放至 144 像素，物品高度自動縮放至 32 像素）。
  - 在 `GroceryStore.gd` 中程式化指派各貨架的背景與所擺放的物品美術（ShelfApples 使用 `shelf_a.png` 與 `apple.png`；ShelfTea 使用 `shelf_b.png` 與 `tea.png`；ShelfWater 使用 `shelf_c.png` 與 `water.png`）。
- **地圖與櫃台**：
  - 將地圖上的 `Floor` 與 `Counter/CounterVisual` placeholder 改為 `Sprite2D`。
  - 於 `GroceryStore.gd` 初始化時，自動將 `floor.png` 縮放至 720x480 以鋪滿背景，並將 `counter.png` 縮放至 120x250 以套用在櫃台上。

### 4. 學習筆記本系統 (Player Notebook)
我們設計並實作了高質感的學習進度與筆記本系統：
- **觸發解鎖機制**：修改 `AudioManager.gd` 的 `play_vocabulary()` 函數。每次玩家靠近 NPC 或貨架互動並播發該單字發音時，系統會自動呼叫 `VocabularyDatabase.mark_learned(id)`，將該詞彙標記為 `learned = true`。
- **筆記本介面 (NotebookUI & NotebookWordItem)**：
  - **NotebookUI.tscn**：遮罩背景與高質感面板。包含標題、單字滾動區域與關閉提示。
  - **NotebookWordItem.tscn**：單個詞彙列。若**已解鎖**，會完整顯示「中文字、(漢語拼音)、英文意譯」，並提供「🔊 播放按鈕」可再次點選聆聽發音。若**未解鎖**，則會顯示為鎖定狀態（`???` 與 `[ 未解鎖 ]`）。
- **切換與翻頁音效**：
  - 在 `PlayerController.gd` 監聽 **`Tab` 鍵** 按下。
  - 開啟與關閉筆記本時，會暫停/恢復遊戲，並透過 AudioManager 播放筆記本翻頁的音效 `res://Assets/SFX/notebook_flip.wav`。

---

## 驗證結果
1. **編譯驗證**：於本機使用 Godot 4.6.3 執行 headless Web 匯出指令，編譯輸出無任何依賴性缺失錯誤或引擎警告。
2. **Git 工作區檢查**：舊檔案皆已移至 `Archive/`，新場景與程式碼全部就緒。
