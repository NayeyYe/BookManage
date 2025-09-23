<template>
  <header class="header">
    <div class="header-left">
      <router-link to="/" class="logo">
        <h2>图书管理系统</h2>
      </router-link>
    </div>
    
    <div class="header-right">
      <div v-if="isLoggedIn" class="user-section">
        <div class="user-menu">
          <div class="user-info" @click="toggleDropdown">
            <span class="username">{{ userInfo.name || userInfo.uid }}</span>
            <i class="arrow" :class="{ 'up': isDropdownOpen }">▼</i>
          </div>
          
          <div v-if="isDropdownOpen" class="dropdown-menu">
            <router-link to="/profile" class="dropdown-item">
              <i class="icon">👤</i>
              个人中心
            </router-link>
            <router-link v-if="isAdmin" to="/admin" class="dropdown-item">
              <i class="icon">⚙️</i>
              管理员面板
            </router-link>
          </div>
        </div>
        
        <button @click="handleLogout" class="logout-button">
          退出登录
        </button>
      </div>
      
      <div v-else class="auth-buttons">
        <router-link to="/login" class="auth-button login">登录</router-link>
        <router-link to="/register" class="auth-button register">注册</router-link>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  name: 'Header',
  data() {
    return {
      isLoggedIn: false,
      isAdmin: false,
      userInfo: null,
      isDropdownOpen: false
    };
  },
  mounted() {
    this.checkUserStatus();
    // 点击页面其他地方关闭下拉菜单
    document.addEventListener('click', this.handleClickOutside);
  },
  beforeUnmount() {
    document.removeEventListener('click', this.handleClickOutside);
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
    
    toggleDropdown() {
      this.isDropdownOpen = !this.isDropdownOpen;
    },
    
    handleClickOutside(event) {
      const userMenu = this.$el.querySelector('.user-menu');
      if (userMenu && !userMenu.contains(event.target)) {
        this.isDropdownOpen = false;
      }
    },
    
    handleLogout() {
      // 清除登录信息
      localStorage.removeItem('token');
      localStorage.removeItem('userInfo');
      this.isLoggedIn = false;
      this.isAdmin = false;
      this.userInfo = null;
      this.isDropdownOpen = false;
      
      // 跳转到首页
      this.$router.push('/');
    }
  },
  watch: {
    // 监听路由变化，重新检查用户状态
    '$route'() {
      this.checkUserStatus();
    }
  }
};
</script>

<style scoped>
.header {
  background-color: #409eff;
  color: white;
  padding: 0 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,.1);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 60px;
}

.header-left .logo {
  text-decoration: none;
  color: white;
}

.header-left h2 {
  margin: 0;
  padding: 0;
  font-size: 24px;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-menu {
  position: relative;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.username {
  margin-right: 8px;
  font-weight: 500;
}

.arrow {
  font-size: 12px;
  transition: transform 0.3s;
}

.arrow.up {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  min-width: 180px;
  margin-top: 8px;
  overflow: hidden;
}

.dropdown-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  color: #333;
  text-decoration: none;
  transition: background-color 0.3s;
  cursor: pointer;
}

.dropdown-item:hover {
  background-color: #f5f5f5;
}

.dropdown-item.logout {
  color: #f56c6c;
}

.dropdown-item.logout:hover {
  background-color: #fef0f0;
}

.dropdown-divider {
  height: 1px;
  background-color: #e4e7ed;
  margin: 4px 0;
}

.icon {
  margin-right: 8px;
  font-size: 16px;
}

.auth-buttons {
  display: flex;
  gap: 12px;
}

.auth-button {
  padding: 8px 16px;
  border-radius: 4px;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s;
}

.auth-button.login {
  background-color: transparent;
  color: white;
  border: 1px solid white;
}

.auth-button.login:hover {
  background-color: white;
  color: #409eff;
}

.auth-button.register {
  background-color: white;
  color: #409eff;
  border: 1px solid white;
}

.auth-button.register:hover {
  background-color: #f0f0f0;
}

.user-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logout-button {
  padding: 8px 16px;
  background-color: transparent;
  color: white;
  border: 1px solid white;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
}

.logout-button:hover {
  background-color: white;
  color: #f56c6c;
  border-color: white;
}

@media (max-width: 768px) {
  .header {
    padding: 0 15px;
  }
  
  .header-left h2 {
    font-size: 20px;
  }
  
  .username {
    max-width: 80px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  
  .dropdown-menu {
    min-width: 160px;
  }
  
  .auth-buttons {
    gap: 8px;
  }
  
  .auth-button {
    padding: 6px 12px;
    font-size: 14px;
  }
}
</style>
