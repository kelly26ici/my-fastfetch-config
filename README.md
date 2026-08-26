# MyFastFetch 🎌

A fastfetch configuration with responsive terminal-aware presets and random anime logo rotation.

---

## Features ✨

- **Responsive layout** — adapts to terminal width (xs/sm/md/lg breakpoints)
- **Random anime logo** — cycles through logos without repeating until all are used
- **Kitty image protocol** — renders images directly in supported terminals
- **Bright, colorful output** — neon-style system info with bars and colors

---

## Structure

```
~/.config/fastfetch/
├── config.jsonc              # Default fastfetch config
├── fastfetch-responsive.sh   # Responsive wrapper (detects terminal width)
├── presets/
│   ├── lg.jsonc              # Large terminals (120+ cols)
│   ├── md.jsonc              # Medium terminals (95–119 cols)
│   ├── sm.jsonc              # Small terminals (68–94 cols)
│   └── xs.jsonc              # Tiny terminals (< 68 cols)
├── logos/                    # 49 anime logo images
├── used_logos.txt            # Tracks which logos have been shown
└── current_logo.png          # Currently selected logo (generated at runtime)
```

---

## Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/kelly26ici/my-fastfetch-config
   cd my-fastfetch-config
   ```

2. Copy to your config directory:
   ```bash
   mkdir -p ~/.config/fastfetch
   cp -r config.jsonc fastfetch-responsive.sh presets logos ~/.config/fastfetch/
   ```

3. Run:
   ```bash
   fastfetch --config ~/.config/fastfetch/fastfetch-responsive.sh
   ```

---

## Supported Terminals

- Kitty
- Ghostty
- iTerm2
- WezTerm
- Terminology