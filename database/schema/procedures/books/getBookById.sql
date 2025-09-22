USE bookmanage;
DROP PROCEDURE IF EXISTS getBookById;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getBookById(
    IN p_book_id VARCHAR(50),
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
    
    -- 检查图书是否存在
    IF NOT EXISTS (SELECT 1 FROM books WHERE book_id = p_book_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '图书未找到';
    ELSE
        -- 根据ID查询图书
        SELECT * FROM books WHERE book_id = p_book_id;
    END IF;
END//

DELIMITER ;
