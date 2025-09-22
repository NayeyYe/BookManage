-- BookManage 数据库初始化脚本
-- 本脚本用于初始化整个图书管理系统数据库

-- 启用事件调度器
use bookmanage;
SET GLOBAL event_scheduler = ON;

-- =============================================
-- 1. 创建表 (Tables)
-- =============================================

-- 创建用户类型表
CREATE TABLE IF NOT EXISTS user_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    max_borrow_count INT NOT NULL DEFAULT 0,
    max_borrow_days INT NOT NULL DEFAULT 0
);

-- 创建出版社表
CREATE TABLE IF NOT EXISTS publishers (
    publisher_id VARCHAR(50) PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL
);

-- 创建作者表
CREATE TABLE IF NOT EXISTS authors (
    author_id VARCHAR(50) PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50)
);

-- 创建图书表
CREATE TABLE IF NOT EXISTS books (
    book_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20),
    publisher_id VARCHAR(50),
    publication_year YEAR,
    total_stock INT DEFAULT 0,
    current_stock INT DEFAULT 0,
    location VARCHAR(100),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- 创建图书作者关联表
CREATE TABLE IF NOT EXISTS book_authors (
    book_id VARCHAR(50),
    author_id VARCHAR(50),
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- 创建标签表
CREATE TABLE IF NOT EXISTS tags (
    tag_id VARCHAR(50) PRIMARY KEY,
    tag_name VARCHAR(100) NOT NULL UNIQUE
);

-- 创建图书标签关联表
CREATE TABLE IF NOT EXISTS book_tags (
    book_id VARCHAR(50),
    tag_id VARCHAR(50),
    PRIMARY KEY (book_id, tag_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);

-- 创建借阅者表
CREATE TABLE IF NOT EXISTS borrowers (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    identity_type INT NOT NULL,
    student_id VARCHAR(50),
    employee_id VARCHAR(50),
    borrowed_count INT DEFAULT 0,
    registration_date DATE NOT NULL,
    borrowing_status ENUM('active', 'suspended') DEFAULT 'active',
    FOREIGN KEY (identity_type) REFERENCES user_types(type_id)
);

-- 创建用户认证表
CREATE TABLE IF NOT EXISTS user_auth (
    user_id VARCHAR(50) PRIMARY KEY,
    password_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES borrowers(uid)
);

-- 创建登录日志表
CREATE TABLE IF NOT EXISTS login_logs (
    log_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    login_time DATETIME NOT NULL,
    ip_address VARCHAR(45) DEFAULT '127.0.0.1',
    login_status VARCHAR(20) DEFAULT 'login',
    FOREIGN KEY (user_id) REFERENCES borrowers(uid)
);

-- 创建借阅记录表
CREATE TABLE IF NOT EXISTS borrowing_records (
    record_id VARCHAR(50) PRIMARY KEY,
    borrower_id VARCHAR(50) NOT NULL,
    book_id VARCHAR(50) NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_status ENUM('borrowed', 'returned', 'overdue') DEFAULT 'borrowed',
    actual_return_date DATE,
    overdue_days INT DEFAULT 0,
    FOREIGN KEY (borrower_id) REFERENCES borrowers(uid),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- 创建罚款记录表
CREATE TABLE IF NOT EXISTS fine_records (
    fine_id VARCHAR(50) PRIMARY KEY,
    borrowing_record_id VARCHAR(50) NOT NULL,
    borrower_id VARCHAR(50) NOT NULL,
    book_id VARCHAR(50) NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    overdue_days INT DEFAULT 0,
    return_status ENUM('returned', 'overdue') NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('unpaid', 'paid') DEFAULT 'unpaid',
    FOREIGN KEY (borrowing_record_id) REFERENCES borrowing_records(record_id),
    FOREIGN KEY (borrower_id) REFERENCES borrowers(uid),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- =============================================
-- 2. 插入基础数据
-- =============================================

-- 插入用户类型数据
INSERT IGNORE INTO user_types (type_name, max_borrow_count, max_borrow_days) VALUES 
('学生', 5, 30),
('教师', 10, 60),
('校外人员', 3, 15),
('管理员', 20, 90),
('超级管理员', 50, 180);

-- =============================================
-- 3. 创建函数 (Functions)
-- =============================================

-- 计算罚款金额函数
DELIMITER //

CREATE FUNCTION IF NOT EXISTS calculateFine(p_overdue_days INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- 检查逾期天数是否有效
    IF p_overdue_days <= 0 THEN
        SET v_fine_amount = 0.00;
    ELSE
        -- 计算罚款金额（假设每天罚款1元）
        SET v_fine_amount = p_overdue_days * 1.00;
    END IF;
    
    RETURN v_fine_amount;
END//

-- 计算逾期天数函数
CREATE FUNCTION IF NOT EXISTS getOverdueDays(p_due_date DATE, p_current_date DATE) 
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_overdue_days INT;
    
    -- 检查日期是否有效
    IF p_due_date IS NULL OR p_current_date IS NULL THEN
        RETURN 0;
    END IF;
    
    -- 计算逾期天数
    IF p_current_date > p_due_date THEN
        SET v_overdue_days = DATEDIFF(p_current_date, p_due_date);
    ELSE
        SET v_overdue_days = 0;
    END IF;
    
    RETURN v_overdue_days;
END//

-- 获取图书总数函数
CREATE FUNCTION IF NOT EXISTS getBookCount() 
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total_books INT;
    
    -- 获取图书总数
    SELECT COUNT(*) INTO v_total_books FROM books;
    
    RETURN v_total_books;
END//

-- 获取用户借阅数量函数
CREATE FUNCTION IF NOT EXISTS getUserBorrowedCount(p_user_id VARCHAR(50)) 
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_borrowed_count INT;
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        RETURN -1; -- 用户不存在
    END IF;
    
    -- 获取用户当前借阅数量
    SELECT borrowed_count INTO v_borrowed_count 
    FROM borrowers 
    WHERE uid = p_user_id;
    
    RETURN v_borrowed_count;
END//

DELIMITER ;

-- =============================================
-- 4. 创建存储过程 (Procedures)
-- =============================================

DELIMITER //

-- 用户登录存储过程
CREATE PROCEDURE IF NOT EXISTS userLogin(
    IN p_user_id VARCHAR(50),
    IN p_password VARCHAR(255),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_user_name VARCHAR(100),
    OUT p_user_type VARCHAR(50),
    OUT p_borrowing_status VARCHAR(20)
)
BEGIN
    DECLARE v_password_hash VARCHAR(255);
    DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_type VARCHAR(50);
    DECLARE v_borrowing_status VARCHAR(20);
    DECLARE v_identity_type INT;
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_user_name = '';
    SET p_user_type = '';
    SET p_borrowing_status = '';
    
    -- 检查用户是否存在
    SELECT ua.password_hash, b.name, b.borrowing_status, b.identity_type
    INTO v_password_hash, v_user_name, v_borrowing_status, v_identity_type
    FROM user_auth ua
    JOIN borrowers b ON ua.user_id = b.uid
    WHERE ua.user_id = p_user_id;
    
    -- 如果用户不存在
    IF v_password_hash IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
    ELSE
        -- 验证密码（这里假设密码在应用层已经哈希处理）
        IF v_password_hash != p_password THEN
            SET p_result_code = 2;
            SET p_result_message = '密码错误';
        ELSE
            -- 检查用户状态
            IF v_borrowing_status = 'suspended' THEN
                SET p_result_code = 3;
                SET p_result_message = '账户已被冻结';
            ELSE
                -- 获取用户类型名称
                SELECT type_name INTO v_user_type
                FROM user_types
                WHERE type_id = v_identity_type;
                
                -- 登录成功
                SET p_result_code = 0;
                SET p_result_message = '登录成功';
                SET p_user_name = v_user_name;
                SET p_user_type = v_user_type;
                SET p_borrowing_status = v_borrowing_status;
            END IF;
        END IF;
    END IF;
END//

-- 用户注册存储过程
CREATE PROCEDURE IF NOT EXISTS userRegister(
    IN p_uid VARCHAR(50),
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_identity_type INT,
    IN p_student_id VARCHAR(50),
    IN p_employee_id VARCHAR(50),
    IN p_password_hash VARCHAR(255),
    IN p_registration_date DATE,
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：注册失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查用户ID是否已存在
    IF EXISTS (SELECT 1 FROM borrowers WHERE uid = p_uid) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户ID已存在';
    ELSE
        -- 检查身份类型是否存在
        IF NOT EXISTS (SELECT 1 FROM user_types WHERE type_id = p_identity_type) THEN
            SET p_result_code = 2;
            SET p_result_message = '身份类型不存在';
        ELSE
            -- 插入用户信息
            INSERT INTO borrowers (
                uid, name, phone, identity_type, student_id, employee_id,
                borrowed_count, registration_date, borrowing_status
            ) VALUES (
                p_uid, p_name, p_phone, p_identity_type, p_student_id, p_employee_id,
                0, p_registration_date, 'active'
            );
            
            -- 插入用户认证信息
            INSERT INTO user_auth (user_id, password_hash) 
            VALUES (p_uid, p_password_hash);
            
            -- 提交事务
            SET p_result_code = 0;
            SET p_result_message = '用户注册成功';
        END IF;
    END IF;
END//

-- 添加图书存储过程
CREATE PROCEDURE IF NOT EXISTS addBook(
    IN p_book_id VARCHAR(50),
    IN p_title VARCHAR(200),
    IN p_isbn VARCHAR(20),
    IN p_publisher_id VARCHAR(50),
    IN p_publication_year YEAR,
    IN p_total_stock INT,
    IN p_location VARCHAR(100),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：添加图书失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查图书是否已存在
    IF EXISTS (SELECT 1 FROM books WHERE book_id = p_book_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '图书ID已存在';
    ELSE
        -- 插入图书信息
        INSERT INTO books (
            book_id, title, isbn, publisher_id, publication_year, 
            total_stock, current_stock, location
        ) VALUES (
            p_book_id, p_title, p_isbn, p_publisher_id, p_publication_year,
            p_total_stock, p_total_stock, p_location
        );
        
        -- 提交事务
        SET p_result_code = 0;
        SET p_result_message = '图书添加成功';
    END IF;
END//

-- 借书存储过程
CREATE PROCEDURE IF NOT EXISTS borrowBook(
    IN p_borrower_id VARCHAR(50),
    IN p_book_id VARCHAR(50),
    IN p_borrow_date DATE,
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_record_id VARCHAR(50)
)
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_borrowed_count INT;
    DECLARE v_max_borrow_count INT;
    DECLARE v_borrowing_status VARCHAR(20);
    DECLARE v_due_date DATE;
    DECLARE v_record_id VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：借书失败';
        SET p_record_id = '';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_record_id = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查用户是否存在和状态
    SELECT b.borrowed_count, b.borrowing_status, ut.max_borrow_count
    INTO v_borrowed_count, v_borrowing_status, v_max_borrow_count
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_borrower_id;
    
    IF v_borrowing_status IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
        ROLLBACK;
    ELSEIF v_borrowing_status = 'suspended' THEN
        SET p_result_code = 2;
        SET p_result_message = '用户账户已被冻结';
        ROLLBACK;
    ELSEIF v_borrowed_count >= v_max_borrow_count THEN
        SET p_result_code = 3;
        SET p_result_message = '已达到最大借阅数量';
        ROLLBACK;
    ELSE
        -- 检查图书库存
        SELECT current_stock INTO v_current_stock 
        FROM books 
        WHERE book_id = p_book_id;
        
        IF v_current_stock IS NULL THEN
            SET p_result_code = 4;
            SET p_result_message = '图书不存在';
            ROLLBACK;
        ELSEIF v_current_stock <= 0 THEN
            SET p_result_code = 5;
            SET p_result_message = '图书库存不足';
            ROLLBACK;
        ELSE
            -- 生成借阅记录ID
            SET v_record_id = CONCAT('BR', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));
            
            -- 计算应还日期
            SELECT max_borrow_days INTO v_due_date
            FROM user_types ut
            JOIN borrowers b ON ut.type_id = b.identity_type
            WHERE b.uid = p_borrower_id;
            
            SET v_due_date = DATE_ADD(p_borrow_date, INTERVAL v_due_date DAY);
            
            -- 插入借阅记录
            INSERT INTO borrowing_records (
                record_id, borrower_id, book_id, borrow_date, due_date, return_status
            ) VALUES (
                v_record_id, p_borrower_id, p_book_id, p_borrow_date, v_due_date, 'borrowed'
            );
            
            -- 更新图书库存
            UPDATE books 
            SET current_stock = current_stock - 1 
            WHERE book_id = p_book_id;
            
            -- 更新用户借阅数量
            UPDATE borrowers
            SET borrowed_count = borrowed_count + 1
            WHERE uid = p_borrower_id;
            
            -- 提交事务
            COMMIT;
            SET p_result_code = 0;
            SET p_result_message = '借书成功';
            SET p_record_id = v_record_id;
        END IF;
    END IF;
END//

-- 还书存储过程
CREATE PROCEDURE IF NOT EXISTS returnBook(
    IN p_record_id VARCHAR(50),
    IN p_return_date DATE,
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_overdue_days INT,
    OUT p_fine_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_book_id VARCHAR(50);
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_due_date DATE;
    DECLARE v_return_status VARCHAR(20);
    DECLARE v_borrowed_count INT;
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：还书失败';
        SET p_overdue_days = 0;
        SET p_fine_amount = 0.00;
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_overdue_days = 0;
    SET p_fine_amount = 0.00;
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查借阅记录是否存在和状态
    SELECT book_id, borrower_id, due_date, return_status
    INTO v_book_id, v_borrower_id, v_due_date, v_return_status
    FROM borrowing_records
    WHERE record_id = p_record_id;
    
    IF v_book_id IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '借阅记录不存在';
        ROLLBACK;
    ELSEIF v_return_status = 'returned' THEN
        SET p_result_code = 2;
        SET p_result_message = '图书已归还';
        ROLLBACK;
    ELSE
        -- 计算逾期天数
        IF p_return_date > v_due_date THEN
            SET p_overdue_days = DATEDIFF(p_return_date, v_due_date);
        ELSE
            SET p_overdue_days = 0;
        END IF;
        
        -- 计算罚款金额（假设每天罚款1元）
        SET p_fine_amount = p_overdue_days * 1.00;
        
        -- 更新借阅记录
        UPDATE borrowing_records
        SET 
            actual_return_date = p_return_date,
            return_status = 'returned',
            overdue_days = p_overdue_days
        WHERE record_id = p_record_id;
        
        -- 更新图书库存
        UPDATE books
        SET current_stock = current_stock + 1
        WHERE book_id = v_book_id;
        
        -- 更新用户借阅数量
        UPDATE borrowers
        SET borrowed_count = borrowed_count - 1
        WHERE uid = v_borrower_id;
        
        -- 如果有逾期，创建罚款记录
        IF p_overdue_days > 0 THEN
            INSERT INTO fine_records (
                fine_id, borrowing_record_id, borrower_id, book_id, 
                borrow_date, due_date, overdue_days, return_status, 
                fine_amount, payment_status
            ) VALUES (
                CONCAT('F', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
                p_record_id, v_borrower_id, v_book_id,
                (SELECT borrow_date FROM borrowing_records WHERE record_id = p_record_id),
                v_due_date, p_overdue_days, 'overdue',
                p_fine_amount, 'unpaid'
            );
        END IF;
        
        -- 提交事务
        COMMIT;
        SET p_result_code = 0;
        SET p_result_message = '还书成功';
    END IF;
END//

-- 按书名搜索图书存储过程
CREATE PROCEDURE IF NOT EXISTS searchBooksByName(
    IN p_book_name VARCHAR(200),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查搜索关键字是否为空
    IF p_book_name IS NULL OR p_book_name = '' THEN
        SET p_result_code = 1;
        SET p_result_message = '搜索关键字不能为空';
    ELSE
        -- 按书名搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        WHERE b.title LIKE CONCAT('%', p_book_name, '%')
        ORDER BY b.title;
    END IF;
END//

-- 按作者名搜索图书存储过程
CREATE PROCEDURE IF NOT EXISTS searchBooksByAuthor(
    IN p_author_name VARCHAR(100),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查搜索作者名是否为空
    IF p_author_name IS NULL OR p_author_name = '' THEN
        SET p_result_code = 1;
        SET p_result_message = '搜索作者名不能为空';
    ELSE
        -- 按作者名搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock,
            GROUP_CONCAT(a.author_name) AS authors
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        JOIN book_authors ba ON b.book_id = ba.book_id
        JOIN authors a ON ba.author_id = a.author_id
        WHERE a.author_name LIKE CONCAT('%', p_author_name, '%')
        GROUP BY b.book_id, b.title, b.isbn, p.publisher_name, b.publication_year, b.current_stock, b.total_stock
        ORDER BY b.title;
    END IF;
END//

-- 按ISBN搜索图书存储过程
CREATE PROCEDURE IF NOT EXISTS searchBooksByISBN(
    IN p_isbn VARCHAR(20),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查ISBN是否为空
    IF p_isbn IS NULL OR p_isbn = '' THEN
        SET p_result_code = 1;
        SET p_result_message = 'ISBN不能为空';
    ELSE
        -- 按ISBN搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        WHERE b.isbn LIKE CONCAT('%', p_isbn, '%')
        ORDER BY b.title;
    END IF;
END//

-- 按出版社搜索图书存储过程
CREATE PROCEDURE IF NOT EXISTS searchBooksByPublisher(
    IN p_publisher_name VARCHAR(100),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查搜索出版社名是否为空
    IF p_publisher_name IS NULL OR p_publisher_name = '' THEN
        SET p_result_code = 1;
        SET p_result_message = '搜索出版社名不能为空';
    ELSE
        -- 按出版社名搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        WHERE p.publisher_name LIKE CONCAT('%', p_publisher_name, '%')
        ORDER BY b.title;
    END IF;
END//

-- 按标签搜索图书存储过程
CREATE PROCEDURE IF NOT EXISTS searchBooksByTag(
    IN p_tag_name VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查搜索标签是否为空
    IF p_tag_name IS NULL OR p_tag_name = '' THEN
        SET p_result_code = 1;
        SET p_result_message = '搜索标签不能为空';
    ELSE
        -- 按标签搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock,
            GROUP_CONCAT(t.tag_name) AS tags
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        JOIN book_tags bt ON b.book_id = bt.book_id
        JOIN tags t ON bt.tag_id = t.tag_id
        WHERE t.tag_name LIKE CONCAT('%', p_tag_name, '%')
        GROUP BY b.book_id, b.title, b.isbn, p.publisher_name, b.publication_year, b.current_stock, b.total_stock
        ORDER BY b.title;
    END IF;
END//

-- 获取用户当前借阅记录存储过程
CREATE PROCEDURE IF NOT EXISTS getUserCurrentBorrowingRecords(
    IN p_user_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
    ELSE
        -- 查询用户当前借阅记录
        SELECT 
            br.record_id,
            b.title AS book_title,
            br.borrow_date,
            br.due_date,
            DATEDIFF(CURDATE(), br.due_date) AS overdue_days
        FROM borrowing_records br
        JOIN books b ON br.book_id = b.book_id
        WHERE br.borrower_id = p_user_id 
        AND br.return_status = 'borrowed'
        ORDER BY br.due_date ASC;
    END IF;
END//

-- 获取用户所有借阅记录存储过程
CREATE PROCEDURE IF NOT EXISTS getUserAllBorrowingRecords(
    IN p_user_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
    ELSE
        -- 查询用户所有借阅记录
        SELECT 
            br.record_id,
            b.title AS book_title,
            br.borrow_date,
            br.due_date,
            br.actual_return_date,
            br.return_status,
            br.overdue_days
        FROM borrowing_records br
        JOIN books b ON br.book_id = b.book_id
        WHERE br.borrower_id = p_user_id
        ORDER BY br.borrow_date DESC;
    END IF;
END//

-- 获取用户罚款记录存储过程
CREATE PROCEDURE IF NOT EXISTS getUserFineRecords(
    IN p_user_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
    ELSE
        -- 查询用户罚款记录
        SELECT 
            fr.fine_id,
            b.title AS book_title,
            fr.borrow_date,
            fr.due_date,
            fr.overdue_days,
            fr.fine_amount,
            fr.payment_status
        FROM fine_records fr
        JOIN books b ON fr.book_id = b.book_id
        WHERE fr.borrower_id = p_user_id
        ORDER BY fr.borrow_date DESC;
    END IF;
END//

-- 管理员获取所有借阅记录存储过程
CREATE PROCEDURE IF NOT EXISTS getAllBorrowingRecords(
    IN p_admin_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '管理员不存在';
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足';
    ELSE
        -- 查询所有借阅记录
        SELECT 
            br.record_id,
            b.title AS book_title,
            br_b.name AS borrower_name,
            br.borrow_date,
            br.due_date,
            br.actual_return_date,
            br.return_status,
            br.overdue_days
        FROM borrowing_records br
        JOIN books b ON br.book_id = b.book_id
        JOIN borrowers br_b ON br.borrower_id = br_b.uid
        ORDER BY br.borrow_date DESC;
    END IF;
END//

-- 管理员获取所有罚款记录存储过程
CREATE PROCEDURE IF NOT EXISTS getAllFineRecords(
    IN p_admin_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '管理员不存在';
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足';
    ELSE
        -- 查询所有罚款记录
        SELECT 
            fr.fine_id,
            b.title AS book_title,
            br.name AS borrower_name,
            fr.borrow_date,
            fr.due_date,
            fr.overdue_days,
            fr.fine_amount,
            fr.payment_status
        FROM fine_records fr
        JOIN books b ON fr.book_id = b.book_id
        JOIN borrowers br ON fr.borrower_id = br.uid
        ORDER BY fr.borrow_date DESC;
    END IF;
END//

-- 管理员获取用户登录日志存储过程
CREATE PROCEDURE IF NOT EXISTS getUserLoginLogs(
    IN p_admin_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '管理员不存在';
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足';
    ELSE
        -- 查询用户登录日志
        SELECT 
            ll.log_id,
            b.name AS user_name,
            ll.login_time,
            ll.ip_address,
            ll.login_status
        FROM login_logs ll
        JOIN borrowers b ON ll.user_id = b.uid
        ORDER BY ll.login_time DESC;
    END IF;
END//

-- 管理员管理用户存储过程
CREATE PROCEDURE IF NOT EXISTS manageUser(
    IN p_admin_id VARCHAR(50),
    IN p_user_id VARCHAR(50),
    IN p_action VARCHAR(20), -- 'freeze' or 'unfreeze'
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：操作失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '管理员不存在';
        ROLLBACK;
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足';
        ROLLBACK;
    ELSE
        -- 检查用户是否存在
        IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
            SET p_result_code = 3;
            SET p_result_message = '用户不存在';
            ROLLBACK;
        ELSE
            -- 执行操作
            IF p_action = 'freeze' THEN
                UPDATE borrowers
                SET borrowing_status = 'suspended'
                WHERE uid = p_user_id;
                
                SET p_result_code = 0;
                SET p_result_message = '用户账户已冻结';
            ELSEIF p_action = 'unfreeze' THEN
                UPDATE borrowers
                SET borrowing_status = 'active'
                WHERE uid = p_user_id;
                
                SET p_result_code = 0;
                SET p_result_message = '用户账户已解冻';
            ELSE
                SET p_result_code = 4;
                SET p_result_message = '无效操作';
                ROLLBACK;
            END IF;
            
            -- 提交事务
            COMMIT;
        END IF;
    END IF;
END//

DELIMITER ;

-- =============================================
-- 5. 创建触发器 (Triggers)
-- =============================================

DELIMITER //

-- 记录用户登录触发器
CREATE TRIGGER IF NOT EXISTS logUserLogin
AFTER INSERT ON user_auth
FOR EACH ROW
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('记录用户登录日志失败');
    END;
    
    -- 记录用户注册为登录事件
    INSERT INTO login_logs (
        log_id, user_id, login_time, ip_address, login_status
    ) VALUES (
        CONCAT('L', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
        NEW.user_id, 
        NOW(), 
        '127.0.0.1', 
        'registered'
    );
END//

-- 检查图书可用性触发器
CREATE TRIGGER IF NOT EXISTS checkBookAvailability
BEFORE INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_borrowed_count INT;
    DECLARE v_max_borrow_count INT;
    DECLARE v_borrowing_status VARCHAR(20);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '系统错误：借书检查失败';
    END;
    
    -- 检查图书库存
    SELECT current_stock INTO v_current_stock 
    FROM books 
    WHERE book_id = NEW.book_id;
    
    IF v_current_stock <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '图书库存不足';
    END IF;
    
    -- 检查用户借阅状态和数量
    SELECT b.borrowed_count, b.borrowing_status, ut.max_borrow_count
    INTO v_borrowed_count, v_borrowing_status, v_max_borrow_count
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = NEW.borrower_id;
    
    IF v_borrowing_status = 'suspended' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '用户账户已被冻结';
    END IF;
    
    IF v_borrowed_count >= v_max_borrow_count THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '已达到最大借阅数量';
    END IF;
END//

-- 更新图书库存触发器
CREATE TRIGGER IF NOT EXISTS updateBookStock
AFTER INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('更新图书库存失败');
    END;
    
    -- 如果是借书操作，减少图书库存
    IF NEW.return_status = 'borrowed' THEN
        UPDATE books 
        SET current_stock = current_stock - 1 
        WHERE book_id = NEW.book_id;
    END IF;
    
    -- 如果是还书操作，增加图书库存
    IF NEW.return_status = 'returned' THEN
        UPDATE books 
        SET current_stock = current_stock + 1 
        WHERE book_id = NEW.book_id;
    END IF;
END//

-- 更新借阅者状态触发器
CREATE TRIGGER IF NOT EXISTS updateBorrowerStatus
AFTER INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('更新借阅者状态失败');
    END;
    
    -- 如果是借书操作，增加用户借阅数量
    IF NEW.return_status = 'borrowed' THEN
        UPDATE borrowers 
        SET borrowed_count = borrowed_count + 1 
        WHERE uid = NEW.borrower_id;
    END IF;
    
    -- 如果是还书操作，减少用户借阅数量
    IF NEW.return_status = 'returned' THEN
        UPDATE borrowers 
        SET borrowed_count = borrowed_count - 1 
        WHERE uid = NEW.borrower_id;
    END IF;
END//

-- 自动计算罚款触发器
CREATE TRIGGER IF NOT EXISTS autoCalculateFine
AFTER UPDATE ON borrowing_records
FOR EACH ROW
BEGIN
    DECLARE v_overdue_days INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('自动计算罚款失败');
    END;
    
    -- 检查是否是还书操作且有逾期
    IF NEW.return_status = 'returned' AND NEW.actual_return_date IS NOT NULL THEN
        -- 计算逾期天数
        SET v_overdue_days = DATEDIFF(NEW.actual_return_date, NEW.due_date);
        
        -- 如果有逾期，自动计算罚款并创建罚款记录
        IF v_overdue_days > 0 THEN
            -- 计算罚款金额
            SET v_fine_amount = v_overdue_days * 1.00;
            
            -- 创建罚款记录
            INSERT INTO fine_records (
                fine_id, borrowing_record_id, borrower_id, book_id, 
                borrow_date, due_date, overdue_days, return_status, 
                fine_amount, payment_status
            ) VALUES (
                CONCAT('F', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
                NEW.record_id, NEW.borrower_id, NEW.book_id,
                NEW.borrow_date, NEW.due_date, v_overdue_days, 'overdue',
                v_fine_amount, 'unpaid'
            );
        END IF;
    END IF;
END//

DELIMITER ;

-- =============================================
-- 6. 创建事件 (Events)
-- =============================================

-- 每日清理事件
DELIMITER //

CREATE EVENT IF NOT EXISTS dailyCleanUp
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 2 HOUR
DO
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('每日清理任务失败');
    END;
    
    -- 清理30天前的登录日志
    DELETE FROM login_logs 
    WHERE login_time < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- 可以添加其他清理任务
    -- 例如：清理过期的临时数据、归档历史记录等
    
END//

-- 每日罚款计算事件
CREATE EVENT IF NOT EXISTS dailyFineCalculation
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 3 HOUR
DO
BEGIN
    DECLARE v_record_id VARCHAR(50);
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_book_id VARCHAR(50);
    DECLARE v_borrow_date DATE;
    DECLARE v_due_date DATE;
    DECLARE v_overdue_days INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- 声明游标结束标志
    DECLARE done INT DEFAULT FALSE;
    
    -- 声明游标
    DECLARE cur_overdue_records CURSOR FOR
        SELECT record_id, borrower_id, book_id, borrow_date, due_date
        FROM borrowing_records
        WHERE return_status = 'borrowed' AND due_date < CURDATE();
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('每日罚款计算任务失败');
    END;
    
    -- 打开游标
    OPEN cur_overdue_records;
    
    -- 循环处理每条超期记录
    read_loop: LOOP
        FETCH cur_overdue_records INTO v_record_id, v_borrower_id, v_book_id, v_borrow_date, v_due_date;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- 计算逾期天数
        SET v_overdue_days = DATEDIFF(CURDATE(), v_due_date);
        
        -- 计算罚款金额
        SET v_fine_amount = v_overdue_days * 1.00;
        
        -- 检查是否已存在罚款记录
        IF NOT EXISTS (SELECT 1 FROM fine_records WHERE borrowing_record_id = v_record_id AND overdue_days = v_overdue_days) THEN
            -- 创建罚款记录
            INSERT INTO fine_records (
                fine_id, borrowing_record_id, borrower_id, book_id, 
                borrow_date, due_date, overdue_days, return_status, 
                fine_amount, payment_status
            ) VALUES (
                CONCAT('F', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
                v_record_id, v_borrower_id, v_book_id,
                v_borrow_date, v_due_date, v_overdue_days, 'overdue',
                v_fine_amount, 'unpaid'
            );
        END IF;
        
    END LOOP;
    
    -- 关闭游标
    CLOSE cur_overdue_records;
    
END//

-- 每日逾期检查事件
CREATE EVENT IF NOT EXISTS dailyOverdueCheck
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 4 HOUR
DO
BEGIN
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_borrowed_count INT;
    DECLARE v_max_borrow_count INT;
    
    -- 声明游标结束标志
    DECLARE done INT DEFAULT FALSE;
    
    -- 声明游标
    DECLARE cur_overdue_borrowers CURSOR FOR
        SELECT DISTINCT br.borrower_id, b.borrowed_count, ut.max_borrow_count
        FROM borrowing_records br
        JOIN borrowers b ON br.borrower_id = b.uid
        JOIN user_types ut ON b.identity_type = ut.type_id
        WHERE br.return_status = 'borrowed' 
        AND br.due_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY); -- 逾期7天以上
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('每日逾期检查任务失败');
    END;
    
    -- 打开游标
    OPEN cur_overdue_borrowers;
    
    -- 循环处理每个逾期用户
    read_loop: LOOP
        FETCH cur_overdue_borrowers INTO v_borrower_id, v_borrowed_count, v_max_borrow_count;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- 如果用户借阅数量超过最大限制，冻结账户
        IF v_borrowed_count > v_max_borrow_count THEN
            UPDATE borrowers
            SET borrowing_status = 'suspended'
            WHERE uid = v_borrower_id;
        END IF;
        
    END LOOP;
    
    -- 关闭游标
    CLOSE cur_overdue_borrowers;
    
END//

DELIMITER ;

-- =============================================
-- 7. 插入种子数据 (Seeds)
-- =============================================

-- 插入出版社数据
INSERT IGNORE INTO publishers (publisher_id, publisher_name) VALUES
('P001', '清华大学出版社'),
('P002', '机械工业出版社'),
('P003', '人民邮电出版社'),
('P004', '电子工业出版社'),
('P005', '高等教育出版社');

-- 插入作者数据
INSERT IGNORE INTO authors (author_id, author_name, birth_date, nationality) VALUES
('A001', 'Robert C. Martin', '1952-01-01', '美国'),
('A002', 'Eric Freeman', '1960-01-01', '美国'),
('A003', 'Bruce Eckel', '1957-01-01', '美国'),
('A004', '周志明', '1982-01-01', '中国'),
('A005', '李刚', '1980-01-01', '中国');

-- 插入标签数据
INSERT IGNORE INTO tags (tag_id, tag_name) VALUES
('T001', '计算机'),
('T002', '编程'),
('T003', 'Java'),
('T004', 'Python'),
('T005', '设计模式'),
('T006', '数据库'),
('T007', 'Web开发'),
('T008', '移动开发');

-- 插入图书数据
INSERT IGNORE INTO books (book_id, title, isbn, publisher_id, publication_year, total_stock, current_stock, location) VALUES
('B001', '代码整洁之道', '9787115216878', 'P001', 2010, 5, 5, 'A区001架'),
('B002', 'Head First设计模式', '9787508362255', 'P002', 2007, 3, 3, 'A区002架'),
('B003', 'Java编程思想', '9787111213826', 'P003', 2007, 4, 4, 'A区003架'),
('B004', '深入理解Java虚拟机', '9787115216879', 'P001', 2011, 2, 2, 'B区001架'),
('B005', 'Python编程：从入门到实践', '9787115428028', 'P001', 2016, 6, 6, 'C区001架');

-- 插入图书作者关联数据
INSERT IGNORE INTO book_authors (book_id, author_id) VALUES
('B001', 'A001'),
('B002', 'A002'),
('B003', 'A003'),
('B004', 'A004'),
('B005', 'A005');

-- 插入图书标签关联数据
INSERT IGNORE INTO book_tags (book_id, tag_id) VALUES
('B001', 'T001'),
('B001', 'T002'),
('B001', 'T005'),
('B002', 'T001'),
('B002', 'T002'),
('B002', 'T005'),
('B003', 'T001'),
('B003', 'T002'),
('B003', 'T003'),
('B004', 'T001'),
('B004', 'T003'),
('B004', 'T006'),
('B005', 'T001'),
('B005', 'T002'),
('B005', 'T004');

-- 插入测试用户数据
INSERT IGNORE INTO borrowers (uid, name, phone, identity_type, student_id, employee_id, borrowed_count, registration_date, borrowing_status) VALUES
('U001', '张三', '13800138001', 1, '2021001', NULL, 0, '2021-09-01', 'active'),
('U002', '李四', '13800138002', 2, NULL, 'E2021001', 0, '2021-09-01', 'active'),
('U003', '王五', '13800138003', 4, NULL, 'E2021002', 0, '2021-09-01', 'active');

-- 插入测试用户认证数据 (密码为123456的哈希值)
INSERT IGNORE INTO user_auth (user_id, password_hash) VALUES
('U001', '$2a$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'),
('U002', '$2a$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'),
('U003', '$2a$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');

-- =============================================
-- 8. 创建索引 (Indexes)
-- =============================================

-- 为常用查询字段创建索引
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_publisher ON books(publisher_id);
CREATE INDEX idx_borrowing_records_borrower ON borrowing_records(borrower_id);
CREATE INDEX idx_borrowing_records_book ON borrowing_records(book_id);
CREATE INDEX idx_borrowing_records_status ON borrowing_records(return_status);
CREATE INDEX idx_fine_records_borrower ON fine_records(borrower_id);
CREATE INDEX idx_fine_records_status ON fine_records(payment_status);
CREATE INDEX idx_login_logs_user ON login_logs(user_id);
CREATE INDEX idx_login_logs_time ON login_logs(login_time);

-- =============================================
-- 9. 数据库初始化完成
-- =============================================

-- 显示初始化完成信息
SELECT '数据库初始化完成' AS message;
