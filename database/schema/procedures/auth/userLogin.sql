USE bookmanage;
DROP PROCEDURE IF EXISTS userLogin;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS userLogin(
    IN p_user_id VARCHAR(50),
    IN p_password VARCHAR(255),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_user_name VARCHAR(100),
    OUT p_user_type VARCHAR(50),
    OUT p_borrowing_status VARCHAR(20)
)
BEGIN
    DECLARE v_password_hash VARCHAR(255);
    DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_type VARCHAR(50);
    DECLARE v_borrowing_status VARCHAR(20);
    DECLARE v_identity_type INT;
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = 'System error';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_user_name = '';
    SET p_user_type = '';
    SET p_borrowing_status = '';
    
    -- 检查用户是否存在
    SELECT ua.password_hash, b.name, b.borrowing_status, b.identity_type
    INTO v_password_hash, v_user_name, v_borrowing_status, v_identity_type
    FROM user_auth ua
    JOIN borrowers b ON ua.user_id = b.uid
    WHERE ua.user_id = p_user_id;
    
    -- 如果用户不存在
    IF v_password_hash IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = 'User does not exist';
    ELSE
        -- 验证密码（这里假设密码在应用层已经哈希处理）
        IF v_password_hash != p_password THEN
            SET p_result_code = 2;
            SET p_result_message = 'Incorrect password';
        ELSE
            -- 检查用户状态
            IF v_borrowing_status = 'suspended' THEN
                SET p_result_code = 3;
                SET p_result_message = 'Account has been suspended';
            ELSE
                -- 获取用户类型名称
                SELECT type_name INTO v_user_type
                FROM user_types
                WHERE type_id = v_identity_type;
                
                -- 登录成功
                SET p_result_code = 0;
                SET p_result_message = 'Login successful';
                SET p_user_name = v_user_name;
                SET p_user_type = v_user_type;
                SET p_borrowing_status = v_borrowing_status;
            END IF;
        END IF;
    END IF;
END//

DELIMITER ;
