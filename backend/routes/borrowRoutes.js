const express = require('express');
const router = express.Router();
const borrowController = require('../controllers/borrowController');

// 借书
router.post('/borrow', borrowController.borrowBook);

// 还书
router.post('/return', borrowController.returnBook);

// 获取所有借阅记录
router.get('/records', borrowController.getAllBorrowingRecords);

// 获取所有罚款记录
router.get('/fines', borrowController.getAllFineRecords);

module.exports = router;
