CREATE TABLE book_authors (
    book_id VARCHAR(50),
    author_id VARCHAR(50),
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);