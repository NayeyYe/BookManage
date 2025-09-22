const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');

// 获取所有图书
router.get('/', bookController.getAllBooks);

// 根据ID获取图书
router.get('/:id', bookController.getBookById);

// 添加新图书
router.post('/', bookController.addBook);

// 更新图书信息
router.put('/:id', bookController.updateBook);

// 删除图书
router.delete('/:id', bookController.deleteBook);

// 搜索图书
router.get('/search/:query', bookController.searchBooks);

module.exports = router;
