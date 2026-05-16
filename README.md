# Kaomoji Picker

Browse and copy kaomoji (Japanese emoticons) directly to your clipboard.

<img src="screenshot.png" width="500" alt="Screenshot">

## Install

**Required:** This plugin requires [dms-common](https://github.com/hthienloc/dms-common) to be installed.

```bash
# 1. Install shared components
git clone https://github.com/hthienloc/dms-common ~/.config/DankMaterialShell/plugins/dms-common

# 2. Install this plugin
dms://plugin/install/kaomojiPicker
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

- [ ] **Category Browsing**: Add support for browsing kaomoji by categories (e.g., happy, sad, animals) directly in the UI.
- [ ] **Custom Kaomoji**: Allow users to add and manage their own custom kaomoji through the settings.
- [ ] **Performance Optimization**: Optimize database loading for large `database.json` files to reduce initial startup time.
- [ ] **Favorites System**: Explicitly mark kaomoji as favorites to pin them to the top of the list independently of usage history.