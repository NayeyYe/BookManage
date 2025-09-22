const { getConnection } = require('../config/database');

// 借书
const borrowBook = async (req, res) => {
    try {
        const { borrower_id, book_id } = req.body;
        const connection = await getConnection();
        
        // 调用存储过程借书
        await connection.execute('CALL borrowBook(?, ?, @result_code, @result_message)', [borrower_id, book_id]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message');
        
        if (result[0].result_code !== 0) {
            return res.status(400).json({ error: result[0].result_message });
        }
        
        res.status(201).json({ message: result[0].result_message });
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
        
        // 调用存储过程还书
        await connection.execute('CALL returnBook(?, @result_code, @result_message, @overdue_days, @fine_amount)', [record_id]);
        const [result] = await connection.execute('SELECT @result_code as result_code, @result_message as result_message, @overdue_days as overdue_days, @fine_amount as fine_amount');
        
        if (result[0].result_code !== 0) {
            return res.status(400).json({ error: result[0].result_message });
        }
        
        res.json({
            message: result[0].result_message,
            overdueDays: result[0].overdue_days,
            fineAmount: result[0].fine_amount
        });
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
