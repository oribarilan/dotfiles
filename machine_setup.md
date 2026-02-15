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
9. [HyperKey](https://hyperkey.app/) — Caps Lock acts as Escape on tap, Hyper (Ctrl+Opt+Cmd) on hold. See also: `keyd` for the Linux equivalent.
10. [DisplayLink](https://www.displaylink.com/downloads/macos) for external monitor issues
11. **Keyboard Shortcuts**
    - System Preferences → Keyboard → Keyboard Shortcuts → Keyboard → "Move focus to the next window"
    - Set shortcut (e.g., hyper + 'a') for alternating between windows of the same app

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

### Development

1. Install [Homebrew](https://brew.sh)
2. **IDE**:
   - **nvim** (set up via dotfiles)
     - Set up nvim as an app:
       1. Follow instructions in `/misc/nvim_automator.sh` to create an Automator app that launches nvim in terminal
       2. Set `/misc/neovim-hicontrast.icns` as the icon (Get Info → Highlight small icon → Paste .icns file)
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
3. Lazygit (alternative: GitHub Desktop)

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

## Linux (Ubuntu)

### Prerequisites

```bash
sudo apt install gcc make git wget zsh fzf zoxide direnv fd-find xclip
```

### Clone Dotfiles

```bash
git clone https://github.com/oribarilan/dotfiles.git ~/.dotfiles
# Create compatibility symlink (many configs reference ~/.config/dotfiles/)
ln -s ~/.dotfiles ~/.config/dotfiles
```

### Hyper Key — [keyd](https://github.com/rvaiya/keyd)

Caps Lock acts as Escape on tap, Hyper (Meta/Super) on hold. This is the Linux equivalent of [HyperKey](https://hyperkey.app/) on macOS.

1. Install keyd from source:
   ```bash
   git clone https://github.com/rvaiya/keyd
   cd keyd
   make && sudo make install
   sudo systemctl enable keyd
   ```
2. Symlink the config from dotfiles:
   ```bash
   sudo ln -sf ~/.dotfiles/keyd/default.conf /etc/keyd/default.conf
   ```
3. Start/restart the daemon:
   ```bash
   sudo systemctl restart keyd
   ```

The config maps:
- **Caps Lock tap** → Escape
- **Caps Lock hold** → Hyper (Meta/Super modifier)

**Note**: keyd's `command()` cannot launch GUI apps (it runs as root via systemd without access to the user's graphical session). To bind Hyper+key to app actions, keyd emits `Super+key` and GNOME handles the rest via custom shortcuts + a GNOME Shell extension.

#### Focus-or-Launch (GNOME Shell Extension)

On GNOME Wayland, external tools (`wmctrl`, `xdotool`) cannot see or focus Wayland-native windows. GNOME Shell's built-in `FocusApp` D-Bus method is permission-locked. The solution is a small GNOME Shell extension (`focus-or-launch@dotfiles`) that runs *inside* the shell process and can directly call `activate_with_focus()` on window objects.

The extension lives in `keyd/gnome-extension/` and exposes a D-Bus method that the `keyd/scripts/focus-or-launch` script calls.

1. Symlink the extension into GNOME's extensions directory:
   ```bash
   ln -s ~/.dotfiles/keyd/gnome-extension \
     ~/.local/share/gnome-shell/extensions/focus-or-launch@dotfiles
   ```

2. Log out and back in (GNOME only discovers new extensions at startup).

3. Enable the extension:
   ```bash
   gnome-extensions enable focus-or-launch@dotfiles
   ```

#### GNOME Hotkeys

Hyper+key bindings use `focus-or-launch` to focus an existing app window or launch it if not running. Set up via Settings → Keyboard → Custom Shortcuts, or via CLI:

```bash
# Register all custom keybindings
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
    '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

# Hyper+T → Focus/Launch Ghostty
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
  name 'Open Ghostty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
  command '/home/ori/.dotfiles/keyd/scripts/focus-or-launch com.mitchellh.ghostty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
  binding '<Super>t'

# Hyper+B → Focus/Launch Firefox
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ \
  name 'Open Firefox'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ \
  command '/home/ori/.dotfiles/keyd/scripts/focus-or-launch firefox_firefox'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ \
  binding '<Super>b'

# Hyper+A → Switch between windows of the same application
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>a']"
```

To add a new Hyper+key binding for another app:
1. Find the app's desktop file ID: `ls /usr/share/applications/ /var/lib/snapd/desktop/applications/ | grep <app>`
2. Add a new `custom<N>` entry following the pattern above, using `focus-or-launch <desktop-id>`
3. Register it in the `custom-keybindings` array

### Shell (zsh)

1. Set zsh as default shell:
   ```bash
   chsh -s $(which zsh)
   ```
   Log out and back in for this to take effect.

2. Install zinit (plugin manager):
   ```bash
   git clone https://github.com/zdharma-continuum/zinit.git \
     "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
   ```

3. Install powerlevel10k:
   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
     ~/.local/share/powerlevel10k
   ```

4. The dotfiles zsh config assumes Homebrew paths (macOS). On Linux, `~/.zshrc` needs
   to shim these paths before sourcing the dotfiles config. See the `.zshrc` created below.

5. Set up `~/.zshrc` — this acts as a Linux override layer:
   ```zsh
   # Fake HOMEBREW_PREFIX so theme.zsh/plugins.zsh paths resolve on Linux
   export HOMEBREW_PREFIX="$HOME/.local/share/homebrew-shim"
   mkdir -p "$HOMEBREW_PREFIX/share/powerlevel10k" 2>/dev/null
   mkdir -p "$HOMEBREW_PREFIX/opt/fzf/shell" 2>/dev/null

   # Symlink powerlevel10k and fzf to where the dotfiles config expects them
   [[ ! -e "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
     ln -sf "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme" \
            "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
   [[ ! -e "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && \
     ln -sf /usr/share/doc/fzf/examples/key-bindings.zsh \
            "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"

   # Linux-specific overrides
   alias pbcopy='xclip -selection clipboard'
   export PATH="$HOME/.local/bin:$PATH"
   command -v fd >/dev/null 2>&1 || alias fd='fdfind'

   # Source the actual dotfiles config
   source "$HOME/.dotfiles/zsh/oribi.zsh"
   ```

6. On first launch, powerlevel10k will prompt for configuration. Choose Unicode.

### Neovim

1. Download the latest AppImage:
   ```bash
   mkdir -p ~/.local/bin
   wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
     -O ~/.local/bin/nvim
   chmod +x ~/.local/bin/nvim
   ```
   Ensure `~/.local/bin` is in PATH (the `.zshrc` above handles this).

2. Symlink the config:
   ```bash
   ln -s ~/.dotfiles/nvim ~/.config/nvim
   ```

### tmux

1. Install TPM (plugin manager):
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. Create `~/.tmux.conf`:
   ```
   source-file ~/.dotfiles/tmux/.tmux.conf
   ```

3. Open tmux and install plugins: press `Ctrl-a + I`
   - If plugins don't install, run manually: `~/.tmux/plugins/tpm/bin/install_plugins`

### Clipboard History — [Clipboard History Extension](https://github.com/SUPERCILEX/gnome-clipboard-history)

On GNOME Wayland, standalone clipboard managers (CopyQ, cliphist, etc.) cannot access the clipboard — only GNOME Shell extensions running inside the shell process can. The **Clipboard History** extension provides searchable clipboard history natively.

1. Install from source (or use Extension Manager: `sudo apt install gnome-shell-extension-manager`):
   ```bash
   git clone https://github.com/SUPERCILEX/gnome-clipboard-history.git \
     ~/.local/share/gnome-shell/extensions/clipboard-history@alexsaveau.dev
   glib-compile-schemas \
     ~/.local/share/gnome-shell/extensions/clipboard-history@alexsaveau.dev/schemas/
   ```

2. Log out and back in (GNOME only discovers new extensions at startup on Wayland).

3. Enable the extension:
   ```bash
   gnome-extensions enable clipboard-history@alexsaveau.dev
   ```

4. Free `Super+V` from GNOME's notification tray and remap to clipboard history:
   ```bash
   # Remove Super+V from notification tray (keep Super+M)
   gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"

   # Set Hyper+V to open clipboard history
   gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-history@alexsaveau.dev/schemas/ \
     set org.gnome.shell.extensions.clipboard-history toggle-menu "['<Super>v']"
   ```

Useful shortcuts while the panel is open: `/` to search, `F` to favorite, `Ctrl+1-9` to select Nth entry.

### Ghostty

See the ghostty section in README.md — in your ghostty config file (`~/.config/ghostty/config`):

```ini
config-file = "/home/ori/.dotfiles/ghostty/config"
```
