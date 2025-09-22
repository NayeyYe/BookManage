USE bookmanage;
DROP TABLE IF EXISTS borrowing_records;
CREATE TABLE IF NOT EXISTS borrowing_records (
    record_id VARCHAR(50) PRIMARY KEY,
    borrower_id VARCHAR(50) NOT NULL,
    book_id VARCHAR(50) NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_status ENUM('borrowed', 'returned', 'overdue') DEFAULT 'borrowed',
    actual_return_date DATE,
    overdue_days INT DEFAULT 0,
    FOREIGN KEY (borrower_id) REFERENCES borrowers(uid),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
