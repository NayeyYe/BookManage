DELIMITER //

CREATE PROCEDURE searchBooks(
    IN p_query VARCHAR(255),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：搜索图书失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 搜索图书（按书名、ISBN、作者名）
    SELECT DISTINCT b.*, p.publisher_name
    FROM books b
    LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
    LEFT JOIN book_authors ba ON b.book_id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.author_id
    WHERE b.title LIKE CONCAT('%', p_query, '%') 
       OR b.isbn LIKE CONCAT('%', p_query, '%') 
       OR a.author_name LIKE CONCAT('%', p_query, '%');
END//

DELIMITER ;
