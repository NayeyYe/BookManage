USE bookmanage;
DROP PROCEDURE IF EXISTS getAllBorrowingRecords;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getAllBorrowingRecords(
    IN p_admin_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = 'System error: Query failed';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = 'Admin does not exist';
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = 'Insufficient permissions';
    ELSE
        -- 查询所有借阅记录
        SELECT 
            br.record_id,
            b.title AS book_title,
            br_b.name AS borrower_name,
            br.borrow_date,
            br.due_date,
            br.actual_return_date,
            br.return_status,
            br.overdue_days
        FROM borrowing_records br
        JOIN books b ON br.book_id = b.book_id
        JOIN borrowers br_b ON br.borrower_id = br_b.uid
        ORDER BY br.borrow_date DESC;
    END IF;
END//

DELIMITER ;
