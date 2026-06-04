---
name: readdatabaseschema
description: Generate SQL Server statements from the AddressBook database schema based on user prompts.
---

# 目的
- 根據 AddressBook 資料庫結構與使用者提示，產生可執行的 SQL Server 指令。

# 使用情境
- 使用者在 SQL 檔案中撰寫需求描述。
- 依據 `localhost - AddressBook - dbo.png` 的 ER 圖與資料庫架構回應 SQL。

# 輸出要求
- 只輸出 SQL 指令，不要額外說明或分析文字。
- SQL 指令必須美化。
- 查詢、插入、更新、刪除需求各輸出一個正確的 SQL 指令。
- 若沒有選取檔案，預設填入 `test.sql`。
- `Create` 指令需加上若物件存在則先刪除再建的檢查。
- 不要在指令中加上 `AddressBook.dbo` 前綴。
- 資料表與欄位名稱除非在提示詞中明確指定，否則不要使用別名。
- 極端值查詢（例如最多、最少、最大、最小）應使用 `TOP 1 WITH TIES`。

# 限制
- 不要讀取或依據任何 `.sql` 檔案內容作為資料庫結構的參考。
- 資料庫結構由 `localhost - AddressBook - dbo.png` 決定。

# 測試與驗證
- 只有 DQL (`SELECT`) 結果需使用 `sqlcmd` 驗證語法正確性。

## Windows
```powershell
sqlcmd -S localhost\SQLEXPRESS -E -d AddressBook -Q "{SQL COMMAND}"
```

## macOS
```bash
sqlcmd \
  -S localhost \
  -U sa \
  -P $SQLSERVER_PWD \
  -d AddressBook \
  -Q "{SQL COMMAND}"
```
