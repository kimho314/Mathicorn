# 🦄 Mathicorn - Fun Math Practice App

A fun arithmetic practice Flutter app for elementary students, featuring the Mathicorn mascot with beautiful glassmorphism design and Supabase integration!

## ✨ 주요 기능

### 🎮 게임 기능
- **사칙연산 연습**: 덧셈, 뺄셈, 곱셈, 나눗셈
- **12단계 레벨 시스템**: 점진적으로 어려워지는 난이도
- **문제 수 선택**: 5~20문제까지 선택 가능
- **실시간 피드백**: 정답/오답 즉시 확인 및 애니메이션
- **오답 노트**: 틀린 문제 복습 기능

### 🏆 보상 시스템
- **스티커 수집**: 100점 달성 시 레벨별 스티커 획득
- **점수 시스템**: 총점과 정답률 표시
- **진행률 표시**: 게임 진행 상황 실시간 확인
- **스켈레톤 로딩**: 데이터 저장 중 아름다운 로딩 화면

### 👤 사용자 관리
- **Supabase 인증**: 안전한 로그인/회원가입
- **프로필 설정**: 이름과 학년 설정
- **학습 통계**: 총 문제 수, 점수, 정답률 확인
- **스티커 갤러리**: 수집한 스티커 모아보기
- **클라우드 동기화**: 데이터 자동 백업 및 동기화

### ⚙️ 설정 기능
- **사운드 설정**: 효과음 ON/OFF
- **음성 안내**: 문제 읽어주기 기능
- **언어 설정**: 한국어/영어 지원
- **테마**: Unicorn 테마의 아름다운 그라데이션

### 🎨 UI/UX 개선사항
- **Glassmorphism 디자인**: 현대적인 반투명 효과
- **부드러운 애니메이션**: 모든 전환과 상호작용에 애니메이션 적용
- **반응형 레이아웃**: 다양한 화면 크기 지원
- **접근성**: 모든 사용자가 쉽게 사용할 수 있는 인터페이스

## 🚀 설치 및 실행

### 필수 요구사항
- Flutter SDK 3.16.0 이상
- Dart SDK 3.2.0 이상
- Supabase 프로젝트 설정

### 설치 방법

1. **저장소 클론**
```bash
git clone https://github.com/your-username/funny-calc.git
cd funny-calc
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **Supabase 설정**
   - Supabase 프로젝트 생성
   - 환경 변수 설정 (`.env` 파일)
   - 데이터베이스 스키마 설정

4. **앱 실행**
```bash
flutter run
```

## 📱 화면 구성

### 1. 홈 화면
- 앱 메인 화면
- 게임 시작, 프로필, 통계 메뉴
- 사용자 정보 표시
- 최근 학습 현황

### 2. 게임 설정 화면
- 문제 수 선택 (5~20문제)
- 레벨 선택 (1~12단계)
- 연산 종류 선택 (덧셈, 뺄셈, 곱셈, 나눗셈)
- 게임 시작 버튼

### 3. 게임 화면
- 문제 표시
- 4개 선택지 제공
- 진행률 및 점수 표시
- 실시간 피드백 및 애니메이션
- 축하 메시지 및 효과음

### 4. 결과 화면
- **스켈레톤 로딩**: 데이터 저장 중 아름다운 로딩 화면
- 최종 점수 및 정답률
- 소요 시간 표시
- 보상 스티커 획득 (100점 시)
- 다음 레벨/홈으로 버튼
- 점수별 맞춤 메시지

### 5. 프로필 화면
- 사용자 정보 편집
- 학습 통계 확인
- 수집한 스티커 보기
- 클라우드 동기화 상태

### 6. 설정 화면
- 사운드/음성 설정
- 언어 설정
- 데이터 초기화
- 로그아웃

### 7. 스티커 갤러리
- 수집한 스티커 전체 보기
- 스티커 상세 정보
- 수집률 표시

### 8. 오답 노트
- 틀린 문제 복습
- 정답 확인
- 학습 진행률

## 🛠️ 기술 스택

- **프레임워크**: Flutter 3.16+
- **상태 관리**: Provider
- **백엔드**: Supabase (PostgreSQL, Auth, Storage)
- **로컬 저장소**: SharedPreferences
- **애니메이션**: Flutter Animate, Lottie
- **오디오**: AudioPlayers
- **UI 디자인**: Glassmorphism, Unicorn Theme

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── math_problem.dart     # 수학 문제 모델
│   ├── statistics.dart       # 통계 데이터 모델
│   ├── user_profile.dart     # 사용자 프로필 모델
│   ├── user_settings.dart    # 사용자 설정 모델
│   └── wrong_answer.dart     # 오답 데이터 모델
├── providers/                # 상태 관리
│   ├── auth_provider.dart        # Supabase 인증 관리
│   ├── game_provider.dart        # 게임 상태 관리
│   ├── settings_provider.dart    # 설정 상태 관리
│   ├── statistics_provider.dart  # 통계 상태 관리
│   └── wrong_note_provider.dart  # 오답노트 상태 관리
├── screens/                  # 화면
│   ├── auth_screen.dart          # 로그인/회원가입 화면
│   ├── gallery_screen.dart       # 스티커 갤러리
│   ├── game_screen.dart          # 게임 화면
│   ├── game_setup_screen.dart    # 게임 설정 화면
│   ├── home_screen.dart          # 홈 화면
│   ├── main_shell.dart           # 메인 쉘(네비게이션)
│   ├── profile_screen.dart       # 프로필 화면
│   ├── result_screen.dart        # 결과 화면 (스켈레톤 포함)
│   ├── settings_screen.dart      # 설정 화면
│   ├── statistics_screen.dart    # 통계 화면
│   └── wrong_note_screen.dart    # 오답노트 화면
├── widgets/                  # 재사용 가능한 위젯
│   └── login_required_dialog.dart # 로그인 필요 다이얼로그
└── utils/                    # 유틸리티 함수
    └── unicorn_theme.dart    # Unicorn 테마 및 디자인 시스템
```

## 🎨 디자인 시스템

### Unicorn Theme
- **색상 팔레트**: 보라색 그라데이션 (#8B5CF6 → #D946EF → #EC4899)
- **Glassmorphism**: 반투명 효과와 블러 처리
- **애니메이션**: 부드러운 전환과 상호작용
- **타이포그래피**: 가독성 높은 폰트와 그림자 효과

### 주요 디자인 요소
- **카드 디자인**: 둥근 모서리와 그림자
- **버튼 스타일**: 그라데이션과 호버 효과
- **아이콘**: 일관된 스타일의 아이콘 시스템
- **로딩**: 스켈레톤과 shimmer 효과

## 🔧 개발 환경 설정

### VS Code 확장 프로그램
- Flutter
- Dart
- Flutter Widget Snippets
- Supabase

### Android Studio 설정
- Flutter 플러그인 설치
- Android 에뮬레이터 설정
- Supabase CLI 설치

## 📊 데이터 관리

### Supabase 통합
- **인증**: 이메일/비밀번호 로그인
- **데이터베이스**: PostgreSQL 기반 사용자 데이터 저장
- **실시간 동기화**: 클라우드 데이터 자동 동기화
- **보안**: Row Level Security (RLS) 적용

### 로컬 저장소
- 앱 설정
- 임시 게임 데이터
- 오프라인 지원

## 🚀 최신 업데이트

### v2.0.0 (2024)
- ✅ **Supabase 통합**: 클라우드 인증 및 데이터 동기화
- ✅ **스켈레톤 로딩**: 아름다운 로딩 화면 구현
- ✅ **12단계 레벨 시스템**: 점진적 난이도 증가
- ✅ **오답 노트**: 틀린 문제 복습 기능
- ✅ **Glassmorphism UI**: 현대적인 디자인 시스템
- ✅ **성능 최적화**: 애니메이션 및 로딩 속도 개선
- ✅ **접근성 개선**: 모든 사용자를 위한 UI/UX

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 👨‍💻 개발자

- **개발자**: Mathicorn Team
- **이메일**: contact@mathicorn.com
- **프로젝트 링크**: https://github.com/your-username/funny-calc

## 🙏 감사의 말

이 프로젝트는 Flutter 커뮤니티, Supabase 팀, 그리고 오픈소스 프로젝트들의 도움으로 만들어졌습니다.

---

⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요! 

🦄 **Mathicorn** - Making math fun and magical! ✨ 