USE bookmanage;
DROP PROCEDURE IF EXISTS getAllFineRecordsDetailed;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getAllFineRecordsDetailed(
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：获取罚款记录失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 获取所有罚款记录
    SELECT fr.*, b.title as book_title, bo.name as borrower_name, bo.identity_type
    FROM fine_records fr
    JOIN books b ON fr.book_id = b.book_id
    JOIN borrowers bo ON fr.borrower_id = bo.uid
    ORDER BY fr.borrow_date DESC;
END//

DELIMITER ;
