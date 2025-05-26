# Script Development Guide

## Overview

This guide outlines the standards and best practices for developing scripts for ScriptGrab. Following these guidelines ensures compatibility and maintainability.

## Script Structure

### File Organization
```
scripts/
├── MacOS/
├── Windows/
├── Linux/
└── Other/
```

### Naming Conventions
- Use descriptive names
- Separate words with underscores
- Include file extension
- Examples:
  - `Network_Test.sh`
  - `Generate_Password.py`
  - `Speed_Test.py`

## Script Headers

### Required Headers
```bash
#!/usr/bin/env bash  # or python3, etc.
# =============================================================================
# Script: script_name.ext
# Description: Brief description of what the script does
# Author: Your Name <email@example.com>
# Version: 1.0.0
# License: MIT
# =============================================================================
```

### Script Metadata
```python
SCRIPT_NAME = "script-name"
SCRIPT_VERSION = "1.0.0"
SCRIPT_DESCRIPTION = "Brief description"
SCRIPT_AUTHOR = "Author Name"
SCRIPT_LICENSE = "MIT"
```

## Error Handling

### Bash Scripts
```bash
set -euo pipefail
IFS=$'\n\t'

# Error handler
error() {
    local line=$1
    local msg=$2
    echo "[ERROR] Line ${line}: ${msg}" >&2
    exit 1
}

# Set up error handling
trap 'cleanup $?' EXIT
trap 'cleanup 1' INT TERM
trap 'error ${LINENO} "$BASH_COMMAND"' ERR
```

### Python Scripts
```python
try:
    # Main script logic
except ValueError as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Unexpected error: {e}", file=sys.stderr)
    sys.exit(1)
```

## Logging

### Environment Variables
```python
ALL_LOGS = os.environ.get('ALL_LOGS', '0') == '1'
INFO_LOGS = os.environ.get('INFO_LOGS', '1') == '1'
DEBUG_LOGS = os.environ.get('DEBUG_LOGS', '1') == '1'
WARN_LOGS = os.environ.get('WARN_LOGS', '1') == '1'
ERROR_LOGS = os.environ.get('ERROR_LOGS', '1') == '1'
```

### Logging Functions
```python
def log_info(msg):
    if ALL_LOGS and INFO_LOGS:
        print(f"[INFO] {msg}")

def log_error(msg):
    if ALL_LOGS or ERROR_LOGS:
        print(f"[ERROR] {msg}", file=sys.stderr)
```

## User Interface

### Command Line Arguments
```python
def parse_args():
    parser = argparse.ArgumentParser(description=SCRIPT_DESCRIPTION)
    parser.add_argument('-v', '--version', action='version',
                      version=f'%(prog)s {SCRIPT_VERSION}')
    return parser.parse_args()
```

### Output Formatting
```python
def boxed(message: str, color: Optional[str] = None, style: Optional[str] = None) -> str:
    border = f"+{'-' * len(message)}+"
    return "\n".join([
        f"{color or ''}{border}",
        f"{color or ''}|{style or ''}{message}{color or ''}|",
        f"{color or ''}{border}{Style.RESET_ALL}",
    ])
```

## Testing

### Test Requirements
- Test on target OS
- Verify dependencies
- Check error handling
- Test with logging enabled

### Test Cases
1. Basic functionality
2. Error conditions
3. Input validation
4. Resource cleanup
5. Permission handling

## Dependencies

### Handling Dependencies
```python
def check_dependencies():
    required = ['curl', 'python3', 'git']
    for cmd in required:
        if not shutil.which(cmd):
            sys.exit(f"Required dependency not found: {cmd}")
```

### Optional Features
```python
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
except ImportError:
    class DummyColor:
        RESET_ALL = ''
        BRIGHT = ''
        def __getattr__(self, name):
            return ''
    Fore = Style = DummyColor()
```

## Script Template

```python
#!/usr/bin/env python3
# =============================================================================
# Script: template.py
# Description: Template for new scripts
# Author: Your Name <email@example.com>
# Version: 1.0.0
# License: MIT
# =============================================================================

"""
Detailed description of the script.
"""

import argparse
import sys
from typing import Optional

# Script metadata
SCRIPT_NAME = "template"
SCRIPT_VERSION = "1.0.0"
SCRIPT_DESCRIPTION = "Template for new scripts"
SCRIPT_AUTHOR = "Your Name"
SCRIPT_LICENSE = "MIT"

def main() -> int:
    """
    Main function to run the script.
    
    Returns:
        int: Exit code (0 for success, non-zero for failure)
    """
    try:
        # Main logic here
        return 0
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
``` 