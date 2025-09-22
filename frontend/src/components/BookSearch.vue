<template>
  <div class="book-search-container">
    <div class="search-form">
      <h2>图书搜索</h2>
      <div class="search-options">
        <div class="search-option" :class="{ active: searchType === 'name' }" @click="searchType = 'name'">
          书名
        </div>
        <div class="search-option" :class="{ active: searchType === 'author' }" @click="searchType = 'author'">
          作者
        </div>
        <div class="search-option" :class="{ active: searchType === 'tag' }" @click="searchType = 'tag'">
          标签
        </div>
        <div class="search-option" :class="{ active: searchType === 'publisher' }" @click="searchType = 'publisher'">
          出版社
        </div>
        <div class="search-option" :class="{ active: searchType === 'isbn' }" @click="searchType = 'isbn'">
          ISBN
        </div>
      </div>
      <div class="search-input-container">
        <input 
          type="text" 
          v-model="searchKeyword" 
          placeholder="请输入搜索关键词"
          @keyup.enter="handleSearch"
        />
        <button @click="handleSearch" :disabled="searching">
          {{ searching ? '搜索中...' : '搜索' }}
        </button>
      </div>
    </div>
    
    <div class="search-results" v-if="searchResults.length > 0">
      <h3>搜索结果</h3>
      <div class="results-list">
        <div class="book-item" v-for="book in searchResults" :key="book.book_id">
          <div class="book-info">
            <h4>{{ book.title }}</h4>
            <p class="book-details">
              <span v-if="book.authors">作者: {{ book.authors }}</span>
              <span v-if="book.publisher_name">出版社: {{ book.publisher_name }}</span>
              <span v-if="book.isbn">ISBN: {{ book.isbn }}</span>
              <span v-if="book.publication_year">出版年份: {{ book.publication_year }}</span>
            </p>
            <p class="book-stock">
              库存: {{ book.current_stock }}/{{ book.total_stock }}
            </p>
          </div>
          <div class="book-actions">
            <button 
              @click="borrowBook(book.book_id)" 
              :disabled="book.current_stock <= 0 || borrowing[book.book_id]"
              class="borrow-button"
            >
              {{ borrowing[book.book_id] ? '借阅中...' : (book.current_stock > 0 ? '借阅' : '无库存') }}
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <div class="no-results" v-else-if="searched && searchResults.length === 0">
      <p>未找到相关图书</p>
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
import { bookAPI } from '../utils/api';

export default {
  name: 'BookSearch',
  data() {
    return {
      searchType: 'name',
      searchKeyword: '',
      searching: false,
      searched: false,
      searchResults: [],
      borrowing: {},
      error: '',
      success: ''
    };
  },
  methods: {
    async handleSearch() {
      // 重置状态
      this.error = '';
      this.success = '';
      this.searched = false;
      
      if (!this.searchKeyword.trim()) {
        this.error = '请输入搜索关键词';
        return;
      }
      
      this.searching = true;
      
      try {
        let response;
        
        // 根据搜索类型调用不同的API
        switch (this.searchType) {
          case 'name':
            response = await bookAPI.searchByName(this.searchKeyword);
            break;
          case 'author':
            response = await bookAPI.searchByAuthor(this.searchKeyword);
            break;
          case 'tag':
            response = await bookAPI.searchByTag(this.searchKeyword);
            break;
          case 'publisher':
            response = await bookAPI.searchByPublisher(this.searchKeyword);
            break;
          case 'isbn':
            response = await bookAPI.searchByISBN(this.searchKeyword);
            break;
          default:
            throw new Error('无效的搜索类型');
        }
        
        if (response.success) {
          this.searchResults = response.data || [];
          this.searched = true;
        } else {
          this.error = response.message || '搜索失败';
        }
      } catch (err) {
        this.error = err.response?.data?.message || '搜索过程中发生错误';
      } finally {
        this.searching = false;
      }
    },
    
    async borrowBook(bookId) {
      // 设置借阅状态
      this.$set(this.borrowing, bookId, true);
      this.error = '';
      this.success = '';
      
      try {
        const response = await bookAPI.borrowBook(bookId);
        
        if (response.success) {
          this.success = '借阅成功！';
          // 更新库存信息
          const book = this.searchResults.find(b => b.book_id === bookId);
          if (book) {
            book.current_stock -= 1;
          }
        } else {
          this.error = response.message || '借阅失败';
        }
      } catch (err) {
        this.error = err.response?.data?.message || '借阅过程中发生错误';
      } finally {
        // 重置借阅状态
        this.$set(this.borrowing, bookId, false);
      }
    }
  }
};
</script>

<style scoped>
.book-search-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.search-form {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.search-form h2 {
  margin-top: 0;
  color: #333;
  text-align: center;
}

.search-options {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.search-option {
  padding: 10px 20px;
  margin: 5px;
  background-color: #f5f5f5;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.search-option.active {
  background-color: #409eff;
  color: white;
}

.search-option:hover:not(.active) {
  background-color: #e0e0e0;
}

.search-input-container {
  display: flex;
  gap: 10px;
  max-width: 600px;
  margin: 0 auto;
}

.search-input-container input {
  flex: 1;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

.search-input-container input:focus {
  border-color: #409eff;
  outline: none;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.search-input-container button {
  padding: 12px 24px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.search-input-container button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.search-input-container button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.search-results h3 {
  margin-top: 30px;
  color: #333;
}

.results-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.book-item {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.book-info {
  flex: 1;
}

.book-info h4 {
  margin: 0 0 10px 0;
  color: #333;
}

.book-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
  color: #666;
  font-size: 14px;
}

.book-details span {
  display: block;
}

.book-stock {
  margin: 10px 0;
  font-weight: 500;
  color: #409eff;
}

.book-actions {
  margin-top: 15px;
}

.borrow-button {
  width: 100%;
  padding: 10px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.borrow-button:hover:not(:disabled) {
  background-color: #66b1ff;
}

.borrow-button:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.no-results {
  text-align: center;
  margin-top: 30px;
  color: #666;
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
  .search-options {
    flex-direction: column;
    align-items: center;
  }
  
  .search-input-container {
    flex-direction: column;
  }
  
  .results-list {
    grid-template-columns: 1fr;
  }
}
</style>
