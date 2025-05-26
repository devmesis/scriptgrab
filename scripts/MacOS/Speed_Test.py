#!/usr/bin/env python3
# =============================================================================
# Script: Speed_Test.py
# Description: Network speed test utility for download and upload measurements
# Author: Devmesis <devmesis@scriptgrab.com>
# Version: 1.0.0
# License: MIT
# =============================================================================

"""
Network speed test utility that measures download and upload speeds.
Supports customizable test files and endpoints with detailed reporting.
"""

import argparse
import os
import sys
import time
import urllib.request
from typing import Optional, Tuple

# Script metadata
SCRIPT_NAME = "speed-test"
SCRIPT_VERSION = "1.0.0"
SCRIPT_DESCRIPTION = "Network speed test utility for download and upload measurements"
SCRIPT_AUTHOR = "Devmesis"
SCRIPT_LICENSE = "MIT"

# Default configuration
DEFAULT_DOWNLOAD_URL = "http://speedtest.tele2.net/1MB.zip"
DEFAULT_UPLOAD_URL = "https://httpbin.org/post"
DEFAULT_UPLOAD_SIZE = 256 * 1024  # 256KB
DEFAULT_TIMEOUT = 30

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

def format_speed_row(label: str, bps: float) -> str:
    """
    Format speed measurements in different units.
    
    Args:
        label: Row label (e.g., "Download" or "Upload")
        bps: Speed in bits per second
    
    Returns:
        str: Formatted row with speeds in different units
    """
    kbps = bps / 1_000
    mbps = bps / 1_000_000
    MBps = bps / 8_000_000
    return f"{label:<10} | {kbps:>10.2f} kbps | {mbps:>10.2f} Mbps | {MBps:>10.2f} MB/s"

def download_test(url: str, filename: str, timeout: int = DEFAULT_TIMEOUT) -> float:
    """
    Perform download speed test.
    
    Args:
        url: URL to download from
        filename: Temporary file to save download
        timeout: Timeout in seconds
    
    Returns:
        float: Download speed in bits per second
    
    Raises:
        urllib.error.URLError: If download fails
        TimeoutError: If download takes too long
    """
    start = time.time()
    
    try:
        # Set up the request with timeout
        opener = urllib.request.build_opener()
        opener.addheaders = [('User-Agent', f'ScriptGrab/{SCRIPT_VERSION}')]
        urllib.request.install_opener(opener)
        
        urllib.request.urlretrieve(url, filename)
        end = time.time()
        
        if end - start > timeout:
            raise TimeoutError(f"Download took longer than {timeout} seconds")
        
        size = os.path.getsize(filename)
        duration = end - start
        return size * 8 / duration
        
    finally:
        if os.path.exists(filename):
            os.remove(filename)

def upload_test(url: str, filename: str, size: int = DEFAULT_UPLOAD_SIZE,
                timeout: int = DEFAULT_TIMEOUT) -> float:
    """
    Perform upload speed test.
    
    Args:
        url: URL to upload to
        filename: Temporary file to create and upload
        size: Size of test file in bytes
        timeout: Timeout in seconds
    
    Returns:
        float: Upload speed in bits per second
    
    Raises:
        urllib.error.URLError: If upload fails
        TimeoutError: If upload takes too long
    """
    try:
        # Create test file
        with open(filename, "wb") as f:
            f.write(os.urandom(size))
        
        start = time.time()
        
        # Perform upload
        with open(filename, "rb") as f:
            data = f.read()
            req = urllib.request.Request(url, data=data, method="POST")
            req.add_header('User-Agent', f'ScriptGrab/{SCRIPT_VERSION}')
            req.add_header('Content-Type', 'application/octet-stream')
            
            try:
                urllib.request.urlopen(req, timeout=timeout)
            except Exception:
                # Some test servers don't accept POST, but we just want the timing
                pass
        
        end = time.time()
        
        if end - start > timeout:
            raise TimeoutError(f"Upload took longer than {timeout} seconds")
        
        duration = end - start
        return size * 8 / duration
        
    finally:
        if os.path.exists(filename):
            os.remove(filename)

def run_speed_test() -> Tuple[float, float]:
    """
    Run both download and upload speed tests.
    
    Returns:
        tuple: Download and upload speeds in bits per second
    """
    print()
    print(boxed(" 🚀 Network Speed Test 🚀 ", color=Fore.CYAN, style=Style.BRIGHT))
    print()
    
    # Download test
    print(f"{Style.BRIGHT}Testing download speed...{Style.RESET_ALL}")
    try:
        download_bps = download_test(DEFAULT_DOWNLOAD_URL, "temp_download.bin")
    except Exception as e:
        print(f"{Fore.RED}Download test failed: {e}{Style.RESET_ALL}")
        download_bps = 0
    
    # Upload test
    print(f"{Style.BRIGHT}Testing upload speed...{Style.RESET_ALL}")
    try:
        upload_bps = upload_test(DEFAULT_UPLOAD_URL, "temp_upload.bin")
    except Exception as e:
        print(f"{Fore.RED}Upload test failed: {e}{Style.RESET_ALL}")
        upload_bps = 0
    
    return download_bps, upload_bps

def parse_args() -> argparse.Namespace:
    """
    Parse command line arguments.
    
    Returns:
        argparse.Namespace: Parsed command line arguments
    """
    parser = argparse.ArgumentParser(description=SCRIPT_DESCRIPTION)
    parser.add_argument('--download-url', default=DEFAULT_DOWNLOAD_URL,
                      help='URL for download test')
    parser.add_argument('--upload-url', default=DEFAULT_UPLOAD_URL,
                      help='URL for upload test')
    parser.add_argument('--timeout', type=int, default=DEFAULT_TIMEOUT,
                      help='Timeout in seconds for each test')
    parser.add_argument('-v', '--version', action='version',
                      version=f'%(prog)s {SCRIPT_VERSION}')
    return parser.parse_args()

def main() -> int:
    """
    Main function to run the speed test.
    
    Returns:
        int: Exit code (0 for success, non-zero for failure)
    """
    try:
        download_bps, upload_bps = run_speed_test()
        
        # Print results
        print()
        print(f"{'Type':<10} | {'kbps':>10} | {'Mbps':>10} | {'MB/s':>10}")
        print("-" * 50)
        print(format_speed_row("Download", download_bps))
        print(format_speed_row("Upload", upload_bps))
        print("-" * 50)
        print()
        
        return 0 if (download_bps > 0 or upload_bps > 0) else 1
        
    except KeyboardInterrupt:
        print("\nTest interrupted by user", file=sys.stderr)
        return 130
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
