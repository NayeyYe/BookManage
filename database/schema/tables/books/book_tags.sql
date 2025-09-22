USE bookmanage;
DROP TABLE IF EXISTS book_tags;
CREATE TABLE IF NOT EXISTS book_tags (
    tag_id VARCHAR(50) PRIMARY KEY,
    tag_name VARCHAR(100) NOT NULL UNIQUE
);
