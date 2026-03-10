# 🟥 Color Trap

A fast-paced hyper-casual mobile game built with Flutter + Flame engine.
Rotate the box. Match the color. Stay alive.

---

## 🎮 Gameplay

A colored ball drops from the top of the screen toward a rotating box.
The box has 4 sides — each a different color: 🔴 Red, 🟢 Green, 🔵 Blue, 🟡 Yellow.

**Your job:** rotate the box so the TOP side matches the falling ball's color before it lands.

- ✅ Match → ball bounces, score +1, ball changes color
- ❌ Mismatch → explosion, game over

Simple to learn. Impossible to master.

---

## 🕹️ Controls

| Action | Control |
|--------|---------|
| Rotate box left | Tap LEFT side of screen |
| Rotate box right | Tap RIGHT side of screen |

---

## 📸 Screenshots

> Coming soon

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio or VS Code

### Installation
```bash
git clone https://github.com/yourusername/color_trap.git
cd color_trap
flutter pub get
flutter run
```

---

## 🏗️ Project Structure
```
lib/
├── main.dart
├── game/
│   ├── color_tap_game.dart    # Game loop, state machine, collision
│   ├── ball.dart              # Ball physics and rendering
│   ├── color_box.dart         # Rotating box, side colors, animation
│   └── particle_effect.dart   # Hit and death particle bursts
├── screens/
│   ├── home_screen.dart       # Home UI
│   └── game_screen.dart       # Game host, HUD, overlays
├── widgets/
│   ├── score_hud.dart         # In-game score display
│   └── game_over_overlay.dart # Game over card
└── utils/
    ├── constants.dart         # Physics, colors, sizing
    ├── score_manager.dart     # Best score persistence
    └── ad_manager.dart        # Ad stub
```

---

## ⚙️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Flame](https://flame-engine.org/) - 2D game engine
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Local score storage

---

## 🎯 Game Constants

| Setting | Value |
|---------|-------|
| Gravity | 900.0 |
| Bounce velocity | -550.0 |
| Ball radius | 28px |
| Box size | 120x120px |
| Rotation speed | 150ms |
| Bounce cooldown | 0.25s |

---

## 📈 Roadmap

- [ ] Sound effects and background music
- [ ] Increasing difficulty over time
- [ ] Online leaderboard
- [ ] Daily challenge mode
- [ ] Unlockable ball skins

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👨‍💻 Author

Built with ❤️ using Flutter + Flame

