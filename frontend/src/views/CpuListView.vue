<script setup>
import { ref, computed } from 'vue'

// 더미 데이터: db/seed/amd_cpu_seed.sql에서 발췌한 실제 10건.
// M2에서 GET /parts?category=CPU 응답으로 교체된다.
const cpus = [
  { id: 1, model: 'Ryzen 9 9950X', socket: 'AM5', cores: 16, threads: 32, boostMhz: 5700, tdp: 170, igpu: true },
  { id: 2, model: 'Ryzen 7 9800X3D', socket: 'AM5', cores: 8, threads: 16, boostMhz: 5200, tdp: 120, igpu: true },
  { id: 3, model: 'Ryzen 7 7700X', socket: 'AM5', cores: 8, threads: 16, boostMhz: 5400, tdp: 105, igpu: true },
  { id: 4, model: 'Ryzen 7 7700', socket: 'AM5', cores: 8, threads: 16, boostMhz: 5300, tdp: 65, igpu: true },
  { id: 5, model: 'Ryzen 5 7600', socket: 'AM5', cores: 6, threads: 12, boostMhz: 5100, tdp: 65, igpu: true },
  { id: 6, model: 'Ryzen 9 5950X', socket: 'AM4', cores: 16, threads: 32, boostMhz: 4900, tdp: 105, igpu: false },
  { id: 7, model: 'Ryzen 7 5800X3D', socket: 'AM4', cores: 8, threads: 16, boostMhz: 4500, tdp: 105, igpu: false },
  { id: 8, model: 'Ryzen 5 5600G', socket: 'AM4', cores: 6, threads: 12, boostMhz: 4400, tdp: 65, igpu: true },
  { id: 9, model: 'Ryzen 5 5600', socket: 'AM4', cores: 6, threads: 12, boostMhz: 4400, tdp: 65, igpu: false },
  { id: 10, model: 'Ryzen 5 3600', socket: 'AM4', cores: 6, threads: 12, boostMhz: 4200, tdp: 65, igpu: false },
]

const socketFilter = ref('')
const minCores = ref(0)

const filtered = computed(() =>
  cpus.filter(
    (c) => (socketFilter.value === '' || c.socket === socketFilter.value) && c.cores >= minCores.value,
  ),
)
</script>

<template>
  <h2>CPU 카탈로그</h2>

  <div class="filter-bar">
    <label>소켓
      <select v-model="socketFilter">
        <option value="">전체</option>
        <option value="AM5">AM5</option>
        <option value="AM4">AM4</option>
      </select>
    </label>
    <label>최소 코어
      <select v-model.number="minCores">
        <option :value="0">전체</option>
        <option :value="6">6+</option>
        <option :value="8">8+</option>
        <option :value="16">16+</option>
      </select>
    </label>
    <span class="count">{{ filtered.length }}건</span>
  </div>

  <table>
    <thead>
      <tr>
        <th>모델명</th>
        <th>소켓</th>
        <th>코어 / 스레드</th>
        <th>부스트 클럭</th>
        <th>TDP</th>
        <th>내장그래픽</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="cpu in filtered" :key="cpu.id">
        <td><a href="#">{{ cpu.model }}</a></td>
        <td>{{ cpu.socket }}</td>
        <td>{{ cpu.cores }} / {{ cpu.threads }}</td>
        <td>{{ (cpu.boostMhz / 1000).toFixed(1) }} GHz</td>
        <td>{{ cpu.tdp }}W</td>
        <td>{{ cpu.igpu ? 'O' : 'X' }}</td>
      </tr>
    </tbody>
  </table>

  <p class="note">더미 데이터 10건 (실제 시드는 247건) — M2에서 GET /parts 연동 예정</p>
</template>
