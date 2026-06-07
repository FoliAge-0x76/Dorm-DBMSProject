DROP PROCEDURE IF EXISTS USP_Maintenance_RefreshDormStudentCount;
GO
-- 更新宿舍人数（修正触发器可能遗漏的数据）
CREATE PROCEDURE USP_Maintenance_RefreshDormStudentCount
    @BuildingID NVARCHAR(20) = NULL
AS
BEGIN
    UPDATE Dormitory
    SET D_StudentCount = (
        SELECT COUNT(*) 
        FROM Student 
        WHERE Student.S_BuildingID = Dormitory.D_BuildingID 
          AND Student.S_RoomID = Dormitory.D_RoomID
    );
END;
GO