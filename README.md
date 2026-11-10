# PhoneLM

A cross-platform AI chat client built with Flutter. Run GGUF models directly on your phone with GPU-accelerated (Vulkan) inference — no internet needed after download — or switch to cloud APIs (OpenAI, Anthropic, Gemini, Kimi) when you want more power.

## What It Does

- **Local on-device inference (Android)** — download and run GGUF models directly on your phone using llama.cpp with Vulkan acceleration. Fully offline afterwards.
- **Cloud API fallback** — one-tap switch to OpenAI, Anthropic Claude, Google Gemini, or Kimi (Moonshot AI).
- **Multimodal chat** — send text and images. Vision works with both local models (Qwen2-VL style GGUF via mtmd) and cloud providers.
- **Image generation** — local Stable Diffusion on-device (tested across Snapdragon, MediaTek, and Tensor devices).
- **Device cluster** — run one GGUF model spread across several phones/tablets on the same Wi-Fi network.
- **Private by default** — chats and settings are stored locally (Hive). Nothing leaves your device unless you explicitly choose cloud mode.
- **Smart auto-configuration** — detects your device RAM on first launch and recommends context size and token limits.
- **In-app updates** — new versions are discovered from GitHub Releases.

## Technical Architecture

### Stack

- **Framework:** Flutter 3.x (Dart >=3.3.0)
- **State management:** GetX
- **Local storage:** Hive
- **Networking:** Dio + `package:http`
- **Background execution:** `flutter_background_service` + `flutter_local_notifications`

### Layers

```
UI (ChatView / ModelView / ClusterView / SettingsView)
        │
Controllers (GetX)
        │
Services (Inference · Cloud · Download · Hive · DeviceInfo · Cluster)
        │
Native plugins (llama.cpp GGUF · Stable Diffusion via FFI)
```

## Building

1. Install Flutter and Android Studio.
2. `flutter pub get`
3. `flutter run` (Android) — or `flutter build apk --release`.

Notes:
- Android builds conditionally apply Firebase only if `android/app/google-services.json` exists; the app runs fine without it.
- Model files (`.gguf`) are downloaded inside the app from Hugging Face or imported from a folder.

## Roadmap

- [ ] Play Store release
- [ ] Polished app icon and store assets
- [ ] Task view for structured multi-step AI workflows
- [ ] iOS App Store build

## License

MIT — see [LICENSE](LICENSE).
