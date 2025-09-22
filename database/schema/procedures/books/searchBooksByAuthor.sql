USE bookmanage;
DROP PROCEDURE IF EXISTS searchBooksByAuthor;
DELIMITER //

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
        SET p_result_message = 'System error: Query failed';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查搜索作者名是否为空
    IF p_author_name IS NULL OR p_author_name = '' THEN
        SET p_result_code = 1;
        SET p_result_message = 'Author name cannot be empty';
    ELSE
        -- 按作者名搜索图书
        SELECT 
            b.book_id,
            b.title,
            b.isbn,
            p.name AS publisher_name,
            b.publication_year,
            b.current_stock,
            b.total_stock,
            GROUP_CONCAT(a.name) AS authors
        FROM books b
        JOIN publishers p ON b.publisher_id = p.publisher_id
        JOIN book_authors ba ON b.book_id = ba.book_id
        JOIN authors a ON ba.author_id = a.author_id
        WHERE a.name LIKE CONCAT('%', p_author_name, '%')
        GROUP BY b.book_id, b.title, b.isbn, p.name, b.publication_year, b.current_stock, b.total_stock
        ORDER BY b.title;
    END IF;
END//

DELIMITER ;
