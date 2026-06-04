select * into test from UserInfo where uid like 'A%'
SELECT * from test

BEGIN TRANSACTION
    UPDATE test
    set [password] ='1234'
    SELECT * from test
    ROLLBACK
    -- COMMIT