USE bookmanage;
DROP PROCEDURE IF EXISTS userRegister;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS userRegister(
    IN p_uid VARCHAR(50),
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_identity_type INT,
    IN p_student_id VARCHAR(50),
    IN p_employee_id VARCHAR(50),
    IN p_password_hash VARCHAR(255),
    IN p_registration_date DATE,
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = 'System error: Registration failed';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查用户ID是否已存在
    IF EXISTS (SELECT 1 FROM borrowers WHERE uid = p_uid) THEN
        SET p_result_code = 1;
        SET p_result_message = 'User ID already exists';
        ROLLBACK;
    ELSE
        -- 检查身份类型是否存在
        IF NOT EXISTS (SELECT 1 FROM user_types WHERE type_id = p_identity_type) THEN
            SET p_result_code = 2;
            SET p_result_message = 'Identity type does not exist';
            ROLLBACK;
        ELSE
            -- 插入用户信息
            INSERT INTO borrowers (
                uid, name, phone, identity_type, student_id, employee_id,
                borrowed_count, registration_date, borrowing_status
            ) VALUES (
                p_uid, p_name, p_phone, p_identity_type, p_student_id, p_employee_id,
                0, p_registration_date, 'active'
            );
            
            -- 插入用户认证信息
            INSERT INTO user_auth (user_id, password_hash) 
            VALUES (p_uid, SHA2(p_password_hash, 256));
            
            -- 提交事务
            COMMIT;
            SET p_result_code = 0;
            SET p_result_message = 'User registration successful';
        END IF;
    END IF;
END//

DELIMITER ;
