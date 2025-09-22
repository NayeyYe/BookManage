USE bookmanage;
DROP TABLE IF EXISTS book_authors;
CREATE TABLE IF NOT EXISTS book_authors (
    book_id VARCHAR(50),
    author_id VARCHAR(50),
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
