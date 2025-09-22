DELIMITER //

CREATE PROCEDURE returnBook(
    IN p_record_id VARCHAR(50),
    OUT p_result_code INT,
    OUT p_result_message VARCHAR(255),
    OUT p_overdue_days INT,
    OUT p_fine_amount DECIMAL(10,2),
    OUT p_fine_record_id VARCHAR(50)
)
BEGIN
    DECLARE v_borrower_id VARCHAR(50);
    DECLARE v_book_id VARCHAR(50);
    DECLARE v_borrow_date DATE;
    DECLARE v_due_date DATE;
    DECLARE v_actual_return_date DATE;
    DECLARE v_fine_record_id VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_code = -1;
        SET p_result_message = '系统错误：还书失败';
        SET p_overdue_days = 0;
        SET p_fine_amount = 0.00;
        SET p_fine_record_id = '';
    END;
    
    -- 初始化返回值
    SET p_result_code = 0;
    SET p_result_message = '';
    SET p_overdue_days = 0;
    SET p_fine_amount = 0.00;
    SET p_fine_record_id = '';
    SET v_fine_record_id = '';
    
    -- 开始事务
    START TRANSACTION;
    
    -- 获取借阅记录
    SELECT br.borrower_id, br.book_id, br.borrow_date, br.due_date, CURDATE()
    INTO v_borrower_id, v_book_id, v_borrow_date, v_due_date, v_actual_return_date
    FROM borrowing_records br
    JOIN books b ON br.book_id = b.book_id
    WHERE br.record_id = p_record_id AND br.return_date IS NULL;
    
    IF v_borrower_id IS NULL THEN
        SET p_result_code = 1;
        SET p_result_message = '借阅记录不存在或已归还';
        ROLLBACK;
    ELSE
        -- 计算逾期天数
        SET p_overdue_days = GREATEST(0, DATEDIFF(v_actual_return_date, v_due_date));
        
        -- 更新借阅记录的归还日期
        UPDATE borrowing_records 
        SET return_date = v_actual_return_date, 
            actual_return_date = v_actual_return_date
        WHERE record_id = p_record_id;
        
        -- 更新图书库存
        UPDATE books 
        SET current_stock = current_stock + 1 
        WHERE book_id = v_book_id;
        
        -- 更新用户借阅数量
        UPDATE borrowers 
        SET borrowed_count = borrowed_count - 1 
        WHERE uid = v_borrower_id;
        
        -- 如果有逾期，插入罚款记录
        IF p_overdue_days > 0 THEN
            SET p_fine_amount = p_overdue_days * 0.5; -- 每天0.5元罚款
            
            -- 生成罚款记录ID
            SET v_fine_record_id = CONCAT('FR', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));
            
            -- 插入罚款记录
            INSERT INTO fine_records (
                record_id, borrower_id, book_id, borrow_date, return_date, 
                overdue_days, fine_amount, payment_status
            ) VALUES (
                v_fine_record_id, v_borrower_id, v_book_id, v_borrow_date, 
                v_actual_return_date, p_overdue_days, p_fine_amount, 'unpaid'
            );
            
            SET p_fine_record_id = v_fine_record_id;
        END IF;
        
        -- 提交事务
        COMMIT;
        SET p_result_message = '还书成功';
    END IF;
END//

DELIMITER ;
