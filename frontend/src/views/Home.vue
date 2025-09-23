<template>
  <div class="home-container">
    <div class="welcome-section">
      <h2>欢迎使用图书管理系统</h2>
      <p>一个功能完善的图书借阅和管理系统</p>
    </div>
    
    <div class="borrow-section">
      <h3>借书功能</h3>
      <div class="borrow-form">
        <div class="form-group">
          <label for="bookId">图书ID</label>
          <input 
            type="text" 
            id="bookId" 
            v-model="borrowForm.bookId" 
            placeholder="请输入要借阅的图书ID"
          />
        </div>
        <button @click="handleBorrow" class="borrow-button" :disabled="loading">
          {{ loading ? '借书中...' : '借书' }}
        </button>
      </div>
      <div v-if="borrowMessage" :class="['message', borrowSuccess ? 'success' : 'error']">
        {{ borrowMessage }}
      </div>
    </div>
    
    <div class="features-section">
      <div class="feature-card">
        <h3>图书搜索</h3>
        <p>快速搜索图书馆中的所有图书</p>
        <router-link to="/search" class="feature-link">开始搜索</router-link>
      </div>
      
      <div class="feature-card">
        <h3>借阅记录</h3>
        <p>查看和管理您的借阅历史</p>
        <router-link to="/borrowing-records" class="feature-link">查看记录</router-link>
      </div>
      
      <div class="feature-card">
        <h3>罚款查询</h3>
        <p>查看您的罚款记录和缴费情况</p>
        <router-link to="/fine-records" class="feature-link">查看罚款</router-link>
      </div>
      
      <div class="feature-card" v-if="isAdmin">
        <h3>管理员面板</h3>
        <p>管理用户、图书和系统设置</p>
        <router-link to="/admin" class="feature-link">进入管理</router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { bookAPI } from '../utils/api';

export default {
  name: 'Home',
  data() {
    return {
      borrowForm: {
        bookId: ''
      },
      loading: false,
      borrowMessage: '',
      borrowSuccess: false,
      isLoggedIn: false,
      isAdmin: false,
      userInfo: null
    };
  },
  mounted() {
    this.checkUserStatus();
  },
  methods: {
    checkUserStatus() {
      const token = localStorage.getItem('token');
      const userInfo = localStorage.getItem('userInfo');
      
      if (token && userInfo) {
        this.isLoggedIn = true;
        this.userInfo = JSON.parse(userInfo);
        // 检查是否是管理员（identity_type为3、4、5）
        this.isAdmin = [3, 4, 5].includes(this.userInfo.identity_type);
      }
    },
    
    async handleBorrow() {
      if (!this.borrowForm.bookId.trim()) {
        this.borrowMessage = '请输入图书ID';
        this.borrowSuccess = false;
        return;
      }
      
      if (!this.isLoggedIn) {
        this.borrowMessage = '请先登录';
        this.borrowSuccess = false;
        return;
      }
      
      this.loading = true;
      this.borrowMessage = '';
      
      try {
        const response = await bookAPI.borrowBook(this.borrowForm.bookId);
        
        if (response.success) {
          this.borrowMessage = '借书成功！';
          this.borrowSuccess = true;
          this.borrowForm.bookId = '';
        } else {
          this.borrowMessage = response.message || '借书失败';
          this.borrowSuccess = false;
        }
      } catch (err) {
        this.borrowMessage = err.response?.data?.message || '借书过程中发生错误';
        this.borrowSuccess = false;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.home-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.welcome-section {
  text-align: center;
  margin-bottom: 40px;
}

.welcome-section h2 {
  color: #333;
  font-size: 32px;
  margin-bottom: 10px;
}

.welcome-section p {
  color: #666;
  font-size: 18px;
}

.borrow-section {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
  margin-bottom: 40px;
}

.borrow-section h3 {
  color: #333;
  margin-bottom: 20px;
  text-align: center;
}

.borrow-form {
  display: flex;
  gap: 15px;
  align-items: flex-end;
  margin-bottom: 20px;
}

.form-group {
  flex: 1;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #555;
  font-weight: 500;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
  box-sizing: border-box;
}

.form-group input:focus {
  border-color: #409eff;
  outline: none;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.borrow-button {
  padding: 12px 24px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
  white-space: nowrap;
}

.borrow-button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.borrow-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.message {
  padding: 10px;
  border-radius: 4px;
  text-align: center;
}

.message.success {
  background-color: #f0f9ff;
  color: #409eff;
  border: 1px solid #d0e9ff;
}

.message.error {
  background-color: #fef0f0;
  color: #f56c6c;
  border: 1px solid #fde2e2;
}

.features-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.feature-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
  text-align: center;
  transition: transform 0.3s, box-shadow 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.feature-card h3 {
  color: #333;
  margin-bottom: 15px;
}

.feature-card p {
  color: #666;
  margin-bottom: 20px;
}

.feature-link {
  display: inline-block;
  padding: 8px 16px;
  background-color: #409eff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.feature-link:hover {
  background-color: #66b1ff;
}

@media (max-width: 768px) {
  .features-section {
    grid-template-columns: 1fr;
  }
  
  .borrow-form {
    flex-direction: column;
    align-items: stretch;
  }
  
  .borrow-button {
    width: 100%;
  }
}
</style>
