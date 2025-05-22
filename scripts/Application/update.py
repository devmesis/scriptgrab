import subprocess
import sys
import os

# ────────────────────────────────────────────────
#  ScriptGrab Updater (for ~/scriptgrab, global cmd: sg)
# ────────────────────────────────────────────────

DEST_DIR = os.path.expanduser("~/scriptgrab")
LAUNCHER = "scriptgrab.sh"

def run(cmd, **kwargs):
    print(f"  $ {' '.join(cmd)}")
    subprocess.run(cmd, check=True, **kwargs)

def update_repo():
    if not os.path.exists(DEST_DIR):
        print(f"❌ Directory '{DEST_DIR}' does not exist. Run the installer first!")
        sys.exit(1)
    print(f"🔄 Pulling latest changes in {DEST_DIR} …")
    run(["git", "-C", DEST_DIR, "pull", "--ff-only"])
    print("✅ Repo updated.")

def make_launcher_executable():
    launcher_path = os.path.join(DEST_DIR, LAUNCHER)
    if os.path.exists(launcher_path):
        run(["chmod", "+x", launcher_path])
        print(f"🔑 Ensured '{LAUNCHER}' is executable.")

def main():
    update_repo()
    make_launcher_executable()
    print("\n🚦 ScriptGrab is up to date. Go break something. 😎")

if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Update failed: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted by user.")
        sys.exit(1)
