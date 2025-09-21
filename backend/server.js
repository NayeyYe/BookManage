// 这是服务器入口文件
// 创建Express应用

const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

// 加载环境变量
require('dotenv').config();

// 创建Express应用
const app = express();

// 使用中间件
app.use(cors());
app.use(express.json());

// 创建MySQL连接池
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// 测试数据库连接
app.get('/connect', (req, res) => {
    res.send('图书管理系统服务器已连接');
});

const port  = process.env.DB_PORT || 3306;
app.listen(port, () =>{
    console.log(`服务器正在运行，监听端口 ${port}`);
});