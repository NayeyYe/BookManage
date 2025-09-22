-- 初始化数据库脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS bookmanage;
USE bookmanage;

-- 创建用户类型表
SOURCE schema/tables/users/user_types.sql;

-- 创建借阅者表
SOURCE schema/tables/users/borrowers.sql;

-- 创建用户认证表
SOURCE schema/tables/users/user_auth.sql;

-- 创建出版社表
SOURCE schema/tables/books/publishers.sql;

-- 创建作者表
SOURCE schema/tables/books/authors.sql;

-- 创建图书表
SOURCE schema/tables/books/books.sql;

-- 创建标签表
SOURCE schema/tables/books/tags.sql;

-- 创建图书作者关联表
SOURCE schema/tables/books/book_authors.sql;

-- 创建图书标签关联表
SOURCE schema/tables/books/book_tags.sql;

-- 创建借阅记录表
SOURCE schema/tables/transactions/borrowing_records.sql;

-- 创建罚款记录表
SOURCE schema/tables/transactions/fine_records.sql;

-- 创建登录日志表
SOURCE schema/tables/users/login_logs.sql;

-- 创建函数
SOURCE schema/functions/calculations/calculateFine.sql;
SOURCE schema/functions/calculations/getOverdueDays.sql;
SOURCE schema/functions/statistics/getBookCount.sql;
SOURCE schema/functions/statistics/getUserBorrowedCount.sql;

-- 创建存储过程
SOURCE schema/procedures/auth/userRegister.sql;
SOURCE schema/procedures/auth/userLogin.sql;
SOURCE schema/procedures/books/addBook.sql;
SOURCE schema/procedures/books/borrowBook.sql;
SOURCE schema/procedures/books/returnBook.sql;
SOURCE schema/procedures/books/searchBooksByAuthor.sql;
SOURCE schema/procedures/books/searchBooksByISBN.sql;
SOURCE schema/procedures/books/searchBooksByName.sql;
SOURCE schema/procedures/books/searchBooksByPublisher.sql;
SOURCE schema/procedures/books/searchBooksByTag.sql;
SOURCE schema/procedures/books/searchBooks.sql;
SOURCE schema/procedures/books/getAllBooks.sql;
SOURCE schema/procedures/books/getBookById.sql;
SOURCE schema/procedures/books/updateBook.sql;
SOURCE schema/procedures/books/deleteBook.sql;
SOURCE schema/procedures/users/getUserAllBorrowingRecords.sql;
SOURCE schema/procedures/users/getUserCurrentBorrowingRecords.sql;
SOURCE schema/procedures/users/getUserFineRecords.sql;
SOURCE schema/procedures/users/getUserById.sql;
SOURCE schema/procedures/users/updateUser.sql;
SOURCE schema/procedures/admin/getAllBorrowingRecords.sql;
SOURCE schema/procedures/admin/getAllBorrowingRecordsDetailed.sql;
SOURCE schema/procedures/admin/getAllFineRecords.sql;
SOURCE schema/procedures/admin/getAllFineRecordsDetailed.sql;
SOURCE schema/procedures/admin/getUserLoginLogs.sql;
SOURCE schema/procedures/admin/getUserLoginLogsDetailed.sql;
SOURCE schema/procedures/admin/manageUser.sql;
SOURCE schema/procedures/admin/manageUserComplete.sql;
SOURCE schema/procedures/admin/manageAdmin.sql;

-- 创建触发器
SOURCE schema/triggers/books/checkBookAvailability.sql;
SOURCE schema/triggers/books/updateBookStock.sql;
SOURCE schema/triggers/users/autoCalculateFine.sql;
SOURCE schema/triggers/users/logUserLogin.sql;
SOURCE schema/triggers/users/updateBorrowerStatus.sql;

-- 创建事件
SOURCE schema/events/daily/dailyCleanUp.sql;
SOURCE schema/events/daily/dailyFineCalculation.sql;
SOURCE schema/events/daily/dailyOverdueCheck.sql;

-- 插入初始数据
SOURCE seeds/students.sql;
SOURCE seeds/teachers.sql;
SOURCE seeds/seed_books.sql;
