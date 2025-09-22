USE bookmanage;
DROP PROCEDURE IF EXISTS deleteBook;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS deleteBook(
    IN p_book_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = 'System error: Failed to delete book';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查图书是否存在
    IF NOT EXISTS (SELECT 1 FROM books WHERE book_id = p_book_id) THEN
        SET p_result_code = 1;
        SET p_result_message = 'Book not found';
        ROLLBACK;
    ELSE
        -- 删除图书
        DELETE FROM books WHERE book_id = p_book_id;
        
        -- 提交事务
        COMMIT;
        SET p_result_code = 0;
        SET p_result_message = 'Book deleted successfully';
    END IF;
END//

DELIMITER ;
