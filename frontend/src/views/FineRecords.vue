<template>
  <div class="fine-records-container">
    <div class="records-header">
      <h2>我的罚款记录</h2>
    </div>
    
    <div class="records-content">
      <div v-if="fineRecords.length > 0" class="records-list">
        <div class="record-item" v-for="record in fineRecords" :key="record.fine_id">
          <div class="record-info">
            <h4>{{ record.book_title }}</h4>
            <p class="record-details">
              <span>借阅日期: {{ formatDate(record.borrow_date) }}</span>
              <span>应还日期: {{ formatDate(record.due_date) }}</span>
              <span>实际归还日期: {{ formatDate(record.actual_return_date) }}</span>
              <span>逾期天数: {{ record.overdue_days }}天</span>
            </p>
          </div>
          <div class="fine-info">
            <div class="fine-amount">
              罚款金额: ¥{{ record.fine_amount }}
            </div>
            <div class="payment-status" :class="getPaymentStatusClass(record.payment_status)">
              {{ getPaymentStatusText(record.payment_status) }}
            </div>
          </div>
        </div>
      </div>
      <div v-else class="no-records">
        <p>暂无罚款记录</p>
      </div>
    </div>
    
    <div class="total-fine" v-if="totalUnpaidFine > 0">
      <p>待缴罚款总额: ¥{{ totalUnpaidFine }}</p>
      <button @click="payAllFines" :disabled="paying" class="pay-button">
        {{ paying ? '缴费中...' : '缴纳所有罚款' }}
      </button>
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
import { userAPI } from '../utils/api';

export default {
  name: 'FineRecords',
  data() {
    return {
      fineRecords: [],
      loading: false,
      paying: false,
      error: '',
      success: ''
    };
  },
  computed: {
    totalUnpaidFine() {
      return this.fineRecords
        .filter(record => record.payment_status === 'unpaid')
        .reduce((total, record) => total + parseFloat(record.fine_amount), 0)
        .toFixed(2);
    }
  },
  mounted() {
    this.loadFineRecords();
  },
  methods: {
    async loadFineRecords() {
      this.error = '';
      this.loading = true;
      
      try {
        const response = await userAPI.getFineRecords();
        
        if (response.success) {
          this.fineRecords = response.data || [];
        } else {
          this.error = response.message || '加载罚款记录失败';
        }
      } catch (err) {
        this.error = err.response?.data?.message || '加载罚款记录过程中发生错误';
      } finally {
        this.loading = false;
      }
    },
    
    async payAllFines() {
      this.error = '';
      this.success = '';
      this.paying = true;
      
      try {
        // 这里应该调用实际的支付API，但为了简化，我们只更新状态
        // 在实际应用中，这里会集成支付系统
        
        // 模拟支付成功
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // 更新所有未支付的罚款记录为已支付
        this.fineRecords.forEach(record => {
          if (record.payment_status === 'unpaid') {
            record.payment_status = 'paid';
          }
        });
        
        this.success = '所有罚款缴纳成功！';
      } catch (err) {
        this.error = '缴纳罚款过程中发生错误';
      } finally {
        this.paying = false;
      }
    },
    
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString('zh-CN');
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
    }
  }
};
</script>

<style scoped>
.fine-records-container {
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

.fine-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  margin-left: 20px;
}

.fine-amount {
  font-size: 18px;
  font-weight: 500;
  color: #f56c6c;
  margin-bottom: 10px;
}

.payment-status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-paid {
  background-color: #f0f9ff;
  color: #409eff;
}

.status-unpaid {
  background-color: #fef0f0;
  color: #f56c6c;
}

.total-fine {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total-fine p {
  font-size: 18px;
  font-weight: 500;
  color: #f56c6c;
  margin: 0;
}

.pay-button {
  padding: 10px 20px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.pay-button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.pay-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.no-records {
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
  .records-list {
    grid-template-columns: 1fr;
  }
  
  .record-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .fine-info {
    margin-left: 0;
    margin-top: 15px;
    align-items: flex-start;
  }
  
  .total-fine {
    flex-direction: column;
    gap: 15px;
  }
}
</style>
