DELIMITER //

CREATE PROCEDURE getAllFineRecords(
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
        SET p_result_message = '系统错误：查询失败';
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
        SET p_result_message = '管理员不存在';
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足';
    ELSE
        -- 查询所有罚款记录
        SELECT 
            fr.fine_id,
            b.title AS book_title,
            br.name AS borrower_name,
            fr.borrow_date,
            fr.due_date,
            fr.overdue_days,
            fr.fine_amount,
            fr.payment_status
        FROM fine_records fr
        JOIN books b ON fr.book_id = b.book_id
        JOIN borrowers br ON fr.borrower_id = br.uid
        ORDER BY fr.borrow_date DESC;
    END IF;
END//

DELIMITER ;
