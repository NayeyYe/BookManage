USE bookmanage;
DROP PROCEDURE IF EXISTS login;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS login(
    IN p_uid VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_password_hash VARCHAR(255),
    OUT p_name VARCHAR(100),
    OUT p_phone VARCHAR(20),
    OUT p_identity_type INT,
    OUT p_borrowing_status VARCHAR(20),
    OUT p_borrowed_count INT,
    OUT p_identity_type_name VARCHAR(50)
)
BEGIN
    DECLARE v_user_exists INT DEFAULT 0;
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result_code = -1;
        SET p_result_message = '系统错误：登录失败';
        SET p_password_hash = '';
        SET p_name = '';
        SET p_phone = '';
        SET p_identity_type = 0;
        SET p_borrowing_status = '';
        SET p_borrowed_count = 0;
        SET p_identity_type_name = '';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_password_hash = '';
    SET p_name = '';
    SET p_phone = '';
    SET p_identity_type = 0;
    SET p_borrowing_status = '';
    SET p_borrowed_count = 0;
    SET p_identity_type_name = '';
    
    -- 获取用户信息
    SELECT b.uid, ua.password_hash, b.name, b.phone, b.identity_type, 
           b.borrowing_status, b.borrowed_count, ut.type_name
    INTO v_user_exists, p_password_hash, p_name, p_phone, p_identity_type, 
         p_borrowing_status, p_borrowed_count, p_identity_type_name
    FROM borrowers b 
    JOIN user_auth ua ON b.uid = ua.user_id
    LEFT JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_uid;
    
    -- 检查用户是否存在
    IF v_user_exists IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
    ELSE
        SET p_result_message = '用户信息获取成功';
    END IF;
END//

DELIMITER ;
