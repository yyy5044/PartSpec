<script setup>
import { nextTick, ref } from 'vue'
import lisaSu from '../assets/ascii/lisa_su.txt?raw'
import jensenHuang from '../assets/ascii/jensen_huang.txt?raw'
import cheyTaewon from '../assets/ascii/chey_taewon.txt?raw'
import leeJaeyong from '../assets/ascii/lee_jaeyong.txt?raw'

// 위아래 빈 줄 제거 (아트마다 여백이 달라 크기 계산을 흐린다)
function trimArt(raw) {
  const lines = raw.split('\n')
  while (lines.length && !lines[0].trim()) lines.shift()
  while (lines.length && !lines[lines.length - 1].trim()) lines.pop()
  return lines.join('\n')
}

// 글자별 고정 배정: S→리사 수, p→젠슨 황, e→이재용, c→최태원
const letters = [
  { ch: 'S', art: trimArt(lisaSu) },
  { ch: 'p', art: trimArt(jensenHuang) },
  { ch: 'e', art: trimArt(leeJaeyong) },
  { ch: 'c', art: trimArt(cheyTaewon) },
]

const visible = ref(false)
const art = ref('')
const scale = ref(0.1)
const boxEl = ref(null)
const preEl = ref(null)

async function show(i) {
  art.value = letters[i].art

  // 아트 실측 크기를 재서 고정 박스에 딱 맞는 배율 계산
  await nextTick()
  const w = preEl.value.scrollWidth
  const h = preEl.value.scrollHeight
  if (w && h) {
    const raw = Math.min(boxEl.value.clientWidth / w, boxEl.value.clientHeight / h)
    // 축소 후 줄 간격(10px×배율)이 물리 픽셀의 정수 배가 되도록 내림 스냅
    // — 줄이 픽셀 경계에 어긋나며 생기는 가로 줄무늬(모아레) 방지
    const dpr = window.devicePixelRatio || 1
    const pitchDevicePx = Math.max(1, Math.floor(10 * raw * dpr))
    scale.value = pitchDevicePx / (10 * dpr)
  }
  visible.value = true
}

function hide() {
  visible.value = false
}
</script>

<template>
  <h1>
    Part<span
      v-for="(l, i) in letters"
      :key="l.ch"
      class="egg-trigger"
      @mouseenter="show(i)"
      @mouseleave="hide"
    >{{ l.ch }}</span>
  </h1>
  <div ref="boxEl" class="portrait-box" :class="{ visible }" aria-hidden="true">
    <pre
      ref="preEl"
      :style="{ top: visible ? '0px' : '36px', transform: `scale(${scale})` }"
    >{{ art }}</pre>
  </div>
</template>

<style scoped>
/* 고정 표시 영역: 헤더 오른쪽 위, 헤더 높이를 벗어나지 않는다 */
.portrait-box {
  position: absolute;
  top: 6px;
  right: 10px;
  bottom: 6px;
  width: 190px;
  overflow: hidden;
  opacity: 0;
  transition: opacity 1.4s ease;
  pointer-events: none;
  user-select: none;
}

.portrait-box.visible {
  opacity: 1;
}

.portrait-box pre {
  position: absolute;
  top: 0;
  right: 0;
  margin: 0;
  font-family: Consolas, 'Courier New', monospace;
  font-size: 10px;
  line-height: 10px;
  color: #444;
  transform-origin: top right;
  /* transform 대신 top으로 이동: 매 스텝 CPU가 최종 화질로 다시 그린다 (GPU 축소 줄무늬 방지)
     36px 상승을 1px씩 36단계로: 소수점 위치를 건너뛰어 이동 중 깜빡임 방지 */
  transition: top 0.6s steps(36);
}
</style>
