-- ==================== 模块1：住宿模块 ====================
-- 1. 验证学生住宿信息（验证宿舍分配是否正确）
SELECT S_StudentID, S_Name, S_BuildingID, S_RoomID, S_BedID, S_IsDormLeader
FROM Student
ORDER BY S_RoomID, S_BedID;

-- 2. 验证宿舍住宿人数统计（验证 D_StudentCount 与实际住宿人数是否一致）
SELECT 
    D.D_RoomID,
    D.D_StudentCount AS RecordedCount,
    COUNT(S.S_StudentID) AS ActualCount,
    CASE WHEN D.D_StudentCount = COUNT(S.S_StudentID) THEN '一致' ELSE '不一致' END AS Status
FROM Dormitory D
LEFT JOIN Student S ON D.D_BuildingID = S.S_BuildingID AND D.D_RoomID = S.S_RoomID
GROUP BY D.D_RoomID, D.D_StudentCount;

-- 3. 查询各宿舍宿舍长信息
SELECT 
    D.D_RoomID,
    S.S_StudentID AS LeaderID,
    S.S_Name AS LeaderName
FROM Dormitory D
INNER JOIN Student S ON D.D_BuildingID = S.S_BuildingID AND D.D_RoomID = S.S_RoomID
WHERE S.S_IsDormLeader = 1;

-- 4. 查询指定宿舍的住宿名单（如101宿舍）
SELECT S_StudentID, S_Name, S_BedID, S_IsDormLeader
FROM Student
WHERE S_BuildingID = 'A栋' AND S_RoomID = '101'
ORDER BY S_BedID;