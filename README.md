# Dotfiles Setup - Distribution Agnostic

A modular, idempotent, and distribution-agnostic dotfiles setup system that works across Ubuntu, Arch, Manjaro, Fedora, and more.

This is my personal dotfiles' repo. I created this repo to keep all my config
files in a single place where I can easily install them.

## 🎯 Key Features

- ✅ **Distribution Agnostic**: Works on Ubuntu, Debian, Arch, Manjaro, Fedora, openSUSE
- ✅ **Idempotent**: Run multiple times safely, only installs what's missing
- ✅ **Enhanced Logging**: Colored console output + detailed log files
- ✅ **Modular Design**: Each program has its own install script
- ✅ **Package Manager Abstraction**: Unified interface for apt, pacman, dnf, zypper

## 📁 New Structure

```
dotfiles/
├── setup.sh                    # Main orchestrator script
├── lib/
│   ├── detect.sh              # OS/distro detection
│   ├── logging.sh             # Enhanced logging utilities
│   └── package_manager.sh     # Package manager abstraction
├── programs/
│   ├── kitty/
│   │   ├── install.sh         # Kitty-specific installation
│   │   └── kitty.conf
│   ├── neovim/
│   │   └── install.sh
│   └── ...                    # Each program self-contained
└── rcFiles/
    └── zshrc
```

## 🚀 Quick Start

### First Time Setup

```bash
cd ~/dotfiles
chmod +x setup.sh lib/*.sh

# Run the setup
./setup.sh
```

### Updating/Re-running

```bash
# Safe to run multiple times - only installs missing components
./setup.sh
```

## 📝 Logs

The script generates two log files:

- `~/dotfiles_setup.log` - Detailed execution log with timestamps
- `~/dotfiles_installed.log` - Simple list of what was installed/skipped

## 🔧 How It Works

### 1. Detection Phase

The script automatically detects:

- Linux distribution (Ubuntu, Arch, Fedora, etc.)
- Package manager (apt, pacman, dnf, zypper)
- AUR helper on Arch-based systems (yay, paru, pamac)

### 2. Installation Phase

For each component:

1. Check if already installed (idempotency)
2. Skip if present, log accordingly
3. Install only what's missing
4. Log success/failure

### 3. Configuration Phase

- Copy configuration files
- Set up shell environment
- Apply user-specific settings

## 📦 Package Manager Abstraction

The library provides unified functions:

```bash
# Update package database
pkg_update

# Install packages (automatically filters installed ones)
pkg_install package1 package2 package3

# Check if package is installed
pkg_is_installed package_name

# Map generic names to distro-specific names
pkg_map build-essential  # Returns base-devel on Arch, build-essential on Ubuntu
```

## 🎨 Logging System

Enhanced logging with colors and levels:

```bash
log_info "Installing package"      # Blue
log_success "Installation complete" # Green
log_warn "Warning message"          # Yellow
log_error "Error occurred"          # Red
log_skip "Already installed"        # Yellow
```

## 🔨 Creating New Program Install Scripts

Use the template at `programs/example/install.sh`:

```bash
#!/bin/bash
# programs/your-program/install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTDIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTDIR/lib/detect.sh"
source "$DOTDIR/lib/logging.sh"
source "$DOTDIR/lib/package_manager.sh"

PROGRAM_NAME="your-program"

# Check if already installed
if command -v your-program &>/dev/null; then
    log_skip "$PROGRAM_NAME already installed"
    exit 0
fi

# Install via package manager
if pkg_install "$PROGRAM_NAME"; then
    log_success "$PROGRAM_NAME installed"
else
    log_error "Failed to install $PROGRAM_NAME"
    exit 1
fi

# Copy configuration
mkdir -p "$HOME/.config/your-program"
cp "$SCRIPT_DIR/config.conf" "$HOME/.config/your-program/"
```

## 🔄 Migration from Old Script

### Changes Made

1. **Package Manager**: Hardcoded `pacman`/`yay` → Abstracted `pkg_install()`
2. **Idempotency**: Partial checks → Comprehensive `is_installed()` checks
3. **Logging**: Basic echo → Structured logging with levels
4. **Modularity**: Inline code → Separate library functions
5. **Distribution Support**: Arch/Manjaro only → Multi-distro support

### What to Update in Your Existing Scripts

1. **Replace direct pacman calls:**

   ```bash
   # Old
   sudo pacman -S --noconfirm package

   # New
   pkg_install package
   ```

2. **Replace echo with log functions:**

   ```bash
   # Old
   echo "Installing package"

   # New
   log_info "Installing package"
   ```

3. **Add idempotency checks:**

   ```bash
   # New - at start of each install script
   if command -v program &>/dev/null; then
       log_skip "Program already installed"
       exit 0
   fi
   ```

## 🎯 Benefits

### For You

- **One codebase** for all distributions
- **Faster setup** on new machines
- **Easy debugging** with detailed logs
- **Safe experimentation** - run anytime without breaking things

### For Maintenance

- **Modular updates** - change one program without touching others
- **Easy testing** - test individual components
- **Clear structure** - new contributors can understand quickly

## 🐛 Troubleshooting

### Script fails on Ubuntu

Check `~/dotfiles_setup.log` for detailed error messages. Common issues:

- Missing sudo permissions
- Package names differ between distributions
- Repository not available

### Package not found

The script may need distribution-specific package names. Add mapping in `lib/package_manager.sh`:

```bash
pkg_map() {
    # Add your mapping
    "your-program:ubuntu-pkg-name:arch-pkg-name:fedora-pkg-name"
}
```

## 📋 TODO/Next Steps

1. ✅ Core library functions
2. ✅ Main orchestrator script
3. ⏳ Migrate all program install scripts to new format
4. ⏳ Add tests for each module
5. ⏳ Create distribution-specific package name mappings
6. ⏳ Add rollback functionality

## 🤝 Contributing

When adding new programs:

1. Create directory: `programs/your-program/`
2. Add `install.sh` using the template
3. Use library functions for installation
4. Test on multiple distributions
5. Document any distribution-specific quirks

## 📚 Testing Checklist

Before deploying:

- [ ] Test on fresh Ubuntu VM
- [ ] Test on fresh Arch VM
- [ ] Check all logs are generated
- [ ] Verify idempotency (run twice)
- [ ] Check failed installations are logged
- [ ] Verify already-installed packages are skipped

## 🔐 Security Notes

- Scripts use `set -euo pipefail` for safety
- All installations logged for audit
- Package verification before installation
- User permissions respected (sudo only when needed)
