#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ────────────────────────────────────────────────
#  🐍 ScriptGrab — Boot Splash + Version Display
# ────────────────────────────────────────────────
clear
MSG_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/message.txt"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/version.txt"
CLOUD_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/cloud.txt"

MSG=$(curl -sf "$MSG_URL" || :)
REMOTE_VERSION=$(curl -sf "$REMOTE_VERSION_URL" | tr -d '\r\n' || echo "Cracked")
CLOUD_STATUS=$(curl -sf "$CLOUD_URL" | tr -d '\r\n' || echo "no")

if [[ "${CLOUD_STATUS,,}" == "yes" ]]; then
  CLOUD_ICON="☁️"
else
  CLOUD_ICON="⚡"
fi

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
printf "%s \e[1;32mVersion: %s\e[0m\n" "$CLOUD_ICON" "$REMOTE_VERSION"

if [[ ${MSG+x} && -n "${MSG// }" ]]; then
  printf "\n\e[1;33m%s\e[0m\n" "$MSG"
fi

printf "\n" && sleep 0.5

# ────────────────────────────────────────────────
#  Environment Checks
# ────────────────────────────────────────────────

command -v python3 >/dev/null 2>&1 || { echo -e "\e[1;31m❌ Python 3 required. Abort.\e[0m"; exit 1; }
command -v bash >/dev/null 2>&1   || { echo -e "\e[1;31m❌ Bash required. Abort.\e[0m";   exit 1; }

# ────────────────────────────────────────────────
#  Secret Settings Menu
# ────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_FILE="$SCRIPT_DIR/scriptgrab/system.txt"
BETA_FILE="$SCRIPT_DIR/scriptgrab/beta.txt"
AUTO_UPDATE_FILE="$SCRIPT_DIR/scriptgrab/update.txt"
AUTO_UPDATE_SCRIPT="$SCRIPT_DIR/scriptgrab/updater.py"

function secret_menu() {
  while true; do
    read -rp "Toggle Cheats: " CMD
    case "$(echo "$CMD" | tr '[:upper:]' '[:lower:]')" in
      reset)
        rm -f "$SYSTEM_FILE" "$BETA_FILE"
        printf "\n\e[1;32mPreferences reset. Please restart script.\e[0m\n\n"
        exit 0
        ;;
      beta)
        if [[ -f $BETA_FILE ]]; then
          rm -f "$BETA_FILE"
          printf "\n\e[1;33mBeta mode disabled.\e[0m\n\n"
        else
          echo "yes" > "$BETA_FILE"
          printf "\n\e[1;32mBeta mode enabled.\e[0m\n\n"
        fi
        ;;
      all)
        if [[ -f $SYSTEM_FILE ]] && [[ "$(cat "$SYSTEM_FILE")" == "All" ]]; then
          rm -f "$SYSTEM_FILE"
          printf "\n\e[1;33mAll mode disabled.\e[0m\n\n"
        else
          echo "All" > "$SYSTEM_FILE"
          printf "\n\e[1;32mAll mode enabled.\e[0m\n\n"
        fi
        ;;
      autoupdate)
        if [[ -f $AUTO_UPDATE_FILE ]] && grep -q "yes" "$AUTO_UPDATE_FILE"; then
          echo "no" > "$AUTO_UPDATE_FILE"
          printf "\n\e[1;33mAuto-update disabled.\e[0m\n\n"
        else
          echo "yes" > "$AUTO_UPDATE_FILE"
          printf "\n\e[1;32mAuto-update enabled.\e[0m\n\n"
        fi
        ;;
      exit|q|"")
        printf "\nExiting secret menu and restarting script...\n\n"
        exec "$0" "$@"
        ;;
      *)
        printf "\n\e[1;31mUnknown command.\e[0m\n\n"
        ;;
    esac
  done
}

# ────────────────────────────────────────────────
#  Auto-update on Boot (if enabled)
# ────────────────────────────────────────────────

if [[ -f "$AUTO_UPDATE_FILE" ]] && grep -q "yes" "$AUTO_UPDATE_FILE"; then
  if [[ -f "$AUTO_UPDATE_SCRIPT" ]]; then
    python3 "$AUTO_UPDATE_SCRIPT"
  fi
fi

# ────────────────────────────────────────────────
#  OS Selection + Beta Flag
# ────────────────────────────────────────────────

if [[ -f $SYSTEM_FILE ]]; then
  SYSTEM="$(<"$SYSTEM_FILE")"
else
  PS3=$'\n👉 Select your OS: '
  options=(Mac Windows Linux Other)
  select opt in "${options[@]}"; do
    [[ -n $opt ]] || { printf "⚠ Invalid choice.\n"; continue; }
    SYSTEM="$opt"
    echo "$SYSTEM" > "$SYSTEM_FILE"
    break
  done
fi

if [[ -f $BETA_FILE ]]; then
  LOAD_BETA="$(<"$BETA_FILE")"
else
  LOAD_BETA="no"
fi

# ────────────────────────────────────────────────
#  Path Selection (Case-Sensitive)
# ────────────────────────────────────────────────

declare -a GH_PATHS

case "$SYSTEM" in
  Mac) GH_PATHS+=("scripts/MacOS") ;;
  Linux) GH_PATHS+=("scripts/Linux") ;;
  Windows) GH_PATHS+=("scripts/Windows") ;;
  Other) GH_PATHS+=("scripts/Other") ;;
  All) GH_PATHS+=("scripts/MacOS" "scripts/Linux" "scripts/Windows" "scripts/Other") ;;
  *) GH_PATHS+=("scripts") ;;
esac

[[ $LOAD_BETA == "yes" ]] && GH_PATHS+=("scripts/beta")

# ────────────────────────────────────────────────
#  Fetch Scripts with portable JSON parsing fallback
# ────────────────────────────────────────────────

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
else
  AUTH_HEADER=""
fi

printf "\e[1;34m🌐 Fetching available scripts for %s…\e[0m\n" "$SYSTEM"

# Declare associative arrays to hold scripts by folder (only if bash supports it)
declare -A SCRIPTS_BY_FOLDER
declare -A DISPLAY_BY_FOLDER

if [[ "$SYSTEM" == "All" ]]; then
  for path in "${GH_PATHS[@]}"; do
    echo "🔍 Checking: $path"
    response=$(curl -sf -H "User-Agent: ScriptGrab" -H "$AUTH_HEADER" --max-time 10 "https://api.github.com/repos/devmesis/scriptgrab/contents/$path") || {
      echo "⚠️ Failed to fetch $path"
      continue
    }

    files=()
    if command -v jq >/dev/null 2>&1; then
      while IFS= read -r file; do
        files+=("$file")
      done < <(echo "$response" | jq -r '.[] | select(.name | test("\\.(py|sh)$"; "i")) | .name')
    else
      tmpfile=$(mktemp)
      echo "$response" | grep -ioE '"name": "[^"]+\.(py|sh)"' | cut -d '"' -f4 > "$tmpfile"
      while IFS= read -r file; do
        files+=("$file")
      done < "$tmpfile"
      rm -f "$tmpfile"
    fi

    # Remove Download_LocalGrab from the list
    filtered_files=()
    for f in "${files[@]}"; do
      [[ "$f" == Download_LocalGrab.* ]] && continue
      filtered_files+=("$f")
    done

    folder_name="${path#scripts/}"
    for f in "${filtered_files[@]}"; do
      SCRIPTS_BY_FOLDER["$folder_name"]+="$f"$'\n'
    done
  done

else
  # For non-all system, just fetch scripts into one array
  raw_names=()
  for path in "${GH_PATHS[@]}"; do
    echo "🔍 Checking: $path"
    response=$(curl -sf -H "User-Agent: ScriptGrab" -H "$AUTH_HEADER" --max-time 10 "https://api.github.com/repos/devmesis/scriptgrab/contents/$path") || {
      echo "⚠️ Failed to fetch $path"
      continue
    }

    if command -v jq >/dev/null 2>&1; then
      while IFS= read -r file; do
        raw_names+=("$file")
      done < <(echo "$response" | jq -r '.[] | select(.name | test("\\.(py|sh)$"; "i")) | .name')
    else
      tmpfile=$(mktemp)
      echo "$response" | grep -ioE '"name": "[^"]+\.(py|sh)"' | cut -d '"' -f4 > "$tmpfile"
      while IFS= read -r file; do
        raw_names+=("$file")
      done < "$tmpfile"
      rm -f "$tmpfile"
    fi
  done

  # Remove Download_LocalGrab from the list entirely
  ARR=()
  for name in "${raw_names[@]}"; do
    [[ "$name" == Download_LocalGrab.* ]] && continue
    ARR+=("$name")
  done

  if (( ${#ARR[@]} == 0 )); then
    printf "\e[1;31m❌ No scripts found!\e[0m\n"
    exit 1
  fi

  # Prettify display names
  DISPLAY=()
  for name in "${ARR[@]}"; do
    base="${name%.*}"
    pretty="${base//_/ }"
    DISPLAY+=("$pretty")
  done
fi

# ────────────────────────────────────────────────
#  Interactive Menu
# ────────────────────────────────────────────────

PS3=$'\n\e[1;31m❌ Q for Quit\e[0m\n\n\e[1;33m👉 Your choice : \e[0m'

if [[ "$SYSTEM" == "All" ]]; then
  index=1
  declare -A INDEX_TO_SCRIPT
  echo -e "\n\e[1;36m📜 Available Scripts:\e[0m\n"

  for folder in MacOS Linux Windows Other; do
    scripts="${SCRIPTS_BY_FOLDER[$folder]}"
    if [[ -z "$scripts" ]]; then
      continue
    fi
    echo -e "\e[1;33m📜 $folder Scripts:\e[0m"

    while IFS= read -r script; do
      [[ -z "$script" ]] && continue
      base="${script%.*}"
      pretty="${base//_/ }"
      printf "%2d) %s\n" "$index" "$pretty"
      INDEX_TO_SCRIPT["$index,$folder"]="$script"
      ((index++))
    done <<<"$scripts"
    echo
  done

  while true; do
    read -rp $'\n\e[1;33m👉 Your choice: \e[0m' reply

    if [[ "$reply" =~ ^[qQ]$ ]]; then
      printf "\n\e[1;33m👋 Bye!\e[0m\n\n"
      exit 0
    fi

    if [[ "$reply" == "cheats" ]]; then
      secret_menu
      echo -e "\n\e[1;36m📜 Available Scripts:\e[0m\n"
      index=1
      for folder in MacOS Linux Windows Other; do
        scripts="${SCRIPTS_BY_FOLDER[$folder]}"
        [[ -z "$scripts" ]] && continue
        echo -e "\e[1;33m📜 $folder Scripts:\e[0m"
        while IFS= read -r script; do
          [[ -z "$script" ]] && continue
          base="${script%.*}"
          pretty="${base//_/ }"
          printf "%2d) %s\n" "$index" "$pretty"
          INDEX_TO_SCRIPT["$index,$folder"]="$script"
          ((index++))
        done <<<"$scripts"
        echo
      done
      continue
    fi

    if [[ "$reply" == "update" ]]; then
        # Manual update logic here
        echo -e "\n\e[1;34m🔄 Updating ScriptGrab to latest version...\e[0m\n"
        printf "\n" && sleep 2.0
        # (Insert your update logic, e.g., pulling from GitHub)
        exec "$0" "$@"
      fi

      if [[ "$reply" == "auto-update" ]]; then
        if [[ -f $AUTO_UPDATE_FILE ]] && grep -q "yes" "$AUTO_UPDATE_FILE"; then
          echo "no" > "$AUTO_UPDATE_FILE"
          printf "\n\e[1;33mAuto-update disabled.\e[0m\n\n"
        else
          echo "yes" > "$AUTO_UPDATE_FILE"
          printf "\n\e[1;32mAuto-update enabled.\e[0m\n\n"
        fi
        continue
      fi

    if [[ "$reply" =~ ^[0-9]+$ ]]; then
      found=0
      for folder in MacOS Linux Windows Other; do
        if [[ -n "${INDEX_TO_SCRIPT["$reply,$folder"]+set}" ]]; then
          script_name="${INDEX_TO_SCRIPT["$reply,$folder"]}"
          found=1
          break
        fi
      done
      if (( found )); then
        echo -e "\n\e[1;34m🚀 Running script $script_name from $folder...\e[0m\n"
        url="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/$folder/$script_name"
        curl -sL "$url" | bash
        exit 0
      else
        echo "⚠ Invalid choice."
      fi
    else
      echo "⚠ Invalid choice."
    fi
  done

else
  echo -e "\n\e[1;36m📜 Available Scripts:\e[0m\n"
  index=1
  declare -A INDEX_TO_SCRIPT

  for i in "${!ARR[@]}"; do
    printf "%2d) %s\n" "$((i+1))" "${DISPLAY[i]}"
    INDEX_TO_SCRIPT[$((i+1))]="${ARR[i]}"
  done

  while true; do
    read -rp $'\n\e[1;33m👉 Your choice: \e[0m' reply

    if [[ "$reply" =~ ^[qQ]$ ]]; then
      printf "\n\e[1;33m👋 Bye!\e[0m\n\n"
      exit 0
    fi

    if [[ "$reply" == "cheats" ]]; then
      secret_menu
      echo -e "\n\e[1;36m📜 Available Scripts:\e[0m\n"
      for i in "${!ARR[@]}"; do
        printf "%2d) %s\n" "$((i+1))" "${DISPLAY[i]}"
        INDEX_TO_SCRIPT[$((i+1))]="${ARR[i]}"
      done
      continue
    fi

    if [[ "$reply" =~ ^[0-9]+$ ]]; then
      if [[ -n "${INDEX_TO_SCRIPT[$reply]:-}" ]]; then
        script_name="${INDEX_TO_SCRIPT[$reply]}"
        echo -e "\n\e[1;34m🚀 Running script $script_name...\e[0m\n"
        url="<https://raw.githubusercontent.com/devmesis/scriptgrab/main/${GH_PATHS>[0]}/$script_name"
        curl -sL "$url" | bash
        exit 0
      else
        echo "⚠ Invalid choice."
      fi
    else
      echo "⚠ Invalid choice."
    fi
  done
fi
