<template>
  <div class="register-container">
    <div class="register-form">
      <h2>用户注册</h2>
      <form @submit.prevent="handleRegister">
        <div class="form-group">
          <label for="uid">用户ID</label>
          <input 
            type="text" 
            id="uid" 
            v-model="registerForm.uid" 
            required 
            placeholder="请输入用户ID"
          />
        </div>
        <div class="form-group">
          <label for="name">姓名</label>
          <input 
            type="text" 
            id="name" 
            v-model="registerForm.name" 
            required 
            placeholder="请输入姓名"
          />
        </div>
        <div class="form-group">
          <label for="phone">手机号</label>
          <input 
            type="tel" 
            id="phone" 
            v-model="registerForm.phone" 
            required 
            placeholder="请输入手机号"
          />
        </div>
        <div class="form-group">
          <label for="identityType">身份类型</label>
          <select id="identityType" v-model="registerForm.identityType" required>
            <option value="1">学生</option>
            <option value="2">教师</option>
            <option value="3">管理员</option>
          </select>
        </div>
        <div class="form-group" v-if="registerForm.identityType == 1">
          <label for="studentId">学号</label>
          <input 
            type="text" 
            id="studentId" 
            v-model="registerForm.studentId" 
            placeholder="请输入学号"
          />
        </div>
        <div class="form-group" v-if="registerForm.identityType == 2">
          <label for="employeeId">工号</label>
          <input 
            type="text" 
            id="employeeId" 
            v-model="registerForm.employeeId" 
            placeholder="请输入工号"
          />
        </div>
        <div class="form-group">
          <label for="password">密码</label>
          <input 
            type="password" 
            id="password" 
            v-model="registerForm.password" 
            required 
            placeholder="请输入密码"
          />
        </div>
        <div class="form-group">
          <label for="confirmPassword">确认密码</label>
          <input 
            type="password" 
            id="confirmPassword" 
            v-model="registerForm.confirmPassword" 
            required 
            placeholder="请再次输入密码"
          />
        </div>
        <button type="submit" class="register-button" :disabled="loading">
          {{ loading ? '注册中...' : '注册' }}
        </button>
      </form>
      <div class="login-link">
        <p>已有账户？<router-link to="/login">立即登录</router-link></p>
      </div>
      <div v-if="error" class="error-message">
        {{ error }}
      </div>
      <div v-if="success" class="success-message">
        {{ success }}
      </div>
    </div>
  </div>
</template>

<script>
import { userAPI } from '../utils/api';

export default {
  name: 'Register',
  data() {
    return {
      registerForm: {
        uid: '',
        name: '',
        phone: '',
        identityType: '1',
        studentId: '',
        employeeId: '',
        password: '',
        confirmPassword: ''
      },
      loading: false,
      error: '',
      success: ''
    };
  },
  methods: {
    async handleRegister() {
      // 重置消息
      this.error = '';
      this.success = '';
      
      // 验证密码一致性
      if (this.registerForm.password !== this.registerForm.confirmPassword) {
        this.error = '两次输入的密码不一致';
        return;
      }
      
      this.loading = true;
      
      try {
        // 准备注册数据
        const userData = {
          uid: this.registerForm.uid,
          name: this.registerForm.name,
          phone: this.registerForm.phone,
          identity_type: parseInt(this.registerForm.identityType),
          student_id: this.registerForm.identityType == 1 ? this.registerForm.studentId : null,
          employee_id: this.registerForm.identityType == 2 ? this.registerForm.employeeId : null,
          password: this.registerForm.password
        };
        
        const response = await userAPI.register(userData);
        
        if (response.success) {
          this.success = '注册成功！即将跳转到登录页面...';
          // 3秒后跳转到登录页面
          setTimeout(() => {
            this.$router.push('/login');
          }, 3000);
        } else {
          this.error = response.message || '注册失败';
        }
      } catch (err) {
        this.error = err.response?.data?.message || '注册过程中发生错误';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f5f5;
}

.register-form {
  width: 100%;
  max-width: 400px;
  padding: 40px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.register-form h2 {
  text-align: center;
  margin-bottom: 30px;
  color: #333;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #555;
  font-weight: 500;
}

.form-group input, .form-group select {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
  box-sizing: border-box;
}

.form-group input:focus, .form-group select:focus {
  border-color: #409eff;
  outline: none;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.register-button {
  width: 100%;
  padding: 12px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.register-button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.register-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.login-link {
  text-align: center;
  margin-top: 20px;
}

.login-link a {
  color: #409eff;
  text-decoration: none;
}

.login-link a:hover {
  text-decoration: underline;
}

.error-message {
  margin-top: 15px;
  padding: 10px;
  background-color: #fef0f0;
  color: #f56c6c;
  border: 1px solid #fde2e2;
  border-radius: 4px;
  text-align: center;
}

.success-message {
  margin-top: 15px;
  padding: 10px;
  background-color: #f0f9ff;
  color: #409eff;
  border: 1px solid #d0e9ff;
  border-radius: 4px;
  text-align: center;
}
</style>
