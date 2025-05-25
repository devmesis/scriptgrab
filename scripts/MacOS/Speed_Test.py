import time
import urllib.request
import os

# ────────────────────────────────────────────────
#  🐍 ScriptGrab: Run any shell script straight from GitHub — no fluff, just speed.
# By Devmesis
# ────────────────────────────────────────────────

def boxed(message):
    border = f"+{'-' * len(message)}+"
    return "\n".join([
        border,
        f"|{message}|",
        border,
    ])

def format_speed_row(label, bps):
    kbps = bps / 1_000
    mbps = bps / 1_000_000
    MBps = bps / 8_000_000
    return f"{label:<10} | {kbps:>10.2f} kbps | {mbps:>10.2f} Mbps | {MBps:>10.2f} MB/s"

def download_test(url, filename):
    start = time.time()
    urllib.request.urlretrieve(url, filename)
    end = time.time()
    size = os.path.getsize(filename)
    os.remove(filename)
    duration = end - start
    bps = size * 8 / duration
    return bps

def upload_test(url, filename, size=1024*256):  # 256KB
    # Create a dummy file
    with open(filename, "wb") as f:
        f.write(os.urandom(size))
    start = time.time()
    with open(filename, "rb") as f:
        data = f.read()
        req = urllib.request.Request(url, data=data, method="POST")
        try:
            urllib.request.urlopen(req)
        except Exception:
            # Some test servers don't accept POST, but we just want the timing
            pass
    end = time.time()
    os.remove(filename)
    duration = end - start
    bps = size * 8 / duration
    return bps

if __name__ == "__main__":
    print()
    print(boxed(" 🚀 Network Speed Test 🚀 "))
    print()

    # Download test (1MB file)
    test_file_url = "http://speedtest.tele2.net/1MB.zip"
    try:
        print("Testing download speed...")
        download_bps = download_test(test_file_url, "temp_download.bin")
    except Exception as e:
        print(f"Download test failed: {e}")
        download_bps = 0

    # Upload test (256KB file, using httpbin.org as a dummy endpoint)
    upload_url = "https://httpbin.org/post"
    try:
        print("Testing upload speed...")
        upload_bps = upload_test(upload_url, "temp_upload.bin")
    except Exception as e:
        print(f"Upload test failed: {e}")
        upload_bps = 0

    print()
    print(f"{'Type':<10} | {'kbps':>10} | {'Mbps':>10} | {'MB/s':>10}")
    print("-" * 50)
    print(format_speed_row("Download", download_bps))
    print(format_speed_row("Upload", upload_bps))
    print("-" * 50)
    print()
