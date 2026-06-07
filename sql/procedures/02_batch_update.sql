DROP PROCEDURE IF EXISTS USP_Batch_CleanExpiredItems;
GO
-- 批量清理过期物品（逾期未取）
CREATE PROCEDURE USP_Batch_CleanExpiredItems
    @ExpiredDays INT = 90,
    @AutoFreeCabinet BIT = 1  -- 是否自动释放柜子
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    -- 将超过指定天数未取走的物品状态改为'逾期未取'
        DECLARE @ExpiredItems TABLE (
        IS_ItemID NVARCHAR(20),
        IS_CabinetID NVARCHAR(20),
        IS_StudentID NVARCHAR(20),
        IS_ItemName NVARCHAR(50),
        IS_DepositTime DATETIME
    );
        
    INSERT INTO @ExpiredItems (IS_ItemID, IS_CabinetID, IS_StudentID, IS_ItemName, IS_DepositTime)
    SELECT 
        IS_ItemID,
        IS_CabinetID,
        IS_StudentID,
        IS_ItemName,
        IS_DepositTime
    FROM ItemStorage
    WHERE IS_Status = '存储中'
        AND IS_DepositTime < DATEADD(DAY, -@ExpiredDays, GETDATE())
        AND IS_PickupTime IS NULL;
        
    DECLARE @UpdatedCount INT = (SELECT COUNT(*) FROM @ExpiredItems);
        
    -- 如果没有过期物品，直接返回
    IF @UpdatedCount = 0
    BEGIN
        SELECT '没有需要清理的过期物品' AS Message;
        COMMIT TRANSACTION;
        RETURN 0;
    END
        
    -- 更新物品状态为'逾期未取'
    UPDATE ItemStorage
    SET IS_Status = '逾期未取'
    WHERE IS_ItemID IN (SELECT IS_ItemID FROM @ExpiredItems);
    
    IF @AutoFreeCabinet = 1
    BEGIN
        UPDATE StorageCabinet
        SET SC_Status = '空闲'
        WHERE SC_Status = '使用中' AND SC_CabinetID IN (
            SELECT SC.SC_CabinetID
            FROM StorageCabinet SC
            WHERE NOT EXISTS (
                SELECT 1 
                FROM ItemStorage IS_
                WHERE IS_.IS_CabinetID = SC.SC_CabinetID
                    AND IS_.IS_Status IN ('存储中')
            )
        );
    END

    COMMIT TRANSACTION;

    SELECT 
        @UpdatedCount AS CleanedCount,
        @ExpiredDays AS ExpiredDaysThreshold,
        GETDATE() AS CleanupTime;
END;
GO