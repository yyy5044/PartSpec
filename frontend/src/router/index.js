import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'Home', component: HomeView },
    { path: '/database', name: 'DataBase', component: () => import('../views/DatabaseView.vue') },
    { path: '/price', name: 'Price', component: () => import('../views/PriceView.vue') },
    {
      path: '/compatibility',
      name: 'Compatibility',
      component: () => import('../views/CompatibilityView.vue'),
    },
  ],
})

export default router
