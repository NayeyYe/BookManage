# 后端测试说明

## 测试环境准备

在运行测试之前，需要确保数据库中有适当的数据。测试中使用的用户ID和图书ID需要在数据库中存在才能通过测试。

## 测试数据要求

### 用户相关测试
- 用户ID: S001 (需要在borrowers表中存在)
- 管理员ID: (需要在borrowers表中存在且具有管理员权限)

### 图书相关测试
- 图书ID: B001 (需要在books表中存在)
- 出版商ID: test (需要在publishers表中存在)

## 运行测试

```bash
# 进入后端目录
cd backend

# 运行所有测试
npm test

# 运行特定测试文件
npx jest tests/user.test.js
npx jest tests/book.test.js
npx jest tests/borrow.test.js
npx jest tests/admin.test.js
```

## 测试文件说明

1. `user.test.js` - 用户相关测试（注册、登录、获取用户信息等）
2. `book.test.js` - 图书相关测试（添加、更新、删除、搜索图书等）
3. `borrow.test.js` - 借阅相关测试（借书、还书、获取记录等）
4. `admin.test.js` - 管理员相关测试（管理用户、获取记录等）

## 注意事项

1. 测试需要数据库连接，确保数据库服务正在运行
2. 测试中使用的ID需要在数据库中存在
3. 部分测试可能需要特定的数据库状态才能通过
4. 测试会实际操作数据库，请确保使用测试数据库而非生产数据库
