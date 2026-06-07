DROP PROCEDURE IF EXISTS USP_Report_AccessStatistics;
GO
-- 出入统计日报/月报
CREATE PROCEDURE USP_Report_AccessStatistics
    @StartDate DATE,
    @EndDate DATE,
    @BuildingID NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CAST(AR.AR_AccessTime AS DATE) AS AccessDate,
        AR.AR_BuildingID,
        -- 总出入人次
        COUNT(*) AS TotalAccessCount,
        -- 学生出入统计
        COUNT(CASE WHEN AR.AR_AccessType = '学生来寝' THEN 1 END) AS StudentArrivalCount,
        COUNT(CASE WHEN AR.AR_AccessType = '学生离寝' THEN 1 END) AS StudentDepartureCount,
        -- 访客出入统计
        COUNT(CASE WHEN AR.AR_AccessType = '访客来寝' THEN 1 END) AS VisitorArrivalCount,
        COUNT(CASE WHEN AR.AR_AccessType = '访客离寝' THEN 1 END) AS VisitorDepartureCount,
        -- 净流入（来寝 - 离寝）
        COUNT(CASE WHEN AR.AR_AccessType IN ('学生来寝', '访客来寝') THEN 1 END) - 
        COUNT(CASE WHEN AR.AR_AccessType IN ('学生离寝', '访客离寝') THEN 1 END) AS NetInflow,
        -- 访客独立统计
        COUNT(DISTINCT CASE WHEN AR.AR_AccessType LIKE '访客%' THEN AR.AR_VisitorName END) AS UniqueVisitorCount
    FROM AccessRecord AR
    WHERE AR.AR_AccessTime >= @StartDate 
      AND AR.AR_AccessTime < DATEADD(DAY, 1, @EndDate)
      AND (@BuildingID IS NULL OR AR.AR_BuildingID = @BuildingID)
    GROUP BY CAST(AR.AR_AccessTime AS DATE), AR.AR_BuildingID
    ORDER BY AccessDate, AR.AR_BuildingID;
END;
GO