#!/usr/bin/env python3
# =============================================================================
# Script: Generate_Password.py
# Description: Secure password generator with customizable length and complexity
# Author: Devmesis <devmesis@scriptgrab.com>
# Version: 1.0.0
# License: MIT
# =============================================================================

"""
Secure password generator that creates strong passwords using Python's secrets module.
Supports customizable length and complexity, with optional colorized output.
"""

import argparse
import secrets
import string
import sys
from typing import Optional

# Script metadata
SCRIPT_NAME = "generate-password"
SCRIPT_VERSION = "1.0.0"
SCRIPT_DESCRIPTION = "Secure password generator with customizable length and complexity"
SCRIPT_AUTHOR = "Devmesis"
SCRIPT_LICENSE = "MIT"

# Script configuration
MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 128
DEFAULT_LENGTH = 12

# Initialize colors globally
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

def generate_password(length: int = DEFAULT_LENGTH,
                     use_uppercase: bool = True,
                     use_lowercase: bool = True,
                     use_digits: bool = True,
                     use_special: bool = True) -> str:
    """
    Generate a secure password with specified characteristics.
    
    Args:
        length: Length of the password (default: 12)
        use_uppercase: Include uppercase letters (default: True)
        use_lowercase: Include lowercase letters (default: True)
        use_digits: Include digits (default: True)
        use_special: Include special characters (default: True)
    
    Returns:
        str: Generated password
        
    Raises:
        ValueError: If length is outside valid range or no character types selected
    """
    if not MIN_PASSWORD_LENGTH <= length <= MAX_PASSWORD_LENGTH:
        raise ValueError(
            f"Password length must be between {MIN_PASSWORD_LENGTH} and {MAX_PASSWORD_LENGTH}"
        )
    
    # Build character set based on selected options
    chars = ''
    if use_uppercase:
        chars += string.ascii_uppercase
    if use_lowercase:
        chars += string.ascii_lowercase
    if use_digits:
        chars += string.digits
    if use_special:
        chars += string.punctuation
    
    if not chars:
        raise ValueError("At least one character type must be selected")
    
    # Generate password ensuring at least one character from each selected type
    password = []
    
    # Add one character from each selected type
    if use_uppercase:
        password.append(secrets.choice(string.ascii_uppercase))
    if use_lowercase:
        password.append(secrets.choice(string.ascii_lowercase))
    if use_digits:
        password.append(secrets.choice(string.digits))
    if use_special:
        password.append(secrets.choice(string.punctuation))
    
    # Fill remaining length with random characters
    remaining = length - len(password)
    password.extend(secrets.choice(chars) for _ in range(remaining))
    
    # Shuffle the password
    secrets.SystemRandom().shuffle(password)
    return ''.join(password)

def boxed(message: str, color: Optional[str] = None, style: Optional[str] = None) -> str:
    """
    Create a boxed message with optional color and style.
    
    Args:
        message: Message to put in box
        color: ANSI color code (default: None)
        style: ANSI style code (default: None)
    
    Returns:
        str: Formatted boxed message
    """
    border = f"+{'-' * len(message)}+"
    color = color or ''
    style = style or ''
    reset = Style.RESET_ALL
    
    return "\n".join([
        f"{color}{border}",
        f"{color}|{style}{message}{color}|",
        f"{color}{border}{reset}",
    ])

def parse_args() -> argparse.Namespace:
    """
    Parse command line arguments.
    
    Returns:
        argparse.Namespace: Parsed command line arguments
    """
    parser = argparse.ArgumentParser(description=SCRIPT_DESCRIPTION)
    parser.add_argument('-l', '--length', type=int, default=DEFAULT_LENGTH,
                      help=f'Password length (default: {DEFAULT_LENGTH})')
    parser.add_argument('--no-upper', action='store_false', dest='use_upper',
                      help='Exclude uppercase letters')
    parser.add_argument('--no-lower', action='store_false', dest='use_lower',
                      help='Exclude lowercase letters')
    parser.add_argument('--no-digits', action='store_false', dest='use_digits',
                      help='Exclude digits')
    parser.add_argument('--no-special', action='store_false', dest='use_special',
                      help='Exclude special characters')
    parser.add_argument('-v', '--version', action='version',
                      version=f'%(prog)s {SCRIPT_VERSION}')
    return parser.parse_args()

def main() -> int:
    """
    Main function to run the password generator.
    
    Returns:
        int: Exit code (0 for success, non-zero for failure)
    """
    args = parse_args()
    
    try:
        pwd = generate_password(
            length=args.length,
            use_uppercase=args.use_upper,
            use_lowercase=args.use_lower,
            use_digits=args.use_digits,
            use_special=args.use_special
        )
        
        header = " Your secure password: "
        print()
        print(boxed(header, color=Fore.CYAN, style=Style.BRIGHT))
        print()
        print(f"{Style.BRIGHT}{Fore.GREEN}{pwd}{Style.RESET_ALL}")
        print()
        return 0
        
    except ValueError as e:
        print(f"{Fore.RED}Error: {e}{Style.RESET_ALL}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"{Fore.RED}Unexpected error: {e}{Style.RESET_ALL}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
