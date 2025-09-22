const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// 用户注册
router.post('/register', userController.register);

// 用户登录
router.post('/login', userController.login);

// 获取用户信息
router.get('/:id', userController.getUserById);

// 更新用户信息
router.put('/:id', userController.updateUser);

// 获取用户借阅记录
router.get('/:id/borrowing-records', userController.getUserBorrowingRecords);

// 获取用户罚款记录
router.get('/:id/fine-records', userController.getUserFineRecords);

module.exports = router;
