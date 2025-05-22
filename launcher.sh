#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
#  ScriptGrab — Boot Splash + Version Display
# ────────────────────────────────────────────────

clear
MSG_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/message.txt"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/version.txt"

MSG=$(curl -sf "$MSG_URL" || :)
REMOTE_VERSION=$(curl -sf "$REMOTE_VERSION_URL" | tr -d '\r\n' || echo "Cracked")

BANNER=$(cat <<'EOF'
┏┓   •   ┏┓    ┓
┗┓┏┏┓┓┏┓╋┃┓┏┓┏┓┣┓
┗┛┗┛ ┗┣┛┗┗┛┛ ┗┻┗┛
      ┛
EOF
)

while IFS= read -r line; do
  printf "\e[1;34m%s\e[0m\n" "$line"
  sleep 0.1
done <<<"$BANNER"

printf "\e[1;33mBy Devmesis\e[0m\n"
printf "\e[1;32mVersion: %s\e[0m\n" "$REMOTE_VERSION"
if [[ ${MSG+x} && -n "${MSG// }" ]]; then
  printf "\n\e[1;33m%s\e[0m\n" "$MSG"
fi
printf "\n" && sleep 0.5

# ────────────────────────────────────────────────
#  Main Menu
# ────────────────────────────────────────────────

OPTIONS=("Mac" "Windows" "Linux" "Other" "Download")
for i in "${!OPTIONS[@]}"; do
  printf "%d) %s\n" $((i+1)) "${OPTIONS[i]}"
done

while true; do
  read -rp $'\n\e[1;33m👉 Your choice: ' choice
  case "${choice,,}" in
    q) printf "\n\e[1;33m👋 Bye!\e[0m\n"; exit 0 ;;
    [1-5])
      opt="${OPTIONS[$((choice-1))]}"
      case "$opt" in
        Mac)      SYSTEM="MacOS";;
        Windows)  SYSTEM="Windows";;
        Linux)    SYSTEM="Linux";;
        Other)    SYSTEM="Other";;
        "Install ScriptGrab")
          echo -e "\n\e[1;34m🚀 Installing ScriptGrab...\e[0m"
          curl -sL "https://github.com/devmesis/scriptgrab/raw/main/scripts/Application/install.py" | python3
          echo -e "\n\e[1;32m✅ ScriptGrab installation completed.\e[0m\n"
          exit 0
          ;;
      esac
      break
      ;;
    *) echo "⚠ Invalid choice." ;;
  esac
done

GH_USER="devmesis"
GH_REPO="scriptgrab"
GH_BRANCH="main"
GH_OSFOLDER="scripts/$SYSTEM"
printf "\e[1;34m🌐 Fetching available scripts for %s…\e[0m\n" "$SYSTEM"

# Get the full tree recursively
tree=$(curl -sf "https://api.github.com/repos/$GH_USER/$GH_REPO/git/trees/$GH_BRANCH?recursive=1") || {
  echo "⚠️ Failed to fetch repo tree"
  exit 1
}

# Parse for .py, .sh, .ps1 files in the right folder (including subfolders)
names=()
urls=()
while IFS= read -r path; do
  name=$(basename "$path")
  url="https://github.com/$GH_USER/$GH_REPO/raw/$GH_BRANCH/$path"
  names+=("$name")
  urls+=("$url")
done < <(echo "$tree" | awk -F'"' '/"path":/ {print $4}' | grep "^$GH_OSFOLDER/" | grep -Ei '\.(py|sh|ps1)$')

if (( ${#names[@]} == 0 )); then
  printf "\e[1;31m❌ No scripts found!\e[0m\n"
  exit 1
fi

echo -e "\n\e[1;36m📜 Available Scripts:\e[0m\n"
for i in "${!names[@]}"; do
  base="${names[$i]%.*}"
  pretty="${base//_/ }"
  printf "%2d) %s\n" "$((i+1))" "$pretty"
done

while true; do
  read -rp $'\n\e[1;33m👉 Your choice (Q to quit): \e[0m' reply
  case "${reply,,}" in
      q) printf "\n\e[1;33m👋 Bye!\e[0m\n\n"; exit 0 ;;
    [1-9]|[1-9][0-9]*)
      if (( reply >= 1 && reply <= ${#names[@]} )); then
        script_name="${names[$((reply-1))]}"
        url="${urls[$((reply-1))]}"
        echo -e "\n\e[1;34m🚀 Running script $script_name...\e[0m\n"
        if [[ "$script_name" == *.py ]]; then
          curl -sL "$url" | python3
        elif [[ "$script_name" == *.ps1 ]]; then
          curl -sL "$url" | pwsh -NoProfile -
        else
          curl -sL "$url" | bash
        fi
        exit 0
      else
        echo "⚠ Invalid choice."
      fi
      ;;
    *) echo "⚠ Invalid choice." ;;
  esac
done
