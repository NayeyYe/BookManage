USE bookmanage;
DROP PROCEDURE IF EXISTS getAllBooks;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getAllBooks(
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
    
    -- 查询所有图书
    SELECT * FROM books;
END//

DELIMITER ;
