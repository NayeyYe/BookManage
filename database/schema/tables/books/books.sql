CREATE TABLE books (
    book_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20),
    publisher_id VARCHAR(50),
    publication_year YEAR,
    total_stock INT DEFAULT 0,
    current_stock INT DEFAULT 0,
    location VARCHAR(100),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);