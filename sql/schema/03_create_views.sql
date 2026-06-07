-- ==================== 清空视图 ====================
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + 'DROP VIEW IF EXISTS ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.views
WHERE name LIKE 'V_%'  -- 删除所有以 V_ 开头的视图

EXEC sp_executesql @sql;
GO
-- ==================== 住宿相关视图 ====================
-- 寝室信息视图
CREATE VIEW V_DormInfo AS
SELECT 
    D.D_BuildingID,
    D.D_RoomID,
    D.D_Floor,
    D.D_StudentCount,
    S.S_StudentID AS LeaderID,
    S.S_Name AS LeaderName,
    S.S_BedID AS LeaderBedID
FROM Dormitory D
LEFT JOIN Student S ON D.D_BuildingID = S.S_BuildingID 
                   AND D.D_RoomID = S.S_RoomID
                   AND S.S_IsDormLeader = 1;
GO
-- 学生信息视图
CREATE VIEW V_StudentInfo AS
WITH StudentAccessStats AS (
    SELECT 
        S.S_StudentID,
        S.S_Name,
        S.S_Gender,
        S.S_BuildingID,
        S.S_RoomID,
        S.S_BedID,
        S.S_IsDormLeader,
        COUNT(CASE WHEN AR.AR_AccessType = '学生来寝' THEN 1 END) AS ReturnCount,
        COUNT(CASE WHEN AR.AR_AccessType = '学生离寝' THEN 1 END) AS LeaveCount
    FROM Student S
    LEFT JOIN AccessRecord AR ON S.S_BuildingID = AR.AR_BuildingID 
                              AND S.S_RoomID = AR.AR_RoomID
                              AND AR.AR_AccessType IN ('学生来寝', '学生离寝')
    GROUP BY S.S_StudentID, S.S_Name, S.S_Gender, 
             S.S_BuildingID, S.S_RoomID, S.S_BedID, S.S_IsDormLeader
)
SELECT 
    A.S_StudentID,
    A.S_Name,
    A.S_Gender,
    A.S_BedID,
    A.S_IsDormLeader,
    A.S_BuildingID,
    A.S_RoomID,
    D.D_Floor,
    D.D_StudentCount AS Dorm_TotalStudents,
    CASE 
        WHEN A.ReturnCount = A.LeaveCount THEN '离寝'
        WHEN A.ReturnCount - A.LeaveCount = 1 THEN '在寝'
        ELSE '异常'
    END AS PresenceStatus
FROM StudentAccessStats A
LEFT JOIN Dormitory D ON A.S_BuildingID = D.D_BuildingID AND A.S_RoomID = D.D_RoomID;
GO
-- ==================== 物品存放相关视图 ====================
-- 所有柜子视图（待办）
-- 空闲柜子视图
CREATE VIEW V_IdleCabinets AS
SELECT 
    SC_CabinetID,
    SC_BuildingID,
    SC_Status,
    SC_Remark
FROM StorageCabinet
WHERE SC_Status = '空闲';
GO
-- 可用柜子视图
CREATE VIEW V_AvailableCabinets AS
SELECT 
    SC_CabinetID,
    SC_BuildingID,
    SC_Status,
    SC_Remark
FROM StorageCabinet
WHERE SC_Status IN ('空闲', '使用中');
GO
-- 按楼栋统计柜子状态视图
CREATE VIEW V_CabinetStatsByBuilding AS
SELECT 
    SC_BuildingID,
    COUNT(*) AS TotalCabinets,
    COUNT(CASE WHEN SC_Status = '空闲' THEN 1 END) AS IdleCount,
    COUNT(CASE WHEN SC_Status = '使用中' THEN 1 END) AS InUseCount,
    COUNT(CASE WHEN SC_Status = '维修中' THEN 1 END) AS RepairingCount,
    COUNT(CASE WHEN SC_Status = '已废弃' THEN 1 END) AS DiscardedCount
FROM StorageCabinet
GROUP BY SC_BuildingID;
GO
-- 学生物品存放明细视图
CREATE VIEW V_StudentItemStorage AS
SELECT 
    S.S_StudentID,
    S.S_Name,
    S.S_BuildingID,
    S.S_RoomID,
    IS_.IS_ItemID,
    IS_.IS_ItemName,
    IS_.IS_ItemType,
    IS_.IS_CabinetID,
    IS_.IS_Status,
    IS_.IS_DepositTime,
    IS_.IS_PickupTime,
    DATEDIFF(DAY, IS_.IS_DepositTime, GETDATE()) AS StorageDays
FROM Student S
INNER JOIN ItemStorage IS_ ON S.S_StudentID = IS_.IS_StudentID;
GO
-- 未取物品清单视图（用于催取）
CREATE VIEW V_UnclaimedItems AS
SELECT 
    S.S_StudentID,
    S.S_Name,
    S.S_BuildingID,
    S.S_RoomID,
    IS_.IS_ItemID,
    IS_.IS_ItemName,
    IS_.IS_ItemType,
    IS_.IS_CabinetID,
    IS_.IS_Status,
    IS_.IS_DepositTime,
    DATEDIFF(DAY, IS_.IS_DepositTime, GETDATE()) AS StorageDays
FROM ItemStorage IS_
INNER JOIN Student S ON IS_.IS_StudentID = S.S_StudentID
WHERE IS_.IS_Status IN ('存储中', '逾期未取');
GO
-- ==================== 报修相关视图 ====================

-- 报修单详细信息视图
CREATE VIEW V_RepairOrderDetail AS
SELECT 
    RO.RO_RepairID,
    RO.RO_BuildingID,
    RO.RO_RoomID,
    RO.RO_RepairType,
    RO.RO_RepairContent,
    RO.RO_RepairTime,
    RO.RO_RepairStatus
FROM RepairOrder RO;
GO
-- 各宿舍报修统计视图
CREATE VIEW V_DormRepairStats AS
SELECT 
    D.D_BuildingID,
    D.D_RoomID,
    D.D_Floor,
    COUNT(CASE WHEN RO.RO_RepairStatus = '待处理' THEN 1 END) AS PendingCount,
    COUNT(CASE WHEN RO.RO_RepairStatus = '处理中' THEN 1 END) AS ProcessingCount,
    COUNT(CASE WHEN RO.RO_RepairStatus = '已完成' THEN 1 END) AS CompletedCount,
    COUNT(CASE WHEN RO.RO_RepairStatus = '已取消' THEN 1 END) AS CancelledCount,
    COUNT(*) AS TotalRepairs,
    AVG(RO.RO_RepairCost) AS AvgRepairCost,
    SUM(RO.RO_RepairCost) AS TotalRepairCost
FROM Dormitory D
LEFT JOIN RepairOrder RO ON D.D_BuildingID = RO.RO_BuildingID AND D.D_RoomID = RO.RO_RoomID
GROUP BY D.D_BuildingID, D.D_RoomID, D.D_Floor;
GO
-- ==================== 水电费相关视图 ====================

-- 水电费账单明细视图
CREATE VIEW V_UtilityBillDetail AS
SELECT 
    UB.UB_BillID,
    UB.UB_BuildingID,
    UB.UB_RoomID,
    UB.UB_BillMonth,
    UB.UB_TotalFee,
    UB.UB_PaymentStatus,
    UB.UB_PaymentTime
FROM UtilityBill UB;
GO
-- 未缴费账单视图（用于催缴）
CREATE VIEW V_UnpaidBills AS
SELECT 
    UB.UB_BillID,
    UB.UB_BuildingID,
    UB.UB_RoomID,
    UB.UB_BillMonth,
    UB.UB_TotalFee,
    UB.UB_PaymentStatus,
    DATEDIFF(DAY, 
        DATEFROMPARTS(YEAR(GETDATE()), MONTH(CAST(UB.UB_BillMonth + '-01' AS DATE)), 1),
        GETDATE()
    ) AS OverdueDays
FROM UtilityBill UB
WHERE UB.UB_PaymentStatus IN ('未缴费', '逾期');
GO
-- ==================== 卫生评估相关视图 ====================

-- 宿舍卫生评估历史视图
CREATE VIEW V_HealthEvaluationHistory AS
SELECT 
    HE.HE_EvaluationID,
    HE.HE_BuildingID,
    HE.HE_RoomID,
    HE.HE_EvaluationDate,
    HE.HE_EvaluationScore,
    CASE 
        WHEN HE.HE_EvaluationScore >= 90 THEN '优秀'
        WHEN HE.HE_EvaluationScore >= 80 THEN '良好'
        WHEN HE.HE_EvaluationScore >= 70 THEN '中等'
        WHEN HE.HE_EvaluationScore >= 60 THEN '合格'
        ELSE '不合格'
    END AS GradeLevel
FROM HealthEvaluation HE;
GO
-- 各宿舍最新卫生评估视图
CREATE VIEW V_DormLatestHealthScore AS
WITH LatestEval AS (
    SELECT 
        HE_BuildingID,
        HE_RoomID,
        HE_EvaluationScore,
        HE_EvaluationDate,
        ROW_NUMBER() OVER (PARTITION BY HE_BuildingID, HE_RoomID ORDER BY HE_EvaluationDate DESC) AS rn
    FROM HealthEvaluation
)
SELECT 
    D.D_BuildingID,
    D.D_RoomID,
    D.D_Floor,
    D.D_StudentCount,
    L.HE_EvaluationScore AS LatestScore,
    L.HE_EvaluationDate AS EvaluationDate,
    CASE 
        WHEN L.HE_EvaluationScore >= 90 THEN '优秀'
        WHEN L.HE_EvaluationScore >= 80 THEN '良好'
        WHEN L.HE_EvaluationScore >= 70 THEN '中等'
        WHEN L.HE_EvaluationScore >= 60 THEN '合格'
        ELSE '不合格'
    END AS GradeLevel
FROM Dormitory D
LEFT JOIN LatestEval L ON D.D_BuildingID = L.HE_BuildingID AND D.D_RoomID = L.HE_RoomID AND L.rn = 1;
GO
-- ==================== 出入记录相关视图 ====================

-- 出入记录详细信息视图
CREATE VIEW V_AccessRecordDetail AS
SELECT 
    AR.AR_RecordID,
    AR.AR_VisitorName,
    AR.AR_VisitorPhone,
    AR.AR_BuildingID,
    AR.AR_RoomID,
    AR.AR_AccessType,
    AR.AR_AccessTime,
    AR.AR_Purpose
FROM AccessRecord AR;
GO
-- 每日出入统计视图
CREATE VIEW V_DailyAccessStats AS
SELECT 
    CAST(AR_AccessTime AS DATE) AS AccessDate,
    AR_BuildingID,
    COUNT(*) AS TotalAccessCount,
    COUNT(CASE WHEN AR_AccessType LIKE '%来寝%' THEN 1 END) AS EntryCount,
    COUNT(CASE WHEN AR_AccessType LIKE '%离寝%' THEN 1 END) AS ExitCount,
    COUNT(CASE WHEN AR_AccessType LIKE '访客来寝' THEN 1 END) AS VisitorCount,
    COUNT(DISTINCT AR_VisitorName) AS UniqueVisitors
FROM AccessRecord
GROUP BY CAST(AR_AccessTime AS DATE), AR_BuildingID;
GO
-- 异常访客查询
CREATE VIEW V_UnbalancedVisitorAccess AS
SELECT 
    AR.AR_BuildingID,
    AR.AR_RoomID,
    AR.AR_VisitorName,
    AR.AR_VisitorPhone,
    CASE 
        WHEN COUNT(CASE WHEN AR.AR_AccessType = '访客来寝' THEN 1 END) > 
             COUNT(CASE WHEN AR.AR_AccessType = '访客离寝' THEN 1 END) THEN '访客未离寝'
        WHEN COUNT(CASE WHEN AR.AR_AccessType = '访客来寝' THEN 1 END) < 
             COUNT(CASE WHEN AR.AR_AccessType = '访客离寝' THEN 1 END) THEN '离寝记录异常（无对应进入）'
        ELSE '正常'
    END AS IssueType,
    STRING_AGG(
        CONCAT(AR.AR_AccessType, ':', FORMAT(AR.AR_AccessTime, 'yyyy-MM-dd HH:mm:ss')), 
        '; '
    ) WITHIN GROUP (ORDER BY AR.AR_AccessTime) AS AccessDetail
FROM AccessRecord AR
WHERE AR.AR_AccessType IN ('访客来寝', '访客离寝')
GROUP BY AR.AR_BuildingID, AR.AR_RoomID, AR.AR_VisitorName, AR.AR_VisitorPhone
HAVING COUNT(CASE WHEN AR.AR_AccessType = '访客来寝' THEN 1 END) <> 
       COUNT(CASE WHEN AR.AR_AccessType = '访客离寝' THEN 1 END);
GO
