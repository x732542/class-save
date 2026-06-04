-- SELECT uid,cname from userinfo
-- WHERE left(cname,1) = '王'

-- SELECT uid,cname from userinfo
-- WHERE cname like  '王%'

-- SELECT uid,cname from userinfo
-- WHERE cname like '%王'
-- SELECT * from userinfo1 with(index(Index_UserInfo1_2)) 
-- WHERE  uid = 'A01'

-- -- SELECT * FROM BILL
-- SELECT dd FROM BILL where YEAR(dd) = 2026 and month(dd) = 1

-- SELECT * FROM BILL 
-- WITH(INDEX(Index_Bill_1))
-- where 
--     dd >= '2019/01/01' and dd < '2019/12/31'
--     and tel ='1111'
--     and fee > 100
-- ORDER BY dd,tel

-- SELECT * FROM BILL 
-- WITH(INDEX(Index_Bill_1))
-- where
--     dd >= '2019/01/01' and dd < '2019/12/31'
--     and tel ='1111'
--     and fee > 100
-- ORDER BY dd desc ,tel

-- SELECT dd FROM BILL where dd BETWEEN  '2026/01/01' and  '2026/1/31 23:59:59.999'

-- SELECT dd FROM BILL with(index(Index_Bill_1)) where dd >= '2026/01/01' and dd < '2026/02/01'
-- SELECT dd FROM BILL with(index(Index_Bill_1)) where dd BETWEEN  '2026/01/01' and  '2026/1/31 23:59:59.999'

SELECT * 
FROM  userinfo,Live,house 
WHERE userinfo.uid =live.uid
and live.hid = house.hid 
and userinfo.uid = 'A03'


SELECT * 
FROM  userinfo,Live,house
WHERE userinfo.uid =live.uid
and live.hid = house.hid 
and address like '台北市南京東路%'