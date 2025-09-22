USE bookmanage;
DROP TABLE IF EXISTS publishers;
CREATE TABLE IF NOT EXISTS publishers (
    publisher_id VARCHAR(50) PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL
);
