# Teamwork Project Prompt — Draft

> Status: Launched
> Goal: Craft prompt → get user approval → delegate to teamwork_preview

一個專為零起點華語學習者設計的 2D Godot 角色扮演遊戲（RPG）概念驗證 Demo。目標是開發一個可互動的教學房間，讓玩家透過與環境物件及 NPC 互動學習基礎華語。

Working directory: /Users/leo57/.gemini/antigravity/scratch/mandarin-learning-game
Integrity mode: development

## Requirements

### R1. 遊戲房間與角色互動 (Room and Character Interactions)
在 Godot 專案中完成一個教學房間。玩家可以使用鍵盤移動角色。房間中必須有 5 位 NPC，其中包含一位「小二」（waiter）與一位「店長」（shopkeeper）。當玩家走近 NPC 或按 E 鍵互動時，NPC 會透過氣泡 UI/對話框顯示華語學習相關的互動對話（例如：簡單的問答或提示，需正確顯示中文，無方塊亂碼）。
此外，房間內需有 3-4 個可互動的環境物品（例如：蘋果、劍等），玩家與之互動時能顯示其中文名稱與拼音。

### R2. Web 匯出與 GitHub Pages 網頁運作 (Web Export & GitHub Pages)
設定 Godot 專案支援 Web 平台匯出（使用 Compatibility 渲染器，以相容瀏覽器）。需在專案中配置好 Web 匯出預設（Export Presets）。當程式碼與場景推送到 GitHub 的 `main` 分支時，必須能透過自動化部署（如 GitHub Actions）將遊戲編譯為 HTML5 並部署至 GitHub Pages，確保任何人都能直接點擊連結遊玩。

### R3. 程式碼與版本管理同步 (Git & Version Control)
遵守 `AGENT_INSTRUCTIONS.md` 的規範。在做出任何腳本、場景、資產更動後，多智能體團隊必須自動且立即將所有變更 commit 並 push 到 GitHub 遠端倉庫。

## Acceptance Criteria

### 1. 網頁端執行與部署 (Web Execution & Deployment)
- [ ] 專案包含已配置好的 GitHub Actions 流程，且每次 push 至 `main` 後能自動、成功完成 Web 匯出編譯。
- [ ] 提供一個可公開訪問的 GitHub Pages 連結，網頁遊戲可順暢載入、點擊並在瀏覽器中遊玩。

### 2. 互動與教學功能 (Interaction & Learning Features)
- [ ] 房間場景中包含 5 位 NPC（含「小二」與「店長」），玩家能正常與其對話並觸發中文學習對答。
- [ ] 房間中包含至少 3 個可互動的教學物品，互動時氣泡 UI 正確以 Arial Unicode 字型顯示中文字元與拼音（無方塊字/亂碼）。
- [ ] 玩家能以鍵盤控制主角移動，並與所有 NPC 與互動資產進行碰撞偵測與功能觸發。

## Verification Plan

### Automated Tests
- 在 CI 流程中執行 Godot 4.x Headless Web 匯出指令，驗證編譯是否能成功結束且無錯誤代碼。

### Manual Verification
- 使用者與多智能體團隊透過訪問部署好的 GitHub Pages 連結，在瀏覽器中操作主角移動、與 5 位 NPC 對話、與物品互動，驗證畫面、字型及遊戲機制運作是否正常。

---
*Next: when approved → delegate via invoke_subagent (see Delegation Protocol)*
