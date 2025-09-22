const jwt = require('jsonwebtoken');
const { getConnection } = require('../config/database');

// 验证JWT令牌
const authenticateToken = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
        
        if (!token) {
            return res.status(401).json({ error: '访问令牌缺失' });
        }
        
        // 验证令牌
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        
        // 验证用户是否存在
        const connection = await getConnection();
        const [users] = await connection.execute(
            'SELECT uid FROM borrowers WHERE uid = ?',
            [decoded.uid]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: '用户不存在' });
        }
        
        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(403).json({ error: '无效的访问令牌' });
        }
        console.error('身份验证失败:', error);
        res.status(500).json({ error: '身份验证失败' });
    }
};

// 验证管理员权限
const authenticateAdmin = async (req, res, next) => {
    try {
        // 首先进行基本的身份验证
        await new Promise((resolve, reject) => {
            authenticateToken(req, res, (err) => {
                if (err) reject(err);
                else resolve();
            });
        });
        
        // 检查用户是否为管理员
        const connection = await getConnection();
        const [admins] = await connection.execute(
            'SELECT user_id FROM user_auth WHERE user_id = ? AND is_admin = 1',
            [req.user.uid]
        );
        
        if (admins.length === 0) {
            return res.status(403).json({ error: '需要管理员权限' });
        }
        
        next();
    } catch (error) {
        console.error('管理员身份验证失败:', error);
        res.status(500).json({ error: '管理员身份验证失败' });
    }
};

module.exports = {
    authenticateToken,
    authenticateAdmin
};
