DELIMITER //

CREATE FUNCTION calculateFine(p_overdue_days INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- 检查逾期天数是否有效
    IF p_overdue_days <= 0 THEN
        SET v_fine_amount = 0.00;
    ELSE
        -- 计算罚款金额（假设每天罚款1元）
        SET v_fine_amount = p_overdue_days * 1.00;
    END IF;
    
    RETURN v_fine_amount;
END//

DELIMITER ;
