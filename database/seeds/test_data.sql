USE bookmanage;

-- 确保publishers表中有数据
INSERT IGNORE INTO publishers (publisher_id, publisher_name) VALUES ('test', '测试出版社');

-- 添加用于测试的图书记录
INSERT IGNORE INTO books (book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location)
VALUES ('B001', '测试图书1', '978-0-12-345678-9', 'test', 2025, 10, 10, 'A区001架');

-- 确保用户类型存在
INSERT IGNORE INTO user_types (type_id, type_name, max_borrow_count, max_borrow_days) VALUES 
(1, '学生', 5, 30),
(2, '教师', 10, 60),
(3, '校外人员', 3, 15),
(4, '管理员', 20, 90),
(5, '超级管理员', 50, 180);

-- 添加用于测试的用户记录
INSERT IGNORE INTO borrowers (uid, name, phone, identity_type, student_id, employee_id, borrowed_count, registration_date, borrowing_status)
VALUES ('S001', '测试学生', '13800138001', 1, '20250001', NULL, 0, '2025-01-01', 'active');

-- 添加用于测试的用户认证信息
-- 密码: password123 (明文存储用于测试)
INSERT IGNORE INTO user_auth (user_id, password_hash) 
VALUES ('S001', 'password123');

-- 添加用于测试的借阅记录
INSERT IGNORE INTO borrowing_records (record_id, borrower_id, book_id, borrow_date, due_date, return_status)
VALUES ('BR001', 'S001', 'B001', '2025-01-01', '2025-02-01', 'borrowed');

SELECT * FROM publishers;
SELECT * FROM books;
SELECT * FROM borrowers;
SELECT * FROM user_auth;
SELECT * FROM borrowing_records;
