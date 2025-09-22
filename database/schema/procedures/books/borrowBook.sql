USE bookmanage;
DROP PROCEDURE IF EXISTS borrowBook;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS borrowBook(
    IN p_borrower_id VARCHAR(50),
    IN p_book_id VARCHAR(50),
    IN p_borrow_date DATE,
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_record_id VARCHAR(50)
)
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_borrowed_count INT;
    DECLARE v_max_borrow_count INT;
    DECLARE v_borrowing_status VARCHAR(20);
    DECLARE v_due_date DATE;
    DECLARE v_record_id VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：借书失败';
        SET p_record_id = '';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_record_id = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查用户是否存在和状态
    SELECT b.borrowed_count, b.borrowing_status, ut.max_borrow_count
    INTO v_borrowed_count, v_borrowing_status, v_max_borrow_count
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = p_borrower_id;
    
    IF v_borrowing_status IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '用户不存在';
        ROLLBACK;
    ELSEIF v_borrowing_status = 'suspended' THEN
        SET p_result_code = 2;
        SET p_result_message = '用户账户已被冻结';
        ROLLBACK;
    ELSEIF v_borrowed_count >= v_max_borrow_count THEN
        SET p_result_code = 3;
        SET p_result_message = '已达到最大借阅数量';
        ROLLBACK;
    ELSE
        -- 检查图书库存
        SELECT current_stock INTO v_current_stock 
        FROM books 
        WHERE book_id = p_book_id;
        
        IF v_current_stock IS NULL THEN
            SET p_result_code = 4;
            SET p_result_message = '图书不存在';
            ROLLBACK;
        ELSEIF v_current_stock <= 0 THEN
            SET p_result_code = 5;
            SET p_result_message = '图书库存不足';
            ROLLBACK;
        ELSE
            -- 生成借阅记录ID
            SET v_record_id = CONCAT('BR', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));
            
            -- 计算应还日期
            SELECT max_borrow_days INTO v_due_date
            FROM user_types ut
            JOIN borrowers b ON ut.type_id = b.identity_type
            WHERE b.uid = p_borrower_id;
            
            SET v_due_date = DATE_ADD(p_borrow_date, INTERVAL v_due_date DAY);
            
            -- 插入借阅记录
            INSERT INTO borrowing_records (
                record_id, borrower_id, book_id, borrow_date, due_date, return_status
            ) VALUES (
                v_record_id, p_borrower_id, p_book_id, p_borrow_date, v_due_date, 'borrowed'
            );
            
            -- 更新图书库存
            UPDATE books 
            SET current_stock = current_stock - 1 
            WHERE book_id = p_book_id;
            
            -- 更新用户借阅数量
            UPDATE borrowers
            SET borrowed_count = borrowed_count + 1
            WHERE uid = p_borrower_id;
            
            -- 提交事务
            COMMIT;
            SET p_result_code = 0;
            SET p_result_message = '借书成功';
            SET p_record_id = v_record_id;
        END IF;
    END IF;
END//

DELIMITER ;
