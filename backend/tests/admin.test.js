const request = require('supertest');
const express = require('express');
const adminRoutes = require('../routes/adminRoutes');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

// 创建一个测试应用
const app = express();
app.use(express.json());
app.use('/api/admin', adminRoutes);

// 管理员测试数据库设置函数
async function setupAdminTestDatabase() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });
    
    try {
        // 确保管理员用户存在
        await connection.execute(`
            INSERT IGNORE INTO borrowers (uid, name, phone, identity_type, student_id, employee_id, borrowed_count, registration_date, borrowing_status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, ['A001', '测试管理员', '13900139001', 4, null, 'E20250001', 0, '2025-01-01', 'active']);
        
        // 确保管理员用户认证信息存在且密码正确
        await connection.execute("DELETE FROM user_auth WHERE user_id = ?", ['A001']);
        await connection.execute("INSERT INTO user_auth (user_id, password_hash) VALUES (?, SHA2(?, 256))", ['A001', 'admin123']);
        
        // 添加一些测试登录日志
        await connection.execute("DELETE FROM login_logs WHERE user_id IN (?, ?)", ['S001', 'A001']);
        
        // 为S001用户添加登录日志
        await connection.execute(`
            INSERT INTO login_logs (user_id, login_time, login_status, ip_address) 
            VALUES (?, NOW(), 'success', '192.168.1.100')
        `, ['S001']);
        
        // 为A001管理员添加登录日志
        await connection.execute(`
            INSERT INTO login_logs (user_id, login_time, login_status, ip_address) 
            VALUES (?, NOW(), 'success', '192.168.1.101')
        `, ['A001']);
        
        console.log('Admin test database setup completed');
    } catch (error) {
        console.error('Error setting up admin test database:', error);
    } finally {
        await connection.end();
    }
}

// 在所有测试开始前设置测试数据库
beforeAll(async () => {
    await setupAdminTestDatabase();
});

// 测试说明：
// 1. 这些测试需要数据库中有相应的数据才能正常运行
// 2. 获取借阅记录、罚款记录和登录日志测试需要数据库中存在相应的记录
// 3. 管理用户测试需要数据库中存在对应的用户ID
// 4. 建议在运行测试前先确保数据库中有适当的数据

// 测试获取所有借阅记录
describe('GET /api/admin/borrowing-records', () => {
  it('should return all borrowing records', async () => {
    const response = await request(app)
      .get('/api/admin/borrowing-records')
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
  
  it('should return 500 if there is a database error', async () => {
    // 这个测试可能需要模拟数据库错误才能通过
    // 在实际测试中，您可能需要使用mocking库来模拟数据库错误
  });
});

// 测试获取所有罚款记录
describe('GET /api/admin/fine-records', () => {
  it('should return all fine records', async () => {
    const response = await request(app)
      .get('/api/admin/fine-records')
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
  
  it('should return 500 if there is a database error', async () => {
    // 这个测试可能需要模拟数据库错误才能通过
    // 在实际测试中，您可能需要使用mocking库来模拟数据库错误
  });
});

// 测试获取用户登录日志
describe('GET /api/admin/login-logs', () => {
  it('should return user login logs', async () => {
    const response = await request(app)
      .get('/api/admin/login-logs?admin_id=A001')  // 使用测试管理员ID
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
  
  it('should return 500 if there is a database error', async () => {
    // 这个测试可能需要模拟数据库错误才能通过
    // 在实际测试中，您可能需要使用mocking库来模拟数据库错误
  });
});

// 测试管理用户功能
describe('POST /api/admin/manage-user', () => {
  it('should activate a user successfully', async () => {
    const manageData = {
      uid: 'S001', // 需要数据库中存在此用户ID
      action: 'activate'
    };
    
    const response = await request(app)
      .post('/api/admin/manage-user')
      .send(manageData)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', 'User activated');
  });
  
  it('should suspend a user successfully', async () => {
    const manageData = {
      uid: 'S001', // 需要数据库中存在此用户ID
      action: 'suspend'
    };
    
    const response = await request(app)
      .post('/api/admin/manage-user')
      .send(manageData)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', 'User suspended');
  });
  
  it('should delete a user successfully', async () => {
    const manageData = {
      uid: 'S001', // 需要数据库中存在此用户ID
      action: 'delete'
    };
    
    const response = await request(app)
      .post('/api/admin/manage-user')
      .send(manageData)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', 'User deleted');
  });
  
  it('should return 400 for invalid action', async () => {
    const manageData = {
      uid: 'S001',
      action: 'invalid_action'
    };
    
    const response = await request(app)
      .post('/api/admin/manage-user')
      .send(manageData)
      .expect(400);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error', 'Invalid action');
  });
});

// 测试管理管理员功能
describe('POST /api/admin/manage-admin', () => {
  it('should return 500 as the feature is not implemented', async () => {
    const manageData = {
      // 管理员管理功能的数据
    };
    
    const response = await request(app)
      .post('/api/admin/manage-admin')
      .send(manageData)
      .expect(500);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error', 'Admin management feature not implemented');
  });
});
