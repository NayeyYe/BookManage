USE bookmanage;
DROP TRIGGER IF EXISTS logUserLogin;
DELIMITER //

CREATE TRIGGER logUserLogin
AFTER INSERT ON user_auth
FOR EACH ROW
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('记录用户登录日志失败');
    END;
    
    -- 记录用户注册为登录事件
    INSERT INTO login_logs (
        log_id, user_id, login_time
    ) VALUES (
        CONCAT('L', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
        NEW.user_id, 
        NOW()
    );
END//

DELIMITER ;
