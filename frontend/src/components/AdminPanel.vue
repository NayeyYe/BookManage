<template>
  <div class="admin-panel-container">
    <div class="panel-header">
      <h2>管理员面板</h2>
    </div>
    
    <div class="panel-tabs">
      <button 
        :class="{ active: activeTab === 'users' }" 
        @click="switchTab('users')"
      >
        用户管理
      </button>
      <button 
        :class="{ active: activeTab === 'records' }" 
        @click="switchTab('records')"
      >
        借阅记录
      </button>
      <button 
        :class="{ active: activeTab === 'fines' }" 
        @click="switchTab('fines')"
      >
        罚款记录
      </button>
      <button 
        :class="{ active: activeTab === 'logs' }" 
        @click="switchTab('logs')"
      >
        登录日志
      </button>
    </div>
    
    <div class="panel-content">
      <!-- 用户管理 -->
      <div v-if="activeTab === 'users'" class="users-management">
        <div class="section-header">
          <h3>用户管理</h3>
          <div class="search-container">
            <input 
              type="text" 
              v-model="userSearchKeyword" 
              placeholder="搜索用户ID或姓名"
              @keyup.enter="searchUsers"
            />
            <button @click="searchUsers">搜索</button>
          </div>
        </div>
        
        <div class="users-list" v-if="users.length > 0">
          <div class="user-item" v-for="user in users" :key="user.uid">
            <div class="user-info">
              <h4>{{ user.name }} ({{ user.uid }})</h4>
              <p class="user-details">
                <span>身份: {{ getIdentityTypeText(user.identity_type) }}</span>
                <span>手机号: {{ user.phone }}</span>
                <span>借阅数量: {{ user.borrowed_count }}</span>
                <span :class="getStatusClass(user.borrowing_status)">
                  状态: {{ getStatusText(user.borrowing_status) }}
                </span>
              </p>
            </div>
            <div class="user-actions">
              <button 
                @click="manageUser(user.uid, user.borrowing_status === 'active' ? 'suspend' : 'activate')"
                :class="user.borrowing_status === 'active' ? 'suspend-button' : 'activate-button'"
              >
                {{ user.borrowing_status === 'active' ? '冻结账户' : '激活账户' }}
              </button>
            </div>
          </div>
        </div>
        <div v-else class="no-data">
          <p>暂无用户数据</p>
        </div>
      </div>
      
      <!-- 借阅记录 -->
      <div v-if="activeTab === 'records'" class="records-management">
        <div class="section-header">
          <h3>所有借阅记录</h3>
        </div>
        
        <div class="records-list" v-if="borrowingRecords.length > 0">
          <div class="record-item" v-for="record in borrowingRecords" :key="record.record_id">
            <div class="record-info">
              <h4>{{ record.book_title }}</h4>
              <p class="record-details">
                <span>借阅人: {{ record.borrower_name }} ({{ record.borrower_id }})</span>
                <span>借阅日期: {{ formatDate(record.borrow_date) }}</span>
                <span>应还日期: {{ formatDate(record.due_date) }}</span>
                <span v-if="record.actual_return_date">
                  归还日期: {{ formatDate(record.actual_return_date) }}
                </span>
                <span :class="getStatusClass(record.return_status)">
                  状态: {{ getStatusText(record.return_status) }}
                </span>
              </p>
            </div>
          </div>
        </div>
        <div v-else class="no-data">
          <p>暂无借阅记录</p>
        </div>
      </div>
      
      <!-- 罚款记录 -->
      <div v-if="activeTab === 'fines'" class="fines-management">
        <div class="section-header">
          <h3>所有罚款记录</h3>
        </div>
        
        <div class="fines-list" v-if="fineRecords.length > 0">
          <div class="fine-item" v-for="record in fineRecords" :key="record.fine_id">
            <div class="fine-info">
              <h4>{{ record.book_title }}</h4>
              <p class="fine-details">
                <span>借阅人: {{ record.borrower_name }} ({{ record.borrower_id }})</span>
                <span>借阅日期: {{ formatDate(record.borrow_date) }}</span>
                <span>应还日期: {{ formatDate(record.due_date) }}</span>
                <span>逾期天数: {{ record.overdue_days }}天</span>
                <span>罚款金额: ¥{{ record.fine_amount }}</span>
                <span :class="getPaymentStatusClass(record.payment_status)">
                  缴费状态: {{ getPaymentStatusText(record.payment_status) }}
                </span>
              </p>
            </div>
          </div>
        </div>
        <div v-else class="no-data">
          <p>暂无罚款记录</p>
        </div>
      </div>
      
      <!-- 登录日志 -->
      <div v-if="activeTab === 'logs'" class="logs-management">
        <div class="section-header">
          <h3>用户登录日志</h3>
        </div>
        
        <div class="logs-list" v-if="loginLogs.length > 0">
          <div class="log-item" v-for="log in loginLogs" :key="log.log_id">
            <div class="log-info">
              <h4>用户: {{ log.user_name }} ({{ log.user_id }})</h4>
              <p class="log-details">
                <span>登录时间: {{ formatDateTime(log.login_time) }}</span>
                <span>IP地址: {{ log.ip_address }}</span>
                <span :class="getLoginStatusClass(log.login_status)">
                  状态: {{ getLoginStatusText(log.login_status) }}
                </span>
              </p>
            </div>
          </div>
        </div>
        <div v-else class="no-data">
          <p>暂无登录日志</p>
        </div>
      </div>
    </div>
    
    <div v-if="error" class="error-message">
      {{ error }}
    </div>
    
    <div v-if="success" class="success-message">
      {{ success }}
    </div>
  </div>
</template>

<script>
import { adminAPI } from '../utils/api';

export default {
  name: 'AdminPanel',
  data() {
    return {
      activeTab: 'users',
      userSearchKeyword: '',
      users: [],
      borrowingRecords: [],
      fineRecords: [],
      loginLogs: [],
      loading: false,
      error: '',
      success: ''
    };
  },
  mounted() {
    this.loadTabData();
  },
  methods: {
    async loadTabData() {
      this.error = '';
      this.loading = true;
      
      try {
        switch (this.activeTab) {
          case 'users':
            await this.loadUsers();
            break;
          case 'records':
            await this.loadBorrowingRecords();
            break;
          case 'fines':
            await this.loadFineRecords();
            break;
          case 'logs':
            await this.loadLoginLogs();
            break;
        }
      } catch (err) {
        this.error = '加载数据过程中发生错误';
      } finally {
        this.loading = false;
      }
    },
    
    async loadUsers() {
      const response = await adminAPI.getAllUsers();
      if (response.success) {
        this.users = response.data || [];
      } else {
        throw new Error(response.message || '加载用户数据失败');
      }
    },
    
    async loadBorrowingRecords() {
      const response = await adminAPI.getAllBorrowingRecords();
      if (response.success) {
        this.borrowingRecords = response.data || [];
      } else {
        throw new Error(response.message || '加载借阅记录失败');
      }
    },
    
    async loadFineRecords() {
      const response = await adminAPI.getAllFineRecords();
      if (response.success) {
        this.fineRecords = response.data || [];
      } else {
        throw new Error(response.message || '加载罚款记录失败');
      }
    },
    
    async loadLoginLogs() {
      const response = await adminAPI.getUserLoginLogs();
      if (response.success) {
        this.loginLogs = response.data || [];
      } else {
        throw new Error(response.message || '加载登录日志失败');
      }
    },
    
    async searchUsers() {
      this.error = '';
      this.loading = true;
      
      try {
        // 这里应该调用实际的搜索API
        // 为了简化，我们只在本地过滤用户数据
        await this.loadUsers();
        
        if (this.userSearchKeyword) {
          this.users = this.users.filter(user => 
            user.uid.includes(this.userSearchKeyword) || 
            user.name.includes(this.userSearchKeyword)
          );
        }
      } catch (err) {
        this.error = '搜索用户过程中发生错误';
      } finally {
        this.loading = false;
      }
    },
    
    async manageUser(userId, action) {
      this.error = '';
      this.success = '';
      
      try {
        const response = await adminAPI.manageUser(userId, action);
        
        if (response.success) {
          this.success = action === 'suspend' ? '用户账户已冻结' : '用户账户已激活';
          // 重新加载用户数据
          await this.loadUsers();
        } else {
          this.error = response.message || '操作失败';
        }
      } catch (err) {
        this.error = '操作过程中发生错误';
      }
    },
    
    switchTab(tab) {
      this.activeTab = tab;
      this.loadTabData();
    },
    
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString('zh-CN');
    },
    
    formatDateTime(dateTimeString) {
      if (!dateTimeString) return '';
      const date = new Date(dateTimeString);
      return date.toLocaleString('zh-CN');
    },
    
    getIdentityTypeText(type) {
      switch (type) {
        case 1: return '学生';
        case 2: return '教师';
        case 3: return '管理员';
        default: return '未知';
      }
    },
    
    getStatusClass(status) {
      switch (status) {
        case 'active':
          return 'status-active';
        case 'suspended':
          return 'status-suspended';
        case 'borrowed':
          return 'status-borrowed';
        case 'returned':
          return 'status-returned';
        case 'overdue':
          return 'status-overdue';
        default:
          return '';
      }
    },
    
    getStatusText(status) {
      switch (status) {
        case 'active':
          return '正常';
        case 'suspended':
          return '已冻结';
        case 'borrowed':
          return '借阅中';
        case 'returned':
          return '已归还';
        case 'overdue':
          return '已逾期';
        default:
          return status;
      }
    },
    
    getPaymentStatusClass(status) {
      switch (status) {
        case 'paid':
          return 'status-paid';
        case 'unpaid':
          return 'status-unpaid';
        default:
          return '';
      }
    },
    
    getPaymentStatusText(status) {
      switch (status) {
        case 'paid':
          return '已缴纳';
        case 'unpaid':
          return '未缴纳';
        default:
          return status;
      }
    },
    
    getLoginStatusClass(status) {
      switch (status) {
        case 'success':
          return 'status-success';
        case 'failed':
          return 'status-failed';
        case 'registered':
          return 'status-registered';
        default:
          return '';
      }
    },
    
    getLoginStatusText(status) {
      switch (status) {
        case 'success':
          return '登录成功';
        case 'failed':
          return '登录失败';
        case 'registered':
          return '注册';
        default:
          return status;
      }
    }
  }
};
</script>

<style scoped>
.admin-panel-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.panel-header {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}

.panel-header h2 {
  margin: 0;
  color: #333;
  text-align: center;
}

.panel-tabs {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.panel-tabs button {
  padding: 10px 20px;
  margin: 5px;
  background-color: #f5f5f5;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.panel-tabs button.active {
  background-color: #409eff;
  color: white;
}

.panel-tabs button:hover:not(.active) {
  background-color: #e0e0e0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
}

.section-header h3 {
  margin: 0;
  color: #333;
}

.search-container {
  display: flex;
  gap: 10px;
}

.search-container input {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.search-container input:focus {
  border-color: #409eff;
  outline: none;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.search-container button {
  padding: 8px 16px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.search-container button:hover {
  background-color: #66b1ff;
}

.users-list, .records-list, .fines-list, .logs-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.user-item, .record-item, .fine-item, .log-item {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-info, .record-info, .fine-info, .log-info {
  flex: 1;
}

.user-info h4, .record-info h4, .fine-info h4, .log-info h4 {
  margin: 0 0 10px 0;
  color: #333;
}

.user-details, .record-details, .fine-details, .log-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
  color: #666;
  font-size: 14px;
}

.user-details span, .record-details span, .fine-details span, .log-details span {
  display: block;
}

.user-actions {
  margin-left: 20px;
}

.suspend-button {
  padding: 8px 16px;
  background-color: #f56c6c;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.suspend-button:hover {
  background-color: #f78989;
}

.activate-button {
  padding: 8px 16px;
  background-color: #67c23a;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.activate-button:hover {
  background-color: #85ce61;
}

.status-active {
  color: #67c23a;
}

.status-suspended {
  color: #f56c6c;
}

.status-borrowed {
  color: #409eff;
}

.status-returned {
  color: #67c23a;
}

.status-overdue {
  color: #f56c6c;
}

.status-paid {
  color: #67c23a;
}

.status-unpaid {
  color: #f56c6c;
}

.status-success {
  color: #67c23a;
}

.status-failed {
  color: #f56c6c;
}

.status-registered {
  color: #409eff;
}

.no-data {
  text-align: center;
  padding: 40px;
  color: #666;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
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

@media (max-width: 768px) {
  .users-list, .records-list, .fines-list, .logs-list {
    grid-template-columns: 1fr;
  }
  
  .user-item, .record-item, .fine-item, .log-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .user-actions {
    margin-left: 0;
    margin-top: 15px;
    align-self: flex-end;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
