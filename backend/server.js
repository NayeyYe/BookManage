// 这是服务器入口文件
// 创建Express应用

const express = require('express');
const cors = require('cors');

// 加载环境变量
require('dotenv').config();

// 创建Express应用
const app = express();

// 使用中间件
app.use(cors());
app.use(express.json());

// 导入路由
const bookRoutes = require('./routes/bookRoutes');
const userRoutes = require('./routes/userRoutes');
const borrowRoutes = require('./routes/borrowRoutes');
const adminRoutes = require('./routes/adminRoutes');

// 使用路由
app.use('/api/books', bookRoutes);
app.use('/api/users', userRoutes);
app.use('/api/borrow', borrowRoutes);
app.use('/api/admin', adminRoutes);

// 测试数据库连接
app.get('/connect', (req, res) => {
    res.send('图书管理系统服务器已连接');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`服务器正在运行，监听端口 ${port}`);
});
