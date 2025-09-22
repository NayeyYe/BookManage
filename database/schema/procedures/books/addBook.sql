USE bookmanage;
DROP PROCEDURE IF EXISTS addBook;
DELIMITER //

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
        SET p_result_message = 'System error: Failed to add book';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查图书是否已存在
    IF EXISTS (SELECT 1 FROM books WHERE book_id = p_book_id) THEN
        SET p_result_code = 1;
        SET p_result_message = 'Book ID already exists';
        ROLLBACK;
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
        COMMIT;
        SET p_result_code = 0;
        SET p_result_message = 'Book added successfully';
    END IF;
END//

DELIMITER ;
