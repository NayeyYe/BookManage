USE bookmanage;
DROP PROCEDURE IF EXISTS searchBooksByTag;
DELIMITER //

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
            p.name AS publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock,
            GROUP_CONCAT(t.tag_name) AS tags
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        JOIN book_tags bt ON b.book_id = bt.book_id
        JOIN tags t ON bt.tag_id = t.tag_id
        WHERE t.tag_name LIKE CONCAT('%', p_tag_name, '%')
        GROUP BY b.book_id, b.title, b.isbn, p.name, b.publication_year, b.current_stock, b.total_stock
        ORDER BY b.title;
    END IF;
END//

DELIMITER ;
