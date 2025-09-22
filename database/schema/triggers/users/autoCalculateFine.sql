DELIMITER //

CREATE TRIGGER autoCalculateFine
AFTER UPDATE ON borrowing_records
FOR EACH ROW
BEGIN
    DECLARE v_overdue_days INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('自动计算罚款失败');
    END;
    
    -- 检查是否是还书操作且有逾期
    IF NEW.return_status = 'returned' AND NEW.actual_return_date IS NOT NULL THEN
        -- 计算逾期天数
        SET v_overdue_days = DATEDIFF(NEW.actual_return_date, NEW.due_date);
        
        -- 如果有逾期，自动计算罚款并创建罚款记录
        IF v_overdue_days > 0 THEN
            -- 计算罚款金额
            SET v_fine_amount = v_overdue_days * 1.00;
            
            -- 创建罚款记录
            INSERT INTO fine_records (
                fine_id, borrowing_record_id, borrower_id, book_id, 
                borrow_date, due_date, overdue_days, return_status, 
                fine_amount, payment_status
            ) VALUES (
                CONCAT('F', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
                NEW.record_id, NEW.borrower_id, NEW.book_id,
                NEW.borrow_date, NEW.due_date, v_overdue_days, 'overdue',
                v_fine_amount, 'unpaid'
            );
        END IF;
    END IF;
END//

DELIMITER ;
