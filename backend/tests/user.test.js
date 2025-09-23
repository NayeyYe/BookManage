const request = require('supertest');
const express = require('express');
const userRoutes = require('../routes/userRoutes');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

// 创建一个测试应用
const app = express();
app.use(express.json());
app.use('/api/users', userRoutes);

// 测试数据库清理和初始化函数
async function setupTestDatabase() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });
    
    try {
        // 按照外键约束的顺序清理数据
        // 1. 删除登录日志
        await connection.execute("DELETE FROM login_logs WHERE user_id = ?", ['newtest123']);
        
        // 2. 删除用户认证信息
        await connection.execute("DELETE FROM user_auth WHERE user_id = ?", ['newtest123']);
        
        // 3. 删除借阅记录
        await connection.execute("DELETE FROM borrowing_records WHERE borrower_id = ?", ['newtest123']);
        
        // 4. 删除罚款记录
        await connection.execute("DELETE FROM fine_records WHERE borrower_id = ?", ['newtest123']);
        
        // 5. 删除用户记录
        await connection.execute("DELETE FROM borrowers WHERE uid = ?", ['newtest123']);
        
        // 重置S001用户的原始数据和密码
        await connection.execute("UPDATE borrowers SET name = '测试学生', phone = '13800138001', student_id = '20250001' WHERE uid = ?", ['S001']);
        await connection.execute("DELETE FROM user_auth WHERE user_id = ?", ['S001']);
        await connection.execute("INSERT INTO user_auth (user_id, password_hash) VALUES (?, SHA2(?, 256))", ['S001', 'password123']);
        
        console.log('Test database setup completed');
    } catch (error) {
        console.error('Error setting up test database:', error);
    } finally {
        await connection.end();
    }
}

// 在所有测试开始前设置测试数据库
beforeAll(async () => {
    await setupTestDatabase();
});

// 在所有测试结束后清理数据
afterAll(async () => {
    await setupTestDatabase();
});

// 测试说明：
// 1. 这些测试需要数据库中有相应的数据才能正常运行
// 2. 用户注册测试需要确保提供的UID在数据库中不存在
// 3. 用户登录测试需要数据库中存在对应的用户记录
// 4. 获取用户信息、更新用户信息、获取用户借阅记录和罚款记录测试需要数据库中存在对应的用户ID
// 5. 建议在运行测试前先确保数据库中有适当的数据

// 测试用户注册
describe('POST /api/users/register', () => {
  it('should register a new user successfully', async () => {
    const userData = {
      uid: 'newtest123',
      name: 'Test User',
      phone: '1234567890',
      identity_type: 1,
      student_id: 'S123456',
      employee_id: null,
      password: 'password123'
    };
    
    const response = await request(app)
      .post('/api/users/register')
      .send(userData)
      .expect(201);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', 'User registration successful');
  });
  
  it('should return 400 for duplicate user registration', async () => {
    const duplicateUserData = {
      uid: 'S001',     // 使用测试数据库中已存在的用户ID
      name: '重复测试用户',
      phone: '13800138001',
      identity_type: 1,
      student_id: '20250002',
      employee_id: null,
      password: 'testpassword'
    };
    
    const response = await request(app)
      .post('/api/users/register')
      .send(duplicateUserData)
      .expect(400);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试用户登录
describe('POST /api/users/login', () => {
  it('should login successfully with valid credentials', async () => {
    const loginData = {
      uid: 'S001',     // 使用测试数据库中的用户
      password: 'password123' // 使用测试用户的密码
    };
    
    const response = await request(app)
      .post('/api/users/login')
      .send(loginData)
      .expect(200);
    
    // 验证响应包含令牌和用户信息
    expect(response.body).toHaveProperty('token');
    expect(response.body).toHaveProperty('user');
  });
  
  it('should return 401 for invalid credentials', async () => {
    const invalidLoginData = {
      uid: 'non_existent_user',
      password: 'wrong_password'
    };
    
    const response = await request(app)
      .post('/api/users/login')
      .send(invalidLoginData)
      .expect(401);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试获取用户信息
describe('GET /api/users/:id', () => {
  it('should return user information for valid user ID', async () => {
    const userId = 'S001'; // 使用测试数据库中的用户ID
    
    const response = await request(app)
      .get(`/api/users/${userId}`)
      .expect(200);
    
    // 验证响应包含用户信息
    expect(response.body).toHaveProperty('uid', userId);
    expect(response.body).toHaveProperty('name');
  });
  
  it('should return 404 for non-existent user ID', async () => {
    const nonExistentUserId = 'non_existent_user_id';
    
    const response = await request(app)
      .get(`/api/users/${nonExistentUserId}`)
      .expect(404);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试更新用户信息
describe('PUT /api/users/:id', () => {
  it('should update user information successfully', async () => {
    const userId = 'S001'; // 使用测试数据库中的用户ID
    const updateData = {
      name: '更新后的用户名称',
      phone: '13900139000'
    };
    
    const response = await request(app)
      .put(`/api/users/${userId}`)
      .send(updateData)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message');
  });
  
  it('should return 404 for non-existent user ID', async () => {
    const nonExistentUserId = 'non_existent_user_id';
    const updateData = {
      name: '更新后的用户名称',
      phone: '13900139000'
    };
    
    const response = await request(app)
      .put(`/api/users/${nonExistentUserId}`)
      .send(updateData)
      .expect(404);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试获取用户借阅记录
describe('GET /api/users/:id/borrowing-records', () => {
  it('should return borrowing records for valid user ID', async () => {
    const userId = 'S001'; // 使用测试数据库中的用户ID
    
    const response = await request(app)
      .get(`/api/users/${userId}/borrowing-records`)
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
  
  it('should return 404 for non-existent user ID', async () => {
    const nonExistentUserId = 'non_existent_user_id';
    
    const response = await request(app)
      .get(`/api/users/${nonExistentUserId}/borrowing-records`)
      .expect(404);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});

// 测试获取用户罚款记录
describe('GET /api/users/:id/fine-records', () => {
  it('should return fine records for valid user ID', async () => {
    const userId = 'S001'; // 使用测试数据库中的用户ID
    
    const response = await request(app)
      .get(`/api/users/${userId}/fine-records`)
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
  
  it('should return 404 for non-existent user ID', async () => {
    const nonExistentUserId = 'non_existent_user_id';
    
    const response = await request(app)
      .get(`/api/users/${nonExistentUserId}/fine-records`)
      .expect(404);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error');
  });
});
