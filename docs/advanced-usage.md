# Advanced Usage Guide

## Special Modes

### Beta Channel Access
```bash
# At the prompt, enter:
beta

# Or set environment variable:
export IS_BETA=1
bash <(curl -sL scriptgrab.com)
```

Features:
- Access experimental scripts
- Purple banner interface
- Different script repository
- Early access to new features

### Cracked Mode
```bash
# At the prompt, enter:
crack

# Or set environment variable:
export IS_CRACKED=1
bash <(curl -sL scriptgrab.com)
```

Features:
- Access all OS scripts
- Red banner interface
- Full script path display
- Cross-OS script access

## Logging System

### Log Levels
```bash
# Enable all logging
export ALL_LOGS=1

# Individual log types
export INFO_LOGS=1    # Informational messages
export DEBUG_LOGS=1   # Debug information
export WARN_LOGS=1    # Warning messages
export ERROR_LOGS=1   # Error messages
```

### Log Output Format
```
[LOG]   Informational messages
[DEBUG] Detailed debug information
[WARN]  Warning messages
[ERROR] Error messages
```

## Script Execution

### Direct Script Access
```bash
# Download specific script
curl -sL "https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/[OS]/[script]" > script

# Make executable
chmod +x script

# Run with environment variables
ALL_LOGS=1 ./script
```

### Script Types
- Python (.py)
  ```bash
  python3 script.py [args]
  ```
- Shell (.sh)
  ```bash
  bash script.sh [args]
  ```
- PowerShell (.ps1)
  ```bash
  pwsh -NoProfile -File script.ps1 [args]
  ```

## Network Configuration

### GitHub API Usage
- Rate limiting protection
- Custom User-Agent
- HTTPS enforcement
- Response validation

### Timeout Settings
```bash
# Default timeouts
DEFAULT_TIMEOUT=30  # 30 seconds

# Custom timeout for downloads
curl -m 30 ...
```

## Terminal Features

### Color Support
```bash
# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'
```

### Text Formatting
```bash
# Center text
center_text "message"

# Colored centered text
center_colored_text "message" "\e[1;31m"

# Prompt text
prompt_text "Your choice: "
```

## File Management

### Temporary Files
```bash
# Create temp file
tmpfile=$(mktemp)

# Use temp file
curl -o "$tmpfile" ...

# Clean up
rm -f "$tmpfile"
```

### File Types
```bash
# Supported extensions
.py   # Python scripts
.sh   # Shell scripts
.ps1  # PowerShell scripts
```

## Error Handling

### Exit Codes
```bash
0   # Success
1   # General error
2   # Invalid argument
130 # Interrupted by user
```

### Error Traps
```bash
# Set up error handling
trap 'cleanup $?' EXIT
trap 'cleanup 1' INT TERM
trap 'error ${LINENO} "$BASH_COMMAND"' ERR
```

## Custom Configuration

### Environment Setup
```bash
# Script metadata
SCRIPT_NAME="custom-script"
SCRIPT_VERSION="1.0.0"
SCRIPT_DESCRIPTION="Custom script description"
SCRIPT_AUTHOR="Your Name"
SCRIPT_LICENSE="MIT"
```

### Dependencies
```bash
# Check for required tools
command -v python3 >/dev/null 2>&1 || { echo "Python 3 required"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl required"; exit 1; }
```

## Advanced Features

### URL Encoding
```bash
# Encode path components
encoded_path=$(urlencode "path/with spaces")
```

### Script Restart
```bash
# Restart the launcher
restart_script "$@"
```

### Banner Customization
```bash
# Display custom banner
display_banner
center_colored_text "Custom Message" "\e[1;36m"
```

## Security Features

### HTTPS Enforcement
- All GitHub interactions use HTTPS
- Certificate validation enabled
- No insecure fallbacks

### File Permissions
```bash
# Set secure permissions
chmod 700 script.sh  # Owner only
chmod 644 data.txt   # Read-only for others
```

### Cleanup Handlers
```bash
# Ensure cleanup on exit
trap cleanup EXIT
trap cleanup SIGINT SIGTERM
```

## Integration

### Shell Integration
```bash
# Add to shell profile
echo 'alias sg="bash <(curl -sL scriptgrab.com)"' >> ~/.bashrc
```

### Custom Scripts
```bash
# Create OS-specific directory
mkdir -p scripts/[OS]/

# Add script with metadata
cat > scripts/[OS]/script.sh << 'EOF'
#!/bin/bash
# Script metadata
SCRIPT_NAME="custom"
...
EOF
``` 