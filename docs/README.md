# ScriptGrab Documentation

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Features](#features)
- [Command Line Options](#command-line-options)
- [Operating System Support](#operating-system-support)

## Overview

ScriptGrab is a command-line tool that provides instant access to a curated collection of system administration and utility scripts. It allows you to run scripts directly from GitHub without manual downloads or setup.

## Installation

Run ScriptGrab directly using:

```bash
bash <(curl -sL scriptgrab.com)
```

## Basic Usage

1. Launch ScriptGrab using the command above
2. Select your operating system from the menu (1-5):
   - Mac
   - Windows
   - Linux
   - Other
   - GitHub (opens repository)
3. Choose a script from the available options
4. Follow the on-screen instructions

## Features

### Operating System Detection
- Dedicated script collections for MacOS, Windows, Linux, and other systems
- Automatic script compatibility checking
- OS-specific optimizations

### Special Modes

#### Beta Channel
- Access experimental features and scripts
- Toggle with `beta` command
- Indicated by purple banner
- Uses separate beta repository

#### Cracked Mode
- Access all scripts across all OS directories
- Toggle with `crack` command
- Indicated by red banner
- Shows full script paths with OS prefixes

### Logging System
- Toggle detailed logging with `logs` command
- Provides debug, info, warning, and error messages
- Helps with troubleshooting

### Navigation Commands
- `q` - Quit the application
- `r` - Restart ScriptGrab
- `b` - Go back to previous menu
- Numbers (1-5) - Select options

## Command Line Options

The launcher supports several environment variables:

```bash
ALL_LOGS=1    # Enable all logging (default: 0)
INFO_LOGS=1   # Enable info logging (default: 1)
DEBUG_LOGS=1  # Enable debug logging (default: 1)
WARN_LOGS=1   # Enable warning logging (default: 1)
ERROR_LOGS=1  # Enable error logging (default: 1)
IS_BETA=1     # Enable beta mode (default: 0)
```

## Operating System Support

### MacOS Scripts
Located in `scripts/MacOS/`
- Python scripts (.py)
- Shell scripts (.sh)
- Network utilities
- System tools

### Windows Scripts
Located in `scripts/Windows/`
- PowerShell scripts (.ps1)
- Batch scripts (.bat)
- System utilities

### Linux Scripts
Located in `scripts/Linux/`
- Shell scripts (.sh)
- Python scripts (.py)
- System utilities

### Other Scripts
Located in `scripts/Other/`
- Cross-platform utilities
- Generic tools

## Security

- All scripts are open source and can be reviewed before execution
- Scripts are downloaded from GitHub using HTTPS
- Temporary files are automatically cleaned up
- No persistent data storage
- Scripts run in isolated environments 