DELIMITER //

CREATE FUNCTION getOverdueDays(p_due_date DATE, p_current_date DATE) 
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_overdue_days INT;
    
    -- 检查日期是否有效
    IF p_due_date IS NULL OR p_current_date IS NULL THEN
        RETURN 0;
    END IF;
    
    -- 计算逾期天数
    IF p_current_date > p_due_date THEN
        SET v_overdue_days = DATEDIFF(p_current_date, p_due_date);
    ELSE
        SET v_overdue_days = 0;
    END IF;
    
    RETURN v_overdue_days;
END//

DELIMITER ;
