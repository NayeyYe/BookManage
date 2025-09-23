import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Profile from '../views/Profile.vue'
import BookSearch from '../views/BookSearch.vue'
import BorrowingRecords from '../views/BorrowingRecords.vue'
import FineRecords from '../views/FineRecords.vue'
import AdminPanel from '../views/AdminPanel.vue'
import ApiTest from '../views/ApiTest.vue'

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
    path: '/profile',
    name: 'Profile',
    component: Profile
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
