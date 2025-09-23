<template>
  <div class="profile-container">
    <div class="profile-header">
      <h2>个人中心</h2>
      <div class="user-info">
        <div class="info-item">
          <span class="label">用户ID：</span>
          <span class="value">{{ userInfo.uid }}</span>
        </div>
        <div class="info-item">
          <span class="label">姓名：</span>
          <span class="value">{{ userInfo.name }}</span>
        </div>
        <div class="info-item">
          <span class="label">身份类型：</span>
          <span class="value">{{ getIdentityTypeText(userInfo.identity_type) }}</span>
        </div>
      </div>
    </div>

    <div class="profile-content">
      <!-- 当前借阅 -->
      <div class="section">
        <h3>当前借阅</h3>
        <div v-if="currentBorrowings.length === 0" class="empty-message">
          暂无当前借阅记录
        </div>
        <div v-else class="records-grid">
          <div v-for="record in currentBorrowings" :key="record.record_id" class="record-card">
            <div class="record-header">
              <h4>{{ record.book_title || record.book_id }}</h4>
              <span :class="['status', record.return_status]">{{ getStatusText(record.return_status) }}</span>
            </div>
            <div class="record-details">
              <div class="detail-item">
                <span class="detail-label">借阅日期：</span>
                <span class="detail-value">{{ formatDate(record.borrow_date) }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">应还日期：</span>
                <span class="detail-value">{{ formatDate(record.due_date) }}</span>
              </div>
              <div v-if="record.overdue_days > 0" class="detail-item overdue">
                <span class="detail-label">逾期天数：</span>
                <span class="detail-value">{{ record.overdue_days }}天</span>
              </div>
            </div>
            <div v-if="record.return_status === 'borrowed'" class="record-actions">
              <button @click="handleReturn(record.record_id)" class="return-button">
                还书
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 历史借阅 -->
      <div class="section">
        <h3>历史借阅</h3>
        <div v-if="allBorrowings.length === 0" class="empty-message">
          暂无历史借阅记录
        </div>
        <div v-else class="records-table">
          <table>
            <thead>
              <tr>
                <th>图书ID</th>
                <th>图书名称</th>
                <th>借阅日期</th>
                <th>归还日期</th>
                <th>状态</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="record in allBorrowings" :key="record.record_id">
                <td>{{ record.book_id }}</td>
                <td>{{ record.book_title || '-' }}</td>
                <td>{{ formatDate(record.borrow_date) }}</td>
                <td>{{ record.return_date ? formatDate(record.return_date) : '-' }}</td>
                <td>
                  <span :class="['status-badge', record.return_status]">
                    {{ getStatusText(record.return_status) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 罚款信息 -->
      <div class="section">
        <h3>罚款信息</h3>
        <div v-if="fineRecords.length === 0" class="empty-message">
          暂无罚款记录
        </div>
        <div v-else>
          <div class="fine-summary">
            <div class="summary-item">
              <span class="summary-label">未缴纳罚款总额：</span>
              <span class="summary-value amount">¥{{ getUnpaidFineAmount() }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">罚款记录总数：</span>
              <span class="summary-value">{{ fineRecords.length }}条</span>
            </div>
          </div>
          <div class="fines-table">
            <table>
              <thead>
                <tr>
                  <th>罚款ID</th>
                  <th>关联借阅</th>
                  <th>罚款金额</th>
                  <th>罚款原因</th>
                  <th>缴纳状态</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="fine in fineRecords" :key="fine.fine_id">
                  <td>{{ fine.fine_id }}</td>
                  <td>{{ fine.record_id }}</td>
                  <td class="amount">¥{{ fine.fine_amount }}</td>
                  <td>{{ fine.fine_reason }}</td>
                  <td>
                    <span :class="['status-badge', fine.payment_status]">
                      {{ getPaymentStatusText(fine.payment_status) }}
                    </span>
                  </td>
                  <td>
                    <button 
                      v-if="fine.payment_status === 'unpaid'" 
                      @click="handlePayFine(fine.fine_id)"
                      class="pay-button"
                    >
                      缴纳
                    </button>
                    <span v-else class="paid-text">已缴纳</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { userAPI, bookAPI } from '../utils/api';

export default {
  name: 'Profile',
  data() {
    return {
      userInfo: {},
      currentBorrowings: [],
      allBorrowings: [],
      fineRecords: [],
      loading: false
    };
  },
  mounted() {
    this.loadUserData();
    this.loadBorrowingRecords();
    this.loadFineRecords();
  },
  methods: {
    loadUserData() {
      const userInfo = localStorage.getItem('userInfo');
      if (userInfo) {
        this.userInfo = JSON.parse(userInfo);
      }
    },

    async loadBorrowingRecords() {
      try {
        this.loading = true;
        
        // 加载当前借阅记录
        const currentResponse = await userAPI.getCurrentBorrowingRecords();
        if (currentResponse.success) {
          this.currentBorrowings = currentResponse.data || [];
        }
        
        // 加载所有借阅记录
        const allResponse = await userAPI.getAllBorrowingRecords();
        if (allResponse.success) {
          this.allBorrowings = allResponse.data || [];
        }
      } catch (err) {
        console.error('加载借阅记录失败:', err);
      } finally {
        this.loading = false;
      }
    },

    async loadFineRecords() {
      try {
        const response = await userAPI.getFineRecords();
        if (response.success) {
          this.fineRecords = response.data || [];
        }
      } catch (err) {
        console.error('加载罚款记录失败:', err);
      }
    },

    async handleReturn(recordId) {
      try {
        const response = await bookAPI.returnBook(recordId);
        if (response.success) {
          // 重新加载数据
          this.loadBorrowingRecords();
          this.loadFineRecords();
          alert('还书成功！');
        } else {
          alert(response.message || '还书失败');
        }
      } catch (err) {
        alert(err.response?.data?.message || '还书过程中发生错误');
      }
    },

    async handlePayFine(fineId) {
      try {
        // 这里应该调用缴纳罚款的API
        // 由于API中可能没有这个功能，我们先模拟一下
        alert(`缴纳罚款 ${fineId} 的功能正在开发中`);
        
        // 模拟缴纳成功后重新加载数据
        this.loadFineRecords();
      } catch (err) {
        alert('缴纳罚款过程中发生错误');
      }
    },

    getIdentityTypeText(type) {
      const types = {
        1: '学生',
        2: '教师',
        3: '管理员',
        4: '管理员',
        5: '超级管理员'
      };
      return types[type] || '未知';
    },

    getStatusText(status) {
      const statusMap = {
        'borrowed': '借阅中',
        'returned': '已归还',
        'overdue': '已逾期'
      };
      return statusMap[status] || status;
    },

    getPaymentStatusText(status) {
      const statusMap = {
        'paid': '已缴纳',
        'unpaid': '未缴纳'
      };
      return statusMap[status] || status;
    },

    getUnpaidFineAmount() {
      return this.fineRecords
        .filter(fine => fine.payment_status === 'unpaid')
        .reduce((total, fine) => total + parseFloat(fine.fine_amount), 0)
        .toFixed(2);
    },

    formatDate(dateString) {
      if (!dateString) return '-';
      const date = new Date(dateString);
      return date.toLocaleDateString('zh-CN');
    }
  }
};
</script>

<style scoped>
.profile-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.profile-header {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
  margin-bottom: 30px;
}

.profile-header h2 {
  color: #333;
  margin-bottom: 20px;
  text-align: center;
}

.user-info {
  display: flex;
  justify-content: center;
  gap: 40px;
  flex-wrap: wrap;
}

.info-item {
  display: flex;
  align-items: center;
}

.info-item .label {
  font-weight: 500;
  color: #666;
  margin-right: 8px;
}

.info-item .value {
  color: #333;
  font-weight: 500;
}

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.section {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
}

.section h3 {
  color: #333;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #409eff;
}

.empty-message {
  text-align: center;
  color: #999;
  padding: 40px;
  font-style: italic;
}

.records-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.record-card {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 20px;
  transition: box-shadow 0.3s;
}

.record-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.record-header h4 {
  margin: 0;
  color: #333;
  font-size: 16px;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status.borrowed {
  background-color: #e6f7ff;
  color: #409eff;
}

.status.returned {
  background-color: #f6ffed;
  color: #52c41a;
}

.status.overdue {
  background-color: #fff2e8;
  color: #fa8c16;
}

.record-details {
  margin-bottom: 15px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.detail-item.overdue {
  color: #f56c6c;
  font-weight: 500;
}

.detail-label {
  color: #666;
}

.detail-value {
  color: #333;
  font-weight: 500;
}

.record-actions {
  text-align: center;
}

.return-button {
  padding: 8px 16px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.return-button:hover {
  background-color: #66b1ff;
}

.records-table, .fines-table {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

th, td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #e4e7ed;
}

th {
  background-color: #f5f7fa;
  color: #333;
  font-weight: 500;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-badge.paid {
  background-color: #f6ffed;
  color: #52c41a;
}

.status-badge.unpaid {
  background-color: #fff2e8;
  color: #fa8c16;
}

.fine-summary {
  display: flex;
  gap: 30px;
  margin-bottom: 20px;
  padding: 20px;
  background-color: #f8f9fa;
  border-radius: 8px;
}

.summary-item {
  display: flex;
  align-items: center;
}

.summary-label {
  color: #666;
  margin-right: 8px;
}

.summary-value {
  font-weight: 500;
  color: #333;
}

.summary-value.amount {
  color: #f56c6c;
  font-size: 18px;
}

.pay-button {
  padding: 6px 12px;
  background-color: #67c23a;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.pay-button:hover {
  background-color: #85ce61;
}

.paid-text {
  color: #999;
  font-style: italic;
}

.amount {
  color: #f56c6c;
  font-weight: 500;
}

@media (max-width: 768px) {
  .profile-container {
    padding: 15px;
  }
  
  .user-info {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .records-grid {
    grid-template-columns: 1fr;
  }
  
  .fine-summary {
    flex-direction: column;
    gap: 15px;
  }
  
  .records-table, .fines-table {
    font-size: 14px;
  }
  
  th, td {
    padding: 8px;
  }
}
</style>
