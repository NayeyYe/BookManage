USE bookmanage;
DROP PROCEDURE IF EXISTS manageUserComplete;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS manageUserComplete(
    IN p_uid VARCHAR(50),
    IN p_action VARCHAR(20),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：管理用户失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 检查用户是否存在
    IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_uid) THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
    ELSE
        CASE p_action
            WHEN 'activate' THEN
                -- 激活用户
                UPDATE borrowers SET borrowing_status = 'active' WHERE uid = p_uid;
                SET p_result_message = '用户已激活';
                
            WHEN 'suspend' THEN
                -- 冻结用户
                UPDATE borrowers SET borrowing_status = 'suspended' WHERE uid = p_uid;
                SET p_result_message = '用户已冻结';
                
            WHEN 'delete' THEN
                -- 开始事务
                START TRANSACTION;
                
                -- 删除用户认证信息
                DELETE FROM user_auth WHERE user_id = p_uid;
                
                -- 删除用户借阅记录
                DELETE FROM borrowing_records WHERE borrower_id = p_uid;
                
                -- 删除用户罚款记录
                DELETE FROM fine_records WHERE borrower_id = p_uid;
                
                -- 删除用户登录日志
                DELETE FROM login_logs WHERE user_id = p_uid;
                
                -- 删除用户
                DELETE FROM borrowers WHERE uid = p_uid;
                
                -- 提交事务
                COMMIT;
                SET p_result_message = '用户已删除';
                
            ELSE
                SET p_result_code = 2;
                SET p_result_message = '无效的操作';
        END CASE;
    END IF;
END//

DELIMITER ;
