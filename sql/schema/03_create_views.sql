-- ==================== 住宿相关视图 ====================

-- 学生信息视图（包含宿舍和出入信息）
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

-- 宿舍长信息视图（通过 Student 表中的 S_IsDormLeader 标识）
CREATE VIEW V_DormLeaderInfo AS
SELECT 
    D.D_BuildingID,
    D.D_RoomID,
    D.D_Floor,
    D.D_StudentCount,
    S.S_StudentID AS LeaderID,
    S.S_Name AS LeaderName,
    S.S_Gender AS LeaderGender,
    S.S_BedID AS LeaderBedID
FROM Dormitory D
INNER JOIN Student S ON D.D_BuildingID = S.S_BuildingID AND D.D_RoomID = S.S_RoomID
WHERE S.S_IsDormLeader = 1;

-- ==================== 物品存放相关视图 ====================
-- 空闲柜子视图
CREATE VIEW V_IdleCabinets AS
SELECT 
    SC_CabinetID,
    SC_BuildingID,
    SC_Status,
    SC_Remark
FROM StorageCabinet
WHERE SC_Status = '空闲';

-- 可用柜子视图
CREATE VIEW V_AvailableCabinets AS
SELECT 
    SC_CabinetID,
    SC_BuildingID,
    SC_Status,
    SC_Remark,
    SC_Status
FROM StorageCabinet
WHERE SC_Status IN ('空闲', '使用中');

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

-- 未取物品清单视图（用于催取）
CREATE VIEW V_UnclaimedItems AS
SELECT 
    S.S_StudentID,
    S.S_Name,
    S.S_BuildingID,
    S.S_RoomID,
    S.S_Phone,
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

-- ==================== 报修相关视图 ====================

-- 报修单详细信息视图
CREATE VIEW V_RepairOrderDetail AS
SELECT 
    RO.RO_RepairID,
    RO.RO_BuildingID,
    RO.RO_RoomID,
    D.D_Floor,
    RO.RO_RepairType,
    RO.RO_RepairContent,
    RO.RO_RepairTime,
    RO.RO_RepairPerson,
    RO.RO_RepairCost,
    RO.RO_RepairStatus,
    DATEDIFF(DAY, RO.RO_RepairTime, GETDATE()) AS ProcessingDays,
    CASE 
        WHEN RO.RO_RepairStatus = '已完成' THEN DATEDIFF(DAY, RO.RO_RepairTime, ISNULL(RO.RO_CompleteTime, GETDATE()))
        ELSE NULL
    END AS CompletionDays
FROM RepairOrder RO
INNER JOIN Dormitory D ON RO.RO_BuildingID = D.D_BuildingID AND RO.RO_RoomID = D.D_RoomID;

-- 未完成报修单视图（待处理+处理中）
CREATE VIEW V_PendingRepairs AS
SELECT 
    RO.RO_RepairID,
    RO.RO_BuildingID,
    RO.RO_RoomID,
    RO.RO_RepairType,
    RO.RO_RepairContent,
    RO.RO_RepairTime,
    RO.RO_RepairStatus
FROM RepairOrder RO
WHERE RO.RO_RepairStatus IN ('待处理', '处理中');

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

-- 各宿舍年度费用统计视图
CREATE VIEW V_DormAnnualCost AS
SELECT 
    UB.UB_BuildingID,
    UB.UB_RoomID,
    YEAR(CAST(UB.UB_BillMonth + '-01' AS DATE)) AS BillYear,
    COUNT(*) AS MonthsCount,
    SUM(UB.UB_TotalFee) AS TotalAnnualFee,
    AVG(UB.UB_TotalFee) AS AvgMonthlyFee,
    SUM(CASE WHEN UB.UB_PaymentStatus = '已缴费' THEN UB.UB_TotalFee ELSE 0 END) AS PaidAmount,
    SUM(CASE WHEN UB.UB_PaymentStatus IN ('未缴费', '逾期') THEN UB.UB_TotalFee ELSE 0 END) AS UnpaidAmount
FROM UtilityBill UB
GROUP BY UB.UB_BuildingID, UB.UB_RoomID, YEAR(CAST(UB.UB_BillMonth + '-01' AS DATE));

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
WHERE AR.AR_AccessType IN ('访客来寝', '访客离开')
GROUP BY AR.AR_BuildingID, AR.AR_RoomID, AR.AR_VisitorName, AR.AR_VisitorPhone
HAVING COUNT(CASE WHEN AR.AR_AccessType = '访客进入' THEN 1 END) <> 
       COUNT(CASE WHEN AR.AR_AccessType = '访客离开' THEN 1 END);

-- ==================== 综合统计视图 ====================

-- 宿舍综合信息视图（整合所有信息）
CREATE VIEW V_DormComprehensiveInfo AS
SELECT 
    D.D_BuildingID,
    D.D_RoomID,
    D.D_Floor,
    D.D_StudentCount,
    S_Leader.S_Name AS DormLeaderName,
    S_Leader.S_Phone AS DormLeaderPhone,
    ISNULL(RepairStats.PendingCount, 0) AS PendingRepairs,
    ISNULL(RepairStats.ProcessingCount, 0) AS ProcessingRepairs,
    ISNULL(UnpaidBills.UnpaidCount, 0) AS UnpaidBills,
    ISNULL(UnpaidBills.UnpaidAmount, 0) AS UnpaidAmount,
    LatestHealth.LatestScore AS LatestHealthScore,
    LatestHealth.GradeLevel AS HealthGrade,
    AccessStats.TotalVisits AS TotalAccessRecords
FROM Dormitory D
LEFT JOIN Student S_Leader ON D.D_DormLeaderID = S_Leader.S_StudentID
LEFT JOIN V_DormRepairStats RepairStats ON D.D_BuildingID = RepairStats.D_BuildingID AND D.D_RoomID = RepairStats.D_RoomID
LEFT JOIN (
    SELECT UB_BuildingID, UB_RoomID, 
           COUNT(*) AS UnpaidCount, 
           SUM(UB_TotalFee) AS UnpaidAmount
    FROM UtilityBill
    WHERE UB_PaymentStatus IN ('未缴费', '逾期')
    GROUP BY UB_BuildingID, UB_RoomID
) UnpaidBills ON D.D_BuildingID = UnpaidBills.UB_BuildingID AND D.D_RoomID = UnpaidBills.UB_RoomID
LEFT JOIN V_DormLatestHealthScore LatestHealth ON D.D_BuildingID = LatestHealth.D_BuildingID AND D.D_RoomID = LatestHealth.D_RoomID
LEFT JOIN V_DormAccessStats AccessStats ON D.D_BuildingID = AccessStats.D_BuildingID AND D.D_RoomID = AccessStats.D_RoomID;

-- 楼栋综合统计视图
CREATE VIEW V_BuildingSummary AS
SELECT 
    D.D_BuildingID,
    COUNT(DISTINCT D.D_RoomID) AS TotalRooms,
    SUM(D.D_StudentCount) AS TotalStudents,
    AVG(D.D_StudentCount) AS AvgStudentsPerRoom,
    COUNT(DISTINCT CASE WHEN S.S_IsDormLeader = 1 THEN S.S_StudentID END) AS TotalDormLeaders,
    SUM(CASE WHEN RO.RO_RepairStatus IN ('待处理', '处理中') THEN 1 ELSE 0 END) AS ActiveRepairs,
    SUM(CASE WHEN UB.UB_PaymentStatus IN ('未缴费', '逾期') THEN 1 ELSE 0 END) AS UnpaidBillsCount,
    AVG(HE.HE_EvaluationScore) AS AvgHealthScore
FROM Dormitory D
LEFT JOIN Student S ON D.D_BuildingID = S.S_BuildingID AND D.D_RoomID = S.S_RoomID
LEFT JOIN RepairOrder RO ON D.D_BuildingID = RO.RO_BuildingID AND D.D_RoomID = RO.RO_RoomID
LEFT JOIN UtilityBill UB ON D.D_BuildingID = UB.UB_BuildingID AND D.D_RoomID = UB.UB_RoomID
LEFT JOIN HealthEvaluation HE ON D.D_BuildingID = HE.HE_BuildingID AND D.D_RoomID = HE.HE_RoomID
GROUP BY D.D_BuildingID;