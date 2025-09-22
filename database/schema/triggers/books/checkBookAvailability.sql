USE bookmanage;
DROP TRIGGER IF EXISTS checkBookAvailability;
DELIMITER //

CREATE TRIGGER checkBookAvailability
BEFORE INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_borrowed_count INT;
    DECLARE v_max_borrow_count INT;
    DECLARE v_borrowing_status VARCHAR(20);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'System error: Trigger execution failed';
    END;
    
    -- 检查图书库存
    SELECT current_stock INTO v_current_stock 
    FROM books 
    WHERE book_id = NEW.book_id;
    
    IF v_current_stock <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book stock is insufficient';
    END IF;
    
    -- 检查用户借阅状态和数量
    SELECT b.borrowed_count, b.borrowing_status, ut.max_borrow_count
    INTO v_borrowed_count, v_borrowing_status, v_max_borrow_count
    FROM borrowers b
    JOIN user_types ut ON b.identity_type = ut.type_id
    WHERE b.uid = NEW.borrower_id;
    
    IF v_borrowing_status = 'suspended' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User account has been suspended';
    END IF;
    
    IF v_borrowed_count >= v_max_borrow_count THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum borrowing limit reached';
    END IF;
END//

DELIMITER ;
