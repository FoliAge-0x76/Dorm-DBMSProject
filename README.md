## 项目环境
* SQL版本：Microsoft SQL Server 17.0
* IDE：Microsoft SSMS 22
## 目录结构说明
* `/docs` - 设计文档和报告
	* `/requirements` - 需求分析
	* `/design` - 设计内容
	* `/reports` - 实验报告
* `/sql` - SQL 脚本
	* `/schema` - 模式定义 
	* `/data` - 数据操作
	* `/role` - 角色定义
	* `/procedures` - 存储过程 函数
* `test` - 测试查询
## 快速开始
1. 按编号顺序执行 `sql/schema` 路径下的前四个 SQL 脚本
2. 执行 `sql/data/01_insert_test_data.sql`
3. 运行 `tests/test_queries.sql` 验证
## 待办
1. 审计
1. 报告最终综合