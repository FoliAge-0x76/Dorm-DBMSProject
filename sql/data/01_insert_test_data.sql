-- ==================== 清空现有数据 ====================
DELETE FROM AccessRecord;
DELETE FROM HealthEvaluation;
DELETE FROM UtilityBill;
DELETE FROM RepairOrder;
DELETE FROM ItemStorage;
DELETE FROM StorageCabinet;
DELETE FROM Student;
DELETE FROM Dormitory;
GO
-- ==================== 宿舍数据 ====================
INSERT INTO Dormitory (D_RoomID, D_BuildingID, D_Floor, D_StudentCount) VALUES
('101', 'A栋', 1, 0),
('102', 'A栋', 1, 0);

-- ==================== 学生数据 ====================
INSERT INTO Student (S_StudentID, S_Name, S_Gender, S_BuildingID, S_RoomID, S_BedID, S_IsDormLeader) VALUES
('S001', 'Aoi', '女', 'A栋', '101', '1', 0),
('S002', 'Akane', '女', 'A栋', '101', '2', 0),
('S003', 'Yukari', '女', 'A栋', '101', '3', 1),
('S004', 'Akari', '女', 'A栋', '101', '4', 0),
('S005', 'Nijika', '女', 'A栋', '102', '1', 1),
('S006', 'Ryo', '女', 'A栋', '102', '2', 0);
-- ==================== StorageCabinet 测试数据 ====================
INSERT INTO StorageCabinet (SC_CabinetID, SC_BuildingID, SC_Status, SC_Remark) VALUES
('CAB-A-01', 'A栋', '空闲', 'A栋1楼大厅东侧，小型柜'),
('CAB-A-02', 'A栋', '空闲', 'A栋2楼走廊，中型柜'),
('CAB-B-01', 'B栋', '维修中', 'B栋1楼，门锁损坏'),
('CAB-B-02', 'B栋', '已废弃', 'B栋3楼，柜体生锈');

-- ==================== 物品存放数据 ====================
INSERT INTO ItemStorage (IS_ItemID, IS_StudentID, IS_ItemName, IS_ItemType, IS_CabinetID, IS_Status, IS_DepositTime, IS_PickupTime) VALUES
('I001', 'S001', '笔记本电脑', '电子产品', 'CAB-A-01', '存储中', '2026-01-15 10:30:00', NULL),
('I002', 'S002', '行李箱', '生活用品', 'CAB-A-02', '已取走', '2026-01-20 14:00:00', '2026-02-01 15:30:00'),
('I003', 'S003', '光碟', NULL, 'CAB-A-02', '存储中', '2026-02-10 16:20:00', NULL),
('I004', 'S004', '书籍', NULL, 'CAB-A-01', '存储中', '2025-12-01 11:00:00', NULL);

-- ==================== 报修单数据 ====================
INSERT INTO RepairOrder (RO_RepairID, RO_BuildingID, RO_RoomID, RO_RepairType, RO_RepairContent, RO_RepairTime, RO_RepairPerson, RO_RepairCost, RO_RepairStatus) VALUES
('R001', 'A栋', '101', '电路维修', '灯管不亮', '2026-02-20 09:00:00', '王师傅', 50.00, '已完成'),
('R002', 'A栋', '102', '水管维修', '水龙头漏水', NULL, NULL, NULL, '待处理'),
('R003', 'A栋', '101', '空调维修', NULL, NULL, '张师傅', NULL, '处理中');

-- ==================== 水电费账单数据 ====================
INSERT INTO UtilityBill (UB_BillID, UB_BuildingID, UB_RoomID, UB_BillMonth, UB_TotalFee, UB_PaymentStatus, UB_PaymentTime) VALUES
('UB001', 'A栋', '101', '2026-01', 85.50, '已缴费', '2026-01-25 10:00:00'),
('UB002', 'A栋', '101', '2026-02', 92.30, '未缴费', NULL),
('UB003', 'A栋', '102', '2026-01', 78.00, '已缴费', '2026-01-28 14:30:00'),
('UB004', 'A栋', '102', '2026-02', 105.60, '逾期', NULL);

-- ==================== 卫生评估数据 ====================
INSERT INTO HealthEvaluation (HE_EvaluationID, HE_BuildingID, HE_RoomID, HE_EvaluationDate, HE_EvaluationScore) VALUES
('HE001', 'A栋', '101', '2026-01-15', 85),
('HE002', 'A栋', '101', '2026-02-15', 88),
('HE003', 'A栋', '102', '2026-01-15', 76),
('HE004', 'A栋', '102', '2026-02-15', NULL);

-- ==================== 出入记录数据 ====================
-- Aoi：在寝测试（原因留空）
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorSID, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime) VALUES
('AR001', 'Aoi', 'S001', 'A栋', '101', '学生来寝', '2026-03-01 14:00:00'),
('AR002', 'Aoi', 'S001', 'A栋', '101', '学生离寝', '2026-03-02 08:00:00'),
('AR003', 'Aoi', 'S001', 'A栋', '101', '学生来寝', '2026-03-02 18:00:00');

-- Akane：离寝测试
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorSID, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime, AR_Purpose) VALUES
('AR004', 'Akane', 'S002', 'A栋', '101', '学生来寝', '2026-02-28 19:00:00', '返校'),
('AR005', 'Akane', 'S002', 'A栋', '101', '学生离寝', '2026-03-01 08:00:00', '回家'),
('AR006', 'Akane', 'S002', 'A栋', '101', '学生来寝', '2026-03-01 17:30:00', '返校'),
('AR007', 'Akane', 'S002', 'A栋', '101', '学生离寝', '2026-03-02 07:00:00', '回家');

-- Yukari：异常情况测试
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorSID, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime, AR_Purpose) VALUES
('AR008', 'Yukari', 'S003', 'A栋', '101', '学生离寝', '2026-03-01 09:00:00', NULL);

-- Akari：默认日期测试
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorSID, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime, AR_Purpose) VALUES
('AR009', 'Akari', 'S004', 'A栋', '101', '学生来寝', NULL, '返校'),
('AR010', 'Akari', 'S004', 'A栋', '101', '学生离寝', NULL, '回家');

-- 访客记录

-- Zundamon：正常测试
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorPhone, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime, AR_Purpose) VALUES
('AR011', 'Zundamon', '13800138001', 'A栋', '101', '访客来寝', '2026-03-01 15:00:00', '看望'),
('AR012', 'Zundamon', '13800138001', 'A栋', '101', '访客离寝', '2026-03-01 17:00:00', '离开');

-- 李芳：未离开
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorPhone, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime, AR_Purpose) VALUES
('AR013', '李芳', '13800138002', 'A栋', '102', '访客来寝', '2026-03-02 20:00:00', '探望');

-- 王磊：异常信息
INSERT INTO AccessRecord (AR_RecordID, AR_VisitorName, AR_VisitorPhone, AR_BuildingID, AR_RoomID, AR_AccessType, AR_AccessTime, AR_Purpose) VALUES
('AR014', '王磊', NULL, 'A栋', '101', '访客离寝', NULL, NULL);