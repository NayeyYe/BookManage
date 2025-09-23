<template>
  <div class="api-test">
    <h2>API测试页面</h2>
    
    <div class="test-section">
      <h3>测试连接</h3>
      <button @click="testConnection">测试服务器连接</button>
      <p v-if="connectionResult">{{ connectionResult }}</p>
    </div>
    
    <div class="test-section">
      <h3>用户注册</h3>
      <form @submit.prevent="registerUser">
        <input v-model="registerForm.uid" placeholder="用户ID" required />
        <input v-model="registerForm.name" placeholder="姓名" required />
        <input v-model="registerForm.phone" placeholder="电话" required />
        <input v-model="registerForm.password" type="password" placeholder="密码" required />
        <button type="submit">注册</button>
      </form>
      <p v-if="registerResult">{{ registerResult }}</p>
    </div>
    
    <div class="test-section">
      <h3>用户登录</h3>
      <form @submit.prevent="loginUser">
        <input v-model="loginForm.uid" placeholder="用户ID" required />
        <input v-model="loginForm.password" type="password" placeholder="密码" required />
        <button type="submit">登录</button>
      </form>
      <p v-if="loginResult">{{ loginResult }}</p>
    </div>
    
    <div class="test-section" v-if="authToken">
      <h3>获取图书列表</h3>
      <button @click="getBooks">获取图书</button>
      <div v-if="books.length > 0">
        <div v-for="book in books" :key="book.book_id" class="book-item">
          <h4>{{ book.title }}</h4>
          <p>ISBN: {{ book.isbn }}</p>
          <p>库存: {{ book.current_stock }}/{{ book.total_stock }}</p>
        </div>
      </div>
      <p v-if="booksResult">{{ booksResult }}</p>
    </div>
  </div>
</template>

<script>
import api from '../utils/api';

export default {
  name: 'ApiTest',
  data() {
    return {
      connectionResult: '',
      registerResult: '',
      loginResult: '',
      booksResult: '',
      authToken: '',
      registerForm: {
        uid: '',
        name: '',
        phone: '',
        password: ''
      },
      loginForm: {
        uid: '',
        password: ''
      },
      books: []
    };
  },
  methods: {
    async testConnection() {
      try {
        const response = await api.get('/connect');
        this.connectionResult = response.data;
      } catch (error) {
        this.connectionResult = '连接失败: ' + error.message;
      }
    },
    
    async registerUser() {
      try {
        const response = await api.post('/users/register', this.registerForm);
        this.registerResult = response.data.message;
      } catch (error) {
        this.registerResult = '注册失败: ' + (error.response?.data?.error || error.message);
      }
    },
    
    async loginUser() {
      try {
        const response = await api.post('/users/login', this.loginForm);
        this.loginResult = response.data.message;
        this.authToken = response.data.token;
        // 保存token到localStorage
        localStorage.setItem('token', this.authToken);
        // 保存用户信息
        localStorage.setItem('user', JSON.stringify(response.data.user));
      } catch (error) {
        this.loginResult = '登录失败: ' + (error.response?.data?.error || error.message);
      }
    },
    
    async getBooks() {
      try {
        const response = await api.get('/books');
        this.books = response.data;
        this.booksResult = `获取到 ${this.books.length} 本图书`;
      } catch (error) {
        this.booksResult = '获取图书失败: ' + (error.response?.data?.error || error.message);
      }
    }
  }
};
</script>

<style scoped>
.api-test {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.test-section {
  margin-bottom: 30px;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.test-section h3 {
  margin-top: 0;
}

form {
  margin: 15px 0;
}

input {
  display: block;
  width: 100%;
  padding: 8px;
  margin: 10px 0;
  border: 1px solid #ddd;
  border-radius: 4px;
}

button {
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}

.book-item {
  border: 1px solid #eee;
  padding: 10px;
  margin: 10px 0;
  border-radius: 4px;
}
</style>
