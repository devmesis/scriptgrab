# Troubleshooting Guide

## Common Issues

### Installation Issues

#### Bad File Descriptor
```
Error: bash: /dev/fd/11: Bad file descriptor
```
**Solution:**
1. Try running the command again
2. Use the full command:
   ```bash
   bash <(curl -sL scriptgrab.com)
   ```
3. Check your internet connection

#### Permission Denied
```
Error: Permission denied
```
**Solution:**
1. Check file permissions
2. Use sudo if required:
   ```bash
   sudo bash <(curl -sL scriptgrab.com)
   ```

### Network Issues

#### GitHub Rate Limiting
```
Error: Rate Limited — try again in 1hr
```
**Solution:**
1. Wait for 1 hour
2. Enable logging to see details:
   ```bash
   export ALL_LOGS=1
   bash <(curl -sL scriptgrab.com)
   ```

#### No Scripts Found
```
Error: No scripts found for [OS]!
```
**Solution:**
1. Check your OS selection
2. Verify internet connection
3. Try cracked mode to see all scripts:
   ```
   Enter 'crack' at the prompt
   ```

### Script Execution Issues

#### Python Script Errors
```
Error: name 'Style' is not defined
```
**Solution:**
1. Install colorama:
   ```bash
   pip3 install colorama
   ```
2. Scripts will work without colorama (plain text)

#### Shell Script Permissions
```
Error: Permission denied: ./script.sh
```
**Solution:**
1. Make script executable:
   ```bash
   chmod +x ./script.sh
   ```
2. Run through bash directly:
   ```bash
   bash ./script.sh
   ```

### Environment Issues

#### Missing Dependencies
```
Error: Required dependency not found: [dependency]
```
**Solution:**
1. Install required tools:
   ```bash
   # For Python
   python3 -m pip install [package]
   
   # For system tools
   sudo apt install [tool]  # Debian/Ubuntu
   brew install [tool]      # macOS
   ```

#### Python Version
```
Error: Python 3 required
```
**Solution:**
1. Install Python 3:
   ```bash
   # macOS
   brew install python3
   
   # Linux
   sudo apt install python3
   ```
2. Verify installation:
   ```bash
   python3 --version
   ```

## Debugging Tools

### Enable Logging
```bash
# Enable all logs
export ALL_LOGS=1

# Enable specific log types
export INFO_LOGS=1
export DEBUG_LOGS=1
export WARN_LOGS=1
export ERROR_LOGS=1
```

### Check Script Source
```bash
# View script before running
curl -sL "https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/[OS]/[script]"
```

### Test Script Locally
```bash
# Download and test
curl -sLO "https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/[OS]/[script]"
chmod +x ./[script]
./[script]
```

## Special Modes

### Beta Mode
```
Enter 'beta' at the prompt
```
- Access experimental features
- Different script repository
- Purple banner indicates beta mode

### Cracked Mode
```
Enter 'crack' at the prompt
```
- Access all OS scripts
- Red banner indicates cracked mode
- Shows full script paths

## Recovery Steps

### Script Interruption
1. Press Ctrl+C to stop script
2. Clean up temporary files:
   ```bash
   rm -f temp_*
   ```
3. Restart ScriptGrab

### Reset Environment
```bash
# Clear environment variables
unset ALL_LOGS INFO_LOGS DEBUG_LOGS WARN_LOGS ERROR_LOGS IS_BETA IS_CRACKED

# Start fresh
bash <(curl -sL scriptgrab.com)
```

### Clean Installation
1. Clear temporary files:
   ```bash
   rm -f /tmp/scriptgrab*
   ```
2. Clear environment:
   ```bash
   unset ALL_LOGS INFO_LOGS DEBUG_LOGS WARN_LOGS ERROR_LOGS IS_BETA IS_CRACKED
   ```
3. Reinstall:
   ```bash
   bash <(curl -sL scriptgrab.com)
   ```

## Support

If issues persist:
1. Enable full logging
2. Capture error messages
3. Check GitHub issues
4. Report new issues with logs 