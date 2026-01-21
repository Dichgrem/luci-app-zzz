# Changelog

## [2.0.0-2] - 2026-01-21

### Changed

- **Internationalization**: Converted all Chinese strings to English with i18n support
- **Makefile**: Added PKG_NAME for proper package registration

### Added

- **Translation Support**: Added `po/templates/zzz.pot` template file
- **Chinese Translation**: Added `po/zh_Hans/zzz.po` for Chinese localization
- Separate `luci-i18n-zzz-zh-cn` package will be generated during build

## [2.0.0] - Initial Release

### Features

- ZZZ 802.1x authentication client configuration
- Service control (start/stop/restart) via web interface
- Real-time service status display
- Username and password configuration with validation
- Network interface selection
- Scheduled auto-start support (weekdays 7:00 AM)
- Crontab task status display
