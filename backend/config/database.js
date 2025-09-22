const mysql = require('mysql2');
require('dotenv').config();

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

// 获取数据库连接
const getConnection = () => {
    return pool.promise();
};

module.exports = {
    getConnection
};
