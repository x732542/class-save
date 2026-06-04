/*============================================================
  個人健康管理系統 - DDL
  教師：朱克剛
  組別：EEIT22 資料庫報告組
  日期：2026-04-17
  檔案：01_schema.sql

  命名規範（對齊朱老師 AddressBook.sql 風格）：
  - 表名  PascalCase
  - 欄位  lowercase
  - 參數  @camelCase（SP 檔使用）
  - 型別  datetime2(7) / nvarchar(64) for SHA256
  - 無 usp_ 前綴
  - 0 Trigger（老師明示初學不推）
  - BMI 使用 Computed Column (persisted) 取代 Trigger
============================================================*/

USE master;
GO

-- 安全重建 DB
IF DB_ID('HealthDB') IS NOT NULL
BEGIN
    ALTER DATABASE HealthDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HealthDB;
END
GO

CREATE DATABASE HealthDB;
GO

USE HealthDB;
GO

/*------------------------------------------------------------
  表 1：Users  使用者主表
------------------------------------------------------------*/
CREATE TABLE Users (
    uid         nvarchar(20)  NOT NULL,                                -- 帳號
    cname       nvarchar(50)  NOT NULL,                                -- 姓名
    gender      char(1)       NOT NULL,                                -- 'M' / 'F'
    birthday    date          NOT NULL,                                -- 生日
    phone       nvarchar(20)  NULL,                                    -- 電話
    password    nvarchar(64)  NOT NULL,                                -- SHA2_256 hex
    createdtime datetime2(7)  NOT NULL
        CONSTRAINT DF_Users_createdtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Users PRIMARY KEY (uid),
    CONSTRAINT CK_Users_gender CHECK (gender IN ('M','F'))
);
GO

/*------------------------------------------------------------
  表 2：HealthLog  身體測量紀錄
  BMI 使用 Computed Column (persisted) 自動計算
------------------------------------------------------------*/
CREATE TABLE HealthLog (
    metricid     int           IDENTITY(1,1) NOT NULL,                 -- 流水號
    uid          nvarchar(20)  NOT NULL,                               -- FK → Users.uid
    height       decimal(5,2)  NOT NULL,                               -- 身高 cm
    weight       decimal(5,2)  NOT NULL,                               -- 體重 kg
    bmi          AS (weight / ((height/100.0) * (height/100.0))) PERSISTED,
    measuredtime datetime2(7)  NOT NULL
        CONSTRAINT DF_HealthLog_measuredtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_HealthLog PRIMARY KEY (metricid),
    CONSTRAINT FK_HealthLog_Users FOREIGN KEY (uid) REFERENCES Users(uid),
    CONSTRAINT CK_HealthLog_height CHECK (height > 0 AND height < 300),
    CONSTRAINT CK_HealthLog_weight CHECK (weight > 0 AND weight < 500)
);
GO

CREATE INDEX idx_healthlog_uid  ON HealthLog(uid);
CREATE INDEX idx_healthlog_time ON HealthLog(measuredtime);
GO

/*------------------------------------------------------------
  表 3：Goals  目標設定
  goaltype：'weight'（減重目標）/ 'calorie'（每日熱量目標）
  isactive：同使用者同類型只能有 1 筆 isactive=1（由 set_goal SP 控制）
------------------------------------------------------------*/
CREATE TABLE Goals (
    goalid      int           IDENTITY(1,1) NOT NULL,
    uid         nvarchar(20)  NOT NULL,
    goaltype    nvarchar(20)  NOT NULL,
    targetvalue decimal(7,2)  NOT NULL,                                -- 目標值（kg 或 kcal）
    targetdate  date          NOT NULL,                                -- 目標日期
    isactive    bit           NOT NULL
        CONSTRAINT DF_Goals_isactive DEFAULT (1),
    createdtime datetime2(7)  NOT NULL
        CONSTRAINT DF_Goals_createdtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Goals PRIMARY KEY (goalid),
    CONSTRAINT FK_Goals_Users FOREIGN KEY (uid) REFERENCES Users(uid),
    CONSTRAINT CK_Goals_goaltype CHECK (goaltype IN ('weight','calorie')),
    CONSTRAINT CK_Goals_targetvalue CHECK (targetvalue > 0)
);
GO

CREATE INDEX idx_goals_uid    ON Goals(uid);
CREATE INDEX idx_goals_active ON Goals(uid, isactive);
GO

/*------------------------------------------------------------
  表 4：FoodLog  飲食紀錄
------------------------------------------------------------*/
CREATE TABLE FoodLog (
    foodid   int           IDENTITY(1,1) NOT NULL,
    uid      nvarchar(20)  NOT NULL,
    foodname nvarchar(100) NOT NULL,                                   -- 食物名稱
    calories int           NOT NULL,                                   -- 熱量 kcal
    mealtime datetime2(7)  NOT NULL
        CONSTRAINT DF_FoodLog_mealtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_FoodLog PRIMARY KEY (foodid),
    CONSTRAINT FK_FoodLog_Users FOREIGN KEY (uid) REFERENCES Users(uid),
    CONSTRAINT CK_FoodLog_calories CHECK (calories >= 0)
);
GO

CREATE INDEX idx_foodlog_uid  ON FoodLog(uid);
CREATE INDEX idx_foodlog_time ON FoodLog(mealtime);
GO

/*------------------------------------------------------------
  表 5：Activity  運動紀錄
  caloriesburn = met × 體重 × (durationmin / 60.0)
  （由 add_activity SP 計算後寫入，不用 Computed Column
    因為 Activity 自己沒有體重欄位，需要 JOIN HealthLog）
------------------------------------------------------------*/
CREATE TABLE Activity (
    actid        int           IDENTITY(1,1) NOT NULL,
    uid          nvarchar(20)  NOT NULL,
    exetype      nvarchar(50)  NOT NULL,                               -- 跑步/重訓/游泳...
    met          decimal(4,2)  NOT NULL,                               -- MET 值
    durationmin  int           NOT NULL,                               -- 時長 min
    caloriesburn decimal(7,2)  NOT NULL,                               -- 消耗 kcal（SP 計算）
    acttime      datetime2(7)  NOT NULL
        CONSTRAINT DF_Activity_acttime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Activity PRIMARY KEY (actid),
    CONSTRAINT FK_Activity_Users FOREIGN KEY (uid) REFERENCES Users(uid),
    CONSTRAINT CK_Activity_met CHECK (met > 0),
    CONSTRAINT CK_Activity_durationmin CHECK (durationmin > 0)
);
GO

CREATE INDEX idx_activity_uid  ON Activity(uid);
CREATE INDEX idx_activity_time ON Activity(acttime);
GO

/*------------------------------------------------------------
  表 6：Log  系統稽核表
  獨立表，不 FK 任何表（稽核表原則：即使 Users 被刪也要留紀錄）
  由 SP 主動寫入（取代 Trigger）
------------------------------------------------------------*/
CREATE TABLE Log (
    logid     int           IDENTITY(1,1) NOT NULL,
    tablename nvarchar(50)  NOT NULL,                                  -- 被動作的表名
    action    nvarchar(20)  NOT NULL,                                  -- insert/update/delete
    actor     nvarchar(20)  NULL,                                      -- 操作者帳號（純字串，不 FK）
    newdata   nvarchar(500) NULL,                                      -- 寫入內容摘要
    logtime   datetime2(7)  NOT NULL
        CONSTRAINT DF_Log_logtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Log PRIMARY KEY (logid),
    CONSTRAINT CK_Log_action CHECK (action IN ('insert','update','delete'))
);
GO

CREATE INDEX idx_log_time  ON Log(logtime);
CREATE INDEX idx_log_actor ON Log(actor);
GO

/*------------------------------------------------------------
  驗證訊息
------------------------------------------------------------*/
PRINT N'============================================================';
PRINT N' HealthDB schema 建立完成';
PRINT N' 6 張表 · 10 條 index · 0 Trigger · 1 Computed Column';
PRINT N'============================================================';
GO

-- 列出所有表
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME;
GO
