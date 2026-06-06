IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_AccessRecord_Dormitory')
    ALTER TABLE AccessRecord DROP CONSTRAINT FK_AccessRecord_Dormitory;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_HealthEvaluation_Dormitory')
    ALTER TABLE HealthEvaluation DROP CONSTRAINT FK_HealthEvaluation_Dormitory;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UtilityBill_Dormitory')
    ALTER TABLE UtilityBill DROP CONSTRAINT FK_UtilityBill_Dormitory;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RepairOrder_Dormitory')
    ALTER TABLE RepairOrder DROP CONSTRAINT FK_RepairOrder_Dormitory;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ItemStorage_Student')
    ALTER TABLE ItemStorage DROP CONSTRAINT FK_ItemStorage_Student;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ItemStorage_Cabinet')
    ALTER TABLE ItemStorage DROP CONSTRAINT FK_ItemStorage_Cabinet;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Student_Dormitory')
    ALTER TABLE Student DROP CONSTRAINT FK_Student_Dormitory;

DROP TABLE IF EXISTS AccessRecord;
DROP TABLE IF EXISTS HealthEvaluation;
DROP TABLE IF EXISTS UtilityBill;
DROP TABLE IF EXISTS RepairOrder;
DROP TABLE IF EXISTS ItemStorage;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS StorageCabinet;
DROP TABLE IF EXISTS Dormitory;

GO
-- ==================== 宿舍表 ====================
CREATE TABLE Dormitory (
    D_RoomID NVARCHAR(20) NOT NULL,
    D_BuildingID NVARCHAR(20) NOT NULL,
    D_Floor INT,
    D_StudentCount INT DEFAULT 0
    CONSTRAINT PK_Dormitory PRIMARY KEY (D_RoomID, D_BuildingID)
);

-- ==================== 学生表 ====================
CREATE TABLE Student (
    S_StudentID NVARCHAR(20) NOT NULL,
    S_Name NVARCHAR(50) NOT NULL,
    S_Gender NVARCHAR(10) CHECK (S_Gender IN ('男', '女')),
    S_BuildingID NVARCHAR(20),
    S_RoomID NVARCHAR(20),
    S_BedID NVARCHAR(10),
    S_IsDormLeader BIT DEFAULT 0,
    CONSTRAINT PK_Student PRIMARY KEY (S_StudentID),
    CONSTRAINT FK_Student_Dormitory FOREIGN KEY (S_RoomID, S_BuildingID) REFERENCES Dormitory(D_RoomID, D_BuildingID)
);

-- ==================== 物品存储柜表 ====================
CREATE TABLE StorageCabinet (
    SC_CabinetID NVARCHAR(20) NOT NULL,
    SC_BuildingID NVARCHAR(20) NOT NULL,
    SC_Status NVARCHAR(20) NOT NULL DEFAULT '空闲',
    SC_Remark NVARCHAR(200),
    CONSTRAINT PK_StorageCabinet PRIMARY KEY (SC_CabinetID),
    CONSTRAINT CK_StorageCabinet_Status CHECK (SC_Status IN ('空闲', '使用中', '维修中', '已废弃'))
);

-- ==================== 物品存放表 ====================
CREATE TABLE ItemStorage (
    IS_ItemID NVARCHAR(20) NOT NULL,
    IS_StudentID NVARCHAR(20) NOT NULL,
    IS_ItemName NVARCHAR(50) NOT NULL,
    IS_ItemType NVARCHAR(30),
    IS_CabinetID NVARCHAR(20) NOT NULL,
    IS_Status NVARCHAR(20) NOT NULL DEFAULT '存储中',
    IS_DepositTime DATETIME NOT NULL DEFAULT GETDATE(),
    IS_PickupTime DATETIME,
    CONSTRAINT PK_ItemStorage PRIMARY KEY (IS_ItemID),
    CONSTRAINT FK_ItemStorage_Student FOREIGN KEY (IS_StudentID) REFERENCES Student(S_StudentID),
    CONSTRAINT FK_ItemStorage_Cabinet FOREIGN KEY (IS_CabinetID) REFERENCES StorageCabinet(SC_CabinetID),
    CONSTRAINT CK_ItemStorage_Status CHECK (IS_Status IN ('存储中', '已取走', '逾期未取', '丢失'))
);

-- ==================== 报修单表 ====================
CREATE TABLE RepairOrder (
    RO_RepairID NVARCHAR(20) NOT NULL,
    RO_BuildingID NVARCHAR(20) NOT NULL,
    RO_RoomID NVARCHAR(20) NOT NULL,
    RO_RepairType NVARCHAR(30),
    RO_RepairContent NVARCHAR(500),
    RO_RepairTime DATETIME,
    RO_RepairPerson NVARCHAR(50),
    RO_RepairCost DECIMAL(10,2),
    RO_RepairStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_RepairOrder PRIMARY KEY (RO_RepairID),
    CONSTRAINT FK_RepairOrder_Dormitory FOREIGN KEY (RO_RoomID, RO_BuildingID) REFERENCES Dormitory(D_RoomID, D_BuildingID),
    CONSTRAINT CK_RepairOrder_Status CHECK (RO_RepairStatus IN ('待处理', '处理中', '已完成', '已取消', '无法修复'))
);

-- ==================== 水电费账单表 ====================
CREATE TABLE UtilityBill (
    UB_BillID NVARCHAR(20) NOT NULL,
    UB_BuildingID NVARCHAR(20) NOT NULL,
    UB_RoomID NVARCHAR(20) NOT NULL,
    UB_BillMonth NVARCHAR(10) NOT NULL DEFAULT FORMAT(GETDATE(), 'yyyy-MM'),
    UB_TotalFee DECIMAL(10,2) DEFAULT 0,
    UB_PaymentStatus NVARCHAR(20) DEFAULT '未缴费',
    UB_PaymentTime DATETIME,
    CONSTRAINT PK_UtilityBill PRIMARY KEY (UB_BillID),
    CONSTRAINT FK_UtilityBill_Dormitory FOREIGN KEY (UB_RoomID, UB_BuildingID) REFERENCES Dormitory(D_RoomID, D_BuildingID),
    CONSTRAINT CK_UtilityBill_Status CHECK (UB_PaymentStatus IN ('未缴费', '已缴费', '逾期', '已减免'))
);

-- ==================== 卫生评估表 ====================
CREATE TABLE HealthEvaluation (
    HE_EvaluationID NVARCHAR(20) NOT NULL,
    HE_BuildingID NVARCHAR(20) NOT NULL,
    HE_RoomID NVARCHAR(20) NOT NULL,
    HE_EvaluationDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    HE_EvaluationScore INT CHECK (HE_EvaluationScore >= 0 AND HE_EvaluationScore <= 100),
    CONSTRAINT PK_HealthEvaluation PRIMARY KEY (HE_EvaluationID),
    CONSTRAINT FK_HealthEvaluation_Dormitory FOREIGN KEY (HE_RoomID, HE_BuildingID) REFERENCES Dormitory(D_RoomID, D_BuildingID)
);

-- ==================== 出入记录表 ====================
CREATE TABLE AccessRecord (
    AR_RecordID NVARCHAR(20) NOT NULL,
    AR_VisitorName NVARCHAR(50) NOT NULL,
    AR_VisitorPhone NVARCHAR(20),
    AR_BuildingID NVARCHAR(20) NOT NULL,
    AR_RoomID NVARCHAR(20) NOT NULL,
    AR_AccessType NVARCHAR(20) NOT NULL,
    AR_AccessTime DATETIME DEFAULT GETDATE(),
    AR_Purpose NVARCHAR(200),
    CONSTRAINT PK_AccessRecord PRIMARY KEY (AR_RecordID),
    CONSTRAINT FK_AccessRecord_Dormitory FOREIGN KEY (AR_RoomID, AR_BuildingID) REFERENCES Dormitory(D_RoomID, D_BuildingID),
    CONSTRAINT CK_AccessRecord_Type CHECK (AR_AccessType IN ('学生来寝', '学生离寝', '访客来寝', '访客离寝'))
);
