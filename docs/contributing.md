# Contributing to ScriptGrab

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Script Guidelines](#script-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

- Be respectful and inclusive
- Follow script standards
- Document your code
- Test thoroughly
- Help others

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/scriptgrab.git
   cd scriptgrab
   ```
3. Create a branch:
   ```bash
   git checkout -b feature/your-feature
   ```

## Development Process

### Directory Structure
```
scriptgrab/
├── docs/
├── scripts/
│   ├── MacOS/
│   ├── Windows/
│   ├── Linux/
│   └── Other/
└── launcher.sh
```

### Script Categories
- Network utilities
- System tools
- Security tools
- Development tools

## Script Guidelines

### Required Headers
```bash
#!/usr/bin/env bash  # or python3, etc.
# =============================================================================
# Script: script_name.ext
# Description: Brief description
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
SCRIPT_AUTHOR = "Your Name"
SCRIPT_LICENSE = "MIT"
```

### Error Handling
```python
try:
    # Main logic
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
```

### Logging Support
```python
ALL_LOGS = os.environ.get('ALL_LOGS', '0') == '1'
if ALL_LOGS:
    print("[DEBUG] Debug message")
```

### Command Line Arguments
```python
def parse_args():
    parser = argparse.ArgumentParser(description=SCRIPT_DESCRIPTION)
    parser.add_argument('-v', '--version', action='version',
                      version=f'%(prog)s {SCRIPT_VERSION}')
    return parser.parse_args()
```

## Testing

### Test Environment
1. Create test directory
2. Copy script to test
3. Set up test data
4. Run tests

### Test Cases
- Basic functionality
- Error handling
- Input validation
- Resource cleanup
- Permissions

### Test Script
```bash
#!/bin/bash
set -euo pipefail

# Test setup
export ALL_LOGS=1

# Run tests
python3 script.py --version
python3 script.py --help
python3 script.py normal-case
python3 script.py error-case || true
```

## Submitting Changes

### Pull Request Process
1. Update documentation
2. Add tests
3. Follow coding standards
4. Submit PR

### Commit Messages
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Other

## Testing
- [ ] Added tests
- [ ] Tested manually
- [ ] No testing needed

## Checklist
- [ ] Documentation updated
- [ ] Code follows standards
- [ ] Tests pass
- [ ] Reviewed personally
```

## Script Standards

### Python Scripts
- Use Python 3.6+
- Include type hints
- Follow PEP 8
- Add docstrings

### Shell Scripts
- Use shellcheck
- Follow Google style
- Add comments
- Handle errors

### PowerShell Scripts
- Follow best practices
- Add comment-based help
- Handle errors
- Support -WhatIf

## Documentation

### Required Files
- README.md
- Script header
- Usage examples
- Dependencies

### Optional Files
- CHANGELOG.md
- CONTRIBUTING.md
- LICENSE

## Beta Testing

### Beta Channel
1. Submit to beta branch
2. Test thoroughly
3. Get feedback
4. Move to main

### Testing Process
1. Enable beta mode
2. Test new features
3. Report issues
4. Provide feedback

## Release Process

### Version Numbers
- MAJOR.MINOR.PATCH
- Semantic versioning
- Document changes

### Release Steps
1. Update version
2. Update docs
3. Create PR
4. Release notes

## Getting Help

- Read documentation
- Check issues
- Ask questions
- Join discussions 