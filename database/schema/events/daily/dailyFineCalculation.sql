DELIMITER //

CREATE EVENT dailyFineCalculation
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 3 HOUR
DO
BEGIN
    DECLARE v_record_id VARCHAR(50);
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_book_id VARCHAR(50);
    DECLARE v_borrow_date DATE;
    DECLARE v_due_date DATE;
    DECLARE v_overdue_days INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- 声明游标结束标志
    DECLARE done INT DEFAULT FALSE;
    
    -- 声明游标
    DECLARE cur_overdue_records CURSOR FOR
        SELECT record_id, borrower_id, book_id, borrow_date, due_date
        FROM borrowing_records
        WHERE return_status = 'borrowed' AND due_date < CURDATE();
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('每日罚款计算任务失败');
    END;
    
    -- 打开游标
    OPEN cur_overdue_records;
    
    -- 循环处理每条超期记录
    read_loop: LOOP
        FETCH cur_overdue_records INTO v_record_id, v_borrower_id, v_book_id, v_borrow_date, v_due_date;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- 计算逾期天数
        SET v_overdue_days = DATEDIFF(CURDATE(), v_due_date);
        
        -- 计算罚款金额
        SET v_fine_amount = v_overdue_days * 1.00;
        
        -- 检查是否已存在罚款记录
        IF NOT EXISTS (SELECT 1 FROM fine_records WHERE borrowing_record_id = v_record_id AND overdue_days = v_overdue_days) THEN
            -- 创建罚款记录
            INSERT INTO fine_records (
                fine_id, borrowing_record_id, borrower_id, book_id, 
                borrow_date, due_date, overdue_days, return_status, 
                fine_amount, payment_status
            ) VALUES (
                CONCAT('F', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
                v_record_id, v_borrower_id, v_book_id,
                v_borrow_date, v_due_date, v_overdue_days, 'overdue',
                v_fine_amount, 'unpaid'
            );
        END IF;
        
    END LOOP;
    
    -- 关闭游标
    CLOSE cur_overdue_records;
    
END//

DELIMITER ;
