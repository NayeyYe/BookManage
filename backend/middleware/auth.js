const jwt = require('jsonwebtoken');
const { getConnection } = require('../config/database');

// 验证JWT令牌
const authenticateToken = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
        
        if (!token) {
            return res.status(401).json({ error: 'Access token missing' });
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
            return res.status(401).json({ error: 'User does not exist' });
        }
        
        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(403).json({ error: 'Invalid access token' });
        }
        console.error('Authentication failed:', error);
        res.status(500).json({ error: 'Authentication failed' });
    }
};

// 验证管理员权限
const authenticateAdmin = async (req, res, next) => {
    try {
        // First perform basic authentication
        await new Promise((resolve, reject) => {
            authenticateToken(req, res, (err) => {
                if (err) reject(err);
                else resolve();
            });
        });
        
        // Check if user is an administrator
        const connection = await getConnection();
        const [admins] = await connection.execute(
            'SELECT user_id FROM user_auth WHERE user_id = ? AND is_admin = 1',
            [req.user.uid]
        );
        
        if (admins.length === 0) {
            return res.status(403).json({ error: 'Admin permissions required' });
        }
        
        next();
    } catch (error) {
        console.error('Admin authentication failed:', error);
        res.status(500).json({ error: 'Admin authentication failed' });
    }
};

module.exports = {
    authenticateToken,
    authenticateAdmin
};
