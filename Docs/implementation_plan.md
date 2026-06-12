# 專案整理與 GitHub Pages 404 修復計畫

本計畫旨在解決以下問題：
1. **GitHub Pages 404 錯誤**：修復 `https://leo57991.github.io/mandalingo/` 的存取問題。
2. **專案資料夾整理**：將 root 目錄及 `Scenes/`、`Scripts/` 中已不再使用的 Phase 1 遺留/測試檔案移至 `Archive/` 資料夾，使專案結構清晰。

---

## ⚠️ User Review Required

> [!IMPORTANT]
> 為了讓新的 GitHub Actions 部署方式生效，您需要在 GitHub 儲存庫的設定中進行一項微調：
> 1. 前往您的 GitHub Repository 設定頁面：**Settings > Pages**
> 2. 在 **Build and deployment** 下方的 **Source** 選擇框中，將 **"Deploy from a branch"** 改為 **"GitHub Actions"**。
>
> 這樣一來，GitHub 就能直接使用我們設定的 workflow 進行自動化部署，而不需要再透過獨立的 `gh-pages` 分支，能有效解決 404 錯誤，也讓部署流程更為簡潔。

---

## Proposed Changes

### 1. GitHub Actions 部署修復與升級

我們會更新 `.github/workflows/deploy.yml` 檔，並進行以下調整：
- 將 Godot CI 的映像檔版本由 `barichello/godot-ci:4.3` 升級為 **`barichello/godot-ci:4.6.3`**，以匹配您本機運行的 Godot 4.6.3 版本，防止因版本不一致導致的匯出失敗。
- 將部署方式切換為官方推薦的 **GitHub Actions 部署 API**（使用 `actions/upload-pages-artifact` 和 `actions/deploy-pages`），這能避免污染分支並省去手動設定權杖的繁瑣步驟。

#### [MODIFY] [.github/workflows/deploy.yml](file:///Users/leo57/Documents/Codex/2026-06-11/mandalingo-godot/mandarin-learning-game/.github/workflows/deploy.yml)
- 升級 `image` 為 `barichello/godot-ci:4.6.3`。
- 修改 `permissions`，新增 `pages: write` 與 `id-token: write`。
- 使用官方部署 Actions 代替 `peaceiris/actions-gh-pages`。

---

### 2. 專案資料夾整理 (封存遺留檔案)

我們將建立一個 `Archive/` 目錄，將不再使用的舊版場景與腳本移入其中，維持開發目錄的乾淨。

#### [NEW] [Archive/](file:///Users/leo57/Documents/Codex/2026-06-11/mandalingo-godot/mandarin-learning-game/Archive/)
- 建立此目錄，並在其下建立對應的 `Scenes/` 與 `Scripts/` 子資料夾來分類保存舊檔案。

#### [MODIFY] 移置以下檔案至封存區：
- **專案根目錄 (Root)**:
  - `main.tscn` ➡️ `Archive/main.tscn`
  - `npc.tscn` ➡️ `Archive/npc.tscn`
  - `player.tscn` ➡️ `Archive/player.tscn`
- **場景目錄 (Scenes/)**:
  - `Scenes/BubbleUI.tscn` ➡️ `Archive/Scenes/BubbleUI.tscn`
- **腳本目錄 (Scripts/)**:
  - `Scripts/BubbleUI.gd` ➡️ `Archive/Scripts/BubbleUI.gd` (及其 `.uid` 檔)
  - `Scripts/NPC.gd` ➡️ `Archive/Scripts/NPC.gd` (及其 `.uid` 檔)
  - `Scripts/Player.gd` ➡️ `Archive/Scripts/Player.gd` (及其 `.uid` 檔)

---

## Verification Plan

### Automated Tests
- 本地匯出測試：執行 Godot 4.6.3 headless 匯出指令，確認能順利生成 Web 版本，無遺失依賴報錯。
  ```bash
  "/Users/leo57/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot" --headless --export-release "Web" test_build/index.html
  ```

### Manual Verification
- 將所有整理後的變更與 workflow 更新 Commit 並 Push 到 GitHub 上。
- 請使用者配合將 GitHub Pages 設定的 Source 切換為 **"GitHub Actions"**。
- 確認 GitHub Actions 流程執行成功，且 `https://leo57991.github.io/mandalingo/` 可以正常進入且不再顯示 404。
