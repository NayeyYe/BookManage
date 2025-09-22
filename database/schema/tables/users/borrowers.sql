CREATE TABLE borrowers (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    identity_type INT NOT NULL,
    student_id VARCHAR(50),
    employee_id VARCHAR(50),
    borrowed_count INT DEFAULT 0,
    registration_date DATE NOT NULL,
    borrowing_status ENUM('active', 'suspended') DEFAULT 'active',
    FOREIGN KEY (identity_type) REFERENCES user_types(type_id)
);