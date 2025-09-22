const { getConnection } = require('../config/database');

// 获取所有借阅记录
const getAllBorrowingRecords = async (req, res) => {
    try {
        const connection = await getConnection();
        const [rows] = await connection.execute(`
            SELECT br.*, b.title as book_title, bo.name as borrower_name, bo.identity_type
            FROM borrowing_records br
            JOIN books b ON br.book_id = b.book_id
            JOIN borrowers bo ON br.borrower_id = bo.uid
            ORDER BY br.borrow_date DESC
        `);
        res.json(rows);
    } catch (error) {
        console.error('获取借阅记录失败:', error);
        res.status(500).json({ error: '获取借阅记录失败' });
    }
};

// 获取所有罚款记录
const getAllFineRecords = async (req, res) => {
    try {
        const connection = await getConnection();
        const [rows] = await connection.execute(`
            SELECT fr.*, b.title as book_title, bo.name as borrower_name, bo.identity_type
            FROM fine_records fr
            JOIN books b ON fr.book_id = b.book_id
            JOIN borrowers bo ON fr.borrower_id = bo.uid
            ORDER BY fr.borrow_date DESC
        `);
        res.json(rows);
    } catch (error) {
        console.error('获取罚款记录失败:', error);
        res.status(500).json({ error: '获取罚款记录失败' });
    }
};

// 获取用户登录日志
const getUserLoginLogs = async (req, res) => {
    try {
        const connection = await getConnection();
        const [rows] = await connection.execute(`
            SELECT ll.*, bo.name as user_name, bo.identity_type
            FROM login_logs ll
            JOIN borrowers bo ON ll.user_id = bo.uid
            ORDER BY ll.login_time DESC
        `);
        res.json(rows);
    } catch (error) {
        console.error('获取登录日志失败:', error);
        res.status(500).json({ error: '获取登录日志失败' });
    }
};

// 管理用户
const manageUser = async (req, res) => {
    try {
        const { uid, action } = req.body; // action: 'activate', 'suspend', 'delete'
        const connection = await getConnection();
        
        switch (action) {
            case 'activate':
                await connection.execute(
                    'UPDATE borrowers SET borrowing_status = "active" WHERE uid = ?',
                    [uid]
                );
                res.json({ message: '用户已激活' });
                break;
                
            case 'suspend':
                await connection.execute(
                    'UPDATE borrowers SET borrowing_status = "suspended" WHERE uid = ?',
                    [uid]
                );
                res.json({ message: '用户已冻结' });
                break;
                
            case 'delete':
                // 开始事务
                await connection.beginTransaction();
                
                try {
                    // 删除用户认证信息
                    await connection.execute(
                        'DELETE FROM user_auth WHERE user_id = ?',
                        [uid]
                    );
                    
                    // 删除用户借阅记录
                    await connection.execute(
                        'DELETE FROM borrowing_records WHERE borrower_id = ?',
                        [uid]
                    );
                    
                    // 删除用户罚款记录
                    await connection.execute(
                        'DELETE FROM fine_records WHERE borrower_id = ?',
                        [uid]
                    );
                    
                    // 删除用户登录日志
                    await connection.execute(
                        'DELETE FROM login_logs WHERE user_id = ?',
                        [uid]
                    );
                    
                    // 删除用户
                    await connection.execute(
                        'DELETE FROM borrowers WHERE uid = ?',
                        [uid]
                    );
                    
                    // 提交事务
                    await connection.commit();
                    res.json({ message: '用户已删除' });
                } catch (error) {
                    // 回滚事务
                    await connection.rollback();
                    throw error;
                }
                break;
                
            default:
                res.status(400).json({ error: '无效的操作' });
        }
    } catch (error) {
        console.error('管理用户失败:', error);
        res.status(500).json({ error: '管理用户失败' });
    }
};

// 管理管理员
const manageAdmin = async (req, res) => {
    try {
        // 这里可以添加管理员管理功能
        // 例如：添加管理员、删除管理员、修改管理员权限等
        res.status(500).json({ error: '管理员管理功能尚未实现' });
    } catch (error) {
        console.error('管理管理员失败:', error);
        res.status(500).json({ error: '管理管理员失败' });
    }
};

module.exports = {
    getAllBorrowingRecords,
    getAllFineRecords,
    getUserLoginLogs,
    manageUser,
    manageAdmin
};
