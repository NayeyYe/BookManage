USE bookmanage;
DROP PROCEDURE IF EXISTS getUserLoginLogs;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getUserLoginLogs(
    IN p_admin_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：查询失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '管理员不存在';
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足';
    ELSE
        -- 查询用户登录日志
        SELECT 
            ll.log_id,
            b.name AS user_name,
            ll.login_time,
            ll.ip_address,
            ll.login_status
        FROM login_logs ll
        JOIN borrowers b ON ll.user_id = b.uid
        ORDER BY ll.login_time DESC;
    END IF;
END//

DELIMITER ;
