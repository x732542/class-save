---
name: writespec
description: 根據網頁內容撰寫規格文件
---
# 目的
- 透過閱讀與分析 HTML/JS 原始碼，產生該網頁的技術規格文件，並存檔於 `/spec/SPEC_{網頁主檔名}.md`。
- 此文件旨在提供開發者一個清晰的實作指引與維護參考，包含資料流、互動邏輯與 API 規格。

# 輸出文件格式
請嚴格依照以下 Markdown 結構進行輸出：

```markdown
# SPEC_{網頁主檔名}.md

來源檔案: `web/{網頁主檔名}.html`

---
## API 互動邏輯 (fetch)
針對頁面中每一個 API 呼叫（fetch/XHR），填寫以下資訊。
**重要：必須實際執行測試或查找現有 JSON 範例檔案來取得真實回傳結構。**

### 1. {API 名稱或用途}
* **請求資訊**
  - Method: `POST` / `GET`
  - URL: `{API_URL_VARIABLE}`
  - Headers: `Content-Type: application/json`, ...
  - Payload (Request Body):
    ```json
    {
      "key": "value description"
    }
    ```

* **回應內容 (Response)**
  - HTTP Status: `200 OK`
  - Body 範例 (請使用真實範例，內容完整列出，**不可擷取部份內容**):
    ```json
    [
      {
        "field1": "value",
        "complexObj": { ... }
      }
    ]
    ```
  - 資料解讀與處理邏輯：（說明前端收到資料後做了什麼重要的轉換，例如日期格式化、欄位計算、過濾無效資料等）

---
```