# Kaomoji Picker

Browse and copy kaomoji (Japanese emoticons) directly to your clipboard.

<img src="screenshot.png" width="500" alt="Screenshot">

## Install

**Required:** This plugin requires [dms-common](https://github.com/hthienloc/dms-common) to be installed.

```bash
# 1. Install shared components
git clone https://github.com/hthienloc/dms-common ~/.config/DankMaterialShell/plugins/dms-common

# 2. Install this plugin
dms plugins install kaomojiPicker
```

Or manually:
```bash
git clone https://github.com/hthienloc/dms-kaomoji-picker ~/.config/DankMaterialShell/plugins/kaomojiPicker
```

## Features

- **3000+ kaomoji** - Comprehensive local database
- **Fuzzy search** - Filter by tags like `happy`, `sad`, `angry`, `bear`
- **Native copy** - One click to clipboard

## Usage

| Action | Result |
|--------|--------|
| Type `:kj` in launcher | Open kaomoji picker |

## License

MIT

## Roadmap / TODO

- [ ] **Categorical Navigation:** UI for browsing emoticons by mood/type (e.g., Happy, Sad, Animals, Action) instead of just searching.
- [ ] **Custom Additions:** Ability to save personal/unique emoticons directly from the UI or settings.
- [ ] **Binary Storage/Indexing:** Migrate from large JSON to a faster indexed format (SQLite or similar) for near-instant search response.
- [ ] **Favorites & Pinning:** Support for permanent favorites that stay at the top regardless of usage frequency.
- [ ] **Direct Injection:** Option to paste the selected kaomoji directly into the active window (requires `ydotool` or similar integration).