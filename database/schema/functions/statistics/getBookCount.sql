USE bookmanage;
DROP FUNCTION IF EXISTS getBookCount;
DELIMITER //

CREATE FUNCTION IF NOT EXISTS getBookCount() 
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total_books INT;
    
    -- 获取图书总数
    SELECT COUNT(*) INTO v_total_books FROM books;
    
    RETURN v_total_books;
END//

DELIMITER ;
