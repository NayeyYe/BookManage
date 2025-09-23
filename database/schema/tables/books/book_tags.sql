USE bookmanage;
DROP TABLE IF EXISTS book_tags;
CREATE TABLE IF NOT EXISTS book_tags (
    book_id VARCHAR(50),
    tag_id VARCHAR(50),
    PRIMARY KEY (book_id, tag_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);
