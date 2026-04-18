#!/usr/bin/env bash
# Right side of the sessionbar: git branch + CPU/memory/disk usage.
# Called via #() on status-interval (polled for resource data).
#
# Catppuccin mocha palette:
#   mantle=#181825  surface_0=#313244  overlay_0=#6c7086
#   lavender=#b4befe  green=#a6e3a1  yellow=#f9e2af  red=#f38ba8  peach=#fab387

# --- Git branch ---
pane_path=$(tmux display-message -p '#{pane_current_path}')
branch=$(git -C "$pane_path" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  printf "#[fg=#313244,bg=#181825]"
  printf "#[fg=#b4befe,bg=#313244]  %s " "$branch"
fi

# --- CPU usage ---
if [[ "$OSTYPE" == darwin* ]]; then
  cpu=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
  cores=$(sysctl -n hw.ncpu)
  cpu_pct=$((cpu / cores))
else
  cpu_pct=$(awk '{printf "%.0f", ($1+$2)*100/($1+$2+$3+$4+$5)}' /proc/stat 2>/dev/null | head -1)
  cpu_pct=${cpu_pct:-0}
fi

# Color based on usage
if [ "$cpu_pct" -ge 90 ]; then
  cpu_color="#f38ba8"  # red
elif [ "$cpu_pct" -ge 70 ]; then
  cpu_color="#fab387"  # peach
else
  cpu_color="#6c7086"  # overlay_0 (subtle)
fi

printf "#[fg=#313244,bg=#181825]"
printf "#[fg=%s,bg=#313244] 󰻠 %s%% " "$cpu_color" "$cpu_pct"

# --- Memory usage ---
if [[ "$OSTYPE" == darwin* ]]; then
  # Match Activity Monitor: Used = (active + speculative + wired + compressed - purgeable)
  mem_used=$(vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
    /^Pages active/                  { active     = +$NF }
    /^Pages speculative/             { spec       = +$NF }
    /^Pages wired down/              { wired      = +$NF }
    /^Pages occupied by compressor/  { compressed = +$NF }
    /^Pages purgeable/               { purgeable  = +$NF }
    END {
      pagesize = '"$(sysctl -n hw.pagesize)"'
      used = (active + spec + wired + compressed - purgeable) * pagesize
      printf "%.0f", used / total * 100
    }
  ')
else
  mem_used=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
fi
mem_used=${mem_used:-0}

if [ "$mem_used" -ge 90 ]; then
  mem_color="#f38ba8"  # red
elif [ "$mem_used" -ge 75 ]; then
  mem_color="#fab387"  # peach
else
  mem_color="#6c7086"  # overlay_0
fi

printf "#[fg=%s,bg=#313244] 󰍛 %s%% " "$mem_color" "$mem_used"

# --- Disk usage ---
disk_pct=$(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
disk_pct=${disk_pct:-0}

if [ "$disk_pct" -ge 90 ]; then
  disk_color="#f38ba8"  # red
elif [ "$disk_pct" -ge 75 ]; then
  disk_color="#fab387"  # peach
else
  disk_color="#6c7086"  # overlay_0
fi

printf "#[fg=%s,bg=#313244] 󰋊 %s%% " "$disk_color" "$disk_pct"
printf "#[fg=#181825,bg=#313244]"
