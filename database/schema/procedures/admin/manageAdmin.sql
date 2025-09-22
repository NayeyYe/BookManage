DELIMITER //

CREATE PROCEDURE manageAdmin(
    IN p_super_admin_id VARCHAR(50),
    IN p_admin_id VARCHAR(50),
    IN p_action VARCHAR(20), -- 'promote' (提升为管理员), 'demote' (降级为普通用户), 'freeze' (冻结), 'unfreeze' (解冻)
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_super_admin_type VARCHAR(50);
    DECLARE v_admin_current_type INT;
    DECLARE v_admin_current_status VARCHAR(20);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：操作失败';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查超级管理员是否存在和权限
    SELECT ut.type_name INTO v_super_admin_type
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_super_admin_id;
    
    IF v_super_admin_type IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '超级管理员不存在';
        ROLLBACK;
    ELSEIF v_super_admin_type != '超级管理员' THEN
        SET p_result_code = 2;
        SET p_result_message = '权限不足，只有超级管理员可以管理管理员';
        ROLLBACK;
    ELSE
        -- 检查要操作的管理员是否存在
        SELECT b.identity_type, b.borrowing_status INTO v_admin_current_type, v_admin_current_status
        FROM borrowers b
        WHERE b.uid = p_admin_id;
        
        IF v_admin_current_type IS NULL THEN
            SET p_result_code = 3;
            SET p_result_message = '用户不存在';
            ROLLBACK;
        ELSE
            -- 执行操作
            CASE p_action
                WHEN 'promote' THEN
                    -- 检查用户是否已经是管理员或更高权限
                    IF v_admin_current_type = 4 OR v_admin_current_type = 5 THEN
                        SET p_result_code = 4;
                        SET p_result_message = '用户已经是管理员或超级管理员';
                        ROLLBACK;
                    ELSE
                        -- 提升为管理员
                        UPDATE borrowers
                        SET identity_type = 4
                        WHERE uid = p_admin_id;
                        
                        SET p_result_code = 0;
                        SET p_result_message = '用户已提升为管理员';
                    END IF;
                    
                WHEN 'demote' THEN
                    -- 检查用户是否是管理员
                    IF v_admin_current_type != 4 THEN
                        SET p_result_code = 5;
                        SET p_result_message = '用户不是管理员';
                        ROLLBACK;
                    ELSE
                        -- 降级为普通用户（学生）
                        UPDATE borrowers
                        SET identity_type = 1
                        WHERE uid = p_admin_id;
                        
                        SET p_result_code = 0;
                        SET p_result_message = '管理员已降级为普通用户';
                    END IF;
                    
                WHEN 'freeze' THEN
                    -- 检查用户是否是管理员
                    IF v_admin_current_type != 4 AND v_admin_current_type != 5 THEN
                        SET p_result_code = 6;
                        SET p_result_message = '用户不是管理员';
                        ROLLBACK;
                    ELSE
                        -- 冻结管理员账户
                        UPDATE borrowers
                        SET borrowing_status = 'suspended'
                        WHERE uid = p_admin_id;
                        
                        SET p_result_code = 0;
                        SET p_result_message = '管理员账户已冻结';
                    END IF;
                    
                WHEN 'unfreeze' THEN
                    -- 检查用户是否是管理员
                    IF v_admin_current_type != 4 AND v_admin_current_type != 5 THEN
                        SET p_result_code = 7;
                        SET p_result_message = '用户不是管理员';
                        ROLLBACK;
                    ELSE
                        -- 解冻管理员账户
                        UPDATE borrowers
                        SET borrowing_status = 'active'
                        WHERE uid = p_admin_id;
                        
                        SET p_result_code = 0;
                        SET p_result_message = '管理员账户已解冻';
                    END IF;
                    
                ELSE
                    SET p_result_code = 8;
                    SET p_result_message = '无效操作';
                    ROLLBACK;
            END CASE;
            
            -- 提交事务
            COMMIT;
        END IF;
    END IF;
END//

DELIMITER ;
