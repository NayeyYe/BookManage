const request = require('supertest');
const express = require('express');
const borrowRoutes = require('../routes/borrowRoutes');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

// 创建一个测试应用
const app = express();
app.use(express.json());
app.use('/api/borrow', borrowRoutes);

// 借书测试数据库设置函数
async function setupBorrowTestDatabase() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });
    
    try {
        // 确保测试用户存在且状态正常
        await connection.execute(`
            INSERT IGNORE INTO borrowers (uid, name, phone, identity_type, student_id, employee_id, borrowed_count, registration_date, borrowing_status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, ['S001', '测试学生', '13800138001', 1, '20250001', null, 0, '2025-01-01', 'active']);
        
        // 确保测试图书存在且有库存
        await connection.execute(`
            INSERT IGNORE INTO books (book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `, ['B001', '测试图书1', '978-0-12-345678-9', 'test', 2025, 10, 10, 'A区001架']);
        
        // 确保出版社存在
        await connection.execute(`
            INSERT IGNORE INTO publishers (publisher_id, publisher_name) 
            VALUES (?, ?)
        `, ['test', '测试出版社']);
        
        // 清理旧的借阅记录
        await connection.execute("DELETE FROM borrowing_records WHERE borrower_id = ? AND book_id = ?", ['S001', 'B001']);
        
        // 重置用户的借阅数量
        await connection.execute("UPDATE borrowers SET borrowed_count = 0 WHERE uid = ?", ['S001']);
        
        // 重置图书的库存
        await connection.execute("UPDATE books SET current_stock = 10 WHERE book_id = ?", ['B001']);
        
        // 确保用户认证信息使用正确的SHA2哈希
        await connection.execute("DELETE FROM user_auth WHERE user_id = ?", ['S001']);
        await connection.execute("INSERT INTO user_auth (user_id, password_hash) VALUES (?, SHA2(?, 256))", ['S001', 'password123']);
        
        // 确保用户类型存在
        await connection.execute(`
            INSERT IGNORE INTO user_types (type_id, type_name, max_borrow_count, max_borrow_days) VALUES 
            (1, '学生', 5, 30),
            (2, '教师', 10, 60),
            (3, '校外人员', 3, 15),
            (4, '管理员', 20, 90),
            (5, '超级管理员', 50, 180)
        `);
        
        console.log('Borrow test database setup completed');
    } catch (error) {
        console.error('Error setting up borrow test database:', error);
    } finally {
        await connection.end();
    }
}

// 在所有测试开始前设置测试数据库
beforeAll(async () => {
    await setupBorrowTestDatabase();
});

// 测试说明：
// 1. 这些测试需要数据库中有相应的数据才能正常运行
// 2. 借书测试需要数据库中存在borrower_id和book_id对应的记录
// 3. 还书测试需要数据库中存在record_id对应的借阅记录
// 4. 建议在运行测试前先确保数据库中有适当的数据

// 测试借书功能
describe('POST /api/borrow/borrow', () => {
  it('should borrow a book successfully', async () => {
    const borrowData = {
      borrower_id: 'S001',
      book_id: 'B001'
    };
    
    const response = await request(app)
      .post('/api/borrow/borrow')
      .send(borrowData)
      .expect(201);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', 'Book borrowed successfully');
  });
  
  it('should return 400 for invalid borrow request', async () => {
    const invalidBorrowData = {
      borrower_id: 'non_existent_borrower',
      book_id: 'non_existent_book'
    };
    
    const response = await request(app)
      .post('/api/borrow/borrow')
      .send(invalidBorrowData)
      .expect(400);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试还书功能
describe('POST /api/borrow/return', () => {
  it('should return a book successfully', async () => {
    // 首先借一本书，然后归还它
    const borrowData = {
      borrower_id: 'S001',
      book_id: 'B001'
    };
    
    const borrowResponse = await request(app)
      .post('/api/borrow/borrow')
      .send(borrowData);
    
    // 借书可能成功也可能失败，取决于测试顺序
    // 如果成功，我们测试还书；如果失败，我们创建一个测试记录
    let recordId;
    
    if (borrowResponse.status === 201) {
      recordId = borrowResponse.body.recordId;
    } else {
      // 如果借书失败，直接在数据库中创建一个测试借阅记录
      const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
      });
      
      try {
        recordId = 'TEST' + Date.now();
        const borrowDate = new Date().toISOString().split('T')[0];
        const dueDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        
        // 创建一个完整的借阅记录
        await connection.execute(`
          INSERT INTO borrowing_records (record_id, borrower_id, book_id, borrow_date, due_date, return_status, return_date, actual_return_date)
          VALUES (?, ?, ?, ?, ?, 'borrowed', NULL, NULL)
        `, [recordId, 'S001', 'B001', borrowDate, dueDate]);
        
        // 更新用户借阅数量
        await connection.execute("UPDATE borrowers SET borrowed_count = borrowed_count + 1 WHERE uid = ?", ['S001']);
        
        // 更新图书库存
        await connection.execute("UPDATE books SET current_stock = current_stock - 1 WHERE book_id = ?", ['B001']);
        
        console.log('Created test borrowing record:', recordId);
      } finally {
        await connection.end();
      }
    }
    
    const returnData = {
      record_id: recordId
    };
    
    console.log('Returning book with record_id:', recordId);
    
    const response = await request(app)
      .post('/api/borrow/return')
      .send(returnData)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', 'Book returned successfully');
  });
  
  it('should return 400 for invalid return request', async () => {
    const invalidReturnData = {
      record_id: 999999 // 假设数据库中不存在此record_id
    };
    
    const response = await request(app)
      .post('/api/borrow/return')
      .send(invalidReturnData)
      .expect(400);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试获取所有借阅记录
describe('GET /api/borrow/records', () => {
  it('should return all borrowing records', async () => {
    const response = await request(app)
      .get('/api/borrow/records')
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
});

// 测试获取所有罚款记录
describe('GET /api/borrow/fines', () => {
  it('should return all fine records', async () => {
    const response = await request(app)
      .get('/api/borrow/fines')
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
});
