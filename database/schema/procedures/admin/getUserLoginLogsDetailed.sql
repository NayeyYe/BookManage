USE bookmanage;
DROP PROCEDURE IF EXISTS getUserLoginLogsDetailed;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS getUserLoginLogsDetailed(
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：获取登录日志失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 获取用户登录日志
    SELECT ll.*, bo.name as user_name, bo.identity_type
    FROM login_logs ll
    JOIN borrowers bo ON ll.user_id = bo.uid
    ORDER BY ll.login_time DESC;
END//

DELIMITER ;
