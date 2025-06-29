# ✨ 사칙연산 게임 앱 – 회원 시스템 및 오답노트 기획서

---

## 📌 1. 서비스 개요

사칙연산 게임 앱은 유치원생부터 초등학교 3학년까지의 어린이를 대상으로 하며, 다음과 같은 특징을 가집니다:

- 비회원(Guest)도 게임 플레이 가능
- 회원가입 시 추가 기능 제공: 오답노트, 통계, 프로필 설정 등

---

## 👤 2. 사용자 유형 및 흐름

| 사용자 유형 | 설명 |
|-------------|------|
| Guest 사용자 | 가입 없이 사용 가능, 닉네임은 'Guest' 고정, 데이터 저장 없음 |
| 회원 사용자 | 이메일/비밀번호로 가입, 프로필/오답노트/통계 저장 및 조회 가능 |

---

## 🧩 3. 기능 요약

### ✅ Guest 사용자 기능
- 게임 플레이 가능
- 닉네임 변경 불가 (Guest 고정)
- 통계/오답노트 사용 불가

### ✅ 회원 기능 (로그인 후 활성화)
- 이메일/비밀번호로 가입 및 로그인
- 프로필 설정 가능 (닉네임, 아바타)
- 오답 노트 저장 및 복습 기능
- 통계 확인 기능

---

## 🧱 4. 테이블 정의 (ERD 요약)

### users
| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| id | UUID | 사용자 고유 ID (PK) |
| email | VARCHAR(100) | 이메일 주소 (UNIQUE) |
| password | VARCHAR(255) | 비밀번호 해시값 |
| nickname | VARCHAR(50) | 사용자 닉네임 (UNIQUE) |
| avatar | VARCHAR(50) | 아바타 이름 |
| created_at | TIMESTAMP | 생성일 |
| updated_at | TIMESTAMP | 수정일 (트리거로 관리) |

---

### wrong_answers
| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| id | UUID | 오답 고유 ID (PK) |
| user_id | UUID | 사용자 ID (FK) |
| question_text | TEXT | 문제 내용 |
| user_answer | VARCHAR(10) | 사용자의 답 |
| correct_answer | VARCHAR(10) | 정답 |
| operation_type | VARCHAR(20) | 연산 유형 (덧셈, 뺄셈 등) |
| level | INTEGER | 문제 레벨 |
| created_at | TIMESTAMP | 기록된 시점 |

---

### statistics
| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| user_id | UUID | 사용자 ID (PK, FK) |
| total_solved | INTEGER | 총 푼 문제 수 |
| total_correct | INTEGER | 정답 수 |
| average_accuracy | FLOAT | 평균 정답률 (0.0~1.0) |
| favorite_operation | VARCHAR(20) | 자주 푼 연산 유형 |
| average_session_time | FLOAT | 평균 세션 시간 (분 단위) |

---

## 🧾 5. PostgreSQL SQL 생성문

```sql
-- 1. 사용자 테이블
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) UNIQUE,
    avatar VARCHAR(50) DEFAULT 'default',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 자동 updated_at 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- 2. 오답 노트 테이블
CREATE TABLE wrong_answers (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    question_text TEXT NOT NULL,
    user_answer VARCHAR(10) NOT NULL,
    correct_answer VARCHAR(10) NOT NULL,
    operation_type VARCHAR(20),
    level INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- 3. 통계 테이블
CREATE TABLE statistics (
    user_id UUID PRIMARY KEY,
    total_solved INTEGER DEFAULT 0,
    total_correct INTEGER DEFAULT 0,
    average_accuracy FLOAT DEFAULT 0.0,
    favorite_operation VARCHAR(20),
    average_session_time FLOAT DEFAULT 0.0,

    CONSTRAINT fk_stat_user
        FOREIGN KEY(user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);
```

---

## 📌 확장 아이디어 (후속 개발용)
- `game_sessions` 테이블로 학습 시간 트래킹
- `levels` 테이블로 난이도 정책 분리
- `achievements` 테이블로 뱃지/보상 연동

---

## ✅ 문서 버전
- 최종 업데이트: 2025-06-28
- 작성자: ChatGPT + hoseop kim