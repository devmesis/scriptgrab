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
  CLOUD_ICON="🔌"
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

command -v python3 >/dev/null 2>&1 || { log_info "❌ Python 3 required. Abort."; exit 1; }
command -v bash >/dev/null 2>&1   || { log_info "❌ Bash required. Abort."; exit 1; }

# ────────────────────────────────────────────────
#  Secret Settings Menu
# ────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_FILE="$SCRIPT_DIR/scriptgrab/system.txt"
BETA_FILE="$SCRIPT_DIR/scriptgrab/beta.txt"
AUTO_UPDATE_FILE="$SCRIPT_DIR/scriptgrab/update.txt"
AUTO_UPDATE_SCRIPT="$SCRIPT_DIR/scriptgrab/updater.py"
LOG_FILE="$SCRIPT_DIR/scriptgrab/logs.txt"

function log_info() {
  if [[ -f "$LOG_FILE" ]] && grep -iq "yes" "$LOG_FILE"; then
    echo -e "\e[1;35m$1\e[0m"
  fi
}

function secret_menu() {
  while true; do
    read -rp "Toggle Cheats: " CMD
    case "$(echo "$CMD" | tr '[:upper:]' '[:lower:]')" in
      reset)
        rm -f "$SYSTEM_FILE" "$BETA_FILE" "$LOG_FILE"
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
      logs)
        if [[ -f $LOG_FILE ]] && grep -iq "yes" "$LOG_FILE"; then
          echo "no" > "$LOG_FILE"
          printf "\n\e[1;33mLogging disabled.\e[0m\n\n"
        else
          echo "yes" > "$LOG_FILE"
          printf "\n\e[1;32mLogging enabled.\e[0m\n\n"
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

if [[ $LOAD_BETA == "yes" ]]; then
  BETA_ENABLED=true
else
  BETA_ENABLED=false
fi

# ────────────────────────────────────────────────
#  Fetch Scripts with portable JSON parsing fallback
# ────────────────────────────────────────────────

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
else
  AUTH_HEADER=""
fi

printf "\e[1;34m🌐 Fetching scripts for %s\e[0m\n" "$SYSTEM"

# Declare associative arrays to hold scripts by folder (only if bash supports it)
declare -A SCRIPTS_BY_FOLDER
declare -A DISPLAY_BY_FOLDER

if [[ "$SYSTEM" == "All" ]]; then
  for path in "${GH_PATHS[@]}"; do
    log_info "🔍 Checking: $path"
    response=$(curl -sf -H "User-Agent: ScriptGrab" -H "$AUTH_HEADER" --max-time 10 "https://api.github.com/repos/devmesis/scriptgrab/contents/$path") || {
      log_info "⚠️ Failed to fetch $path"
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

  # Only fetch Beta if enabled!
  if $BETA_ENABLED; then
    log_info "🔍 Checking: beta"
    beta_response=$(curl -sf -H "User-Agent: ScriptGrab" --max-time 10 "https://api.github.com/repos/devmesis/betagrap/contents/beta") || {
      log_info "⚠️ Failed to fetch beta scripts"
      beta_response=""
    }

    beta_files=()
    if [[ -n "$beta_response" ]]; then
      if command -v jq >/dev/null 2>&1; then
        while IFS= read -r file; do
          beta_files+=("$file")
        done < <(echo "$beta_response" | jq -r '.[] | select(.name | test("\\.(py|sh)$"; "i")) | .name')
      else
        tmpfile=$(mktemp)
        echo "$beta_response" | grep -ioE '"name": "[^"]+\.(py|sh)"' | cut -d '"' -f4 > "$tmpfile"
        while IFS= read -r file; do
          beta_files+=("$file")
        done < "$tmpfile"
        rm -f "$tmpfile"
      fi
    fi

    # Filter and add Beta scripts to the Beta folder
    for f in "${beta_files[@]}"; do
      [[ "$f" == Download_LocalGrab.* ]] && continue
      SCRIPTS_BY_FOLDER["Beta"]+="$f"$'\n'
    done
  fi
fi


# ────────────────────────────────────────────────
#  Interactive Menu (Global Index, Beta-aware)
# ────────────────────────────────────────────────

# ────────────────────────────────────────────────
#  Interactive Menu (Global Index, Beta-aware)
# ────────────────────────────────────────────────

PS3=$'\n\e[1;31m❌ Q for Quit\e[0m\n\n\e[1;33m👉 Your choice : \e[0m'

if [[ "$SYSTEM" == "All" ]]; then
  echo -e "\n\e[1;36m📜 Scripts:\e[0m\n"
  declare -A INDEX_TO_SCRIPT
  folders=(MacOS Linux Windows Other)
  $BETA_ENABLED && folders+=(Beta)

  INDEX=1

  for folder in "${folders[@]}"; do
    if [[ -n "${SCRIPTS_BY_FOLDER[$folder]}" ]]; then
      echo -e "\e[1;33m📜 $folder Scripts:\e[0m"
      while IFS= read -r script; do
        [[ -z "$script" ]] && continue
        base="${script%.*}"
        pretty="${base//_/ }"
        if [[ "$folder" == "Beta" ]]; then
          printf " %2d) [BETA] %s\n" "$INDEX" "$pretty"
        else
          printf " %2d) %s\n" "$INDEX" "$pretty"
        fi
        INDEX_TO_SCRIPT["$INDEX"]="$folder/$script"  # Store full path
        ((INDEX++))
      done <<< "${SCRIPTS_BY_FOLDER[$folder]}"
      echo
    fi
  done

  if (( INDEX == 1 )); then
    echo "❌ No scripts found!"
    exit 1
  fi

  while true; do
    read -rp $'\n\e[1;33m👉 Your choice: \e[0m' reply

    if [[ "$reply" =~ ^[qQ]$ ]]; then
      printf "\n\e[1;33m👋 Bye!\e[0m\n\n"
      exit 0
    fi

    if [[ "$reply" == "cheats" ]]; then
      secret_menu
      echo -e "\n\e[1;36m📜 Scripts:\e[0m\n"
      INDEX=1
      for folder in "${folders[@]}"; do
        if [[ -n "${SCRIPTS_BY_FOLDER[$folder]}" ]]; then
          echo -e "\e[1;33m📜 $folder Scripts:\e[0m"
          while IFS= read -r script; do
            [[ -z "$script" ]] && continue
            base="${script%.*}"
            pretty="${base//_/ }"
            if [[ "$folder" == "Beta" ]]; then
              printf " %2d) [BETA] %s\n" "$INDEX" "$pretty"
            else
              printf " %2d) %s\n" "$INDEX" "$pretty"
            fi
            INDEX_TO_SCRIPT["$INDEX"]="$folder/$script"
            ((INDEX++))
          done <<< "${SCRIPTS_BY_FOLDER[$folder]}"
          echo
        fi
      done
      continue
    fi

    if [[ "$reply" == "update" ]]; then
      echo -e "\n\e[1;34m🔄 Updating ScriptGrab to latest version...\e[0m\n"
      printf "\n" && sleep 2.0
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
      if [[ -n "${INDEX_TO_SCRIPT[$reply]:-}" ]]; then
        script_path="${INDEX_TO_SCRIPT[$reply]}"
        folder="${script_path%%/*}"
        script_name="${script_path#*/}"
        echo -e "\n\e[1;34m🚀 Running $script_name from $folder\e[0m\n"
        if [[ "$folder" == "Beta" ]]; then
          url="https://raw.githubusercontent.com/devmesis/betagrap/main/beta/$script_name"
        else
          url="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/$folder/$script_name"
        fi
        if [[ "$script_name" == *.py ]]; then
          curl -sL "$url" | python3
        else
          curl -sL "$url" | bash
        fi
        exit 0
      else
        echo "⚠ Invalid choice."
      fi
    else
      echo "⚠ Invalid choice."
    fi
  done

else
  echo -e "\n\e[1;36m📜 Scripts:\e[0m\n"
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
      echo -e "\n\e[1;36m📜 Scripts:\e[0m\n"
      for i in "${!ARR[@]}"; do
        printf "%2d) %s\n" "$((i+1))" "${DISPLAY[i]}"
        INDEX_TO_SCRIPT[$((i+1))]="${ARR[i]}"
      done
      continue
    fi

    if [[ "$reply" =~ ^[0-9]+$ ]]; then
      if [[ -n "${INDEX_TO_SCRIPT[$reply]:-}" ]]; then
        script_name="${INDEX_TO_SCRIPT[$reply]}"
        echo -e "\n\e[1;34m🚀 Running $script_name\e[0m\n"
        if [[ "$folder" == "Beta" ]]; then
          url="https://raw.githubusercontent.com/devmesis/betagrap/main/beta/$script_name"
        else
          url="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/$folder/$script_name"
        fi
        if [[ "$script_name" == *.py ]]; then
          curl -sL "$url" | python3
        else
          curl -sL "$url" | bash
        fi
        exit 0
      else
        echo "⚠ Invalid choice."
      fi
    else
      echo "⚠ Invalid choice."
    fi
  done
fi
