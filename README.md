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
	* `/queries` - 查询
	* `/procedures` - 存储过程 函数
* `test` - 测试查询
## 快速开始
1. 执行 `sql/schema/01_create_tables.sql`
2. 执行 `sql/data/01_insert_test_data.sql`
3. 运行 `tests/test_queries.sql` 验证
## 待办
1. 触发器与审计
1. 测试查询补全
1. 存储过程
1. 报告补全