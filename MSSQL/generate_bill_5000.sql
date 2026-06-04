USE [AddressBook1]
GO
SET NOCOUNT ON
GO
WITH Tally AS (
    SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_columns a
    CROSS JOIN sys.all_columns b
)
INSERT INTO dbo.Bill ([tel], [fee], [hid], [dd])
SELECT
    CONCAT(N'09', RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6)),
    100 + ABS(CHECKSUM(NEWID())) % 901,
    1 + ABS(CHECKSUM(NEWID())) % 5,
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        DATEFROMPARTS(2025 + ABS(CHECKSUM(NEWID())) % 2, 1, 1)
    )
FROM Tally;
GO
