DELIMITER //

CREATE PROCEDURE getAllBorrowingRecordsDetailed(
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：获取借阅记录失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 获取所有借阅记录
    SELECT br.*, b.title as book_title, bo.name as borrower_name, bo.identity_type
    FROM borrowing_records br
    JOIN books b ON br.book_id = b.book_id
    JOIN borrowers bo ON br.borrower_id = bo.uid
    ORDER BY br.borrow_date DESC;
END//

DELIMITER ;
