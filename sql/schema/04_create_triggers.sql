
DROP TRIGGER IF EXISTS TR_Student_Change;
DROP TRIGGER IF EXISTS TR_Student_DormLeaderCheck;
DROP TRIGGER IF EXISTS TR_ItemStorage_Insert;
DROP TRIGGER IF EXISTS TR_ItemStorage_Update;
DROP TRIGGER IF EXISTS TR_RepairOrder_StatusChange;
DROP TRIGGER IF EXISTS TR_UtilityBill_Payment;
GO

-- ==================== 学生住宿信息变化 ====================

CREATE TRIGGER TR_Student_Change
ON Student
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- 处理 DELETE 和 UPDATE（减少旧宿舍人数）
    UPDATE Dormitory
    SET D_StudentCount = D_StudentCount - DEL.DeleteCount
    FROM Dormitory D
    INNER JOIN (
        SELECT S_BuildingID, S_RoomID, COUNT(*) AS DeleteCount
        FROM deleted
        GROUP BY S_BuildingID, S_RoomID
    ) AS DEL ON D.D_BuildingID = DEL.S_BuildingID AND D.D_RoomID = DEL.S_RoomID
    WHERE D.D_StudentCount >= DEL.DeleteCount;
    
    -- 处理 INSERT 和 UPDATE（增加新宿舍人数）
    UPDATE Dormitory
    SET D_StudentCount = D_StudentCount + INS.InsertCount
    FROM Dormitory D
    INNER JOIN (
        SELECT S_BuildingID, S_RoomID, COUNT(*) AS InsertCount
        FROM inserted
        GROUP BY S_BuildingID, S_RoomID
    ) AS INS ON D.D_BuildingID = INS.S_BuildingID AND D.D_RoomID = INS.S_RoomID;
END;
GO

-- ==================== 寝室长数量检查 ====================

CREATE TRIGGER TR_Student_DormLeaderCheck
ON Student
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT S_BuildingID, S_RoomID
        FROM (
            SELECT S_BuildingID, S_RoomID, S_IsDormLeader, S_StudentID
            FROM Student
            
            UNION
            
            SELECT I.S_BuildingID, I.S_RoomID, I.S_IsDormLeader, I.S_StudentID
            FROM inserted I
        ) AS AllStudents
        WHERE S_IsDormLeader = 1
        GROUP BY S_BuildingID, S_RoomID
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR('每个寝室最多只能有一个寝室长！', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- ==================== 存放物品 ====================

CREATE TRIGGER TR_ItemStorage_Insert
ON ItemStorage
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted I
        INNER JOIN StorageCabinet SC ON I.IS_CabinetID = SC.SC_CabinetID
        WHERE I.IS_Status = '存储中' AND SC.SC_Status != '空闲'
    )
    BEGIN
        RAISERROR('存入失败：对应柜子非空闲状态，无法存入', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    UPDATE StorageCabinet
    SET SC_Status = '使用中'
    FROM StorageCabinet SC
    INNER JOIN inserted I ON SC.SC_CabinetID = I.IS_CabinetID
    WHERE I.IS_Status = '存储中';
END;
GO

-- ==================== 存放物品状态更新 ====================

CREATE TRIGGER TR_ItemStorage_Update
ON ItemStorage
AFTER UPDATE
AS
BEGIN
    IF UPDATE(IS_Status)
    BEGIN
        UPDATE ItemStorage
        SET IS_PickupTime = GETDATE()
        FROM ItemStorage IS_
        INNER JOIN inserted I ON IS_.IS_ItemID = I.IS_ItemID
        WHERE I.IS_Status = '已取走' AND IS_.IS_PickupTime IS NULL;
        
        UPDATE StorageCabinet
        SET SC_Status = '空闲'
        FROM StorageCabinet SC
        INNER JOIN (
            SELECT DISTINCT I.IS_CabinetID
            FROM inserted I
            WHERE I.IS_Status IN ('已取走', '丢失')
        ) AS Taken ON SC.SC_CabinetID = Taken.IS_CabinetID
        WHERE SC.SC_Status = '使用中'
          AND NOT EXISTS (
              SELECT 1 
              FROM ItemStorage IS_
              WHERE IS_.IS_CabinetID = SC.SC_CabinetID
                AND IS_.IS_Status IN ('存储中', '逾期未取')
          );
    END
END;
GO

-- ==================== 报修单自动更新修复时间 ====================

CREATE TRIGGER TR_RepairOrder_StatusChange
ON RepairOrder
AFTER UPDATE
AS
BEGIN
    IF UPDATE(RO_RepairStatus)
    BEGIN
        UPDATE RepairOrder
        SET RO_RepairTime = GETDATE()
        FROM RepairOrder RO
        INNER JOIN inserted I ON RO.RO_RepairID = I.RO_RepairID
        INNER JOIN deleted D ON RO.RO_RepairID = D.RO_RepairID
        WHERE D.RO_RepairStatus = '处理中'
          AND I.RO_RepairStatus IN ('已完成', '无法修复')
          AND RO.RO_RepairTime IS NULL;
    END
END;
GO

-- ==================== 水电费账单自动更新缴费时间 ====================

CREATE TRIGGER TR_UtilityBill_Payment
ON UtilityBill
AFTER UPDATE
AS
BEGIN
    IF UPDATE(UB_PaymentStatus)
    BEGIN
        UPDATE UtilityBill
        SET UB_PaymentTime = GETDATE()
        FROM UtilityBill UB
        INNER JOIN inserted I ON UB.UB_BillID = I.UB_BillID
        WHERE I.UB_PaymentStatus = '已缴费' AND UB.UB_PaymentTime IS NULL;
    END
END;
GO