# 🦄 Mathicorn - Fun Math Practice App

A fun arithmetic practice Flutter app for elementary students, now featuring the Mathicorn mascot!

## ✨ 주요 기능

### 🎮 게임 기능
- **사칙연산 연습**: 덧셈, 뺄셈, 곱셈, 나눗셈
- **난이도 조절**: 학년별 맞춤 문제 출제
- **문제 수 선택**: 5~20문제까지 선택 가능
- **실시간 피드백**: 정답/오답 즉시 확인

### 🏆 보상 시스템
- **스티커 수집**: 문제를 풀면 스티커 획득
- **점수 시스템**: 총점과 정답률 표시
- **진행률 표시**: 게임 진행 상황 확인

### 👤 사용자 관리
- **프로필 설정**: 이름과 학년 설정
- **학습 통계**: 총 문제 수, 점수, 정답률 확인
- **스티커 갤러리**: 수집한 스티커 모아보기

### ⚙️ 설정 기능
- **사운드 설정**: 효과음 ON/OFF
- **음성 안내**: 문제 읽어주기 기능
- **다크 모드**: 어두운 테마 지원
- **언어 설정**: 한국어/영어 지원

## 🚀 설치 및 실행

### 필수 요구사항
- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상

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

3. **앱 실행**
```bash
flutter run
```

## 📱 화면 구성

### 1. 홈 화면
- 앱 메인 화면
- 게임 시작, 프로필, 통계 메뉴
- 사용자 정보 표시

### 2. 게임 설정 화면
- 문제 수 선택 (5~20문제)
- 연산 종류 선택 (덧셈, 뺄셈, 곱셈, 나눗셈)
- 게임 시작 버튼

### 3. 게임 화면
- 문제 표시
- 4개 선택지 제공
- 진행률 및 점수 표시
- 실시간 피드백

### 4. 결과 화면
- 최종 점수 및 정답률
- 소요 시간 표시
- 보상 스티커 획득
- 다시 도전/홈으로 버튼

### 5. 프로필 화면
- 사용자 정보 편집
- 학습 통계 확인
- 수집한 스티커 보기

### 6. 설정 화면
- 사운드/음성 설정
- 다크 모드 설정
- 언어 설정
- 데이터 초기화

### 7. 스티커 갤러리
- 수집한 스티커 전체 보기
- 스티커 상세 정보

## 🛠️ 기술 스택

- **프레임워크**: Flutter
- **상태 관리**: Provider
- **로컬 저장소**: SharedPreferences
- **백엔드**: Supabase
- **애니메이션**: Flutter Animate
- **오디오**: AudioPlayers

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── math_problem.dart     # 수학 문제 모델
│   ├── statistics.dart       # 통계 데이터 모델
│   ├── user_profile.dart     # 사용자 프로필 모델
│   └── wrong_answer.dart     # 오답 데이터 모델
├── providers/                # 상태 관리
│   ├── auth_provider.dart        # 인증 상태 관리
│   ├── game_provider.dart        # 게임 상태 관리
│   ├── settings_provider.dart    # 설정 상태 관리
│   ├── statistics_provider.dart  # 통계 상태 관리
│   └── wrong_note_provider.dart  # 오답노트 상태 관리
├── screens/                  # 화면
│   ├── auth_screen.dart          # 인증 화면
│   ├── gallery_screen.dart       # 스티커 갤러리
│   ├── game_screen.dart          # 게임 화면
│   ├── game_setup_screen.dart    # 게임 설정 화면
│   ├── home_screen.dart          # 홈 화면
│   ├── main_shell.dart           # 메인 쉘(네비게이션)
│   ├── profile_screen.dart       # 프로필 화면
│   ├── result_screen.dart        # 결과 화면
│   ├── settings_screen.dart      # 설정 화면
│   ├── statistics_screen.dart    # 통계 화면
│   └── wrong_note_screen.dart    # 오답노트 화면
├── widgets/                  # 재사용 가능한 위젯
│   └── login_required_dialog.dart # 로그인 필요 다이얼로그
└── utils/                    # 유틸리티 함수
```

## 🎨 디자인 특징

- **친근한 UI**: 아이들이 좋아할 만한 밝고 경쾌한 색상
- **직관적인 UX**: 쉽고 간단한 조작
- **애니메이션**: 부드러운 전환 효과
- **반응형 디자인**: 다양한 화면 크기 지원

## 🔧 개발 환경 설정

### VS Code 확장 프로그램
- Flutter
- Dart
- Flutter Widget Snippets

### Android Studio 설정
- Flutter 플러그인 설치
- Android 에뮬레이터 설정

## 📊 데이터 저장

앱은 로컬 저장소를 사용하여 다음 데이터를 저장합니다:
- 사용자 프로필 정보
- 학습 통계
- 수집한 스티커
- 앱 설정

## 🚀 향후 개발 계획

- [X] 레벨 기능
- [X] 오답 노트 기능
- [X] 보상 시스템


## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 👨‍💻 개발자

- **개발자**: Funny Calc Team
- **이메일**: contact@funnycalc.com
- **프로젝트 링크**: https://github.com/your-username/funny-calc

## 🙏 감사의 말

이 프로젝트는 Flutter 커뮤니티와 오픈소스 프로젝트들의 도움으로 만들어졌습니다.

---

⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요! 