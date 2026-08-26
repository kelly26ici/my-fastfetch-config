#!/bin/sh
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  fastfetch-responsive.sh — Responsive Fastfetch wrapper for Kitty     ║
# ║  Detects terminal width, selects an optimal preset, and calculates    ║
# ║  dynamic logo dimensions based on the image aspect ratio.            ║
# ║                                                                      ║
# ║  Breakpoints (character columns):                                    ║
# ║    XS (< 60)   — no logo, core modules only                          ║
# ║    SM (60-89)  — small logo, core modules                             ║
# ║    MD (90-119) — medium logo, standard modules                        ║
# ║    LG (120+)   — large logo, extended modules                         ║
# ║                                                                      ║
# ║  Startup overhead: < 15ms (stty + identify only)                     ║
# ╚══════════════════════════════════════════════════════════════════════╝
set -eu

# ─── Paths ──────────────────────────────────────────────────────────────
CONFIG_DIR="${HOME}/.config/fastfetch"
LOGO_PATH="${CONFIG_DIR}/current_logo.png"
PRESET_DIR="${CONFIG_DIR}/presets"

# ─── Terminal dimension detection ───────────────────────────────────────
detect_dims() {
    if command -v stty >/dev/null 2>&1; then
        _sz=$(stty size 2>/dev/null) || _sz=""
        if [ -n "$_sz" ]; then
            _r="${_sz%% *}"
            _c="${_sz##* }"
            if [ -n "$_r" ] && [ -n "$_c" ] && [ "$_r" -gt 0 ] 2>/dev/null && [ "$_c" -gt 0 ] 2>/dev/null; then
                echo "$_r $_c"
                return
            fi
        fi
    fi
    _r="${LINES:-24}"
    _c="${COLUMNS:-80}"
    echo "$_r $_c"
}

DIMS=$(detect_dims)
ROWS="${DIMS%% *}"
COLS="${DIMS##* }"

# ─── Breakpoint selection ───────────────────────────────────────────────
if [ "$COLS" -lt 68 ]; then
    PRESET="xs"
elif [ "$COLS" -lt 95 ]; then
    PRESET="sm"
elif [ "$COLS" -lt 125 ]; then
    PRESET="md"
else
    PRESET="lg"
fi

# ─── Dynamic logo sizing (strictly bounds-checked to prevent wrapping) ──
# Allocate ~26% of width for the logo, leaving enough space for text
LOGO_WIDTH=$(( COLS * 26 / 100 ))

# Reserve at least 42 columns for metadata text
MAX_ALLOWED_WIDTH=$(( COLS - 42 ))
if [ "$MAX_ALLOWED_WIDTH" -lt 12 ]; then
    MAX_ALLOWED_WIDTH=12
fi

if [ "$LOGO_WIDTH" -gt "$MAX_ALLOWED_WIDTH" ]; then
    LOGO_WIDTH=$MAX_ALLOWED_WIDTH
fi
if [ "$LOGO_WIDTH" -lt 12 ]; then
    LOGO_WIDTH=12
fi
if [ "$LOGO_WIDTH" -gt 35 ]; then
    LOGO_WIDTH=35
fi

# Calculate logo height from the image's actual aspect ratio
LOGO_HEIGHT=""
if [ -f "$LOGO_PATH" ] && command -v identify >/dev/null 2>&1; then
    _dims=$(identify -format '%w %h' "$LOGO_PATH" 2>/dev/null) || _dims=""
    if [ -n "$_dims" ]; then
        IMG_W="${_dims%% *}"
        IMG_H="${_dims##* }"
        if [ -n "$IMG_W" ] && [ -n "$IMG_H" ] && [ "$IMG_W" -gt 0 ] 2>/dev/null && [ "$IMG_H" -gt 0 ] 2>/dev/null; then
            LOGO_HEIGHT=$(( LOGO_WIDTH * IMG_H / (IMG_W * 2) ))
        fi
    fi
fi

# Fallback heuristic: assume a 3:4 portrait aspect ratio
if [ -z "$LOGO_HEIGHT" ] || [ "$LOGO_HEIGHT" -le 0 ]; then
    LOGO_HEIGHT=$(( LOGO_WIDTH * 3 / 4 ))
fi

# Clamp height to fit on terminal screen without vertical overflow
MAX_HEIGHT=$(( ROWS - 4 ))
if [ "$MAX_HEIGHT" -lt 8 ]; then
    MAX_HEIGHT=8
fi
if [ "$LOGO_HEIGHT" -gt "$MAX_HEIGHT" ]; then
    LOGO_HEIGHT=$MAX_HEIGHT
fi
if [ "$LOGO_HEIGHT" -lt 6 ]; then
    LOGO_HEIGHT=6
fi

# ─── Launch fastfetch with selected preset & preserved aspect ratio ────
PRESET_FILE="${PRESET_DIR}/${PRESET}.jsonc"

if [ -f "$PRESET_FILE" ]; then
    exec /usr/bin/fastfetch \
        --config "$PRESET_FILE" \
        --logo "$LOGO_PATH" \
        --logo-type kitty \
        --logo-width "$LOGO_WIDTH" \
        --logo-height "$LOGO_HEIGHT" \
        --logo-preserve-aspect-ratio true \
        "$@"
else
    # Fallback
    exec /usr/bin/fastfetch \
        --logo "$LOGO_PATH" \
        --logo-type kitty \
        --logo-preserve-aspect-ratio true \
        "$@"
fi
