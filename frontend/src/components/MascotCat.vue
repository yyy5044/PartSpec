<script setup>
import { computed, onBeforeUnmount, reactive, ref } from 'vue'

// 껍데기(ฅ·괄호·귀)는 템플릿에 고정, 눈·입만 상태에 따라 교체
const EXPRESSIONS = {
  normal: { eyeL: '・', eyeR: '・', mouth: 'ω' },
  cry: { eyeL: '╥', eyeR: '╥', mouth: 'ω' },
  happy: { eyeL: '´', eyeR: '｀', mouth: '∇' },
}

const root = ref(null)
const rams = reactive([
  { x: 0, y: 0, spin: 0, vy: 0, floorY: 0, state: 'held', wasFallen: false, el: null },
  { x: 0, y: 0, spin: 0, vy: 0, floorY: 0, state: 'held', wasFallen: false, el: null },
])

const override = ref('')
let overrideTimer = null
let drag = null
let rafId = 0

const expression = computed(() => {
  if (override.value) return EXPRESSIONS[override.value]
  // 떨어졌던 램이 아직 손에 돌아오지 않았으면(바닥·줍는 중 포함) 운다
  return rams.some((r) => r.wasFallen) ? EXPRESSIONS.cry : EXPRESSIONS.normal
})

function ramStyle(i) {
  const r = rams[i]
  const baseTilt = i === 0 ? -14 : 14
  return {
    transform: `translate(${r.x}px, ${r.y}px) rotate(${baseTilt + r.spin}deg)`,
    transition: r.state === 'held' ? 'transform 0.15s ease-out' : 'none',
    cursor: drag && drag.i === i ? 'grabbing' : 'grab',
  }
}

function onDown(i, e) {
  const r = rams[i]
  if (r.state === 'falling') return
  e.preventDefault()
  drag = { i, px: e.clientX, py: e.clientY, bx: r.x, by: r.y }
  r.state = 'drag'
  window.addEventListener('pointermove', onMove)
  window.addEventListener('pointerup', onUp)
}

function onMove(e) {
  if (!drag) return
  const r = rams[drag.i]
  r.x = drag.bx + (e.clientX - drag.px)
  r.y = drag.by + (e.clientY - drag.py)
}

function onUp() {
  if (!drag) return
  window.removeEventListener('pointermove', onMove)
  window.removeEventListener('pointerup', onUp)
  const r = rams[drag.i]
  drag = null
  if (Math.hypot(r.x, r.y) < 45) {
    r.x = 0
    r.y = 0
    r.spin = 0
    r.vy = 0
    r.state = 'held'
    if (r.wasFallen) {
      r.wasFallen = false
      // 양손에 램이 모두 돌아왔을 때만 기뻐한다
      if (rams.every((x) => x.state === 'held')) showHappy()
    }
  } else {
    startFall(r)
  }
}

function startFall(r) {
  const headerEl = root.value.closest('.site-header') || root.value.parentElement
  const floor = headerEl.getBoundingClientRect().bottom - 6
  const ramBottom = r.el.getBoundingClientRect().bottom
  r.floorY = r.y + (floor - ramBottom)
  if (r.floorY <= r.y) {
    land(r)
    return
  }
  r.state = 'falling'
  r.vy = 0
  if (!rafId) rafId = requestAnimationFrame(step)
}

function step() {
  rafId = 0
  let active = false
  for (const r of rams) {
    if (r.state !== 'falling') continue
    r.vy += 0.55
    r.y += r.vy
    r.spin += r.vy * 1.2
    if (r.y >= r.floorY) {
      r.y = r.floorY
      if (Math.abs(r.vy) > 2.2) {
        r.vy = -r.vy * 0.35
        active = true
      } else {
        land(r)
      }
    } else {
      active = true
    }
  }
  if (active) rafId = requestAnimationFrame(step)
}

function land(r) {
  r.state = 'fallen'
  r.wasFallen = true
  r.vy = 0
  // 기본 기울기(±14도)와 합쳐 90도로 눕힘
  r.spin = r === rams[0] ? 104 : 76
}

function showHappy() {
  override.value = 'happy'
  clearTimeout(overrideTimer)
  overrideTimer = setTimeout(() => {
    override.value = ''
  }, 1500)
}

onBeforeUnmount(() => {
  cancelAnimationFrame(rafId)
  clearTimeout(overrideTimer)
  window.removeEventListener('pointermove', onMove)
  window.removeEventListener('pointerup', onUp)
})
</script>

<template>
  <div ref="root" class="mascot" aria-label="램을 양손에 든 고양이 마스코트">
    <svg
      class="ram ram-left"
      viewBox="0 0 20 40"
      :style="ramStyle(0)"
      :ref="(el) => (rams[0].el = el)"
      @pointerdown="onDown(0, $event)"
    >
      <rect x="2" y="2" width="16" height="30" fill="#2e7d4f" />
      <rect x="2" y="32" width="16" height="6" fill="#c9a227" />
      <rect x="5" y="6" width="10" height="5" fill="#222" />
      <rect x="5" y="15" width="10" height="5" fill="#222" />
      <rect x="5" y="24" width="10" height="5" fill="#222" />
    </svg>
    <span class="mascot-face"
      >ฅ(＾<span class="slot eye">{{ expression.eyeL }}</span
      ><span class="slot mouth">{{ expression.mouth }}</span
      ><span class="slot eye">{{ expression.eyeR }}</span
      >＾)ฅ</span
    >
    <svg
      class="ram ram-right"
      viewBox="0 0 20 40"
      :style="ramStyle(1)"
      :ref="(el) => (rams[1].el = el)"
      @pointerdown="onDown(1, $event)"
    >
      <rect x="2" y="2" width="16" height="30" fill="#2e7d4f" />
      <rect x="2" y="32" width="16" height="6" fill="#c9a227" />
      <rect x="5" y="6" width="10" height="5" fill="#222" />
      <rect x="5" y="15" width="10" height="5" fill="#222" />
      <rect x="5" y="24" width="10" height="5" fill="#222" />
    </svg>
  </div>
</template>

<style scoped>
.mascot {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 8px;
}

.mascot-face {
  font-size: 38px;
  line-height: 1;
  color: #333;
  white-space: nowrap;
}

/* 눈·입 고정 폭 슬롯: 글자가 바뀌어도 주변이 밀리지 않는다 */
.slot {
  display: inline-block;
  text-align: center;
  overflow: visible;
}

.eye {
  width: 0.7em;
}

.mouth {
  width: 0.9em;
}

.ram {
  width: 20px;
  height: 38px;
  position: relative;
  z-index: 2;
  touch-action: none;
}

.ram-left {
  margin-right: -9px;
  margin-top: -8px;
}

.ram-right {
  margin-left: -9px;
  margin-top: -8px;
}
</style>
