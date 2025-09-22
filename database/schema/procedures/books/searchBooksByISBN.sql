DELIMITER //

CREATE PROCEDURE searchBooksByISBN(
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
            p.name AS publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        WHERE b.isbn LIKE CONCAT('%', p_isbn, '%')
        ORDER BY b.title;
    END IF;
END//

DELIMITER ;
