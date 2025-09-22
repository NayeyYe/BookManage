const { getConnection } = require('../config/database');

// 获取所有图书
const getAllBooks = async (req, res) => {
    try {
        const connection = await getConnection();
        const [rows] = await connection.execute('SELECT * FROM books');
        res.json(rows);
    } catch (error) {
        console.error('获取图书列表失败:', error);
        res.status(500).json({ error: '获取图书列表失败' });
    }
};

// 根据ID获取图书
const getBookById = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        const [rows] = await connection.execute('SELECT * FROM books WHERE book_id = ?', [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ error: '图书未找到' });
        }
        
        res.json(rows[0]);
    } catch (error) {
        console.error('获取图书失败:', error);
        res.status(500).json({ error: '获取图书失败' });
    }
};

// 添加新图书
const addBook = async (req, res) => {
    try {
        const { book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location } = req.body;
        const connection = await getConnection();
        
        // 检查图书是否已存在
        const [existing] = await connection.execute('SELECT book_id FROM books WHERE book_id = ?', [book_id]);
        if (existing.length > 0) {
            return res.status(400).json({ error: '图书ID已存在' });
        }
        
        // 插入新图书
        const [result] = await connection.execute(
            'INSERT INTO books (book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location]
        );
        
        res.status(201).json({ message: '图书添加成功', book_id: result.insertId });
    } catch (error) {
        console.error('添加图书失败:', error);
        res.status(500).json({ error: '添加图书失败' });
    }
};

// 更新图书信息
const updateBook = async (req, res) => {
    try {
        const { id } = req.params;
        const { title, isbn, publisher_id, publication_year, total_stock, current_stock, location } = req.body;
        const connection = await getConnection();
        
        // 检查图书是否存在
        const [existing] = await connection.execute('SELECT book_id FROM books WHERE book_id = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ error: '图书未找到' });
        }
        
        // 更新图书信息
        const [result] = await connection.execute(
            'UPDATE books SET title = ?, isbn = ?, publisher_id = ?, publication_year = ?, total_stock = ?, current_stock = ?, location = ? WHERE book_id = ?',
            [title, isbn, publisher_id, publication_year, total_stock, current_stock, location, id]
        );
        
        res.json({ message: '图书更新成功', affectedRows: result.affectedRows });
    } catch (error) {
        console.error('更新图书失败:', error);
        res.status(500).json({ error: '更新图书失败' });
    }
};

// 删除图书
const deleteBook = async (req, res) => {
    try {
        const { id } = req.params;
        const connection = await getConnection();
        
        // 检查图书是否存在
        const [existing] = await connection.execute('SELECT book_id FROM books WHERE book_id = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ error: '图书未找到' });
        }
        
        // 删除图书
        const [result] = await connection.execute('DELETE FROM books WHERE book_id = ?', [id]);
        
        res.json({ message: '图书删除成功', affectedRows: result.affectedRows });
    } catch (error) {
        console.error('删除图书失败:', error);
        res.status(500).json({ error: '删除图书失败' });
    }
};

// 搜索图书
const searchBooks = async (req, res) => {
    try {
        const { query } = req.params;
        const connection = await getConnection();
        
        // 搜索图书（按书名、ISBN、作者名）
        const [rows] = await connection.execute(`
            SELECT DISTINCT b.*, p.publisher_name
            FROM books b
            LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
            LEFT JOIN book_authors ba ON b.book_id = ba.book_id
            LEFT JOIN authors a ON ba.author_id = a.author_id
            WHERE b.title LIKE ? OR b.isbn LIKE ? OR a.author_name LIKE ?
        `, [`%${query}%`, `%${query}%`, `%${query}%`]);
        
        res.json(rows);
    } catch (error) {
        console.error('搜索图书失败:', error);
        res.status(500).json({ error: '搜索图书失败' });
    }
};

module.exports = {
    getAllBooks,
    getBookById,
    addBook,
    updateBook,
    deleteBook,
    searchBooks
};
