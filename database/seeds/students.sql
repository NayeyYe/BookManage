CREATE TABLE students (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    student_id VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO students (id, name, student_id) VALUES
('S001', '张三', '2021001'),
('S002', '李四', '2021002'),
('S003', '王五', '2021003'),
('S004', '赵六', '2021004'),
('S005', '钱七', '2021005');