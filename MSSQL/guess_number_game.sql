IF OBJECT_ID('dbo.GuessLog', 'U') IS NOT NULL
    DROP TABLE dbo.GuessLog;
GO

IF OBJECT_ID('dbo.GameSession', 'U') IS NOT NULL
    DROP TABLE dbo.GameSession;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GameSession]
(
    [game_id] [int] IDENTITY(1,1) NOT NULL,
    [uid] [nvarchar](20) NOT NULL,
    [target_number] [int] NOT NULL,
    [start_time] [datetime2](7) NOT NULL DEFAULT SYSUTCDATETIME(),
    [end_time] [datetime2](7) NULL,
    [attempt_count] [int] NOT NULL DEFAULT((0)),
    [status] [nvarchar](20) NOT NULL DEFAULT(N'IN_PROGRESS'),
    [win_flag] [bit] NOT NULL DEFAULT((0)),
    CONSTRAINT [PK_GameSession] PRIMARY KEY CLUSTERED ([game_id] ASC)
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GameSession]
ADD CONSTRAINT [FK_GameSession_UserInfo]
FOREIGN KEY ([uid]) REFERENCES [dbo].[UserInfo] ([uid]);
GO

CREATE TABLE [dbo].[GuessLog]
(
    [guess_id] [int] IDENTITY(1,1) NOT NULL,
    [game_id] [int] NOT NULL,
    [guess_time] [datetime2](7) NOT NULL DEFAULT SYSUTCDATETIME(),
    [guess_value] [int] NOT NULL,
    [feedback] [nvarchar](20) NULL,
    CONSTRAINT [PK_GuessLog] PRIMARY KEY CLUSTERED ([guess_id] ASC)
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GuessLog]
ADD CONSTRAINT [FK_GuessLog_GameSession]
FOREIGN KEY ([game_id]) REFERENCES [dbo].[GameSession] ([game_id]);
GO

IF OBJECT_ID('dbo.sp_SetColumnDescription', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SetColumnDescription;
GO

CREATE PROCEDURE dbo.sp_SetColumnDescription
    @schema_name sysname,
    @table_name sysname,
    @column_name sysname,
    @description nvarchar(4000)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
    FROM sys.extended_properties ep
        INNER JOIN sys.tables t ON ep.major_id = t.object_id
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        INNER JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = ep.minor_id
    WHERE ep.class = 1
        AND s.name = @schema_name
        AND t.name = @table_name
        AND c.name = @column_name
        AND ep.name = N'MS_Description'
    )
    BEGIN
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = @description,
            @level0type = N'SCHEMA', @level0name = @schema_name,
            @level1type = N'TABLE', @level1name = @table_name,
            @level2type = N'COLUMN', @level2name = @column_name;
    END
    ELSE
    BEGIN
        EXEC sys.sp_updateextendedproperty
            @name = N'MS_Description',
            @value = @description,
            @level0type = N'SCHEMA', @level0name = @schema_name,
            @level1type = N'TABLE', @level1name = @table_name,
            @level2type = N'COLUMN', @level2name = @column_name;
    END
END;
GO

EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'game_id', N'遊戲場次識別碼';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'uid', N'玩家帳號';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'target_number', N'電腦隨機產生之答案';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'start_time', N'遊戲開始時間';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'end_time', N'遊戲結束時間';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'attempt_count', N'猜測次數';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'status', N'遊戲狀態（進行中/完成）';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GameSession', N'win_flag', N'是否猜中（0=否,1=是）';

EXEC dbo.sp_SetColumnDescription N'dbo', N'GuessLog', N'guess_id', N'猜測紀錄識別碼';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GuessLog', N'game_id', N'對應遊戲場次';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GuessLog', N'guess_time', N'猜測時間';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GuessLog', N'guess_value', N'玩家猜的數值';
EXEC dbo.sp_SetColumnDescription N'dbo', N'GuessLog', N'feedback', N'系統回饋（太大/太小/猜對了）';
GO

IF OBJECT_ID('dbo.sp_StartGuessNumberGame', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_StartGuessNumberGame;
GO

CREATE PROCEDURE dbo.sp_StartGuessNumberGame
    @uid nvarchar(20),
    @min_value int = 1,
    @max_value int = 100
AS
BEGIN
    SET NOCOUNT ON;

    IF @min_value >= @max_value
    BEGIN
        RAISERROR('min_value 必須小於 max_value。', 16, 1);
        RETURN;
    END

    DECLARE @target_number int = ABS(CHECKSUM(NEWID())) % (@max_value - @min_value + 1) + @min_value;
    DECLARE @game_id int;

    INSERT INTO dbo.GameSession
        ([uid], [target_number], [start_time], [attempt_count], [status], [win_flag])
    VALUES
        (@uid, @target_number, SYSUTCDATETIME(), 0, N'IN_PROGRESS', 0);

    SET @game_id = SCOPE_IDENTITY();

    SELECT
        @game_id AS game_id,
        @target_number AS target_number;
END;
GO

IF OBJECT_ID('dbo.sp_PlayGuessNumber', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_PlayGuessNumber;
GO

CREATE PROCEDURE dbo.sp_PlayGuessNumber
    @game_id int,
    @guess_value int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @target_number int;
    DECLARE @status nvarchar(20);
    DECLARE @attempt_count int;
    DECLARE @feedback nvarchar(20);
    DECLARE @is_correct bit;

    SELECT @target_number = target_number,
        @status = status,
        @attempt_count = attempt_count
    FROM dbo.GameSession
    WHERE game_id = @game_id;

    IF @target_number IS NULL
    BEGIN
        RAISERROR('找不到指定的遊戲場次。', 16, 1);
        RETURN;
    END

    IF @status <> N'IN_PROGRESS'
    BEGIN
        SELECT
            N'遊戲已結束' AS feedback,
            CAST(0 AS bit) AS is_correct;
        RETURN;
    END

    SET @attempt_count += 1;

    IF @guess_value < @target_number
    BEGIN
        SET @feedback = N'太小';
        SET @is_correct = 0;
    END
    ELSE IF @guess_value > @target_number
    BEGIN
        SET @feedback = N'太大';
        SET @is_correct = 0;
    END
    ELSE
    BEGIN
        SET @feedback = N'猜對了';
        SET @is_correct = 1;
    END

    INSERT INTO dbo.GuessLog
        ([game_id], [guess_value], [guess_time], [feedback])
    VALUES
        (@game_id, @guess_value, SYSUTCDATETIME(), @feedback);

    IF @is_correct = 1
    BEGIN
        UPDATE dbo.GameSession
        SET attempt_count = @attempt_count,
            end_time = SYSUTCDATETIME(),
            status = N'COMPLETED',
            win_flag = 1
        WHERE game_id = @game_id;
    END
    ELSE
    BEGIN
        UPDATE dbo.GameSession
        SET attempt_count = @attempt_count
        WHERE game_id = @game_id;
    END

    SELECT
        @feedback AS feedback,
        @is_correct AS is_correct;
END;
GO

IF OBJECT_ID('dbo.sp_GetGuessNumberGameStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetGuessNumberGameStatus;
GO

CREATE PROCEDURE dbo.sp_GetGuessNumberGameStatus
    @game_id int,
    @uid nvarchar(20) OUTPUT,
    @status nvarchar(20) OUTPUT,
    @attempt_count int OUTPUT,
    @win_flag bit OUTPUT,
    @start_time datetime2(7) OUTPUT,
    @end_time datetime2(7) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @uid = uid,
        @status = status,
        @attempt_count = attempt_count,
        @win_flag = win_flag,
        @start_time = start_time,
        @end_time = end_time
    FROM dbo.GameSession
    WHERE game_id = @game_id;

    IF @uid IS NULL
    BEGIN
        RAISERROR('找不到指定的遊戲場次。', 16, 1);
    END
END;
GO

