USE bookmanage;
DROP PROCEDURE IF EXISTS manageUser;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS manageUser(
    IN p_admin_id VARCHAR(50),
    IN p_user_id VARCHAR(50),
    IN p_action VARCHAR(20), -- 'freeze' or 'unfreeze'
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_admin_type VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = 'System error: Operation failed';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查管理员是否存在和权限
    SELECT ut.type_name INTO v_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_admin_id;
    
    IF v_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = 'Admin does not exist';
        ROLLBACK;
    ELSEIF v_admin_type != '管理员' AND v_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = 'Insufficient permissions';
        ROLLBACK;
    ELSE
        -- 检查用户是否存在
        IF NOT EXISTS (SELECT 1 FROM borrowers WHERE uid = p_user_id) THEN
            SET p_result_code = 3;
            SET p_result_message = 'User does not exist';
            ROLLBACK;
        ELSE
            -- 执行操作
            IF p_action = 'freeze' THEN
                UPDATE borrowers
                SET borrowing_status = 'suspended'
                WHERE uid = p_user_id;
                
                SET p_result_code = 0;
                SET p_result_message = 'User account has been suspended';
            ELSEIF p_action = 'unfreeze' THEN
                UPDATE borrowers
                SET borrowing_status = 'active'
                WHERE uid = p_user_id;
                
                SET p_result_code = 0;
                SET p_result_message = 'User account has been unsuspended';
            ELSE
                SET p_result_code = 4;
                SET p_result_message = 'Invalid operation';
                ROLLBACK;
            END IF;
            
            -- 提交事务
            COMMIT;
        END IF;
    END IF;
END//

DELIMITER ;
