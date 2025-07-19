# 🦄 Mathicorn - Fun Math Practice App

A fun arithmetic practice Flutter app for elementary students, featuring the Mathicorn mascot with beautiful glassmorphism design and Supabase integration!

## ✨ Key Features

### 🎮 Game Features
- **Four Operations Practice**: Addition, subtraction, multiplication, division
- **12-Level System**: Gradually increasing difficulty levels
- **Problem Count Selection**: Choose from 5 to 20 problems
- **Real-time Feedback**: Instant correct/incorrect feedback with animations
- **Wrong Answer Notes**: Review incorrect problems

### 🏆 Reward System
- **Sticker Collection**: Earn level-specific stickers for perfect scores (100 points)
- **Scoring System**: Total score and accuracy rate display
- **Progress Tracking**: Real-time game progress monitoring
- **Skeleton Loading**: Beautiful loading screen during data saving

### 👤 User Management
- **Supabase Authentication**: Secure login/signup
- **Profile Settings**: Name and grade configuration
- **Learning Statistics**: View total problems, scores, and accuracy rates
- **Sticker Gallery**: Browse collected stickers
- **Cloud Synchronization**: Automatic data backup and sync

### ⚙️ Settings Features
- **Sound Settings**: Toggle sound effects on/off
- **Voice Guidance**: Problem reading functionality
- **Language Settings**: Korean/English support
- **Theme**: Beautiful gradient with Unicorn theme

### 🎨 UI/UX Improvements
- **Glassmorphism Design**: Modern translucent effects
- **Smooth Animations**: Applied to all transitions and interactions
- **Responsive Layout**: Support for various screen sizes
- **Accessibility**: Interface designed for all users

## 🚀 Installation and Setup

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Dart SDK 3.2.0 or higher
- Supabase project setup

### Installation Steps

1. **Clone Repository**
```bash
git clone https://github.com/your-username/funny-calc.git
cd funny-calc
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Supabase Setup**
   - Create Supabase project
   - Configure environment variables (`.env` file)
   - Set up database schema

4. **Run App**
```bash
flutter run
```

## 📱 Screen Structure

### 1. Home Screen
- App main screen
- Game start, profile, statistics menus
- User information display
- Recent learning status

### 2. Game Setup Screen
- Problem count selection (5-20 problems)
- Level selection (1-12 levels)
- Operation type selection (addition, subtraction, multiplication, division)
- Game start button

### 3. Game Screen
- Problem display
- 4 multiple choice options
- Progress and score display
- Real-time feedback and animations
- Congratulations messages and sound effects

### 4. Result Screen
- **Skeleton Loading**: Beautiful loading screen during data saving
- Final score and accuracy rate
- Time taken display
- Reward sticker acquisition (for 100 points)
- Next level/Home buttons
- Score-specific custom messages

### 5. Profile Screen
- User information editing
- Learning statistics review
- Collected stickers viewing
- Cloud synchronization status

### 6. Settings Screen
- Sound/voice settings
- Language settings
- Data reset
- Logout

### 7. Sticker Gallery
- View all collected stickers
- Sticker details
- Collection rate display

### 8. Wrong Answer Notes
- Review incorrect problems
- Check correct answers
- Learning progress

## 🛠️ Tech Stack

- **Framework**: Flutter 3.16+
- **State Management**: Provider
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Local Storage**: SharedPreferences
- **Animations**: Flutter Animate, Lottie
- **Audio**: AudioPlayers
- **UI Design**: Glassmorphism, Unicorn Theme

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── math_problem.dart     # Math problem model
│   ├── statistics.dart       # Statistics data model
│   ├── user_profile.dart     # User profile model
│   ├── user_settings.dart    # User settings model
│   └── wrong_answer.dart     # Wrong answer data model
├── providers/                # State management
│   ├── auth_provider.dart        # Supabase authentication management
│   ├── game_provider.dart        # Game state management
│   ├── settings_provider.dart    # Settings state management
│   ├── statistics_provider.dart  # Statistics state management
│   └── wrong_note_provider.dart  # Wrong note state management
├── screens/                  # Screens
│   ├── auth_screen.dart          # Login/signup screen
│   ├── gallery_screen.dart       # Sticker gallery
│   ├── game_screen.dart          # Game screen
│   ├── game_setup_screen.dart    # Game setup screen
│   ├── home_screen.dart          # Home screen
│   ├── main_shell.dart           # Main shell (navigation)
│   ├── profile_screen.dart       # Profile screen
│   ├── result_screen.dart        # Result screen (with skeleton)
│   ├── settings_screen.dart      # Settings screen
│   ├── statistics_screen.dart    # Statistics screen
│   └── wrong_note_screen.dart    # Wrong note screen
├── widgets/                  # Reusable widgets
│   └── login_required_dialog.dart # Login required dialog
└── utils/                    # Utility functions
    └── unicorn_theme.dart    # Unicorn theme and design system
```

## 🎨 Design System

### Unicorn Theme
- **Color Palette**: Purple gradient (#8B5CF6 → #D946EF → #EC4899)
- **Glassmorphism**: Translucent effects and blur processing
- **Animations**: Smooth transitions and interactions
- **Typography**: High readability fonts with shadow effects

### Key Design Elements
- **Card Design**: Rounded corners and shadows
- **Button Styles**: Gradients and hover effects
- **Icons**: Consistent icon system style
- **Loading**: Skeleton and shimmer effects

## 🔧 Development Environment Setup

### VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Supabase

### Android Studio Setup
- Install Flutter plugin
- Configure Android emulator
- Install Supabase CLI

## 📊 Data Management

### Supabase Integration
- **Authentication**: Email/password login
- **Database**: PostgreSQL-based user data storage
- **Real-time Sync**: Automatic cloud data synchronization
- **Security**: Row Level Security (RLS) implementation

### Local Storage
- App settings
- Temporary game data
- Offline support

## 🚀 Latest Updates

### v2.0.0 (2024)
- ✅ **Supabase Integration**: Cloud authentication and data synchronization
- ✅ **Skeleton Loading**: Beautiful loading screen implementation
- ✅ **12-Level System**: Progressive difficulty increase
- ✅ **Wrong Answer Notes**: Incorrect problem review feature
- ✅ **Glassmorphism UI**: Modern design system
- ✅ **Performance Optimization**: Animation and loading speed improvements
- ✅ **Accessibility Improvements**: UI/UX for all users

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is distributed under the MIT License. See the `LICENSE` file for details.

## 👨‍💻 Developers

- **Developer**: Mathicorn Team
- **Email**: contact@mathicorn.com
- **Project Link**: https://github.com/your-username/funny-calc

## 🙏 Acknowledgments

This project was made possible with the help of the Flutter community, Supabase team, and open-source projects.

---

⭐ If this project helped you, please give it a star!

🦄 **Mathicorn** - Making math fun and magical! ✨ 