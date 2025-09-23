<template>
  <div class="borrowing-records-container">
    <div class="records-header">
      <h2>我的借阅记录</h2>
      <div class="record-tabs">
        <button 
          :class="{ active: activeTab === 'current' }" 
          @click="switchTab('current')"
        >
          当前借阅
        </button>
        <button 
          :class="{ active: activeTab === 'history' }" 
          @click="switchTab('history')"
        >
          历史记录
        </button>
      </div>
    </div>
    
    <div class="records-content">
      <!-- 当前借阅记录 -->
      <div v-if="activeTab === 'current'" class="current-records">
        <div v-if="currentRecords.length > 0" class="records-list">
          <div class="record-item" v-for="record in currentRecords" :key="record.record_id">
            <div class="record-info">
              <h4>{{ record.book_title }}</h4>
              <p class="record-details">
                <span>借阅日期: {{ formatDate(record.borrow_date) }}</span>
                <span>应还日期: {{ formatDate(record.due_date) }}</span>
                <span :class="getOverdueClass(record.overdue_days)">
                  {{ getOverdueText(record.overdue_days) }}
                </span>
              </p>
            </div>
            <div class="record-actions">
              <button 
                @click="returnBook(record.record_id)" 
                :disabled="returning[record.record_id]"
                class="return-button"
              >
                {{ returning[record.record_id] ? '还书中...' : '归还' }}
              </button>
            </div>
          </div>
        </div>
        <div v-else class="no-records">
          <p>暂无当前借阅记录</p>
        </div>
      </div>
      
      <!-- 历史借阅记录 -->
      <div v-if="activeTab === 'history'" class="history-records">
        <div v-if="historyRecords.length > 0" class="records-list">
          <div class="record-item" v-for="record in historyRecords" :key="record.record_id">
            <div class="record-info">
              <h4>{{ record.book_title }}</h4>
              <p class="record-details">
                <span>借阅日期: {{ formatDate(record.borrow_date) }}</span>
                <span>应还日期: {{ formatDate(record.due_date) }}</span>
                <span v-if="record.actual_return_date">
                  归还日期: {{ formatDate(record.actual_return_date) }}
                </span>
                <span :class="getStatusClass(record.return_status)">
                  状态: {{ getStatusText(record.return_status) }}
                </span>
                <span v-if="record.overdue_days && record.overdue_days > 0">
                  逾期天数: {{ record.overdue_days }}天
                </span>
              </p>
            </div>
          </div>
        </div>
        <div v-else class="no-records">
          <p>暂无历史借阅记录</p>
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
import { userAPI, bookAPI } from '../utils/api';

export default {
  name: 'BorrowingRecords',
  data() {
    return {
      activeTab: 'current',
      currentRecords: [],
      historyRecords: [],
      loading: false,
      returning: {},
      error: '',
      success: ''
    };
  },
  mounted() {
    this.loadRecords();
  },
  methods: {
    async loadRecords() {
      this.error = '';
      this.loading = true;
      
      try {
        if (this.activeTab === 'current') {
          // 加载当前借阅记录
          const response = await userAPI.getCurrentBorrowingRecords();
          if (response.success) {
            this.currentRecords = response.data || [];
          } else {
            this.error = response.message || '加载当前借阅记录失败';
          }
        } else {
          // 加载历史借阅记录
          const response = await userAPI.getAllBorrowingRecords();
          if (response.success) {
            this.historyRecords = response.data || [];
          } else {
            this.error = response.message || '加载历史借阅记录失败';
          }
        }
      } catch (err) {
        this.error = err.response?.data?.message || '加载借阅记录过程中发生错误';
      } finally {
        this.loading = false;
      }
    },
    
    switchTab(tab) {
      this.activeTab = tab;
      this.loadRecords();
    },
    
    async returnBook(recordId) {
      // 设置还书状态
      this.$set(this.returning, recordId, true);
      this.error = '';
      this.success = '';
      
      try {
        const response = await bookAPI.returnBook(recordId);
        
        if (response.success) {
          this.success = '还书成功！';
          // 重新加载当前借阅记录
          await this.loadRecords();
        } else {
          this.error = response.message || '还书失败';
        }
      } catch (err) {
        this.error = err.response?.data?.message || '还书过程中发生错误';
      } finally {
        // 重置还书状态
        this.$set(this.returning, recordId, false);
      }
    },
    
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString('zh-CN');
    },
    
    getOverdueClass(overdueDays) {
      if (overdueDays > 0) {
        return 'overdue';
      }
      return '';
    },
    
    getOverdueText(overdueDays) {
      if (overdueDays > 0) {
        return `已逾期${overdueDays}天`;
      } else if (overdueDays === 0) {
        return '今天到期';
      } else {
        return `剩余${Math.abs(overdueDays)}天`;
      }
    },
    
    getStatusClass(status) {
      switch (status) {
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
        case 'borrowed':
          return '借阅中';
        case 'returned':
          return '已归还';
        case 'overdue':
          return '已逾期';
        default:
          return status;
      }
    }
  }
};
</script>

<style scoped>
.borrowing-records-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.records-header {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}

.records-header h2 {
  margin-top: 0;
  color: #333;
  text-align: center;
}

.record-tabs {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.record-tabs button {
  padding: 10px 20px;
  margin: 0 10px;
  background-color: #f5f5f5;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.record-tabs button.active {
  background-color: #409eff;
  color: white;
}

.record-tabs button:hover:not(.active) {
  background-color: #e0e0e0;
}

.records-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.record-item {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.record-info {
  flex: 1;
}

.record-info h4 {
  margin: 0 0 10px 0;
  color: #333;
}

.record-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
  color: #666;
  font-size: 14px;
}

.record-details span {
  display: block;
}

.record-details .overdue {
  color: #f56c6c;
  font-weight: 500;
}

.record-actions {
  margin-left: 20px;
}

.return-button {
  padding: 8px 16px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.return-button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.return-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.no-records {
  text-align: center;
  padding: 40px;
  color: #666;
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
  .records-list {
    grid-template-columns: 1fr;
  }
  
  .record-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .record-actions {
    margin-left: 0;
    margin-top: 15px;
    align-self: flex-end;
  }
}
</style>
