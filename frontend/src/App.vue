<script setup>
import { RouterLink, RouterView } from 'vue-router'
import { ref, onMounted } from 'vue'

const isLoggedIn = ref(false)

onMounted(() => {
  // 检查用户是否已登录
  isLoggedIn.value = !!localStorage.getItem('token')
})

const logout = () => {
  // 清除登录信息
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  isLoggedIn.value = false
  // 跳转到首页
  window.location.href = '/'
}
</script>

<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">
        <h2>图书管理系统</h2>
      </div>
      <ul class="nav-menu">
        <li><router-link to="/">首页</router-link></li>
        <li><router-link to="/search">图书搜索</router-link></li>
        <li><router-link to="/borrowing-records">借阅记录</router-link></li>
        <li><router-link to="/fine-records">罚款记录</router-link></li>
        <li><router-link to="/admin">管理员面板</router-link></li>
        <li><router-link to="/api-test">API测试</router-link></li>
        <li v-if="!isLoggedIn"><router-link to="/login">登录</router-link></li>
        <li v-if="!isLoggedIn"><router-link to="/register">注册</router-link></li>
        <li v-if="isLoggedIn" @click="logout"><a>退出登录</a></li>
      </ul>
    </nav>
    <div class="container">
      <RouterView />
    </div>
  </div>
</template>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 0;
}

/* 导航栏样式 */
.navbar {
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
}

.nav-brand h2 {
  margin: 0;
  padding: 15px 0;
}

.nav-menu {
  display: flex;
  list-style: none;
}

.nav-menu li {
  margin-left: 20px;
}

.nav-menu a {
  color: white;
  text-decoration: none;
  padding: 15px 10px;
  display: block;
  transition: background-color 0.3s;
}

.nav-menu a:hover {
  background-color: rgba(255, 255, 255, 0.2);
  cursor: pointer;
}

.nav-menu a.router-link-exact-active {
  background-color: rgba(255, 255, 255, 0.3);
}

.container {
  margin-top: 60px;
  padding: 20px;
}
</style>
