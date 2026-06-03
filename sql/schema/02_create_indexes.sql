-- ==================== 学生表索引 ====================
-- 宿舍查询索引（用于查找某宿舍的所有学生）
CREATE INDEX IX_Student_DormLocation ON Student(S_BuildingID, S_RoomID);

-- 姓名查询索引（支持模糊搜索）
CREATE INDEX IX_Student_Name ON Student(S_Name);

-- 宿舍长查询索引（筛选索引）
CREATE INDEX IX_Student_IsDormLeader ON Student(S_IsDormLeader) WHERE S_IsDormLeader = 1;

-- ==================== 宿舍表索引 ====================
-- 楼栋查询索引
CREATE INDEX IX_Dormitory_BuildingID ON Dormitory(D_BuildingID);

-- 楼层查询索引
CREATE INDEX IX_Dormitory_Floor ON Dormitory(D_Floor);

-- 学生数量范围查询索引（用于查找空宿舍或满员宿舍）
CREATE INDEX IX_Dormitory_StudentCount ON Dormitory(D_StudentCount);

-- ==================== 物品存储柜表索引 ====================
-- 楼栋查询索引
CREATE INDEX IX_StorageCabinet_BuildingID ON StorageCabinet(SC_BuildingID);

-- 状态查询索引（筛选可用的柜子）
CREATE INDEX IX_StorageCabinet_Status ON StorageCabinet(SC_Status) WHERE SC_Status = '空闲';

-- 复合索引：楼栋+状态（查询某楼栋可用柜子）
CREATE INDEX IX_StorageCabinet_Building_Status ON StorageCabinet(SC_BuildingID, SC_Status);

-- ==================== 物品存放表索引 ====================
-- 学生物品查询索引（最常用）
CREATE INDEX IX_ItemStorage_StudentID ON ItemStorage(IS_StudentID);

-- 物品状态查询索引（用于查找未取走的物品）
CREATE INDEX IX_ItemStorage_Status ON ItemStorage(IS_Status) WHERE IS_Status IN ('存储中', '逾期未取');

-- 复合索引：按学生+状态（查询某学生的未取物品）
CREATE INDEX IX_ItemStorage_StudentID_Status ON ItemStorage(IS_StudentID, IS_Status);

-- 复合索引：状态+存放时间（用于定时清理逾期物品）
CREATE INDEX IX_ItemStorage_Status_DepositTime ON ItemStorage(IS_Status, IS_DepositTime) WHERE IS_Status = '存储中';

-- ==================== 报修单表索引 ====================
-- 宿舍报修记录查询索引
CREATE INDEX IX_RepairOrder_DormLocation ON RepairOrder(RO_BuildingID, RO_RoomID);

-- 报修状态查询索引（待处理、处理中）
CREATE INDEX IX_RepairOrder_Status ON RepairOrder(RO_RepairStatus) WHERE RO_RepairStatus IN ('待处理', '处理中');

-- 报修时间范围查询索引
CREATE INDEX IX_RepairOrder_Time ON RepairOrder(RO_RepairTime);

-- 复合索引：宿舍+状态（查询某宿舍未完成的报修）
CREATE INDEX IX_RepairOrder_Dorm_Status ON RepairOrder(RO_BuildingID, RO_RoomID, RO_RepairStatus);

-- 复合索引：宿舍+时间（查询某宿舍时间段内的报修记录）
CREATE INDEX IX_RepairOrder_Dorm_Time ON RepairOrder(RO_BuildingID, RO_RoomID, RO_RepairTime);

-- ==================== 水电费账单表索引 ====================
-- 宿舍账单查询索引
CREATE INDEX IX_UtilityBill_DormLocation ON UtilityBill(UB_BuildingID, UB_RoomID);

-- 账单月份查询索引
CREATE INDEX IX_UtilityBill_Month ON UtilityBill(UB_BillMonth);

-- 缴费状态查询索引（筛选未缴费账单）
CREATE INDEX IX_UtilityBill_PaymentStatus ON UtilityBill(UB_PaymentStatus) WHERE UB_PaymentStatus IN ('未缴费', '逾期');

-- 复合索引：月份+状态（用于催缴查询）
CREATE INDEX IX_UtilityBill_Month_Status ON UtilityBill(UB_BillMonth, UB_PaymentStatus);

-- 复合索引：宿舍+月份（查询某宿舍某月账单）
CREATE INDEX IX_UtilityBill_Dorm_Month ON UtilityBill(UB_BuildingID, UB_RoomID, UB_BillMonth);

-- 复合索引：宿舍+状态+月份（统计未缴费宿舍）
CREATE INDEX IX_UtilityBill_Dorm_Status_Month ON UtilityBill(UB_BuildingID, UB_RoomID, UB_PaymentStatus, UB_BillMonth);

-- ==================== 卫生评估表索引 ====================
-- 宿舍卫生评分查询索引
CREATE INDEX IX_HealthEvaluation_DormLocation ON HealthEvaluation(HE_BuildingID, HE_RoomID);

-- 评估日期范围查询索引
CREATE INDEX IX_HealthEvaluation_Date ON HealthEvaluation(HE_EvaluationDate);

-- 评分范围查询索引
CREATE INDEX IX_HealthEvaluation_Score ON HealthEvaluation(HE_EvaluationScore);

-- 复合索引：宿舍+日期（查询某宿舍历史评分）
CREATE INDEX IX_HealthEvaluation_Dorm_Date ON HealthEvaluation(HE_BuildingID, HE_RoomID, HE_EvaluationDate);

-- ==================== 出入记录表索引 ====================
-- 宿舍出入记录查询索引
CREATE INDEX IX_AccessRecord_DormLocation ON AccessRecord(AR_BuildingID, AR_RoomID);

-- 出入时间范围查询索引（最常用）
CREATE INDEX IX_AccessRecord_Time ON AccessRecord(AR_AccessTime);

-- 复合索引：时间+类型（用于出入统计）
CREATE INDEX IX_AccessRecord_Time_Type ON AccessRecord(AR_AccessTime, AR_AccessType);