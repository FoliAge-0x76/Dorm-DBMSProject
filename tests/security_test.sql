-- ==================== 创建示例登录用户并分配角色 ====================

-- 创建宿舍管理员登录账户
CREATE LOGIN DormManager WITH PASSWORD = 'Manager@2024', DEFAULT_DATABASE = Dorm;
CREATE USER DormManager FOR LOGIN DormManager;
ALTER ROLE Role_DormManager ADD MEMBER DormManager;
GO

-- 创建学生登录账户示例（实际使用时应动态创建）
CREATE LOGIN S001 WITH PASSWORD = 'Student@2024', DEFAULT_DATABASE = Dorm;
CREATE USER S001 FOR LOGIN S001;
ALTER ROLE Role_Student ADD MEMBER S001;
GO

-- 创建访客登录账户
CREATE LOGIN Guest001 WITH PASSWORD = 'Guest@2024', DEFAULT_DATABASE = Dorm;
CREATE USER Guest001 FOR LOGIN Guest001;
ALTER ROLE Role_Guest ADD MEMBER Guest001;
GO

-- ==================== 权限验证查询 ====================

-- 查看所有角色及其成员
SELECT 
    r.name AS RoleName,
    m.name AS MemberName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY r.name, m.name;
GO

-- 查看特定角色的权限
SELECT 
    p.class_desc,
    OBJECT_NAME(p.major_id) AS ObjectName,
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals r ON p.grantee_principal_id = r.principal_id
WHERE r.name = 'Role_DormManager'
ORDER BY ObjectName;
GO

-- 查询权限示例
EXECUTE AS USER = 'S001';
GO

SELECT S_StudentID, S_Name, S_Gender, PresenceStatus 
FROM V_StudentInfo 
WHERE S_StudentID = USER_NAME();
GO

REVERT;
GO
-- 无权限查询
EXECUTE AS USER = 'S001';
GO

SELECT * FROM V_UnbalancedVisitorAccess;
GO

REVERT;
GO