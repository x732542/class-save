CREATE view vw_NewUserInfo as
SELECT UID, CNAME
FROM UserInfo
UNION ALL
    SELECT 'B01','宗經理'
UNION     
    SELECT 'A01','王大明'