USE bookmanage;
DROP TABLE IF EXISTS teachers;

CREATE TABLE teachers (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    employee_id VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO teachers (id, name, employee_id) VALUES
('T001', '陈教授', 'E1001'),
('T002', '刘副教授', 'E1002'),
('T003', '杨讲师', 'E1003'),
('T004', '周教授', 'E1004'),
('T005', '吴副教授', 'E1005');
