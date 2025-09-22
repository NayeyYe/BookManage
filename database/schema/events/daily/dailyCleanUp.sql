DELIMITER //

CREATE EVENT dailyCleanUp
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 2 HOUR
DO
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('每日清理任务失败');
    END;
    
    -- 清理30天前的登录日志
    DELETE FROM login_logs 
    WHERE login_time < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- 可以添加其他清理任务
    -- 例如：清理过期的临时数据、归档历史记录等
    
END//

DELIMITER ;
