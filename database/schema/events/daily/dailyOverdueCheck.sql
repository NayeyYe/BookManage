DELIMITER //

CREATE EVENT dailyOverdueCheck
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 4 HOUR
DO
BEGIN
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_borrowed_count INT;
    DECLARE v_max_borrow_count INT;
    
    -- 声明游标结束标志
    DECLARE done INT DEFAULT FALSE;
    
    -- 声明游标
    DECLARE cur_overdue_borrowers CURSOR FOR
        SELECT DISTINCT br.borrower_id, b.borrowed_count, ut.max_borrow_count
        FROM borrowing_records br
        JOIN borrowers b ON br.borrower_id = b.uid
        JOIN user_types ut ON b.identity_type = ut.type_id
        WHERE br.return_status = 'borrowed' 
        AND br.due_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY); -- 逾期7天以上
    
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('每日逾期检查任务失败');
    END;
    
    -- 打开游标
    OPEN cur_overdue_borrowers;
    
    -- 循环处理每个逾期用户
    read_loop: LOOP
        FETCH cur_overdue_borrowers INTO v_borrower_id, v_borrowed_count, v_max_borrow_count;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- 如果用户借阅数量超过最大限制，冻结账户
        IF v_borrowed_count > v_max_borrow_count THEN
            UPDATE borrowers
            SET borrowing_status = 'suspended'
            WHERE uid = v_borrower_id;
        END IF;
        
    END LOOP;
    
    -- 关闭游标
    CLOSE cur_overdue_borrowers;
    
END//

DELIMITER ;
