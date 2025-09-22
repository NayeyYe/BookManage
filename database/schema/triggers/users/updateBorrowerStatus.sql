DELIMITER //

CREATE TRIGGER updateBorrowerStatus
AFTER INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('更新借阅者状态失败');
    END;
    
    -- 如果是借书操作，增加用户借阅数量
    IF NEW.return_status = 'borrowed' THEN
        UPDATE borrowers 
        SET borrowed_count = borrowed_count + 1 
        WHERE uid = NEW.borrower_id;
    END IF;
    
    -- 如果是还书操作，减少用户借阅数量
    IF NEW.return_status = 'returned' THEN
        UPDATE borrowers 
        SET borrowed_count = borrowed_count - 1 
        WHERE uid = NEW.borrower_id;
    END IF;
END//

DELIMITER ;
