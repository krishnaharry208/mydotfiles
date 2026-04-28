#!/bin/bash

# ================= CONFIG =================

FONT="JetBrainsMono Nerd Font:style=Medium:size=10"

# Colors (Nord / Tokyo hybrid)
BG_BAR="#00000000"   # Transparent
BG_PILL="#2e3440"
FG_TEXT="#d8dee9"
ACCENT="#88c0d0"
DIM="#4c566a"
RED="#bf616a"

# Geometry
WIDTH=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
HEIGHT=28
TOP_GAP=12

# Padding & shapes
PAD="  "
SEP="  "

START_PILL="%{F$BG_PILL}%{B$BG_PILL}%{F$FG_TEXT}${PAD}"
END_PILL="${PAD}%{B$BG_BAR}%{F$BG_PILL}%{F-}"

# ================ FUNCTIONS ================

get_workspaces() {
    local icons=("" "" "" "" "" "" "" "" "")
    local i=0
    local out=""
    local focused=$(bspc query -D -d focused --names)

    for d in $(bspc query -D --names); do
        if [ "$d" = "$focused" ]; then
            out+="%{F$ACCENT}${icons[$i]}%{F-} "
        else
            out+="%{F$DIM}${icons[$i]}%{F-} "
        fi
        ((i++))
    done

    echo "$START_PILL${out% }$END_PILL"
}

get_window_title() {
    title=$(xtitle 2>/dev/null)
    [ -z "$title" ] && title="Desktop"
    echo "$START_PILL $title $END_PILL"
}

get_right() {
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -Po '[0-9]+(?=%)' | head -1)
    TIME=$(date "+%I:%M %p")

    echo "$START_PILL%{F$ACCENT}%{F-}$END_PILL$SEP\
$START_PILL ETH $END_PILL$SEP\
$START_PILL%{F$ACCENT}%{F-} $TIME$END_PILL"
}

# ================ MAIN LOOP ================

while true; do
    LEFT="$(get_workspaces)$SEP$START_PILL%{F$ACCENT}%{F-}$END_PILL"
    CENTER="$(get_window_title)"
    RIGHT="$(get_right)"

    echo "%{l} $LEFT %{c}$CENTER %{r}$RIGHT "

    # instant refresh on bspwm events, fallback every 5s
    read -t 5 -n 1 < <(bspc subscribe report)
done | lemonbar \
    -p \
    -g "${WIDTH}x${HEIGHT}+0+${TOP_GAP}" \
    -B "$BG_BAR" \
    -F "$FG_TEXT" \
    -f "$FONT" \
    -u 2 | sh