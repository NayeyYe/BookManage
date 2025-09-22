DELIMITER //

CREATE TRIGGER updateBookStock
AFTER INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 记录错误日志（如果需要）
        -- INSERT INTO error_logs (error_message) VALUES ('更新图书库存失败');
    END;
    
    -- 如果是借书操作，减少图书库存
    IF NEW.return_status = 'borrowed' THEN
        UPDATE books 
        SET current_stock = current_stock - 1 
        WHERE book_id = NEW.book_id;
    END IF;
    
    -- 如果是还书操作，增加图书库存
    IF NEW.return_status = 'returned' THEN
        UPDATE books 
        SET current_stock = current_stock + 1 
        WHERE book_id = NEW.book_id;
    END IF;
END//

DELIMITER ;
