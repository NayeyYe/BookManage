<script setup>
import { RouterView } from 'vue-router'
import Header from './components/Header.vue'
</script>

<template>
  <div id="app">
    <Header />
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
  color: #2c3e50;
  margin-top: 0;
}

.container {
  margin-top: 60px;
  padding: 20px;
  min-height: calc(100vh - 60px);
}
</style>
