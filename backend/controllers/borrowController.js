const { getConnection } = require('../config/database');

// 借书
const borrowBook = async (req, res) => {
    try {
        const { borrower_id, book_id } = req.body;
        const connection = await getConnection();
        
        // 开始事务
        await connection.beginTransaction();
        
        try {
            // 检查图书是否存在且可借
            const [books] = await connection.execute(
                'SELECT current_stock FROM books WHERE book_id = ? AND current_stock > 0',
                [book_id]
            );
            
            if (books.length === 0) {
                await connection.rollback();
                return res.status(400).json({ error: '图书不可借或不存在' });
            }
            
            // 检查用户是否存在且状态正常
            const [borrowers] = await connection.execute(
                'SELECT borrowing_status, borrowed_count FROM borrowers WHERE uid = ? AND borrowing_status = "active"',
                [borrower_id]
            );
            
            if (borrowers.length === 0) {
                await connection.rollback();
                return res.status(400).json({ error: '用户不存在或账户状态异常' });
            }
            
            const borrower = borrowers[0];
            
            // 检查用户是否已借阅此书
            const [existingBorrow] = await connection.execute(
                'SELECT record_id FROM borrowing_records WHERE borrower_id = ? AND book_id = ? AND return_date IS NULL',
                [borrower_id, book_id]
            );
            
            if (existingBorrow.length > 0) {
                await connection.rollback();
                return res.status(400).json({ error: '用户已借阅此书且未归还' });
            }
            
            // 插入借阅记录
            const [result] = await connection.execute(
                'INSERT INTO borrowing_records (borrower_id, book_id, borrow_date, due_date) VALUES (?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY))',
                [borrower_id, book_id]
            );
            
            // 更新图书库存
            await connection.execute(
                'UPDATE books SET current_stock = current_stock - 1 WHERE book_id = ?',
                [book_id]
            );
            
            // 更新用户借阅数量
            await connection.execute(
                'UPDATE borrowers SET borrowed_count = borrowed_count + 1 WHERE uid = ?',
                [borrower_id]
            );
            
            // 提交事务
            await connection.commit();
            
            res.status(201).json({ message: '借书成功', record_id: result.insertId });
        } catch (error) {
            // 回滚事务
            await connection.rollback();
            throw error;
        }
    } catch (error) {
        console.error('借书失败:', error);
        res.status(500).json({ error: '借书失败' });
    }
};

// 还书
const returnBook = async (req, res) => {
    try {
        const { record_id } = req.body;
        const connection = await getConnection();
        
        // 开始事务
        await connection.beginTransaction();
        
        try {
            // 获取借阅记录
            const [records] = await connection.execute(`
                SELECT br.*, b.title as book_title, b.book_id as book_id, br.borrower_id as borrower_id
                FROM borrowing_records br
                JOIN books b ON br.book_id = b.book_id
                WHERE br.record_id = ? AND br.return_date IS NULL
            `, [record_id]);
            
            if (records.length === 0) {
                await connection.rollback();
                return res.status(400).json({ error: '借阅记录不存在或已归还' });
            }
            
            const record = records[0];
            const borrowerId = record.borrower_id;
            const bookId = record.book_id;
            
            // 计算逾期天数
            const [overdueDaysResult] = await connection.execute(
                'SELECT DATEDIFF(CURDATE(), ?) as overdue_days',
                [record.due_date]
            );
            
            const overdueDays = Math.max(0, overdueDaysResult[0].overdue_days);
            
            // 更新借阅记录的归还日期
            await connection.execute(
                'UPDATE borrowing_records SET return_date = CURDATE() WHERE record_id = ?',
                [record_id]
            );
            
            // 更新图书库存
            await connection.execute(
                'UPDATE books SET current_stock = current_stock + 1 WHERE book_id = ?',
                [bookId]
            );
            
            // 更新用户借阅数量
            await connection.execute(
                'UPDATE borrowers SET borrowed_count = borrowed_count - 1 WHERE uid = ?',
                [borrowerId]
            );
            
            // 如果有逾期，插入罚款记录
            let fineRecordId = null;
            if (overdueDays > 0) {
                const fineAmount = overdueDays * 0.5; // 每天0.5元罚款
                const [fineResult] = await connection.execute(
                    'INSERT INTO fine_records (borrower_id, book_id, borrow_date, return_date, overdue_days, fine_amount, payment_status) VALUES (?, ?, ?, CURDATE(), ?, ?, ?)',
                    [borrowerId, bookId, record.borrow_date, overdueDays, fineAmount, 'unpaid']
                );
                fineRecordId = fineResult.insertId;
            }
            
            // 提交事务
            await connection.commit();
            
            res.json({
                message: '还书成功',
                overdueDays,
                fineAmount: overdueDays > 0 ? overdueDays * 0.5 : 0,
                fineRecordId
            });
        } catch (error) {
            // 回滚事务
            await connection.rollback();
            throw error;
        }
    } catch (error) {
        console.error('还书失败:', error);
        res.status(500).json({ error: '还书失败' });
    }
};

// 获取所有借阅记录
const getAllBorrowingRecords = async (req, res) => {
    try {
        const connection = await getConnection();
        const [rows] = await connection.execute(`
            SELECT br.*, b.title as book_title, bo.name as borrower_name
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
            SELECT fr.*, b.title as book_title, bo.name as borrower_name
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

module.exports = {
    borrowBook,
    returnBook,
    getAllBorrowingRecords,
    getAllFineRecords
};
