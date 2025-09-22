<template>
  <div class="home-container">
    <div class="welcome-section">
      <h2>欢迎使用图书管理系统</h2>
      <p>一个功能完善的图书借阅和管理系统</p>
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
    
    <div class="auth-section" v-if="!isLoggedIn">
      <h3>账户操作</h3>
      <div class="auth-buttons">
        <router-link to="/login" class="auth-button login-button">登录</router-link>
        <router-link to="/register" class="auth-button register-button">注册</router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      // 在实际应用中，这些值应该从用户状态中获取
      isLoggedIn: false,
      isAdmin: false
    };
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

.features-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
  margin-bottom: 40px;
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

.auth-section {
  text-align: center;
}

.auth-section h3 {
  color: #333;
  margin-bottom: 20px;
}

.auth-buttons {
  display: flex;
  justify-content: center;
  gap: 20px;
}

.auth-button {
  display: inline-block;
  padding: 12px 24px;
  text-decoration: none;
  border-radius: 4px;
  font-weight: 500;
  transition: background-color 0.3s;
}

.login-button {
  background-color: #409eff;
  color: white;
}

.login-button:hover {
  background-color: #66b1ff;
}

.register-button {
  background-color: #67c23a;
  color: white;
}

.register-button:hover {
  background-color: #85ce61;
}

@media (max-width: 768px) {
  .features-section {
    grid-template-columns: 1fr;
  }
  
  .auth-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .auth-button {
    width: 200px;
  }
}
</style>
