# SearchGPT 🔍✨
**AI-Powered Search & Summarization for Mobile**

SearchGPT integrates **Travily AI** for search and **Gemini** (or other LLMs) to generate summaries and cached answers—all in a cross-platform Flutter app.

---

## 📱 Features
- **Travily AI Search**: Fast, accurate search results.
- **LLM Summarization**: Gemini processes results into concise reports.
- **Answer Caching**: Stores LLM-generated answers per `SearchResultItem` for faster reuse.
- **State Management**: Uses **MobX** + **Provider** for reactive UI.
- **Offline Support**: Hive or sembast for caching searches.

---

## 🚀 Setup (Flutter)

### Prerequisites
- Flutter 3.0+
- API Keys: Travily AI, Gemini (or OpenAI)

### Installation
1. Clone the repo:
   ```bash
   git clone https://github.com/yourusername/searchgpt.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate MobX/DI files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Add API keys to `lib/constants/api_constants.dart`:
   ```dart
   const String TRAVILY_API_KEY = 'your_key';
   const String GEMINI_API_KEY = 'your_key';
   ```

---

## � Architecture (Flutter)
```
lib/
├── core/
│   ├── api/               # Travily & Gemini clients
│   ├── models/            # SearchResultItem, Report
│   └── stores/            # MobX stores (SearchStore, SummaryStore)
├── data/
│   ├── cache/             # Hive/sembast for offline
│   └── repository.dart    # Central data handler
├── ui/
│   ├── screens/           # Search, Results, Summary
│   └── widgets/           # Reusable components
└── main.dart              # App entry
```

---

## ⚙️ Key Libraries
- **HTTP**: `dio` (Travily API calls)
- **State**: `mobx` + `provider`
- **Local DB**: `hive` or `sembast`
- **LLM**: `google_generative_ai` (Gemini) or `openai_dart`

---

## 📝 Optimizations Needed?
Let me help with:
1. **Latency**:
   - Pre-cache frequent queries.
   - Use `StreamBuilder` for incremental results.
2. **Prompt Tuning**:
   - Refine Gemini prompts for better summaries.
3. **Offline**:
   - Cache search history with Hive.

---

## 🌟 Upcoming
- [ ] Multi-LLM fallback (e.g., GPT-4o + Gemini).
- [ ] Voice search support.

---

**Star ⭐ the repo if you find it useful!**
Questions? Open an issue or reach out.

---

### Notes:
- Replace `yourusername`, `your_key`, and API libs with your actual details.
- Add screenshots/GIFs in a `assets/` folder if available.
- For web support, see the Flutter boilerplate’s `web` branch.

Let me know if you'd like to emphasize any other aspects! 🚀
