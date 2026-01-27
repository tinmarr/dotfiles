# AGENTS.md - Dotfiles Repository

This is a **personal dotfiles repository** for managing system configuration files,
primarily for Arch Linux with Hyprland. It is NOT a traditional software project -
there are no build systems, tests, or compiled code.

## Repository Overview

| Component        | Technology                                      |
| ---------------- | ----------------------------------------------- |
| OS               | Arch Linux                                      |
| Window Manager   | Hyprland (Wayland compositor)                   |
| Shell            | ZSH (zinit plugin manager)                      |
| Terminal         | Ghostty                                         |
| Editor           | Neovim (Lua config, lazy.nvim)                  |
| Theme            | Catppuccin Mocha (consistent across all apps)   |
| Dotfile Manager  | GNU Stow                                        |

## Directory Structure

```
~/dotfiles/
├── install/              # Installation scripts (NOT stowed)
│   ├── archpost          # Full Arch post-install automation
│   ├── stowall           # Stow all dotfiles to ~
│   ├── unstowall         # Unstow all dotfiles
│   └── restowall         # Re-stow (update) all dotfiles
├── root/                 # Root-level configs (manually symlinked via linkroot.sh)
├── dot-config/           # -> ~/.config/
│   ├── nvim/             # Neovim configuration
│   ├── hypr/             # Hyprland configs
│   ├── tmux/             # Tmux configuration
│   └── [app configs...]  # Other application configs
├── dot-local/bin/        # -> ~/.local/bin/ (custom scripts)
├── dot-zshrc             # -> ~/.zshrc
├── dot-zshenv            # -> ~/.zshenv
└── dot-vimrc             # -> ~/.vimrc
```

## Commands

### Stow Commands

```bash
# Stow all dotfiles (creates symlinks in ~)
./install/stowall

# Unstow all dotfiles (removes symlinks)
./install/unstowall

# Re-stow all dotfiles (update after changes)
./install/restowall
```

Stow is invoked with `--no-folding --dotfiles`:
- `--no-folding`: Creates individual file symlinks, not directory symlinks
- `--dotfiles`: Translates `dot-` prefix to `.` (e.g., `dot-config` -> `.config`)

### New Machine Setup

```bash
curl "https://raw.githubusercontent.com/tinmarr/dotfiles/main/install/archpost" > archpost && \
chmod +x archpost && ./archpost && rm archpost
```

<!-- The repository contains various helper scripts in `dot-local/bin/` (for example `mkscript`).
     Do not run the `update` script or other high-privilege update scripts automatically.
     Agents should not execute any system update commands in this repository. -->

## Code Style Guidelines

### Git Commit Messages

Use short prefix + colon + description format:

```
hypr: reload swww
nvim: small improvements
pkgs: add libreoffice
tmux: update keybinds
```

Common prefixes: `hypr`, `nvim`, `pkgs`, `tmux`, `zsh`, `rofi`, `waybar`, `ghostty`, etc.

### Shell Scripts (Bash)

1. **Shebang**: Always use `#!/usr/bin/env bash`
2. **Formatting**: 4-space indentation (or tabs if consistent)
3. **Variables**: Use `$VAR` syntax, quote variables in conditionals: `[[ -z $VAR ]]`
4. **Functions**: Use `name () { ... }` syntax
5. **Conditionals**: Use `[[ ]]` for tests (bash-specific, safer)
6. **Exit on error**: Scripts generally don't use `set -e`; handle errors explicitly
7. **User output**: Use `printf` with ANSI colors for important messages

Example:
```bash
#!/usr/bin/env bash

mag="\e[35m"
reset="\e[m"

if [[ -z $TMUX ]]; then
    printf "${mag}Not in tmux${reset}\n"
    exit 1
fi
```

### Neovim (Lua)

1. **Structure**:
   - `init.lua` requires config modules
   - `lua/config/` for core settings (options, keymaps, commands, lazy bootstrap)
   - `lua/plugins/` for lazy.nvim plugin specs (one file per plugin/group)

2. **Formatting**:
   - 4-space indentation
   - Single quotes for strings (except when embedding quotes)
   - Trailing commas in tables
   - One blank line between logical sections

3. **Plugin Specs**: Return table with lazy.nvim spec
   ```lua
   return {
       {
           "author/plugin-name",
           ft = { "lua", "python" },  -- lazy load by filetype
           opts = { ... },
           config = function() ... end,
       },
   }
   ```

4. **Keymaps**: Use `vim.keymap.set()` with description
   ```lua
   vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Definition" })
   ```

5. **Autocommands**: Use `vim.api.nvim_create_autocmd()` with named groups
   ```lua
   vim.api.nvim_create_augroup("bufcheck", { clear = true })
   vim.api.nvim_create_autocmd("BufWritePre", {
       group = "bufcheck",
       pattern = "*",
       callback = function() ... end,
   })
   ```

### ZSH Configuration

1. Comments use `#` with space after
2. Group related configurations with `#### Section Name ####` headers
3. Aliases are single-letter or short abbreviations: `v="nvim"`, `lg="lazygit"`
4. Export environment variables at top or in logical groups
5. Source order: prompt -> plugin manager -> plugins -> options -> keybinds -> exports -> aliases

### Hyprland Configuration

1. Use section headers with `#####` comments
2. Variables prefixed with `$`: `$mainMod = SUPER`
3. Source external files for modularity: `source = ~/.config/hypr/colors.conf`
4. Comments explain non-obvious settings with wiki links

### Tmux Configuration

1. Use `#` comments to explain settings
2. Group by functionality (appearance, keybinds, plugins)
3. Vi mode keybinds preferred

## Files to Never Stow

Defined in `.stow-local-ignore`:
- `install/` directory
- `root/` directory
- `README.md`, `.envrc`, `showcase.png`
- Git files, backup files, lock files

## Per-Host Configuration

The `metapac` tool manages packages per hostname. Configuration in `dot-config/metapac/`:
- `config.toml`: Hostname to group mappings
- `groups/*.toml`: Package lists by category

Hostnames: `martinpc`, `martinfw`, `martinsv`, `martinmac`

## Theme: Catppuccin Mocha

All applications use Catppuccin Mocha theme for consistency. When adding new
application configs, prefer Catppuccin theme if available.

## Adding New Configurations

1. Create file/directory with `dot-` prefix in repo root or under `dot-config/`
2. Run `./install/restowall` to create symlink
3. Commit with appropriate prefix (e.g., `app: add initial config`)

## Adding New Scripts

Use the `mkscript` utility:
```bash
mkscript script-name  # Creates ~/.local/bin/script-name with bash template
```
