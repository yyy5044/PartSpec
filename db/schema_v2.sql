-- ============================================================
-- PartSpec 카탈로그 DB 스키마 v2
-- 패턴: Class Table Inheritance
--   part(부모) + 카테고리별 spec 테이블(1:1, PK=FK)
--   GPU만 gpu_chipset(설계) / part(실물 상품) 2단 구조
-- 시드 데이터는 db/seed/ 의 별도 스크립트로 적재한다.
-- ============================================================

CREATE DATABASE IF NOT EXISTS parts_catalog
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE parts_catalog;

-- 모든 부품 참조의 단일 진입점.
-- 가격/별칭/견적 등 후속 테이블은 전부 part_id만 참조한다.
CREATE TABLE part (
    part_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category       VARCHAR(20)  NOT NULL,              -- 'CPU', 'GPU', ...
    manufacturer   VARCHAR(50)  NOT NULL,              -- 'AMD', 'Intel', 'ASUS', ...
    model_name     VARCHAR(200) NOT NULL,              -- 정규화된 모델명 (™/® 및 브랜드 접두어 제거)
    canonical_name VARCHAR(200) NOT NULL,              -- 제조사 표기 원형
    release_year   SMALLINT UNSIGNED NULL,
    PRIMARY KEY (part_id),
    UNIQUE KEY uk_part (manufacturer, model_name)
) ENGINE=InnoDB;

CREATE TABLE cpu_spec (
    part_id         INT UNSIGNED NOT NULL,
    socket          VARCHAR(20)  NOT NULL,             -- 'AM4', 'AM5', 'LGA1700', ...
    core_count      SMALLINT UNSIGNED NOT NULL,
    thread_count    SMALLINT UNSIGNED NULL,            -- 구형 모델 일부 미공개
    base_clock_mhz  INT UNSIGNED NULL,
    boost_clock_mhz INT UNSIGNED NULL,
    tdp_watt        SMALLINT UNSIGNED NULL,
    has_igpu        BOOLEAN NULL,                      -- NULL = 원본에 정보 없음
    PRIMARY KEY (part_id),
    CONSTRAINT fk_cpu_spec_part FOREIGN KEY (part_id) REFERENCES part (part_id)
) ENGINE=InnoDB;

-- GPU 칩셋(설계). 실물 카드(part)와 분리 — 같은 칩셋의 제조사별 카드가 N개 존재.
CREATE TABLE gpu_chipset (
    chipset_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    chip_maker   VARCHAR(50)  NOT NULL,                -- 'NVIDIA', 'AMD', 'Intel'
    chipset_name VARCHAR(100) NOT NULL,                -- 'GeForce RTX 4070', ...
    vram_gb      SMALLINT UNSIGNED NULL,
    PRIMARY KEY (chipset_id),
    UNIQUE KEY uk_gpu_chipset (chip_maker, chipset_name)
) ENGINE=InnoDB;

-- 실물 GPU 상품 스펙 (part 1:1)
CREATE TABLE gpu_spec (
    part_id             INT UNSIGNED NOT NULL,
    chipset_id          INT UNSIGNED NOT NULL,
    length_mm           SMALLINT UNSIGNED NULL,
    slot_thickness      DECIMAL(3,1) NULL,             -- 2.0, 2.5, 3.0 슬롯
    recommended_psu_watt SMALLINT UNSIGNED NULL,
    power_connector     VARCHAR(50) NULL,              -- '8-pin x2', '12VHPWR', ...
    PRIMARY KEY (part_id),
    CONSTRAINT fk_gpu_spec_part FOREIGN KEY (part_id) REFERENCES part (part_id),
    CONSTRAINT fk_gpu_spec_chipset FOREIGN KEY (chipset_id) REFERENCES gpu_chipset (chipset_id)
) ENGINE=InnoDB;
