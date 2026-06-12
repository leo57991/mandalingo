# 專案整理、自動部署與美術/筆記本套用任務

## 1. 專案整理與封存
- [ ] 建立 `Archive/`、`Archive/Scenes/`、`Archive/Scripts/` 資料夾
- [ ] 移動根目錄舊場景 (`main.tscn`, `npc.tscn`, `player.tscn`) 到 `Archive/`
- [ ] 移動 `Scenes/BubbleUI.tscn` 到 `Archive/Scenes/`
- [ ] 移動 `Scripts/BubbleUI.gd`、`Scripts/NPC.gd`、`Scripts/Player.gd`（及 `.uid` 檔）到 `Archive/Scripts/`

## 2. GitHub Pages 部署修復
- [ ] 修改 `.github/workflows/deploy.yml`：
  - [ ] 升級 CI 映像檔為 `barichello/godot-ci:4.6.3`
  - [ ] 更新權限（`pages: write`, `id-token: write`）
  - [ ] 使用官方 `actions/upload-pages-artifact` 與 `actions/deploy-pages` 部署

## 3. 美術資源套用與自適應縮放
- [ ] 更新 `Player.tscn`：
  - [ ] 隱藏/停用 `PlaceholderBody` (Polygon2D)
  - [ ] 新增 `Sprite2D` 並設定為 `player.png`
- [ ] 更新 `PlayerController.gd`：
  - [ ] 在 `_ready()` 中讀取 `Sprite2D`，根據紋理高度自動縮放至 48 像素高
- [ ] 更新 `NPC.tscn`：
  - [ ] 隱藏/停用 `PlaceholderBody` (Polygon2D)
  - [ ] 新增 `Sprite2D` 節點
- [ ] 更新 `NPCController.gd`：
  - [ ] 新增 `@export var sprite_texture: Texture2D`
  - [ ] 在 `_ready()` 中套用並自動縮放至 48 像素高
- [ ] 更新 `Shelf.tscn`：
  - [ ] 隱藏/停用 `PlaceholderShelf` (Polygon2D)
  - [ ] 新增 `Sprite2D` (貨架背景) 與 `ItemSprite` (上方物品圖示) 節點
- [ ] 更新 `Shelf.gd`：
  - [ ] 新增 `@export var shelf_texture: Texture2D` 與 `@export var item_texture: Texture2D`
  - [ ] 在 `_ready()` 中設定紋理並自動縮放（貨架寬 144 像素，物品高 32 像素，物品置頂偏移）
- [ ] 更新 `GroceryStore.tscn`：
  - [ ] 將 `Floor` (Polygon2D) 改為 `Sprite2D`，套用 `floor.png`
  - [ ] 將 `Counter/CounterVisual` (Polygon2D) 改為 `Sprite2D`，套用 `counter.png`
  - [ ] 為各 NPC 實例（林阿姨、小安、美美、阿明、小雨）設定對應的美術貼圖
  - [ ] 為各貨架實例（ShelfApples, ShelfTea, ShelfWater）設定對應的貨架與物品貼圖
- [ ] 更新 `GroceryStore.gd`：
  - [ ] 在 `_ready()` 中自動縮放 `Floor` 至 720x480，縮放 `CounterVisual` 至 120x250

## 4. 學習進度與筆記本系統 (Player Notebook)
- [ ] 修改 `AudioManager.gd`：
  - [ ] 在播放單字發音時，自動調用 `VocabularyDatabase.mark_learned(id)` 解鎖單字
- [ ] 建立筆記本 UI：
  - [ ] 建立腳本 `Scripts/UI/NotebookWordItem.gd`
  - [ ] 建立場景 `Scenes/UI/NotebookWordItem.tscn` (顯示單字、拼音、英文，以及發音播放按鈕，未解鎖顯示為 `???`)
  - [ ] 建立腳本 `Scripts/UI/NotebookUI.gd` (控制筆記本開啟/關閉、暫停遊戲、播放翻頁音效、載入單字列表)
  - [ ] 建立場景 `Scenes/UI/NotebookUI.tscn` (包含標題、滾動列表、關閉按鈕與提示)
- [ ] 將 `NotebookUI` 實例加入到 `GroceryStore.tscn`
- [ ] 更新 `PlayerController.gd`：
  - [ ] 監聽 `Tab` 鍵 (或 `ui_focus_next`) 按下，用來切換筆記本 UI 的開啟與關閉
