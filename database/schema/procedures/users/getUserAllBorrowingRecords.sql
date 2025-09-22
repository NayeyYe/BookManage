USE bookmanage;
DROP PROCEDURE IF EXISTS getUserAllBorrowingRecords;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getUserAllBorrowingRecords(
    IN p_user_id VARCHAR(50),
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
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = 'User does not exist';
    ELSE
        -- 查询用户所有借阅记录
        SELECT 
            br.record_id,
            b.title AS book_title,
            br.borrow_date,
            br.due_date,
            br.actual_return_date,
            br.return_status,
            br.overdue_days
        FROM borrowing_records br
        JOIN books b ON br.book_id = b.book_id
        WHERE br.borrower_id = p_user_id
        ORDER BY br.borrow_date DESC;
    END IF;
END//

DELIMITER ;
