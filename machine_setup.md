# Machine Setup

## Mac

### System Settings

1. Switch to uppercase English with **Shift** (set input source to *Hebrew-PC*)
2. Enable *Tap to Click*
3. Enable *Three-finger Drag* (Accessibility → Pointer Control)
4. Enable *Night Shift*
5. Dock Settings:
   - Disable "Show recent apps"
   - Enable "Auto-hide"
6. Always show scroll bars: *System Preferences → Scroll Bars → Always*
7. Finder:
   - Show full POSIX path:
     ```bash
     defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
     killall Finder
     ```
   - Show folders first:
     ```bash
     defaults write com.apple.finder _FXSortFoldersFirst -bool true
     killall Finder
     ```
   - Enable Path + Status bars (View → Show Path Bar + Show Status Bar)
8. Set `Cmd+Shift+V` → Paste with matching style ([guide](https://superuser.com/a/725127))
9. Hyperkey (Caps Lock → Ctrl+Opt+Cmd)
10. [DisplayLink](https://www.displaylink.com/downloads/macos) for external monitor issues

### Peripherals

1. **Mouse** — Download [LinearMouse](https://linearmouse.org) and set scroll speed
   - Alternative: MacMouseFix
2. **Microsoft Keyboard**
   1. Search "Customize modifier keys"
   2. Select MS keyboard
   3. Swap **CMD** and **Option**
3. **Logi Tune**
   - If peripherals aren't detected → *System Settings → Privacy & Security → Input Monitoring → enable Logi Options Daemon*

### Essential Apps

#### Productivity

1. **Launcher**: [Raycast](https://raycast.com)
   - Alternative: [Alfred](https://www.alfredapp.com/)
     - Activate license
     - Remove hat icon from search bar
     - Hide Spotlight in menu bar
     - Add Stack Search + Timer workflow
     - Grant Full Disk Access (manually add Alfred)
     - Install [Power Thesaurus Workflow](https://github.com/giovannicoppola/alfred-powerthesaurus/releases)

2. **Todo App**: Todoist 
    - Alternatives: TickTick

3. **Obsidian**
   - Should be set up by default. If not:
     1. Editor → enable **Spell Check**
     2. Plugins → **Tag Pane**, **Page Preview**, **Starred**
     3. Files → *Deleted Files → System Trash*
     4. Files → *Always update internal links*
     5. Appearance → select preferred **Theme**

#### Screenshots

- [Shottr](https://shottr.cc) — license in pass-manager
  - Disable diagnostics
  - Enable transparent background
  - Shortcut: `Cmd+Shift+S` for area capture
- Alternatives: [CleanShot X](https://cleanshot.com) *(paid)*, [Xnip](https://xnipapp.com) *(free)*

#### Clipboard Manager

- Built-in Raycast clipboard or [Maccy](https://github.com/p0deje/Maccy)

#### Window Management

- Set up via Raycast (hyper + h/j/k/l, hyper + n, hyper + m)
- **Tiling Manager**: [Aerospace](https://github.com/nikitabobko/AeroSpace)
- **Window Switcher**: [AltTab](https://alt-tab-macos.netlify.app)
   - Appearance → Hide apps with no open windows

#### Menu Bar

1. **Menu Bar Management**: Ice
   - Alternatives: [HiddenBar](https://github.com/dwarvesf/hidden), [Dozer](https://github.com/Mortennn/Dozer), [Vanilla](https://matthewpalmer.net/vanilla/)
2. **Calendar/Meetings**:
   - [Itsycal](https://www.mowglii.com/itsycal/)
   - [MeetingBar](https://meetingbar.app/)
   - Alternatives: In Your Face, [Today](https://sindresorhus.com/today), [Dato](https://sindresorhus.com/dato), [Jump In Meetings](https://apps.apple.com/app/id1506451016), [Up Next](https://upnextapp.com), [Next Meeting](https://apps.apple.com/app/id1017470484), [Calendar 366](https://nspektor.com/en/calendar366/mac)

#### Utilities

1. **Always-On**: [Amphetamine](https://apps.apple.com/app/id937984704)
2. **Timer**: [Smart Countdown Timer](https://apps.apple.com/app/id1492910143)
3. **PDF Tools**: [PDF Gear](https://www.pdfgear.com), [PDFSam Basic](https://pdfsam.org)
4. **F.lux** (screen warmth)
5. **Battery Management**:
   - [BatFi](https://files.micropixels.software/batfi/BatFi-latest.zip) *(open source)*
   - [AlDente](https://apphousekitchen.com) *(paid)* — hide in Alt+Tab
6. **File Drag & Drop**:
   - [Yoink](https://eternalstorms.at/yoink/) (purchased)
   - [Dropover](https://dropoverapp.com)
7. **Focus Mode**: [HazeOver](https://hazeover.com)
8. **App Updater**: [Latest](https://max.codes/latest)
9. **Emoji Picker**: [Rocket](https://matthewpalmer.net/rocket/)
   - Trigger: `::`
10. **Display Management**: [BetterDisplay](https://betterdisplay.pro)
12. **Cleanup Tools**:
    - [OnyX](https://www.titanium-software.fr/en/onyx.html)
    - [AppCleaner](https://freemacsoft.net/appcleaner/)
13. **TinkerTool** → configure Dock
14. **Screenshot**: Flameshot (opensource, via Homebrew)

### Terminal

- **Ghostty**
- Alternatives: WezTerm, Alacritty, Kitty

1. Install [Homebrew](https://brew.sh)
### Development

- **IDE**:
    - nvim (set up via dotfiles)
   - **JetBrains Toolbox**
     - Enable:
       - "Open files with single click"
       - "Always select opened file"
     - Plugins: Key Promoter X, Grep Console
   - **VS Code**
     - Sync settings from dotfiles
     - Theme: *Catppuccin Macchiato*
     - Fonts: *Cascadia Code* or *Fira Code (ligatures on)*
     - Extensions: Git History, Todo Tree, Relative Goto, Settings Sync, Indent Rainbow, GitLens, Code Runner, Error Lens
4. Lazygit (alternative: GitHub Desktop)

### Virtual Machines

- [Parallels](https://www.parallels.com)
  - Alternative: VMware Fusion
- [Windows 11 ISO](https://www.microsoft.com/software-download/windows11)

### Mouseless Tools

1. [Vimium](https://vimium.github.io/) — Vim navigation for browsers
2. [Shortcat](https://shortcat.app)

## Windows

### Productivity

1. **Launcher**: [Ueli](https://ueli.app) / [Wox](https://github.com/Wox-launcher/Wox)
2. **Screenshots**: [Greenshot](https://getgreenshot.org)
3. **Clipboard Manager**: [Ditto](https://ditto-cp.sourceforge.io/)
