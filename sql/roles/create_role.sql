-- ==================== 创建数据库角色 ====================

CREATE ROLE Role_DormManager;
GO

CREATE ROLE Role_Student;
GO

CREATE ROLE Role_Guest;
GO

-- ==================== 宿舍管理员角色权限 ====================

-- 视图权限（可查看所有视图）
GRANT SELECT ON V_DormInfo TO Role_DormManager;
GRANT SELECT ON V_StudentInfo TO Role_DormManager;
GRANT SELECT ON V_IdleCabinets TO Role_DormManager;
GRANT SELECT ON V_AvailableCabinets TO Role_DormManager;
GRANT SELECT ON V_CabinetStatsByBuilding TO Role_DormManager;
GRANT SELECT ON V_StudentItemStorage TO Role_DormManager;
GRANT SELECT ON V_UnclaimedItems TO Role_DormManager;
GRANT SELECT ON V_RepairOrderDetail TO Role_DormManager;
GRANT SELECT ON V_DormRepairStats TO Role_DormManager;
GRANT SELECT ON V_UtilityBillDetail TO Role_DormManager;
GRANT SELECT ON V_UnpaidBills TO Role_DormManager;
GRANT SELECT ON V_HealthEvaluationHistory TO Role_DormManager;
GRANT SELECT ON V_DormLatestHealthScore TO Role_DormManager;
GRANT SELECT ON V_AccessRecordDetail TO Role_DormManager;
GRANT SELECT ON V_DailyAccessStats TO Role_DormManager;
GRANT SELECT ON V_UnbalancedVisitorAccess TO Role_DormManager;

-- 基表权限（需要更新操作）
GRANT SELECT, INSERT, UPDATE ON Dormitory TO Role_DormManager;
GRANT SELECT, INSERT, UPDATE ON Student TO Role_DormManager;
GRANT SELECT, INSERT, UPDATE ON StorageCabinet TO Role_DormManager;
GRANT SELECT, INSERT, UPDATE ON ItemStorage TO Role_DormManager;
GRANT SELECT, INSERT, UPDATE ON RepairOrder TO Role_DormManager;
GRANT SELECT, UPDATE ON UtilityBill TO Role_DormManager;
GRANT SELECT, INSERT ON HealthEvaluation TO Role_DormManager;
GRANT SELECT, INSERT ON AccessRecord TO Role_DormManager;
GO

-- ==================== 普通学生角色权限 ====================

-- 视图权限（仅限查看自身相关信息）
GRANT SELECT ON V_StudentInfo TO Role_Student;
GRANT SELECT ON V_StudentItemStorage TO Role_Student;
GRANT SELECT ON V_IdleCabinets TO Role_Student;
GRANT SELECT ON V_AvailableCabinets TO Role_Student;
GRANT SELECT ON V_StudentItemStorage TO Role_Student;
GRANT SELECT ON V_RepairOrderDetail TO Role_Student;
GRANT SELECT ON V_UtilityBillDetail TO Role_Student;
GRANT SELECT ON V_HealthEvaluationHistory TO Role_Student;
GRANT SELECT ON V_DormLatestHealthScore TO Role_Student;
GRANT SELECT ON V_AccessRecordDetail TO Role_Student;

-- 基表权限（限制操作）
GRANT SELECT, INSERT ON RepairOrder TO Role_Student;      -- 可提交报修
GO

-- ==================== 访客角色权限 ====================

-- 视图权限（仅限公开信息）
GRANT SELECT ON V_DormInfo TO Role_Guest;
GRANT SELECT ON V_IdleCabinets TO Role_Guest;
GRANT SELECT ON V_AvailableCabinets TO Role_Guest;
GO