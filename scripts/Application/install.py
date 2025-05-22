import subprocess
import sys
import os

# ────────────────────────────────────────────────
#  ScriptGrab Installer (Global command: sg)
# ────────────────────────────────────────────────

REPO_URL = "https://github.com/devmesis/scriptgrab"
DEST_DIR = os.path.expanduser("~/scriptgrab")
LAUNCHER = "scriptgrab.sh"
SYMLINK_PATH = "/usr/local/bin/sg"

def run(cmd, **kwargs):
    print(f"  $ {' '.join(cmd)}")
    subprocess.run(cmd, check=True, **kwargs)

def clone_repo():
    if os.path.exists(DEST_DIR):
        print(f"🚨 Directory '{DEST_DIR}' already exists. Remove it or choose another location.")
        sys.exit(1)
    print(f"🚀 Cloning {REPO_URL} into {DEST_DIR} …")
    run(["git", "clone", REPO_URL, DEST_DIR])
    print("✅ Clone complete. Time to break, fix, and make it better.")

def make_launcher_executable():
    launcher_path = os.path.join(DEST_DIR, LAUNCHER)
    if not os.path.exists(launcher_path):
        print(f"❌ Can't find '{LAUNCHER}' in {DEST_DIR}.")
        sys.exit(1)
    run(["chmod", "+x", launcher_path])
    print(f"🔑 Made '{LAUNCHER}' executable.")

def create_symlink():
    launcher_path = os.path.join(DEST_DIR, LAUNCHER)
    try:
        if os.path.islink(SYMLINK_PATH) or os.path.exists(SYMLINK_PATH):
            run(["sudo", "rm", "-f", SYMLINK_PATH])
        run(["sudo", "ln", "-s", launcher_path, SYMLINK_PATH])
        print(f"🔗 Symlinked '{LAUNCHER}' to '{SYMLINK_PATH}'.")
    except Exception as e:
        print(f"❌ Failed to symlink: {e}")
        sys.exit(1)

def main():
    clone_repo()
    make_launcher_executable()
    create_symlink()
    print("\n🚦 All set! You can now run '\033[1msg\033[0m' from anywhere.")
    print("If you want to poke around, cd into the repo:")
    print(f"    cd {DEST_DIR}")
    print("Break it. Fix it. Make it better.")

if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Command failed: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted by user.")
        sys.exit(1)
