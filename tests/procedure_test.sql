PRINT '========== 测试1：出入统计报表（全部楼栋）==========';
DECLARE @StartDate DATE = DATEADD(DAY, -365, GETDATE());
DECLARE @EndDate DATE = GETDATE();

EXEC USP_Report_AccessStatistics 
    @StartDate = @StartDate,
    @EndDate = @EndDate;
GO

DECLARE @StartDate DATE = DATEADD(DAY, -365, GETDATE());
DECLARE @EndDate DATE = GETDATE();

EXEC USP_Report_AccessStatistics 
    @StartDate = @StartDate,
    @EndDate = @EndDate,
    @BuildingID = 'B栋';
GO

PRINT '========== 测试2：执行清理（90天阈值）==========';
EXEC USP_Batch_CleanExpiredItems @ExpiredDays = 90, @AutoFreeCabinet = 1;
GO
SELECT 
    IS_ItemID,
    IS_ItemName,
    IS_Status,
    IS_DepositTime,
    DATEDIFF(DAY, IS_DepositTime, GETDATE()) AS StorageDays
FROM ItemStorage
ORDER BY StorageDays DESC;
GO
SELECT 
    SC_CabinetID,
    SC_Status,
    (SELECT COUNT(*) FROM ItemStorage WHERE IS_CabinetID = SC_CabinetID AND IS_Status IN ('存储中')) AS ActiveItems
FROM StorageCabinet;
GO

PRINT '========== 测试3：刷新存储过程 ==========';
UPDATE Dormitory SET D_StudentCount = 0 WHERE D_RoomID = '101' AND D_BuildingID = 'A栋';
GO
EXEC USP_Maintenance_RefreshDormStudentCount;
GO
SELECT 
    D.D_BuildingID,
    D.D_RoomID,
    D.D_StudentCount AS RecordedCount,
    COUNT(S.S_StudentID) AS ActualCount,
    CASE WHEN D.D_StudentCount = COUNT(S.S_StudentID) THEN '一致' ELSE '不一致' END AS Status
FROM Dormitory D
LEFT JOIN Student S ON D.D_BuildingID = S.S_BuildingID AND D.D_RoomID = S.S_RoomID
GROUP BY D.D_BuildingID, D.D_RoomID, D.D_StudentCount
ORDER BY D.D_BuildingID, D.D_RoomID;
GO