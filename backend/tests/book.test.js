const request = require('supertest');
const express = require('express');
const bookRoutes = require('../routes/bookRoutes');

// 创建一个测试应用
const app = express();
app.use(express.json());
app.use('/api/books', bookRoutes);

// 测试说明：
// 1. 这些测试需要数据库中有相应的数据才能正常运行
// 2. 特别是添加图书的测试需要publishers表中存在publisher_id为'test'的记录
// 3. GET /api/books/:id、PUT /api/books/:id和DELETE /api/books/:id测试需要数据库中存在指定ID的图书
// 4. POST /api/books 重复ID测试需要数据库中已存在相同ID的图书
// 5. 建议在运行测试前先确保数据库中有适当的数据
// 6. 测试中使用的图书ID '978-0-12-345678-9' 需要在数据库中存在才能通过相关测试
// 7. 测试中使用的图书ID '978-0-98-765432-1' 不能在数据库中存在，否则添加图书测试会失败

// 在所有测试之前，确保数据库中有必要的测试数据
beforeAll(async () => {
  // 这里可以添加一些初始化代码，例如确保publishers表中有数据
  // 但由于我们使用的是模拟请求，实际不需要操作数据库
  // 只需要确保测试数据符合数据库约束
});

// 在每个测试之后，可以清理测试数据
afterEach(async () => {
  // 如果需要清理测试数据，可以在这里添加代码
});

// 测试获取所有图书
describe('GET /api/books', () => {
  it('should return all books', async () => {
    const response = await request(app)
      .get('/api/books')
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
});

// 测试根据ID获取图书
describe('GET /api/books/:id', () => {
  it('should return a book by ID', async () => {
    const bookId = '978-0-12-345678-9'; // 假设存在的一本书的ID
    
    const response = await request(app)
      .get(`/api/books/${bookId}`)
      .expect(200);
    
    // 验证响应包含图书信息
    expect(response.body).toHaveProperty('book_id', bookId);
  });
  
  it('should return 404 for non-existent book', async () => {
    const nonExistentId = 'non-existent-id';
    
    const response = await request(app)
      .get(`/api/books/${nonExistentId}`)
      .expect(404);
  });
});

// 测试添加新图书
describe('POST /api/books', () => {
  it('should add a new book', async () => {
    const newBook = {
      book_id: '978-0-98-765432-1',
      title: '测试图书',
      isbn: '978-0-98-765432-1',
      publisher_id: 'test',
      publication_year: 2025,
      total_stock: 10,
      current_stock: 10,
      location: 'A区001架'
    };
    
    const response = await request(app)
      .post('/api/books')
      .send(newBook)
      .expect(201);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message', '图书添加成功');
  });
  
  it('should return 400 for duplicate book ID', async () => {
    const duplicateBook = {
      book_id: '978-0-12-345678-9', // 假设已存在的一本书的ID
      title: '重复测试图书',
      isbn: '978-0-12-345678-9',
      publisher_id: 'test',
      publication_year: 2025,
      total_stock: 10,
      current_stock: 10,
      location: 'A区002架'
    };
    
    const response = await request(app)
      .post('/api/books')
      .send(duplicateBook)
      .expect(400);
    
    // 验证响应包含错误消息
    expect(response.body).toHaveProperty('error', '图书ID已存在');
  });
});

// 测试更新图书信息
describe('PUT /api/books/:id', () => {
  it('should update a book', async () => {
    const bookId = '978-0-12-345678-9'; // 假设存在的一本书的ID
    const updatedBook = {
      title: '更新后的图书',
      isbn: '978-0-12-345678-9',
      publisher_id: 'test',
      publication_year: 2025,
      total_stock: 15,
      current_stock: 15,
      location: 'B区001架'
    };
    
    const response = await request(app)
      .put(`/api/books/${bookId}`)
      .send(updatedBook)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message');
  });
  
  it('should return 404 for non-existent book', async () => {
    const nonExistentId = 'non-existent-id';
    const updatedBook = {
      title: '更新测试图书',
      isbn: '978-0-98-765432-1',
      publisher_id: 'test',
      publication_year: 2025,
      total_stock: 10,
      current_stock: 10,
      location: 'B区002架'
    };
    
    const response = await request(app)
      .put(`/api/books/${nonExistentId}`)
      .send(updatedBook)
      .expect(404);
  });
});

// 测试删除图书
describe('DELETE /api/books/:id', () => {
  it('should delete a book', async () => {
    const bookId = '978-0-98-765432-1'; // 假设存在的一本书的ID
    
    const response = await request(app)
      .delete(`/api/books/${bookId}`)
      .expect(200);
    
    // 验证响应包含成功消息
    expect(response.body).toHaveProperty('message');
  });
  
  it('should return 404 for non-existent book', async () => {
    const nonExistentId = 'non-existent-id';
    
    const response = await request(app)
      .delete(`/api/books/${nonExistentId}`)
      .expect(404);
  });
});

// 测试搜索图书
describe('GET /api/books/search/:query', () => {
  it('should search books by query', async () => {
    const query = '测试'; // 搜索关键词
    
    const response = await request(app)
      .get(`/api/books/search/${query}`)
      .expect(200);
    
    // 验证响应是一个数组
    expect(Array.isArray(response.body)).toBe(true);
  });
});
