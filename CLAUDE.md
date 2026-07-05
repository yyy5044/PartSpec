# PartSpec — PC 부품 카탈로그 Open API

컴퓨터 부품 스펙 데이터베이스 + 그 위의 Open API. 비영리, 공개 배포 전제.

원래 구상(PC 부품 가격 추적기)에서 피벗: 가격 데이터는 법적 제약(약관·DB제작자권리·부정경쟁방지법)이 커서, **부품 카탈로그 Open API를 Phase 1 독립 프로젝트로 먼저 완성**하고 가격 추적기는 이 API의 첫 소비자(Phase 2)로 얹는다.

스택: Java / Spring Boot / MyBatis / MySQL (API 서버), Python (데이터 파이프라인 스크립트).

## 디렉터리 구조

```
datasource/   원본 데이터 (AMD 공식 스펙 CSV 등) — 삭제 금지, 미수용 필드의 유일한 보관처
db/           schema_v2.sql (DDL), seed/ (생성된 INSERT 스크립트)
scripts/      재실행 가능한 파싱·시드 생성 스크립트
frontend/     Vue 3 + Vite (Router만 사용, TS/Pinia 없음). M2 전까지는 더미 데이터 목업
```

## DB 스키마 (v2, 확정)

패턴: **Class Table Inheritance** — `part`(부모, 모든 참조의 단일 진입점) + 카테고리별 spec 테이블(1:1, PK=FK). GPU만 `gpu_chipset`(설계) / `part`(실물 상품) 2단 구조.

- `part` (part_id PK, category, manufacturer, model_name, canonical_name, release_year) — UNIQUE(manufacturer, model_name)
- `cpu_spec` (part_id PK/FK, socket, core_count, thread_count, base_clock_mhz, boost_clock_mhz, tdp_watt, has_igpu)
- `gpu_chipset` (chipset_id PK, chip_maker, chipset_name, vram_gb) — UNIQUE(chip_maker, chipset_name)
- `gpu_spec` (part_id PK/FK, chipset_id FK, length_mm, slot_thickness, recommended_psu_watt, power_connector)

의도적으로 뺀 것 (YAGNI, 추가해도 구조 변경 없음): `part_alias`(Phase 2), `price_history`(Phase 2), 메인보드/RAM/PSU 등 spec 테이블(카테고리 확장 시).

스키마 v3 1순위 후보: AMD CSV의 **Product ID(Boxed/Tray/MPK)** 컬럼 — Phase 2 canonical matching 키.

## 데이터 소스 (조사 완료, 재조사 불필요)

- **AMD CPU**: 공식 스펙 CSV (amd.com/en/products/specifications/processors.html) — 채택, `datasource/`에 보관
- **Intel CPU**: 공식 API 신규 발급 중단 → GitHub `toUpperCase78/intel-processors` 데이터셋 사용 예정 (라이선스 확인 필요)
- 가격 소스: 다나와 API 포기 확정, 네이버 API는 저장 불가 약관, 쿠팡 파트너스가 Phase 2 최유력(판매실적 15만원 달성 후 승인 필요)

## 정규화 규칙 (AMD CSV → DB)

- `"Up to 5.1 GHz"` → boost_clock_mhz 5100 / `"2 GHz"` → 2000
- `"65W"` → tdp_watt 65
- `"3/2/2026"` → release_year 2026
- Graphics Model `"Discrete Graphics Card Required"` → has_igpu FALSE / 값 있으면 TRUE / 공란 NULL
- Name에서 ™·® 제거 + `"AMD "` 접두어 제거 → model_name / 원형 유지 → canonical_name
- 필터: CPU Socket ∈ {AM4, AM5} → 247건 (AM4 164 / AM5 83)

정규화 함수는 저장·조회 양쪽에서 동일 함수를 사용한다 (Phase 2 alias 사전 오염 방지).

## 로드맵

- **M1. 카탈로그 DB + 시드** ← 현재
  - [x] 스키마 v2 설계·검증
  - [x] AMD 데스크톱 CPU 247건 시드 파이프라인 (`scripts/generate_amd_seed.py`)
  - [ ] Intel CPU 시드 (LGA1700/LGA1851 데스크톱 필터, 단위 표기 AMD와 다를 수 있음)
  - [ ] GPU 시드 소량 (gpu_chipset/gpu_spec 구조 검증용)
- **M2.** 조회 API 최소 버전 (Spring Boot 읽기 전용: `GET /parts?category=CPU&socket=AM5`, `GET /parts/{id}`)
- **M3.** 배포 (EC2 + nginx)
- **M4.** Open API화 (API 키, rate limiting, Swagger, 에러 규격)
- **M5.** 확장 (호환성 API, 갱신 자동화, 가격 추적기) — 별도 프로젝트 취급

**규칙: 한 마일스톤이 끝나기 전에 다음 것을 시작하지 않는다.**

## 설계 원칙

1. 모든 부품 참조는 part_id 하나로 통일
2. 호환성 판정에 쓰는 필드만 타입 있는 컬럼으로, 표시용 잡스펙은 추후 JSON 컬럼 고려
3. 되돌리기 비싼 결정(GPU 2단 구조)은 미리, 싼 결정(part_alias)은 필요할 때
4. "원본 전체 다운로드 + 코드로 필터"가 재현성 정석 — 필터 로직은 코드에 남긴다
