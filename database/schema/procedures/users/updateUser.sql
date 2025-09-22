DELIMITER //

CREATE PROCEDURE updateUser(
    IN p_user_id VARCHAR(50),
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：更新用户信息失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户未找到';
        ROLLBACK;
    ELSE
        -- 更新用户信息
        UPDATE borrowers 
        SET name = p_name, phone = p_phone 
        WHERE uid = p_user_id;
        
        -- 提交事务
        COMMIT;
        SET p_result_message = '用户信息更新成功';
    END IF;
END//

DELIMITER ;
