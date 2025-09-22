DELIMITER //

CREATE PROCEDURE searchBooksByName(
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
            p.name AS publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        WHERE b.title LIKE CONCAT('%', p_book_name, '%')
        ORDER BY b.title;
    END IF;
END//

DELIMITER ;
