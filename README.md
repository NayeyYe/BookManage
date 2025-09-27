# 图书管理系统

一个基于Vue.js和Node.js的图书借阅管理系统，支持用户注册、登录、图书搜索、借阅管理、罚款处理等功能。

## 项目简介

本系统是一个完整的图书管理解决方案，包含前端用户界面和后端API服务。系统支持多种用户角色（学生、教师、管理员），提供图书借阅、归还、罚款管理等功能。

## 技术栈

### 前端
- **Vue 3** - 渐进式JavaScript框架
- **Vue Router** - 官方路由管理器
- **Axios** - HTTP客户端
- **Vite** - 前端构建工具

### 后端
- **Node.js** - JavaScript运行时
- **Express** - Web应用框架
- **MySQL** - 关系型数据库

## 本地运行步骤

### 环境要求
- Node.js 22.0+
- MySQL 8.0+
- npm 11.6+

### 1. 数据库配置

#### 安装MySQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server
```

#### 启动MySQL服务
```bash
# Windows
net start mysql

# Ubuntu/Debian
sudo systemctl start mysql
```

#### 配置环境变量

创建 `.env` 文件：
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=你的MySQL密码
DB_NAME=bookmanage
PORT=3000
```

#### 创建数据库

```bash
-- 使用setup脚本
cd database
./setup.sh(或者./setup.bat)

-- (可选)插入基本数据
cd seeds
```

```mysql
-- 登录mysql
mysql -u root -p

-- 插入数据
sources teachers.sql
sources students.sql
```

### 2. 后端配置

#### 进入后端目录
```bash
cd backend
```

#### 安装依赖
```bash
npm install
```

#### 启动后端服务
```bash
npm start
```

后端服务将在 `http://localhost:3000` 启动

### 3. 前端配置

#### 进入前端目录
```bash
cd frontend
```

#### 安装依赖
```bash
npm install
```

#### 配置API地址
编辑 `frontend/src/utils/api.js` 文件，确保 `baseURL` 配置正确：
```javascript
const api = axios.create({
  baseURL: 'http://localhost:3000/api', // 确保与后端地址匹配
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});
```

#### 启动前端服务
```bash
npm run dev
```

前端服务将在 `http://localhost:5173` 启动

### 4. 访问应用

打开浏览器访问：`http://localhost:5173`

## 项目结构

```
BookManage/
├── backend/                 # 后端服务
│   ├── config/             # 配置文件
│   ├── controllers/        # 控制器
│   ├── middleware/         # 中间件
│   ├── routes/             # 路由
│   ├── utils/              # 工具函数
│   ├── tests/              # 测试文件
│   ├── server.js           # 服务器入口
│   └── package.json        # 后端依赖配置
├── frontend/               # 前端应用
│   ├── src/
│   │   ├── components/     # 可重用组件
│   │   ├── views/          # 页面组件
│   │   ├── router/         # 路由配置
│   │   ├── utils/          # 工具函数
│   │   ├── App.vue         # 根组件
│   │   └── main.js         # 入口文件
│   ├── package.json        # 前端依赖配置
│   └── vite.config.js      # Vite配置
├── database/               # 数据库相关
│   ├── migrations/         # 数据库迁移
│   ├── schema/            # 数据库结构
│   └── seeds/             # 种子数据
└── README.md              # 项目说明文档
```

## 功能说明

### 用户功能
- **用户注册**：支持学生、教师、管理员等不同身份类型注册
- **用户登录**：基于JWT的安全认证
- **个人中心**：查看个人信息、当前借阅、历史记录、罚款信息
- **图书搜索**：支持按书名、作者、标签、出版社、ISBN搜索
- **在线借书**：快速借阅功能
- **在线还书**：便捷的还书操作
- **罚款查询**：查看罚款记录和缴纳状态

### 管理员功能
- **用户管理**：查看、搜索、冻结/激活用户账户
- **借阅记录管理**：查看所有用户的借阅记录
- **罚款记录管理**：查看所有罚款记录
- **登录日志**：查看用户登录历史和IP地址

### 系统功能
- **权限控制**：基于用户角色的访问控制
- **数据统计**：借阅量、罚款等数据统计
- **自动计算**：逾期天数、罚款金额自动计算
- **实时更新**：数据变更实时反映到界面

## 测试账号

### 管理员账号
- 用户ID: `admin`
- 密码: `admin123`

### 测试用户账号
- 用户ID: `S001`
- 密码: `password123`

## 常见问题

### 1. 数据库连接失败
**问题**：后端启动时显示数据库连接错误

**解决方案**：
```bash
# 检查MySQL服务状态
net start mysql  # Windows
brew services start mysql  # macOS

# 检查数据库配置
# 确认根目录中.env 文件中的数据库配置正确

# 重新创建数据库
cd database
./setup.sh
```

### 2. 前端无法连接后端

**问题**：前端显示"连接失败"或API请求错误

**解决方案**：
```bash
# 检查后端服务状态
curl http://localhost:3000/api

# 检查前端API配置
# 确认 frontend/src/utils/api.js 中的 baseURL 正确

# 检查CORS配置
# 确认后端已配置允许跨域访问
```

### 3. 端口冲突
**问题**：启动服务时提示端口被占用

**解决方案**：
```bash
# 查找占用端口的进程
netstat -ano | findstr :3000  # Windows
lsof -i :3000  # macOS/Linux

# 终止占用进程
taskkill /PID <进程ID> /F  # Windows
kill -9 <进程ID>  # macOS/Linux

# 或者修改端口配置
# 在 backend/.env 中修改 PORT
# 在前端启动时 Vite 会自动分配可用端口
```

### 4. 依赖安装失败
**问题**：npm install 时出现错误

**解决方案**：
```bash
# 清除npm缓存
npm cache clean --force

# 删除依赖并重新安装
rm -rf node_modules package-lock.json
npm install
```

### 5. 前端页面空白
**问题**：访问前端页面时显示空白

**解决方案**：
```bash
# 检查浏览器控制台错误
# 按F12打开开发者工具，查看Console标签

# 重新启动前端服务
cd frontend
npm run dev

# 检查路由配置
# 确认 frontend/src/router/index.js 配置正确
```

## 开发说明

### 添加新功能
1. 后端：在 `backend/controllers/` 添加新的控制器方法
2. 前端：在 `frontend/src/views/` 添加新的页面组件
3. 路由：在 `frontend/src/router/index.js` 添加新路由
4. API：在 `frontend/src/utils/api.js` 添加新的API调用

### 数据库修改
1. 在 `database/migrations/` 中添加新的迁移文件
2. 运行迁移：`npm run migrate`
3. 更新相关模型和控制器

### 样式修改
- 全局样式：在 `frontend/src/main.js` 中导入CSS文件
- 组件样式：在Vue组件的 `<style>` 标签中编写
- 使用CSS预处理器：项目支持Sass/Less

## 联系方式

如有问题或建议，请联系开发团队。

---

**注意**：本项目仅用于本地开发和测试环境，请勿在生产环境中使用。
