const { getConnection } = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// 用户注册
const register = async (req, res) => {
    try {
        const { uid, name, phone, identity_type, student_id, employee_id, password } = req.body;
        const connection = await getConnection();
        
        // 检查用户是否已存在
        const [existing] = await connection.execute('SELECT uid FROM borrowers WHERE uid = ?', [uid]);
        if (existing.length > 0) {
            return res.status(400).json({ error: '用户ID已存在' });
        }
        
        // 密码加密
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);
        
        // 开始事务
        await connection.beginTransaction();
        
        try {
            // 插入借阅者信息
            await connection.execute(
                'INSERT INTO borrowers (uid, name, phone, identity_type, student_id, employee_id, borrowed_count, registration_date, borrowing_status) VALUES (?, ?, ?, ?, ?, ?, ?, CURDATE(), ?)',
                [uid, name, phone, identity_type, student_id, employee_id, 0, 'active']
            );
            
            // 插入用户认证信息
            await connection.execute(
                'INSERT INTO user_auth (user_id, password_hash) VALUES (?, ?)',
                [uid, hashedPassword]
            );
            
            // 提交事务
            await connection.commit();
            
            res.status(201).json({ message: '用户注册成功' });
        } catch (error) {
            // 回滚事务
            await connection.rollback();
            throw error;
        }
    } catch (error) {
        console.error('用户注册失败:', error);
        res.status(500).json({ error: '用户注册失败' });
    }
};

// 用户登录
const login = async (req, res) => {
    try {
        const { uid, password } = req.body;
        const connection = await getConnection();
        
        // 获取用户信息
        const [users] = await connection.execute(
            'SELECT b.*, ua.password_hash FROM borrowers b JOIN user_auth ua ON b.uid = ua.user_id WHERE b.uid = ?',
            [uid]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: '用户不存在' });
        }
        
        const user = users[0];
        
        // 验证密码
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);
        if (!isPasswordValid) {
            return res.status(401).json({ error: '密码错误' });
        }
        
        // 检查账户状态
        if (user.borrowing_status === 'suspended') {
            return res.status(401).json({ error: '账户已被冻结' });
        }
        
        // 生成JWT令牌
        const token = jwt.sign(
            { uid: user.uid, name: user.name, identity_type: user.identity_type },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );
        
        // 获取用户类型名称
        const [userTypes] = await connection.execute(
            'SELECT type_name FROM user_types WHERE type_id = ?',
            [user.identity_type]
        );
        
        const userTypeName = userTypes.length > 0 ? userTypes[0].type_name : '未知';
        
        res.json({
            message: '登录成功',
            token,
            user: {
                uid: user.uid,
                name: user.name,
                phone: user.phone,
                identity_type: user.identity_type,
                identity_type_name: userTypeName,
                borrowing_status: user.borrowing_status,
                borrowed_count: user.borrowed_count
            }
        });
    } catch (error) {
        console.error('用户登录失败:', error);
        res.status(500).json({ error: '用户登录失败' });
    }
};

// 获取用户信息
const getUserById = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        const [rows] = await connection.execute(`
            SELECT b.*, ut.type_name as identity_type_name 
            FROM borrowers b 
            JOIN user_types ut ON b.identity_type = ut.type_id 
            WHERE b.uid = ?
        `, [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ error: '用户未找到' });
        }
        
        res.json(rows[0]);
    } catch (error) {
        console.error('获取用户信息失败:', error);
        res.status(500).json({ error: '获取用户信息失败' });
    }
};

// 更新用户信息
const updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone } = req.body;
        const connection = await getConnection();
        
        // 检查用户是否存在
        const [existing] = await connection.execute('SELECT uid FROM borrowers WHERE uid = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ error: '用户未找到' });
        }
        
        // 更新用户信息
        const [result] = await connection.execute(
            'UPDATE borrowers SET name = ?, phone = ? WHERE uid = ?',
            [name, phone, id]
        );
        
        res.json({ message: '用户信息更新成功', affectedRows: result.affectedRows });
    } catch (error) {
        console.error('更新用户信息失败:', error);
        res.status(500).json({ error: '更新用户信息失败' });
    }
};

// 获取用户借阅记录
const getUserBorrowingRecords = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        // 检查用户是否存在
        const [existing] = await connection.execute('SELECT uid FROM borrowers WHERE uid = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ error: '用户未找到' });
        }
        
        const [rows] = await connection.execute(`
            SELECT br.*, b.title as book_title
            FROM borrowing_records br
            JOIN books b ON br.book_id = b.book_id
            WHERE br.borrower_id = ?
            ORDER BY br.borrow_date DESC
        `, [id]);
        
        res.json(rows);
    } catch (error) {
        console.error('获取用户借阅记录失败:', error);
        res.status(500).json({ error: '获取用户借阅记录失败' });
    }
};

// 获取用户罚款记录
const getUserFineRecords = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        // 检查用户是否存在
        const [existing] = await connection.execute('SELECT uid FROM borrowers WHERE uid = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ error: '用户未找到' });
        }
        
        const [rows] = await connection.execute(`
            SELECT fr.*, b.title as book_title
            FROM fine_records fr
            JOIN books b ON fr.book_id = b.book_id
            WHERE fr.borrower_id = ?
            ORDER BY fr.borrow_date DESC
        `, [id]);
        
        res.json(rows);
    } catch (error) {
        console.error('获取用户罚款记录失败:', error);
        res.status(500).json({ error: '获取用户罚款记录失败' });
    }
};

module.exports = {
    register,
    login,
    getUserById,
    updateUser,
    getUserBorrowingRecords,
    getUserFineRecords
};
