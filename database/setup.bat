@echo off
setlocal enabledelayedexpansion

REM 读取根目录.env文件中的环境变量
if exist ..\.env (
    for /f "tokens=1,2 delims==" %%a in (..\.env) do (
        set "%%a=%%b"
    )
)

REM 设置MySQL连接参数
set MYSQL_HOST=%DB_HOST%
set MYSQL_USER=%DB_USER%
set MYSQL_PASSWORD=%DB_PASSWORD%
set MYSQL_DATABASE=%DB_NAME%

REM 创建数据库
echo Creating database...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% -e "DROP DATABASE IF EXISTS %MYSQL_DATABASE%;"
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS %MYSQL_DATABASE% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

REM 使用数据库
echo Using database...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% -e "USE %MYSQL_DATABASE%;"

REM 创建表
echo Creating tables...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/users/user_types.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/users/borrowers.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/users/user_auth.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/books/publishers.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/books/authors.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/books/books.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/books/tags.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/books/book_authors.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/books/book_tags.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/transactions/borrowing_records.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/transactions/fine_records.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/tables/users/login_logs.sql

REM 创建函数
echo Creating functions...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/functions/calculations/calculateFine.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/functions/calculations/getOverdueDays.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/functions/statistics/getBookCount.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/functions/statistics/getUserBorrowedCount.sql

REM 创建存储过程
echo Creating procedures...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/auth/userRegister.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/auth/userLogin.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/addBook.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/borrowBook.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/returnBook.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/searchBooksByAuthor.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/searchBooksByISBN.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/searchBooksByName.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/searchBooksByPublisher.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/searchBooksByTag.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/searchBooks.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/getAllBooks.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/getBookById.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/updateBook.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/books/deleteBook.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/users/getUserAllBorrowingRecords.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/users/getUserBorrowingRecords.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/users/getUserCurrentBorrowingRecords.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/users/getUserFineRecords.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/users/getUserById.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/users/updateUser.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/getAllBorrowingRecords.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/getAllBorrowingRecordsDetailed.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/getAllFineRecords.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/getAllFineRecordsDetailed.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/getUserLoginLogs.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/getUserLoginLogsDetailed.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/manageUser.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/manageUserComplete.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/procedures/admin/manageAdmin.sql

REM 创建触发器
echo Creating triggers...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/triggers/books/checkBookAvailability.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/triggers/books/updateBookStock.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/triggers/users/autoCalculateFine.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/triggers/users/logUserLogin.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/triggers/users/updateBorrowerStatus.sql

REM 创建事件
echo Creating events...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/events/daily/dailyCleanUp.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/events/daily/dailyFineCalculation.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < schema/events/daily/dailyOverdueCheck.sql

REM 插入初始数据
echo Inserting seed data...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < seeds/students.sql
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < seeds/teachers.sql

REM 插入测试数据
echo Inserting test data...
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < seeds/test_data.sql

echo Setup completed successfully!
pause
