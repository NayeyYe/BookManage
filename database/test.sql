-- BookManage 数据库测试脚本
-- 本脚本用于测试数据库的所有内容，包括表、存储过程、函数、事件和触发器

USE bookmanage;

-- =============================================
-- 1. 测试表结构
-- =============================================

SELECT '========== 测试表结构 ==========' AS message;

-- 测试用户类型表
SELECT '1. 用户类型表测试' AS test_name;
SELECT COUNT(*) AS user_type_count FROM user_types;
SELECT * FROM user_types;

-- 测试出版社表
SELECT '2. 出版社表测试' AS test_name;
SELECT COUNT(*) AS publisher_count FROM publishers;
SELECT * FROM publishers LIMIT 5;

-- 测试作者表
SELECT '3. 作者表测试' AS test_name;
SELECT COUNT(*) AS author_count FROM authors;
SELECT * FROM authors LIMIT 5;

-- 测试图书表
SELECT '4. 图书表测试' AS test_name;
SELECT COUNT(*) AS book_count FROM books;
SELECT * FROM books LIMIT 5;

-- 测试标签表
SELECT '5. 标签表测试' AS test_name;
SELECT COUNT(*) AS tag_count FROM tags;
SELECT * FROM tags LIMIT 5;

-- 测试借阅者表
SELECT '6. 借阅者表测试' AS test_name;
SELECT COUNT(*) AS borrower_count FROM borrowers;
SELECT * FROM borrowers LIMIT 5;

-- 测试用户认证表
SELECT '7. 用户认证表测试' AS test_name;
SELECT COUNT(*) AS user_auth_count FROM user_auth;
SELECT * FROM user_auth LIMIT 5;

-- 测试图书作者关联表
SELECT '8. 图书作者关联表测试' AS test_name;
SELECT COUNT(*) AS book_author_count FROM book_authors;
SELECT * FROM book_authors LIMIT 5;

-- 测试图书标签关联表
SELECT '9. 图书标签关联表测试' AS test_name;
SELECT COUNT(*) AS book_tag_count FROM book_tags;
SELECT * FROM book_tags LIMIT 5;

-- 测试借阅记录表
SELECT '10. 借阅记录表测试' AS test_name;
SELECT COUNT(*) AS borrowing_record_count FROM borrowing_records;
SELECT * FROM borrowing_records LIMIT 5;

-- 测试罚款记录表
SELECT '11. 罚款记录表测试' AS test_name;
SELECT COUNT(*) AS fine_record_count FROM fine_records;
SELECT * FROM fine_records LIMIT 5;

-- 测试登录日志表
SELECT '12. 登录日志表测试' AS test_name;
SELECT COUNT(*) AS login_log_count FROM login_logs;
SELECT * FROM login_logs LIMIT 5;

-- =============================================
-- 2. 测试函数
-- =============================================

SELECT '========== 测试函数 ==========' AS message;

-- 测试计算罚款金额函数
SELECT '1. calculateFine函数测试' AS test_name;
SELECT calculateFine(0) AS fine_0_days;
SELECT calculateFine(5) AS fine_5_days;
SELECT calculateFine(10) AS fine_10_days;

-- 测试计算逾期天数函数
SELECT '2. getOverdueDays函数测试' AS test_name;
SELECT getOverdueDays('2023-01-01', '2023-01-05') AS overdue_4_days;
SELECT getOverdueDays('2023-01-05', '2023-01-01') AS overdue_0_days;
SELECT getOverdueDays(NULL, '2023-01-01') AS overdue_null;

-- 测试获取图书总数函数
SELECT '3. getBookCount函数测试' AS test_name;
SELECT getBookCount() AS total_books;

-- 测试获取用户借阅数量函数
SELECT '4. getUserBorrowedCount函数测试' AS test_name;
SELECT getUserBorrowedCount('S001') AS user_S001_borrowed_count;
SELECT getUserBorrowedCount('T001') AS user_T001_borrowed_count;
SELECT getUserBorrowedCount('NONEXIST') AS nonexist_user_borrowed_count;

-- =============================================
-- 3. 测试存储过程
-- =============================================

SELECT '========== 测试存储过程 ==========' AS message;

-- 测试用户登录存储过程
SELECT '1. userLogin存储过程测试' AS test_name;
CALL userLogin('S001', 'hashed_password_for_S001', @result_code, @result_message, @user_name, @user_type, @borrowing_status);
SELECT @result_code AS result_code, @result_message AS result_message, @user_name AS user_name, @user_type AS user_type, @borrowing_status AS borrowing_status;

-- 测试错误密码登录
CALL userLogin('S001', 'wrong_password', @result_code, @result_message, @user_name, @user_type, @borrowing_status);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试不存在用户登录
CALL userLogin('S009', 'hashed_password_for_S001', @result_code, @result_message, @user_name, @user_type, @borrowing_status);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试用户注册存储过程
SELECT '2. userRegister存储过程测试' AS test_name;
CALL userRegister('S004', '赵六', '13800138004', 1, '2021004', NULL, 'hashed_password_for_S004', '2023-01-01', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试重复用户ID注册
CALL userRegister('S004', '赵六', '13800138004', 1, '2021004', NULL, 'hashed_password_for_S004', '2023-01-01', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试添加图书存储过程
SELECT '3. addBook存储过程测试' AS test_name;
CALL addBook('B006', '测试图书', '9787115216880', 'P001', 2023, 10, 'D区001架', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试重复图书ID添加
CALL addBook('B006', '测试图书2', '9787115216881', 'P002', 2023, 5, 'D区002架', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试搜索图书存储过程
SELECT '4. searchBooksByName存储过程测试' AS test_name;
CALL searchBooksByName('代码', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试按作者名搜索图书
SELECT '5. searchBooksByAuthor存储过程测试' AS test_name;
CALL searchBooksByAuthor('Robert', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试按ISBN搜索图书
SELECT '6. searchBooksByISBN存储过程测试' AS test_name;
CALL searchBooksByISBN('9787115216878', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试按出版社搜索图书
SELECT '7. searchBooksByPublisher存储过程测试' AS test_name;
CALL searchBooksByPublisher('清华大学', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试按标签搜索图书
SELECT '8. searchBooksByTag存储过程测试' AS test_name;
CALL searchBooksByTag('计算机', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试获取所有图书存储过程
SELECT '9. getAllBooks存储过程测试' AS test_name;
CALL getAllBooks(@result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试根据ID获取图书存储过程
SELECT '10. getBookById存储过程测试' AS test_name;
CALL getBookById('B001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试更新图书存储过程
SELECT '11. updateBook存储过程测试' AS test_name;
CALL updateBook('B001', '更新后的图书标题', '9787115216878', 'P001', 2023, 10, 5, 'A区001架', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试删除图书存储过程
SELECT '12. deleteBook存储过程测试' AS test_name;
CALL deleteBook('B006', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试获取用户当前借阅记录存储过程
SELECT '13. getUserCurrentBorrowingRecords存储过程测试' AS test_name;
CALL getUserCurrentBorrowingRecords('S001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试获取用户所有借阅记录存储过程
SELECT '14. getUserAllBorrowingRecords存储过程测试' AS test_name;
CALL getUserAllBorrowingRecords('S001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试获取用户罚款记录存储过程
SELECT '15. getUserFineRecords存储过程测试' AS test_name;
CALL getUserFineRecords('S001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试根据ID获取用户存储过程
SELECT '16. getUserById存储过程测试' AS test_name;
CALL getUserById('S001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试更新用户存储过程
SELECT '17. updateUser存储过程测试' AS test_name;
CALL updateUser('S001', '更新后的姓名', '13800138001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员获取所有借阅记录存储过程
SELECT '18. getAllBorrowingRecords存储过程测试' AS test_name;
CALL getAllBorrowingRecords('A001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员获取详细借阅记录存储过程
SELECT '19. getAllBorrowingRecordsDetailed存储过程测试' AS test_name;
CALL getAllBorrowingRecordsDetailed(@result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员获取所有罚款记录存储过程
SELECT '20. getAllFineRecords存储过程测试' AS test_name;
CALL getAllFineRecords('A001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员获取详细罚款记录存储过程
SELECT '21. getAllFineRecordsDetailed存储过程测试' AS test_name;
CALL getAllFineRecordsDetailed(@result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员获取用户登录日志存储过程
SELECT '22. getUserLoginLogs存储过程测试' AS test_name;
CALL getUserLoginLogs('A001', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员获取详细用户登录日志存储过程
SELECT '23. getUserLoginLogsDetailed存储过程测试' AS test_name;
CALL getUserLoginLogsDetailed(@result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员管理用户存储过程
SELECT '24. manageUser存储过程测试' AS test_name;
CALL manageUser('A001', 'S001', 'freeze', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 解冻用户
CALL manageUser('A001', 'S001', 'unfreeze', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试无效操作
CALL manageUser('A001', 'S001', 'invalid', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 测试管理员管理存储过程
SELECT '25. manageAdmin存储过程测试' AS test_name;
CALL manageAdmin('SA001', 'A002', 'add', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- 删除管理员
CALL manageAdmin('SA001', 'A002', 'remove', @result_code, @result_message);
SELECT @result_code AS result_code, @result_message AS result_message;

-- =============================================
-- 4. 测试触发器
-- =============================================

SELECT '========== 测试触发器 ==========' AS message;

-- 测试记录用户登录触发器
SELECT '1. logUserLogin触发器测试' AS test_name;
SELECT COUNT(*) AS login_logs_before FROM login_logs;
-- 注册新用户会触发登录日志记录
CALL userRegister('S005', '测试用户', '13800138005', 1, '2021005', NULL, 'hashed_password_for_S005', '2023-01-01', @result_code, @result_message);
SELECT COUNT(*) AS login_logs_after FROM login_logs;

-- 测试借书和还书触发器
SELECT '2. 借书和还书触发器测试' AS test_name;
SELECT current_stock AS book_stock_before FROM books WHERE book_id = 'B001';
SELECT borrowed_count AS user_borrowed_before FROM borrowers WHERE uid = 'S001';

-- 测试借书存储过程（会触发多个触发器）
CALL borrowBook('S001', 'B001', CURDATE(), @result_code, @result_message, @record_id);
SELECT @result_code AS result_code, @result_message AS result_message, @record_id AS record_id;

SELECT current_stock AS book_stock_after_borrow FROM books WHERE book_id = 'B001';
SELECT borrowed_count AS user_borrowed_after_borrow FROM borrowers WHERE uid = 'S001';

-- 测试还书存储过程（会触发多个触发器）
SET @return_date = DATE_ADD(CURDATE(), INTERVAL 5 DAY);
CALL returnBook(@record_id, @return_date, @result_code, @result_message, @overdue_days, @fine_amount);
SELECT @result_code AS result_code, @result_message AS result_message, @overdue_days AS overdue_days, @fine_amount AS fine_amount;

SELECT current_stock AS book_stock_after_return FROM books WHERE book_id = 'B001';
SELECT borrowed_count AS user_borrowed_after_return FROM borrowers WHERE uid = 'S001';

-- 测试自动计算罚款触发器
SELECT '3. autoCalculateFine触发器测试' AS test_name;
-- 由于外键约束，我们无法直接插入测试数据
-- 我们可以通过调用借书和还书存储过程来间接测试触发器
-- 首先确保用户S001存在并已注册
CALL userRegister('S001', '张三', '13800138001', 1, '2021001', NULL, 'hashed_password_for_S001', '2023-01-01', @result_code, @result_message);

-- 借一本书
CALL borrowBook('S001', 'B001', CURDATE(), @result_code, @result_message, @record_id);

-- 还书并产生逾期罚款
SET @return_date = DATE_ADD(CURDATE(), INTERVAL 5 DAY);
CALL returnBook(@record_id, @return_date, @result_code, @result_message, @overdue_days, @fine_amount);

-- 检查是否自动生成了罚款记录
SELECT COUNT(*) AS fine_records_count FROM fine_records WHERE borrower_id = 'S001';

-- =============================================
-- 5. 测试事件
-- =============================================

SELECT '========== 测试事件 ==========' AS message;

-- 查看事件状态
SELECT '1. 事件状态检查' AS test_name;
SHOW EVENTS LIKE 'daily%';

-- 查看事件调度器状态
SELECT '2. 事件调度器状态检查' AS test_name;
SHOW VARIABLES LIKE 'event_scheduler';

-- =============================================
-- 6. 测试索引
-- =============================================

SELECT '========== 测试索引 ==========' AS message;

-- 查看索引信息
SELECT '1. 索引信息检查' AS test_name;
SHOW INDEX FROM books;
SHOW INDEX FROM borrowing_records;
SHOW INDEX FROM fine_records;
SHOW INDEX FROM login_logs;

-- =============================================
-- 7. 测试数据完整性
-- =============================================

SELECT '========== 测试数据完整性 ==========' AS message;

-- 检查外键约束
SELECT '1. 外键约束检查' AS test_name;
SELECT 
    COUNT(*) AS total_books,
    COUNT(p.publisher_id) AS books_with_publisher
FROM books b
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id;

-- 检查图书作者关联
SELECT 
    COUNT(*) AS total_book_authors,
    COUNT(b.book_id) AS valid_book_authors,
    COUNT(a.author_id) AS valid_authors
FROM book_authors ba
LEFT JOIN books b ON ba.book_id = b.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id;

-- 检查借阅记录完整性
SELECT 
    COUNT(*) AS total_borrowing_records,
    COUNT(br.borrower_id) AS valid_borrowers,
    COUNT(br.book_id) AS valid_books
FROM borrowing_records br
LEFT JOIN borrowers b ON br.borrower_id = b.uid
LEFT JOIN books bo ON br.book_id = bo.book_id;

SELECT '========== 数据库测试完成 ==========' AS message;
