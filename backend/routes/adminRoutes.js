const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

// 获取所有借阅记录
router.get('/borrowing-records', adminController.getAllBorrowingRecords);

// 获取所有罚款记录
router.get('/fine-records', adminController.getAllFineRecords);

// 获取用户登录日志
router.get('/login-logs', adminController.getUserLoginLogs);

// 管理用户
router.post('/manage-user', adminController.manageUser);

// 管理管理员
router.post('/manage-admin', adminController.manageAdmin);

module.exports = router;
