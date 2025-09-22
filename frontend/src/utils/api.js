import axios from 'axios';

// 创建axios实例
const api = axios.create({
  baseURL: 'http://localhost:3000/api', // 后端API基础URL
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// 请求拦截器
api.interceptors.request.use(
  config => {
    // 在发送请求之前做些什么
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    // 对请求错误做些什么
    return Promise.reject(error);
  }
);

// 响应拦截器
api.interceptors.response.use(
  response => {
    // 对响应数据做点什么
    return response.data;
  },
  error => {
    // 对响应错误做点什么
    if (error.response) {
      switch (error.response.status) {
        case 401:
          // 未授权，清除token并跳转到登录页
          localStorage.removeItem('token');
          window.location.href = '/login';
          break;
        case 403:
          // 禁止访问
          console.error('访问被禁止');
          break;
        case 500:
          // 服务器错误
          console.error('服务器错误');
          break;
        default:
          console.error('未知错误');
      }
    }
    return Promise.reject(error);
  }
);

// 用户相关API
export const userAPI = {
  // 用户登录
  login: (username, password) => 
    api.post('/auth/login', { username, password }),
  
  // 用户注册
  register: (userData) => 
    api.post('/auth/register', userData),
  
  // 获取用户信息
  getUserInfo: () => 
    api.get('/user/info'),
  
  // 获取用户所有借阅记录
  getAllBorrowingRecords: () => 
    api.get('/user/borrowing-records/all'),
  
  // 获取用户当前借阅记录
  getCurrentBorrowingRecords: () => 
    api.get('/user/borrowing-records/current'),
  
  // 获取用户罚款记录
  getFineRecords: () => 
    api.get('/user/fine-records')
};

// 图书相关API
export const bookAPI = {
  // 添加图书
  addBook: (bookData) => 
    api.post('/books', bookData),
  
  // 借书
  borrowBook: (bookId) => 
    api.post('/books/borrow', { bookId }),
  
  // 还书
  returnBook: (recordId) => 
    api.post('/books/return', { recordId }),
  
  // 按书名搜索图书
  searchByName: (bookName) => 
    api.get(`/books/search/name/${bookName}`),
  
  // 按标签搜索图书
  searchByTag: (tagName) => 
    api.get(`/books/search/tag/${tagName}`),
  
  // 按作者搜索图书
  searchByAuthor: (authorName) => 
    api.get(`/books/search/author/${authorName}`),
  
  // 按出版社搜索图书
  searchByPublisher: (publisherName) => 
    api.get(`/books/search/publisher/${publisherName}`),
  
  // 按ISBN搜索图书
  searchByISBN: (isbn) => 
    api.get(`/books/search/isbn/${isbn}`)
};

// 管理员相关API
export const adminAPI = {
  // 管理用户（冻结/解冻）
  manageUser: (userId, action) => 
    api.post('/admin/manage-user', { userId, action }),
  
  // 获取所有借阅记录
  getAllBorrowingRecords: () => 
    api.get('/admin/borrowing-records'),
  
  // 获取所有罚款记录
  getAllFineRecords: () => 
    api.get('/admin/fine-records'),
  
  // 获取用户登录日志
  getUserLoginLogs: () => 
    api.get('/admin/login-logs')
};

export default api;
