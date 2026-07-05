<script setup>
import { RouterLink, RouterView, useRoute } from 'vue-router'
import HeaderEasterEgg from './components/HeaderEasterEgg.vue'
import MascotCat from './components/MascotCat.vue'

const route = useRoute()
</script>

<template>
  <div class="container">
    <header class="site-header">
      <MascotCat />
      <HeaderEasterEgg />
    </header>

    <nav class="top-nav">
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/database">DataBase</RouterLink>
      <RouterLink to="/price">Price</RouterLink>
      <RouterLink to="/compatibility">Compatibility check</RouterLink>
    </nav>

    <div class="content">
      <aside class="sidebar">
        <span class="region-label">aside — {{ route.name }}</span>
      </aside>
      <main>
        <RouterView />
      </main>
    </div>

    <footer class="site-footer">
      <span class="region-label">footer — 내용 미정</span>
    </footer>
  </div>
</template>
