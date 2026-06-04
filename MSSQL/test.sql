-- SELECT QUARTER, sum(sum_fee) as sum_fee
-- from (
--     SELECT *
--     from vw_2019port
-- union all SELECT 1, 0
-- union all SELECT 2, 0
-- union all SELECT 3, 0
-- union all SELECT 4, 0) as x
-- GROUP BY quarter

-- if exists (select 1 from UserInfo where uid = 'A05')
--     update UserInfo
--     set cname = '香蕉', birthday = dateadd(day, -1, convert(date, getdate()))
--     where uid = 'A05';
-- else
--     insert into UserInfo (uid,cname,birthday)
--     values ('A05', '香蕉', dateadd(day, -1, convert(date, getdate())));
-- SELECT * FROM UserInfo

-- SELECT case
--     when FLOOR(month(dd)/ 7.0) = 0 then'上半年'
--     when FLOOR(month(dd)/ 7.0) = 1 then'下半年'
-- end as half_year ,sum(fee) as sum_fee
-- FROM Bill
-- WHERE YEAR(dd) = 2019
-- GROUP by FLOOR(month(dd)/ 7.0)

-- SELECT * FroM UserInfo

-- IF OBJECT_ID('dbo.trg_UserInfo_Insert_Log', 'TR') IS NOT NULL
-- DROP TRIGGER dbo.trg_UserInfo_Insert_Log;
-- GO

-- CREATE TRIGGER dbo.trg_UserInfo_Insert_Log
-- ON dbo.UserInfo
-- AFTER INSERT
-- AS
-- BEGIN
-- SET NOCOUNT ON;
-- INSERT INTO dbo.Log (body)
--     SELECT
--         N'Inserted UserInfo: uid=' + ISNULL(i.uid, N'<NULL>')
--         + N', cname=' + ISNULL(i.cname, '878787')
--         + N', birthday=' + ISNULL(CONVERT(nvarchar(30), i.birthday, 121), N'<NULL>')
--     FROM inserted AS i;

-- END;
-- GO

-- SELECT* FROM UserInfo
-- SELECT* FROM log

-- IF OBJECT_ID('dbo.trg_UserInfo_Activity', 'TR') IS NOT NULL
--     DROP TRIGGER dbo.trg_UserInfo_Activity;
-- GO

-- CREATE TRIGGER dbo.trg_UserInfo_Activity
-- ON dbo.UserInfo
-- AFTER INSERT, UPDATE, DELETE
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     INSERT INTO dbo.Log (body)
--     SELECT
--         N'UserInfo INSERT uid=' + ISNULL(i.uid, N'<NULL>')
--         + N', cname=' + ISNULL(i.cname, N'<NULL>')
--         + N', password=' + ISNULL(i.[password], N'<NULL>')
--         + N', birthday=' + ISNULL(CONVERT(nvarchar(30), i.birthday, 121), N'<NULL>')
--     FROM inserted AS i
--     WHERE NOT EXISTS (
--         SELECT 1 FROM deleted AS d WHERE d.uid = i.uid
--     );

--     INSERT INTO dbo.Log (body)
--     SELECT
--         N'UserInfo UPDATE old_uid=' + ISNULL(d.uid, N'<NULL>')
--         + N', old_cname=' + ISNULL(d.cname, N'<NULL>')
--         + N', old_password=' + ISNULL(d.[password], N'<NULL>')
--         + N', old_birthday=' + ISNULL(CONVERT(nvarchar(30), d.birthday, 121), N'<NULL>')
--         + N' -> new_uid=' + ISNULL(i.uid, N'<NULL>')
--         + N', new_cname=' + ISNULL(i.cname, N'<NULL>')
--         + N', new_password=' + ISNULL(i.[password], N'<NULL>')
--         + N', new_birthday=' + ISNULL(CONVERT(nvarchar(30), i.birthday, 121), N'<NULL>')
--     FROM deleted AS d
--     INNER JOIN inserted AS i
--         ON d.uid = i.uid;

--     INSERT INTO dbo.Log (body)
--     SELECT
--         N'UserInfo DELETE uid=' + ISNULL(d.uid, N'<NULL>')
--         + N', cname=' + ISNULL(d.cname, N'<NULL>')
--         + N', password=' + ISNULL(d.[password], N'<NULL>')
--         + N', birthday=' + ISNULL(CONVERT(nvarchar(30), d.birthday, 121), N'<NULL>')
--     FROM deleted AS d
--     WHERE NOT EXISTS (
--         SELECT 1 FROM inserted AS i WHERE i.uid = d.uid
--     );
-- END;
-- GO

-- IF OBJECT_ID('dbo.trg_UserInfo_BlockMultiPasswordUpdate', 'TR') IS NOT NULL
--     DROP TRIGGER dbo.trg_UserInfo_BlockMultiPasswordUpdate;
-- GO

-- CREATE TRIGGER dbo.trg_UserInfo_BlockMultiPasswordUpdate
-- ON dbo.UserInfo
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     IF UPDATE([password])
--     BEGIN
--         DECLARE @PasswordChangeCount INT;

--         SELECT @PasswordChangeCount =
--             COUNT(*)
--         FROM inserted i
--         INNER JOIN deleted d
--             ON i.uid = d.uid
--         WHERE ISNULL(i.[password], N'') <> ISNULL(d.[password], N'');

--         IF @PasswordChangeCount > 1
--         BEGIN
--             RAISERROR('一次更新不得修改兩筆以上 UserInfo.password。', 16, 1);
--             ROLLBACK TRANSACTION;
--             RETURN;
--         END
--     END
-- END;
-- GO

-- UPDATE UserInfo set [password] =null

-- DROP proc if EXISTS insertInfoData 
-- go

-- CREATE proc insertInfoData
--     @prefix NVARCHAR(10),
--     @times int
-- as
-- BEGIN

--     declare @i  int =@times
--     DECLARE @uid NVARCHAR(50)= null

--     WHILE @i > 0
--     BEGIN
--         SET @uid = CONCAT('0000',@i)
--         SET @uid = CONCAT(@prefix, RIGHT(@uid,5))
--         INSERT into UserInfo
--             (uid,cname)
--         VALUES( @uid, @uid   
--     )
--         set @i =@i-1
--     end
-- end

-- SELECT *
-- FROM UserInfo

-- exec sp_databases
-- exec sp_tables @table_qualifier='AddressBook', @table_owner='dbo'

-- IF OBJECT_ID('dbo.sp_CheckUserLogin', 'P') IS NOT NULL
--     DROP PROCEDURE dbo.sp_CheckUserLogin;
-- GO

-- CREATE PROCEDURE dbo.sp_CheckUserLogin
--     @uid nvarchar(20),
--     @pwd nvarchar(64)
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     SELECT
--         CASE
--             WHEN EXISTS (
--                 SELECT 1
--                 FROM dbo.UserInfo
--                 WHERE uid = @uid
--                   AND ISNULL([password], N'') = ISNULL(@pwd, N'')
--             )
--             THEN 1
--             ELSE 0
--         END AS status;
-- END;
-- GO

-- IF OBJECT_ID('dbo.sp_AddUserWithAddress', 'P') IS NOT NULL
--     DROP PROCEDURE dbo.sp_AddUserWithAddress;
-- GO

-- EXEC(N'
-- CREATE PROCEDURE dbo.sp_AddUserWithAddress
--     @uid nvarchar(20),
--     @password nvarchar(64),
--     @address nvarchar(100)
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     SET XACT_ABORT ON;

--     DECLARE @hashedPassword nvarchar(64);
--     DECLARE @hid int;
--     DECLARE @user_action nvarchar(10);

--     IF NULLIF(LTRIM(RTRIM(@uid)), N'''''''') IS NULL
--     BEGIN
--         RAISERROR(N''uid 不可為空。'', 16, 1);
--         RETURN;
--     END

--     IF NULLIF(LTRIM(RTRIM(@password)), N'''''''') IS NULL
--     BEGIN
--         RAISERROR(N''password 不可為空。'', 16, 1);
--         RETURN;
--     END

--     IF NULLIF(LTRIM(RTRIM(@address)), N'''''''') IS NULL
--     BEGIN
--         RAISERROR(N''address 不可為空。'', 16, 1);
--         RETURN;
--     END

--     SET @hashedPassword =
--         LOWER(CONVERT(nvarchar(64), HASHBYTES(''SHA2_256'', CONVERT(nvarchar(400), @password)), 2));

--     BEGIN TRY
--         BEGIN TRANSACTION;

--         IF EXISTS (
--             SELECT 1
--             FROM dbo.UserInfo
--             WHERE uid = @uid
--         )
--         BEGIN
--             UPDATE dbo.UserInfo
--             SET [password] = @hashedPassword
--             WHERE uid = @uid;

--             SET @user_action = N''UPDATE'';
--         END
--         ELSE
--         BEGIN
--             INSERT INTO dbo.UserInfo ([uid], [cname], [password], [birthday])
--             VALUES (@uid, NULL, @hashedPassword, NULL);

--             SET @user_action = N''INSERT'';
--         END

--         INSERT INTO dbo.House ([address])
--         VALUES (@address);

--         SET @hid = SCOPE_IDENTITY();

--         INSERT INTO dbo.Live ([uid], [hid])
--         VALUES (@uid, @hid);

--         COMMIT TRANSACTION;

--         SELECT
--             @uid AS uid,
--             @hid AS hid,
--             @user_action AS user_action;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;

--         THROW;
--     END CATCH;
-- END;
-- ');
-- GO

-- exec sp_AddUserWithAddress 'A08','1234','地址'

-- select * from UserInfo
-- -- exec sp_StartGuessNumberGame 'A02'

-- -- exec sp_PlayGuessNumber 6,5

-- DECLARE c CURSOR for 
--     SELECT uid, cname,birthday
--     from UserInfo
--     WHERE uid like 'A%' and [password] is  null
-- DECLARE @uid NVARCHAR(5)
-- DECLARE @cname NVARCHAR(5)
-- DECLARE @birthday DATETIME2
-- DECLARE @password NVARCHAR(64)

-- OPEN c
-- FETCH c into @uid,@cname,@birthday
-- while (@@FETCH_STATUS = 0)
-- BEGIN
--     set @password =  concat(RIGHT(@uid,2),FORMAT(@birthday,'MMdd'))
--     UPDATE UserInfo set [password] = @password where uid =@uid
--     PRINT(CONCAT(@uid,':',@cname))
--     FETCH c into @uid,@cname,@birthday
-- end

-- CLOSE c
-- DEALLOCATE c

-- SELECT * from UserInfo where uid like'A%'

-- update UserInfo set birthday = '2000/01/01' where uid like 'A01'
-- update UserInfo set birthday = '2000/11/11' where uid like 'A02'
-- update UserInfo set birthday = '2000/02/05' where uid like 'A03'
-- update UserInfo set birthday = '2000/03/08' where uid like 'A04'
-- update UserInfo set birthday = '2000/04/19' where uid like 'A05'
-- update UserInfo set birthday = '2000/09/01' where uid like 'A06'

-- set TRANSACTION ISOLATION LEVEL serializable
-- BEGIN TRAN
--     SELECT * from Product where Id = 1
--     WAITFOR delay '0:0:5'
--     UPDATE Product set quantity = 30 WHere Id = 1
--     commit

-- set transaction isolation level snapshot;
-- begin tran
-- select * from UserInfo where uid = 'A01';
-- waitfor delay '0:0:10';
-- update UserInfo set cname = 'Tom' where uid = 'A01';
-- commit;

-- SELECT * from UserInfo1 WHere uid ='A01' 