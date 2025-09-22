DELIMITER //

CREATE FUNCTION getUserBorrowedCount(p_user_id VARCHAR(50)) 
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_borrowed_count INT;
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        RETURN -1; -- 用户不存在
    END IF;
    
    -- 获取用户当前借阅数量
    SELECT borrowed_count INTO v_borrowed_count 
    FROM borrowers 
    WHERE uid = p_user_id;
    
    RETURN v_borrowed_count;
END//

DELIMITER ;
