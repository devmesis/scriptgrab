# Getting Started with ScriptGrab

## Quick Start

1. Open your terminal
2. Run the following command:
   ```bash
   bash <(curl -sL scriptgrab.com)
   ```
3. Select your operating system from the menu
4. Choose a script to run

## Interface Guide

### Main Menu
When you launch ScriptGrab, you'll see:

1. The ScriptGrab banner
2. Current version and timestamp
3. Any system messages
4. Operating system selection menu:
   - 1) Mac
   - 2) Windows
   - 3) Linux
   - 4) Other
   - 5) GitHub

### Script Selection
After choosing an operating system:

1. You'll see a list of available scripts
2. Each script is numbered
3. Enter the number to run that script
4. Scripts will execute in your current terminal

### Navigation Commands

- `q` - Quit ScriptGrab
- `r` - Restart the application
- `b` - Go back to previous menu
- Numbers - Select menu options

### Special Commands

- `beta` - Toggle beta channel access
  - Access experimental features
  - Purple banner indicates beta mode
  - Different script repository

- `crack` - Toggle cracked mode
  - Access all OS scripts
  - Red banner indicates cracked mode
  - Shows full script paths

- `logs` - Toggle detailed logging
  - Shows debug information
  - Useful for troubleshooting

## Environment Variables

You can customize ScriptGrab behavior using these variables:

```bash
# Enable all logging
export ALL_LOGS=1

# Enable specific log types
export INFO_LOGS=1
export DEBUG_LOGS=1
export WARN_LOGS=1
export ERROR_LOGS=1

# Enable beta mode
export IS_BETA=1
```

## Script Execution

Scripts are:
1. Downloaded from GitHub
2. Stored in a temporary location
3. Executed in your current shell
4. Automatically cleaned up after execution

Supported script types:
- `.py` (Python)
- `.sh` (Shell)
- `.ps1` (PowerShell)

## Troubleshooting

If you encounter issues:

1. Enable logging:
   ```bash
   export ALL_LOGS=1
   bash <(curl -sL scriptgrab.com)
   ```

2. Check your internet connection

3. Common error messages:
   - "Rate Limited" - Wait 1 hour before trying again
   - "No scripts found" - Check your OS selection
   - "Bad file descriptor" - Try running the command again

4. If a script fails:
   - Check the error message
   - Enable logging for more details
   - Try running in a new terminal session 