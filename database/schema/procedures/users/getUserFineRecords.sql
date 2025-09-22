DELIMITER //

CREATE PROCEDURE getUserFineRecords(
    IN p_user_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询用户罚款记录失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户未找到';
    ELSE
        -- 查询用户罚款记录
        SELECT fr.*, b.title as book_title
        FROM fine_records fr
        JOIN books b ON fr.book_id = b.book_id
        WHERE fr.borrower_id = p_user_id
        ORDER BY fr.borrow_date DESC;
    END IF;
END//

DELIMITER ;
