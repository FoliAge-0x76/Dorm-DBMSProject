-- ==================== 模块1：住宿模块 ====================
-- 1. 视图验证
SELECT * FROM V_StudentInfo ORDER BY S_BuildingID, S_RoomID, S_BedID;
SELECT * FROM V_DormInfo ORDER BY D_BuildingID, D_RoomID;
GO

-- 2. 触发器测试
-- 换寝室
UPDATE Student 
SET S_BuildingID = 'A栋', S_RoomID = '102'
WHERE S_StudentID = 'S004';

SELECT S_StudentID, S_Name, S_BedID, S_IsDormLeader
FROM V_StudentInfo
WHERE S_BuildingID = 'A栋' AND S_RoomID = '102'
ORDER BY S_BedID;
GO

-- 多寝室长
INSERT INTO Student (S_StudentID, S_Name, S_Gender, S_BuildingID, S_RoomID, S_BedID, S_IsDormLeader) VALUES
('SBAD', '???', '女', 'A栋', '101', '7', 1);
GO

-- ==================== 模块2：存取模块 ====================
-- 1. 视图验证
SELECT * FROM V_IdleCabinets ORDER BY SC_CabinetID;
SELECT * FROM V_AvailableCabinets ORDER BY SC_CabinetID;
SELECT * FROM V_CabinetStatsByBuilding ORDER BY SC_BuildingID;
SELECT * FROM V_StudentItemStorage ORDER BY IS_ItemID;
SELECT * FROM V_UnclaimedItems ORDER BY StorageDays DESC;
GO

-- 2. 触发器测试
-- 存入不可用格子
INSERT INTO ItemStorage (IS_ItemID, IS_StudentID, IS_ItemName, IS_ItemType, IS_CabinetID, IS_Status, IS_DepositTime, IS_PickupTime) VALUES
('IBAD', 'S005', '原神吧唧', NULL, 'CAB-A-01', '存储中', '2026-06-01 10:30:00', NULL);
INSERT INTO ItemStorage (IS_ItemID, IS_StudentID, IS_ItemName, IS_ItemType, IS_CabinetID, IS_Status, IS_DepositTime, IS_PickupTime) VALUES
('IBAD', 'S005', '原神吧唧', NULL, 'CAB-B-01', '存储中', '2026-06-01 10:30:00', NULL);
INSERT INTO ItemStorage (IS_ItemID, IS_StudentID, IS_ItemName, IS_ItemType, IS_CabinetID, IS_Status, IS_DepositTime, IS_PickupTime) VALUES
('IBAD', 'S005', '原神吧唧', NULL, 'CAB-B-02', '存储中', '2026-06-01 10:30:00', NULL);
GO

-- 取走物品
UPDATE ItemStorage SET IS_Status = '已取走' WHERE IS_ItemID = 'I003';
SELECT IS_ItemID, IS_Status, IS_PickupTime FROM V_StudentItemStorage WHERE IS_ItemID = 'I003';
SELECT SC_CabinetID, SC_Status FROM V_AvailableCabinets WHERE SC_CabinetID = 'CAB-A-02';
GO

-- ==================== 模块3：报修模块 ====================
-- 1. 视图验证
SELECT * FROM V_RepairOrderDetail ORDER BY RO_RepairID;
SELECT * FROM V_RepairOrderDetail WHERE RO_RepairStatus IN ('待处理', '处理中') ORDER BY RO_RepairID;
SELECT * FROM V_DormRepairStats ORDER BY D_BuildingID, D_RoomID;
GO

-- 2. 触发器测试
-- 自动填写时间
UPDATE RepairOrder SET RO_RepairStatus = '已完成' WHERE RO_RepairID = 'R002';
UPDATE RepairOrder SET RO_RepairStatus = '已完成' WHERE RO_RepairID = 'R003';
SELECT * FROM V_RepairOrderDetail ORDER BY RO_RepairID;
GO

-- ==================== 模块4：水电费模块 ====================
-- 1. 视图验证
SELECT * FROM V_UtilityBillDetail ORDER BY UB_BillID;
SELECT * FROM V_UnpaidBills ORDER BY OverdueDays DESC;
GO

-- 2. 触发器测试
-- 自动填写时间
UPDATE UtilityBill SET UB_PaymentStatus = '已缴费' WHERE UB_BillID = 'UB002';
SELECT * FROM V_UtilityBillDetail ORDER BY UB_BillID;
GO

-- ==================== 模块5：卫生评估模块 ====================
-- 1. 视图验证
SELECT * FROM V_HealthEvaluationHistory ORDER BY HE_EvaluationID;
SELECT * FROM V_DormLatestHealthScore ORDER BY LatestScore;

-- ==================== 模块6：出入记录模块 ====================
-- 1. 视图验证
SELECT * FROM V_AccessRecordDetail ORDER BY AR_RecordID;
SELECT * FROM V_DailyAccessStats ORDER BY AccessDate DESC;
SELECT * FROM V_UnbalancedVisitorAccess;