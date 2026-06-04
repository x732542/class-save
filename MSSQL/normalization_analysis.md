# AddressBook Schema Normalization Analysis

## 結論
整體設計至少達到 **第三正規化 (3NF)**。

部分表格應該已經符合 **BCNF**，但 `Bill` 表可能僅維持在 **3NF**，因為 `tel` 這類欄位很可能是非超鍵的決定因子。

## 各表評估

- `UserInfo`: PK = `uid`，欄位 `birthday`、`cname`、`password` 皆直接依賴於主鍵。 3NF / BCNF
- `HeadPhoto`: PK = `uid`（同時 FK），欄位 `photo` 直接依賴於主鍵。 3NF / BCNF
- `House`: PK = `hid`，欄位 `address` 直接依賴於主鍵。 3NF / BCNF
- `Live`: 可能為複合 PK (`hid`,`uid`) 的關聯表，沒有額外非鍵屬性。 3NF / BCNF
- `Phone`: PK 可能是 `tel`，`hid` 為外鍵。 若 `tel` 為主鍵，則也為 BCNF
- `Log`: PK = `id`，剩餘欄位 `body`、`dd` 直接依賴主鍵。 3NF / BCNF
- `Bill`: 若主鍵為 `(dd, tel)` 或類似，則 `hid` 很可能由 `tel` 決定；此情形下仍符合 3NF，但不一定符合 BCNF。

## 具體判斷

- 大多數表的所有非鍵欄位都僅依賴於該表的候選鍵，因此可視為 BCNF。
- 若要嚴格判斷整體資料庫正規化等級，必須確認每個表的主鍵定義和所有函數相依關係。
- 目前最安全的結論是：「整體至少已達到 3NF，部分表甚至已達 BCNF。」
