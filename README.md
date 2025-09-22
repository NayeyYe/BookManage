# BookManage 图书管理系统

这是一个基于Vue.js和MySQL的图书管理系统。

## 前端项目设置

```
npm install
```

### 编译和热重载以进行开发
```
npm run serve
```

### 编译和压缩以用于生产
```
npm run build
```

### Lints和修复文件
```
npm run lint
```

### 自定义配置
See [Configuration Reference](https://cli.vuejs.org/config/).

## 后端数据库设置

### 数据库初始化

有两种方式可以初始化数据库：

1. 使用批处理脚本（推荐）：
   - Windows系统：运行 `database/setup.bat`
   - Linux/Mac系统：运行 `database/setup.sh`

2. 手动执行SQL文件：
   按以下顺序依次执行SQL文件：
   - database/schema/tables/ 目录下的所有文件
   - database/schema/functions/ 目录下的所有文件
   - database/schema/procedures/ 目录下的所有文件
   - database/schema/triggers/ 目录下的所有文件
   - database/schema/events/ 目录下的所有文件
   - database/seeds/ 目录下的所有文件

### 数据库配置

在运行脚本之前，请确保修改 `database/setup.bat` 或 `database/setup.sh` 中的数据库连接参数：
- MYSQL_HOST：MySQL服务器地址
- MYSQL_USER：MySQL用户名
- MYSQL_PASSWORD：MySQL密码
- MYSQL_DATABASE：数据库名称
