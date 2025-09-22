USE bookmanage;
DROP TABLE IF EXISTS fine_records;
CREATE TABLE IF NOT EXISTS fine_records (
    fine_id VARCHAR(50) PRIMARY KEY,
    borrowing_record_id VARCHAR(50) NOT NULL,
    borrower_id VARCHAR(50) NOT NULL,
    book_id VARCHAR(50) NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    overdue_days INT DEFAULT 0,
    return_status ENUM('returned', 'overdue') NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('unpaid', 'paid') DEFAULT 'unpaid',
    FOREIGN KEY (borrowing_record_id) REFERENCES borrowing_records(record_id),
    FOREIGN KEY (borrower_id) REFERENCES borrowers(uid),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
