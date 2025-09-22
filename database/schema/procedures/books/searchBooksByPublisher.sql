USE bookmanage;
DROP PROCEDURE IF EXISTS searchBooksByPublisher;
DELIMITER //

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
        SET p_result_message = 'System error: Query failed';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查搜索出版社名是否为空
    IF p_publisher_name IS NULL OR p_publisher_name = '' THEN
        SET p_result_code = 1;
        SET p_result_message = 'Publisher name cannot be empty';
    ELSE
        -- 按出版社名搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.name AS publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        WHERE p.name LIKE CONCAT('%', p_publisher_name, '%')
        ORDER BY b.title;
    END IF;
END//

DELIMITER ;
