# 目的
建立猜數字的Stored Procefure，資料庫為SQL sever

# 資料庫結構
開啟‵GameER.png‵ 檔案，內容為ER

# 遊戲規則
打算設計一個玩猜數字比大小的遊戲，玩法是電腦隨機產生一個數字然後人來猜。如果猜錯，會傳回太大或太小的訊息，如果猜對會顯示猜對了

# Stored Procefure
## 1. 開局
-輸入 
    *uid
-輸出
    *game_id
    *target_number
-輸出方式
    *資料集
## 2. 每一回合
-輸入
    *game_id
    *guess_value
-輸出 
    *feedback
-輸出方式
    *資料集

