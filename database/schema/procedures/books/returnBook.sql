DELIMITER //

CREATE PROCEDURE returnBook(
    IN p_record_id VARCHAR(50),
    IN p_return_date DATE,
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_overdue_days INT,
    OUT p_fine_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_book_id VARCHAR(50);
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_due_date DATE;
    DECLARE v_return_status VARCHAR(20);
    DECLARE v_borrowed_count INT;
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：还书失败';
        SET p_overdue_days = 0;
        SET p_fine_amount = 0.00;
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_overdue_days = 0;
    SET p_fine_amount = 0.00;
    
    -- 开始事务
    START TRANSACTION;
    
    -- 检查借阅记录是否存在和状态
    SELECT book_id, borrower_id, due_date, return_status
    INTO v_book_id, v_borrower_id, v_due_date, v_return_status
    FROM borrowing_records
    WHERE record_id = p_record_id;
    
    IF v_book_id IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '借阅记录不存在';
        ROLLBACK;
    ELSEIF v_return_status = 'returned' THEN
        SET p_result_code = 2;
        SET p_result_message = '图书已归还';
        ROLLBACK;
    ELSE
        -- 计算逾期天数
        IF p_return_date > v_due_date THEN
            SET p_overdue_days = DATEDIFF(p_return_date, v_due_date);
        ELSE
            SET p_overdue_days = 0;
        END IF;
        
        -- 计算罚款金额（假设每天罚款1元）
        SET p_fine_amount = p_overdue_days * 1.00;
        
        -- 更新借阅记录
        UPDATE borrowing_records
        SET 
            actual_return_date = p_return_date,
            return_status = 'returned',
            overdue_days = p_overdue_days
        WHERE record_id = p_record_id;
        
        -- 更新图书库存
        UPDATE books
        SET current_stock = current_stock + 1
        WHERE book_id = v_book_id;
        
        -- 更新用户借阅数量
        UPDATE borrowers
        SET borrowed_count = borrowed_count - 1
        WHERE uid = v_borrower_id;
        
        -- 如果有逾期，创建罚款记录
        IF p_overdue_days > 0 THEN
            INSERT INTO fine_records (
                fine_id, borrowing_record_id, borrower_id, book_id, 
                borrow_date, due_date, overdue_days, return_status, 
                fine_amount, payment_status
            ) VALUES (
                CONCAT('F', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 
                p_record_id, v_borrower_id, v_book_id,
                (SELECT borrow_date FROM borrowing_records WHERE record_id = p_record_id),
                v_due_date, p_overdue_days, 'overdue',
                p_fine_amount, 'unpaid'
            );
        END IF;
        
        -- 提交事务
        COMMIT;
        SET p_result_code = 0;
        SET p_result_message = '还书成功';
    END IF;
END//

DELIMITER ;
