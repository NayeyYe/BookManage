USE bookmanage;
DROP TABLE IF EXISTS authors;
CREATE TABLE IF NOT EXISTS authors (
    author_id VARCHAR(50) PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50)
);
