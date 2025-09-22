import { createRouter, createWebHistory } from 'vue-router'
import Home from '../components/Home.vue'
import Login from '../components/Login.vue'
import Register from '../components/Register.vue'
import BookSearch from '../components/BookSearch.vue'
import BorrowingRecords from '../components/BorrowingRecords.vue'
import FineRecords from '../components/FineRecords.vue'
import AdminPanel from '../components/AdminPanel.vue'
import ApiTest from '../components/ApiTest.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  },
  {
    path: '/search',
    name: 'BookSearch',
    component: BookSearch
  },
  {
    path: '/borrowing-records',
    name: 'BorrowingRecords',
    component: BorrowingRecords
  },
  {
    path: '/fine-records',
    name: 'FineRecords',
    component: FineRecords
  },
  {
    path: '/admin',
    name: 'AdminPanel',
    component: AdminPanel
  },
  {
    path: '/api-test',
    name: 'ApiTest',
    component: ApiTest
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
