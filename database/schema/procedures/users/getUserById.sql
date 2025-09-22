USE bookmanage;
DROP PROCEDURE IF EXISTS getUserById;
DELIMITER //

CREATE PROCEDURE getUserById(
    IN p_user_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询用户信息失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户未找到';
    ELSE
        -- 获取用户信息
        SELECT b.*, ut.type_name as identity_type_name 
        FROM borrowers b 
        JOIN user_types ut ON b.identity_type = ut.type_id 
        WHERE b.uid = p_user_id;
    END IF;
END//

DELIMITER ;
