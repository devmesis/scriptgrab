# API Reference

## Launcher Functions

### Display Functions

```bash
center_text()
Description: Center text in terminal window
Arguments:
  - text: String to center
Returns: None
Example: center_text "Hello World"

center_colored_text()
Description: Center colored text in terminal window
Arguments:
  - text: String to center
  - color: ANSI color code
Returns: None
Example: center_colored_text "Error" "\e[1;31m"

prompt_text()
Description: Format prompt text
Arguments:
  - text: Prompt text
Returns: None
Example: prompt_text "Your choice: "
```

### Logging Functions

```bash
log_info()
Description: Log informational message
Arguments:
  - message: Message to log
Environment: ALL_LOGS=1, INFO_LOGS=1
Example: log_info "Starting process"

log_debug()
Description: Log debug message
Arguments:
  - message: Debug message
Environment: ALL_LOGS=1, DEBUG_LOGS=1
Example: log_debug "Variable value: $var"

log_warn()
Description: Log warning message
Arguments:
  - message: Warning message
Environment: ALL_LOGS=1, WARN_LOGS=1
Example: log_warn "Resource not found"

log_error()
Description: Log error message
Arguments:
  - message: Error message
Environment: ALL_LOGS=1 or ERROR_LOGS=1
Example: log_error "Failed to connect"
```

### Network Functions

```bash
github_fetch()
Description: Fetch content from GitHub
Arguments:
  - url: GitHub URL to fetch
Returns: Response content or empty string
Example: github_fetch "https://api.github.com/repos/user/repo/contents"

urlencode()
Description: URL encode a string
Arguments:
  - string: String to encode
Returns: URL encoded string
Example: urlencode "path/to/file"
```

### Utility Functions

```bash
restart_script()
Description: Restart the launcher
Arguments: None
Returns: None (Executes new instance)
Example: restart_script

cleanup()
Description: Clean up temporary files
Arguments:
  - exit_code: Exit code to return
Returns: None
Example: cleanup $?
```

## Script Interfaces

### Python Scripts

#### Required Functions

```python
def main() -> int:
    """Main entry point for script"""
    return 0  # Success

def parse_args() -> argparse.Namespace:
    """Parse command line arguments"""
    return parser.parse_args()
```

#### Optional Functions

```python
def setup_colors() -> tuple:
    """Set up color support"""
    return Fore, Style

def boxed(message: str, color: Optional[str] = None, style: Optional[str] = None) -> str:
    """Create boxed message"""
    return formatted_string
```

### Shell Scripts

#### Required Functions

```bash
main()
Description: Main entry point
Returns: Exit code
Example: main "$@"

cleanup()
Description: Clean up resources
Arguments:
  - exit_code: Exit code
Returns: None
Example: cleanup $?
```

#### Optional Functions

```bash
error()
Description: Handle errors
Arguments:
  - line: Line number
  - message: Error message
Returns: None
Example: error "${LINENO}" "Failed"

check_dependencies()
Description: Check required tools
Arguments: None
Returns: 0 if all present, 1 if missing
Example: check_dependencies
```

## Environment Variables

```bash
# Logging Configuration
ALL_LOGS=0|1      # Enable all logging
INFO_LOGS=0|1     # Enable info logging
DEBUG_LOGS=0|1    # Enable debug logging
WARN_LOGS=0|1     # Enable warning logging
ERROR_LOGS=0|1    # Enable error logging

# Mode Configuration
IS_BETA=0|1       # Enable beta mode
IS_CRACKED=0|1    # Enable cracked mode
```

## Script Metadata

```python
# Required Script Variables
SCRIPT_NAME        # Script identifier
SCRIPT_VERSION     # Version string
SCRIPT_DESCRIPTION # Brief description
SCRIPT_AUTHOR      # Author name
SCRIPT_LICENSE     # License type
```

## Exit Codes

```bash
0   # Success
1   # General error
2   # Invalid argument
130 # Interrupted by user
```

## File Types

```bash
.py   # Python scripts
.sh   # Shell scripts
.ps1  # PowerShell scripts
``` 