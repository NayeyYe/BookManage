const { getConnection } = require('../config/database');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

// 用户注册
const register = async (req, res) => {
    try {
        const { uid, name, phone, identity_type, student_id, employee_id, password } = req.body;
        const connection = await getConnection();
        
        // Get current date
        const registration_date = new Date().toISOString().split('T')[0];
        
        console.log('Registering user with data:', { uid, name, phone, identity_type, student_id, employee_id, password, registration_date });
        
        // 调用存储过程用户注册，直接传递明文密码，让存储过程使用SHA2进行哈希
        await connection.execute(
            'CALL userRegister(?, ?, ?, ?, ?, ?, ?, ?, @result_code, @result_message)',
            [uid, name, phone, identity_type, student_id, employee_id, password, registration_date]
        );
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message');
        
        console.log('Registration result:', result[0]);
        
        if (result[0].result_code !== 0) {
            return res.status(400).json({ error: result[0].result_message });
        }
        
        res.status(201).json({ message: result[0].result_message });
    } catch (error) {
        console.error('User registration failed:', error);
        res.status(500).json({ error: 'User registration failed' });
    }
};

// 用户登录
const login = async (req, res) => {
    try {
        const { uid, password } = req.body;
        const connection = await getConnection();
        
        // 直接传递明文密码给存储过程，让存储过程使用SHA2进行哈希
        // 调用存储过程用户登录
        await connection.execute('CALL userLogin(?, ?, @result_code, @result_message, @user_name, @user_type, @borrowing_status)', [uid, password]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message, @user_name as user_name, @user_type as user_type, @borrowing_status as borrowing_status');
        
        if (result[0].result_code !== 0) {
            return res.status(401).json({ error: result[0].result_message });
        }

        // 生成JWT令牌
        const token = jwt.sign(
            { uid: uid, name: result[0].user_name, identity_type: result[0].user_type },
            process.env.JWT_SECRET || 'default_secret_key',
            { expiresIn: '24h' }
        );
        
        res.json({
            message: result[0].result_message,
            token,
            user: {
                uid: uid,
                name: result[0].user_name,
                identity_type: result[0].user_type,
                borrowing_status: result[0].borrowing_status
            }
        });
    } catch (error) {
        console.error('User login failed:', error);
        res.status(500).json({ error: 'User login failed' });
    }
};

// 获取用户信息
const getUserById = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        // 调用存储过程获取用户信息
        await connection.execute('CALL getUserById(?, @result_code, @result_message)', [id]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message');
        
        if (result[0].result_code === 1) {
            return res.status(404).json({ error: result[0].result_message });
        } else if (result[0].result_code !== 0) {
            return res.status(500).json({ error: result[0].result_message });
        }
        
        // 获取实际查询结果
        const [rows] = await connection.execute(`
            SELECT b.*, ut.type_name as identity_type_name 
            FROM borrowers b 
            JOIN user_types ut ON b.identity_type = ut.type_id 
            WHERE b.uid = ?
        `, [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        res.json(rows[0]);
    } catch (error) {
        console.error('Failed to get user information:', error);
        res.status(500).json({ error: 'Failed to get user information' });
    }
};

// 更新用户信息
const updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone } = req.body;
        const connection = await getConnection();
        
        // 调用存储过程更新用户信息
        await connection.execute('CALL updateUser(?, ?, ?, @result_code, @result_message)', [id, name, phone]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message');
        
        if (result[0].result_code === 1) {
            return res.status(404).json({ error: result[0].result_message });
        } else if (result[0].result_code !== 0) {
            return res.status(500).json({ error: result[0].result_message });
        }
        
        res.json({ message: result[0].result_message, affectedRows: 1 });
    } catch (error) {
        console.error('Failed to update user information:', error);
        res.status(500).json({ error: 'Failed to update user information' });
    }
};

// 获取用户借阅记录
const getUserBorrowingRecords = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        // 调用存储过程获取用户借阅记录
        await connection.execute('CALL getUserBorrowingRecords(?, @result_code, @result_message)', [id]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message');
        
        if (result[0].result_code === 1) {
            return res.status(404).json({ error: result[0].result_message });
        } else if (result[0].result_code !== 0) {
            return res.status(500).json({ error: result[0].result_message });
        }
        
        // 获取实际查询结果
        const [rows] = await connection.execute(`
            SELECT br.*, b.title as book_title
            FROM borrowing_records br
            JOIN books b ON br.book_id = b.book_id
            WHERE br.borrower_id = ?
            ORDER BY br.borrow_date DESC
        `, [id]);
        
        res.json(rows);
    } catch (error) {
        console.error('Failed to get user borrowing records:', error);
        res.status(500).json({ error: 'Failed to get user borrowing records' });
    }
};

// 获取用户罚款记录
const getUserFineRecords = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        // 调用存储过程获取用户罚款记录
        await connection.execute('CALL getUserFineRecords(?, @result_code, @result_message)', [id]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message');
        
        if (result[0].result_code === 1) {
            return res.status(404).json({ error: result[0].result_message });
        } else if (result[0].result_code !== 0) {
            return res.status(500).json({ error: result[0].result_message });
        }
        
        // 获取实际查询结果
        const [rows] = await connection.execute(`
            SELECT fr.*, b.title as book_title
            FROM fine_records fr
            JOIN books b ON fr.book_id = b.book_id
            WHERE fr.borrower_id = ?
            ORDER BY fr.borrow_date DESC
        `, [id]);
        
        res.json(rows);
    } catch (error) {
        console.error('Failed to get user fine records:', error);
        res.status(500).json({ error: 'Failed to get user fine records' });
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
