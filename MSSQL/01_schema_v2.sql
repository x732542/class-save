/*============================================================
  個人健康管理系統 - DDL v2（支援佛系模式）
  教師：朱克剛
  組別：EEIT22 資料庫報告組
  日期：2026-04-17
  檔案：01_schema_v2.sql

  v2 變更：
  [1] Users 加 usermode 欄位：'goal' 目標導向 / 'record' 佛系記錄
  [2] Users 加 tdee 欄位：預估每日總消耗（用於目標模式卡路里建議）
  [3] HealthLog.bmi 型別改為 decimal(5,2)（原本 numeric(38,21) 過長）
  [4] Goals 加 isachieved 欄位：目標是否已達成（供週報顯示）
  [5] Log.action 擴充：加入 'mode_switch' 紀錄使用者切換模式
============================================================*/

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE master;
GO

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

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*------------------------------------------------------------
  階段 1：建立所有表
------------------------------------------------------------*/

-- 表 1：Users  使用者主表（v2：新增 usermode、tdee）
CREATE TABLE Users (
    uid         nvarchar(20)  NOT NULL,
    cname       nvarchar(50)  NOT NULL,
    gender      char(1)       NOT NULL,
    birthday    date          NOT NULL,
    phone       nvarchar(20)  NULL,
    password    nvarchar(64)  NOT NULL,
    usermode    nvarchar(10)  NOT NULL                                 -- 'goal' / 'record'
        CONSTRAINT DF_Users_usermode DEFAULT ('goal'),
    tdee        int           NULL,                                    -- 預估每日總消耗 kcal（可選填）
    createdtime datetime2(7)  NOT NULL
        CONSTRAINT DF_Users_createdtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Users PRIMARY KEY (uid),
    CONSTRAINT CK_Users_gender   CHECK (gender IN ('M','F')),
    CONSTRAINT CK_Users_usermode CHECK (usermode IN ('goal','record'))
);
GO

-- 表 2：HealthLog  身體測量紀錄（v2：BMI 轉 decimal(5,2)）
CREATE TABLE HealthLog (
    metricid     int           IDENTITY(1,1) NOT NULL,
    uid          nvarchar(20)  NOT NULL,
    height       decimal(5,2)  NOT NULL,
    weight       decimal(5,2)  NOT NULL,
    bmi          AS (CAST(weight / ((height/100.0) * (height/100.0)) AS decimal(5,2))) PERSISTED,
    measuredtime datetime2(7)  NOT NULL
        CONSTRAINT DF_HealthLog_measuredtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_HealthLog PRIMARY KEY (metricid),
    CONSTRAINT CK_HealthLog_height CHECK (height > 0 AND height < 300),
    CONSTRAINT CK_HealthLog_weight CHECK (weight > 0 AND weight < 500)
);
GO

-- 表 3：Goals  目標設定（v2：新增 isachieved）
CREATE TABLE Goals (
    goalid      int           IDENTITY(1,1) NOT NULL,
    uid         nvarchar(20)  NOT NULL,
    goaltype    nvarchar(20)  NOT NULL,
    targetvalue decimal(7,2)  NOT NULL,
    targetdate  date          NOT NULL,
    isactive    bit           NOT NULL
        CONSTRAINT DF_Goals_isactive DEFAULT (1),
    isachieved  bit           NOT NULL                                 -- v2：是否已達成
        CONSTRAINT DF_Goals_isachieved DEFAULT (0),
    createdtime datetime2(7)  NOT NULL
        CONSTRAINT DF_Goals_createdtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Goals PRIMARY KEY (goalid),
    CONSTRAINT CK_Goals_goaltype    CHECK (goaltype IN ('weight','calorie')),
    CONSTRAINT CK_Goals_targetvalue CHECK (targetvalue > 0)
);
GO

-- 表 4：FoodLog  飲食紀錄
CREATE TABLE FoodLog (
    foodid   int           IDENTITY(1,1) NOT NULL,
    uid      nvarchar(20)  NOT NULL,
    foodname nvarchar(100) NOT NULL,
    calories int           NOT NULL,
    mealtime datetime2(7)  NOT NULL
        CONSTRAINT DF_FoodLog_mealtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_FoodLog PRIMARY KEY (foodid),
    CONSTRAINT CK_FoodLog_calories CHECK (calories >= 0)
);
GO

-- 表 5：Activity  運動紀錄
CREATE TABLE Activity (
    actid        int           IDENTITY(1,1) NOT NULL,
    uid          nvarchar(20)  NOT NULL,
    exetype      nvarchar(50)  NOT NULL,
    met          decimal(4,2)  NOT NULL,
    durationmin  int           NOT NULL,
    caloriesburn decimal(7,2)  NOT NULL,
    acttime      datetime2(7)  NOT NULL
        CONSTRAINT DF_Activity_acttime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Activity PRIMARY KEY (actid),
    CONSTRAINT CK_Activity_met         CHECK (met > 0),
    CONSTRAINT CK_Activity_durationmin CHECK (durationmin > 0)
);
GO

-- 表 6：Log  稽核表（v2：action 擴充 mode_switch）
CREATE TABLE Log (
    logid     int           IDENTITY(1,1) NOT NULL,
    tablename nvarchar(50)  NOT NULL,
    action    nvarchar(20)  NOT NULL,
    actor     nvarchar(20)  NULL,
    newdata   nvarchar(500) NULL,
    logtime   datetime2(7)  NOT NULL
        CONSTRAINT DF_Log_logtime DEFAULT (sysdatetime()),
    CONSTRAINT PK_Log PRIMARY KEY (logid),
    CONSTRAINT CK_Log_action CHECK (action IN ('insert','update','delete','mode_switch'))
);
GO

/*------------------------------------------------------------
  階段 2：Foreign Key
------------------------------------------------------------*/
ALTER TABLE HealthLog ADD CONSTRAINT FK_HealthLog_Users FOREIGN KEY (uid) REFERENCES Users(uid);
ALTER TABLE Goals     ADD CONSTRAINT FK_Goals_Users     FOREIGN KEY (uid) REFERENCES Users(uid);
ALTER TABLE FoodLog   ADD CONSTRAINT FK_FoodLog_Users   FOREIGN KEY (uid) REFERENCES Users(uid);
ALTER TABLE Activity  ADD CONSTRAINT FK_Activity_Users  FOREIGN KEY (uid) REFERENCES Users(uid);
GO

/*------------------------------------------------------------
  階段 3：索引
------------------------------------------------------------*/
CREATE INDEX idx_users_mode      ON Users(usermode);                   -- v2 新增
CREATE INDEX idx_healthlog_uid   ON HealthLog(uid);
CREATE INDEX idx_healthlog_time  ON HealthLog(measuredtime);
CREATE INDEX idx_goals_uid       ON Goals(uid);
CREATE INDEX idx_goals_active    ON Goals(uid, isactive);
CREATE INDEX idx_foodlog_uid     ON FoodLog(uid);
CREATE INDEX idx_foodlog_time    ON FoodLog(mealtime);
CREATE INDEX idx_activity_uid    ON Activity(uid);
CREATE INDEX idx_activity_time   ON Activity(acttime);
CREATE INDEX idx_log_time        ON Log(logtime);
CREATE INDEX idx_log_actor       ON Log(actor);
GO

/*------------------------------------------------------------
  驗證
------------------------------------------------------------*/
PRINT N'============================================================';
PRINT N' HealthDB v2 schema 建立完成（支援佛系模式）';
PRINT N' 6 張表 · 4 FK · 11 索引 · 0 Trigger · 1 Computed Column';
PRINT N' 新功能：Users.usermode（goal/record）· Goals.isachieved';
PRINT N'============================================================';
GO

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
 WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME;
GO
