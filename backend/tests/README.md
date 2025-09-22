# 后端测试说明

## 运行测试

1. 确保已安装所有依赖：
   ```
   cd backend
   npm install
   ```

2. 运行所有测试：
   ```
   cd backend
   npm test
   ```

3. 运行特定测试文件：
   ```
   cd backend
   npx jest tests/book.test.js
   ```

4. 运行测试并查看覆盖率：
   ```
   cd backend
   npx jest --coverage
   ```

## 测试前提条件

为了确保测试能够正常运行，需要满足以下条件：

1. 数据库服务器正在运行
2. 数据库中已创建了所有必要的表结构
3. `publishers`表中至少有一条记录（publisher_id=1）
4. 环境变量已正确配置（DB_HOST, DB_USER, DB_PASSWORD, DB_NAME等）

## 解决外键约束错误

测试中出现的外键约束错误是因为添加图书时，`publisher_id`在`publishers`表中不存在。要解决这个问题：

1. 确保`publishers`表中有数据：
   ```sql
   INSERT INTO publishers (publisher_id, publisher_name) VALUES ('test', '测试出版社');
   ```

2. 或者修改测试数据，使用数据库中实际存在的`publisher_id`。

注意：`publisher_id`是VARCHAR类型，不是数字。

## 测试数据准备

建议在运行测试前，先在数据库中准备一些测试数据：

1. 确保`publishers`表中有至少一条记录：
   ```sql
   INSERT INTO publishers (publisher_id, publisher_name) VALUES ('test', '测试出版社');
   ```

2. 为了通过所有测试，您需要确保数据库中有以下数据：
   - ID为'978-0-12-345678-9'的图书记录（用于GET、PUT、DELETE和重复ID测试）
   - ID为'978-0-98-765432-1'的图书记录不能存在（用于添加图书测试）

3. 如果您的数据库中还没有图书记录，可以使用以下SQL语句添加测试数据：
   ```sql
   -- 添加用于测试的图书记录（请根据实际情况调整publisher_id）
   INSERT INTO books (book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location) 
   VALUES ('978-0-12-345678-9', '测试图书', '978-0-12-345678-9', 'test', 2025, 10, 10, 'A区001架');
   ```

4. 如果seed_books.sql文件中有数据，可以运行它来初始化数据：
   ```
   cd database
   # 根据您的数据库客户端调整以下命令
   mysql -u root -p bookmanage < seeds/seed_books.sql
   ```

## 测试说明

当前的测试文件`book.test.js`包含了以下测试用例：

1. **GET /api/books** - 测试获取所有图书
2. **GET /api/books/:id** - 测试根据ID获取图书
3. **POST /api/books** - 测试添加新图书
4. **PUT /api/books/:id** - 测试更新图书信息
5. **DELETE /api/books/:id** - 测试删除图书
6. **GET /api/books/search/:query** - 测试搜索图书

注意：部分测试用例需要数据库中存在特定的数据才能通过。
