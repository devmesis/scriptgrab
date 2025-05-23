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
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
    SYSTEM_FILE="$SCRIPT_DIR/scriptgrab/system.txt"
    BETA_FILE="$SCRIPT_DIR/scriptgrab/beta.txt"
    AUTO_UPDATE_FILE="$SCRIPT_DIR/scriptgrab/update.txt"
    AUTO_UPDATE_SCRIPT="$SCRIPT_DIR/scriptgrab/updater.py"
    LOG_FILE="$SCRIPT_DIR/scriptgrab/logs.txt"
    LOCAL_SCRIPT_DIR="/Users/devmesis/scriptgrab/scripts"

    # Read local version from file
    LOCAL_VERSION_FILE="/Users/devmesis/Developer/scriptgrab/scriptgrab/version.txt"
    if [[ -f "$LOCAL_VERSION_FILE" ]]; then
      LOCAL_VERSION=$(<"$LOCAL_VERSION_FILE")
    else
      LOCAL_VERSION="unknown"
    fi

    function log_info() {
      if [[ -f "$LOG_FILE" ]] && grep -iq "yes" "$LOG_FILE"; then
        echo -e "\e[1;35m$1\e[0m"
      fi
    }

    function github_fetch() {
      local url="$1"
      local tmpfile=$(mktemp)
      local http_code
      local response

      http_code=$(curl -s -w "%{http_code}" -H "User-Agent: ScriptGrab" ${2:+-H "$2"} --max-time 10 -o "$tmpfile" "$url")
      response=$(cat "$tmpfile")
      rm -f "$tmpfile"

      if [[ "$http_code" == "403" || "$http_code" == "429" ]] && [[ "$response" == *"rate limit"* ]]; then
        echo -e "\n\e[1;31mStopping, Rate Limited — try again in 1hr\e[0m" | tee /dev/stderr
        log_info "\e[1;36mGitHub says: $(echo "$response" | grep -o '"message":"[^"]*"' | cut -d: -f2-)\e[0m" | tee /dev/stderr
        exit 1
      fi

      if [[ "$http_code" != "200" ]]; then
        log_info "⚠️ Failed to fetch $url (HTTP $http_code)"
        echo ""
        return 1
      fi

      echo "$response"
    }



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
printf "%s \e[1;32mVersion: %s\e[0m\n" "$CLOUD_ICON" "$LOCAL_VERSION"

if [[ "$LOCAL_VERSION" != "unknown" && "$REMOTE_VERSION" != "Cracked" ]]; then
  if [[ "$(printf '%s\n%s' "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | head -n1)" == "$LOCAL_VERSION" && "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
    printf "\n\e[1;33m🚨 New update available: \e[1;32m%s\e[1;33m!\e[0m\n" "$REMOTE_VERSION"
    echo -e "\e[1;31mU for update or A to toggle auto update.\e[0m"
  fi
fi

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






function secret_menu() {
  while true; do
    read -rp "Toggle Cheats: " CMD
    case "$(echo "$CMD" | tr '[:upper:]' '[:lower:]')" in
      reset)
        rm -f "$SYSTEM_FILE" "$BETA_FILE" "$LOG_FILE"
        printf "\n\e[1;32mPreferences reset.\e[0m\n\n"

        ;;
      beta)
        if [[ -f $BETA_FILE ]]; then
          rm -f "$BETA_FILE"
          printf "\n\e[1;31mBeta mode disabled.\e[0m\n\n"
        else
          echo "yes" > "$BETA_FILE"
          printf "\n\e[1;32mBeta mode enabled.\e[0m\n\n"
        fi
        ;;
      all)
        if [[ -f $SYSTEM_FILE ]] && [[ "$(cat "$SYSTEM_FILE")" == "All" ]]; then
          rm -f "$SYSTEM_FILE"
          printf "\n\e[1;31mAll mode disabled.\e[0m\n\n"
        else
          echo "All" > "$SYSTEM_FILE"
          printf "\n\e[1;32mAll mode enabled.\e[0m\n\n"
        fi
        ;;
      logs)
        if [[ -f $LOG_FILE ]] && grep -iq "yes" "$LOG_FILE"; then
          echo "no" > "$LOG_FILE"
          printf "\n\e[1;31mLogging disabled.\e[0m\n\n"
        else
          echo "yes" > "$LOG_FILE"
          printf "\n\e[1;32mLogging enabled.\e[0m\n\n"
        fi
        ;;
        os)
                rm -f "$SYSTEM_FILE"
                printf "\n\e[1;32mOS selection cleared. Restarting for new OS choice...\e[0m\n\n"
                exec "$0" "$@"
                ;;
      exit|q|r|"")
        printf "\nExiting secret menu and restarting script...\n\n"
        sleep 1
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

if [[ "${CLOUD_STATUS,,}" == "yes" ]]; then
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
      response=$(github_fetch "https://api.github.com/repos/devmesis/scriptgrab/contents/$path" "$AUTH_HEADER")
      if [[ -z "$response" ]]; then
        log_info "⚠️ Failed to fetch $path"
        continue
      fi

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
      beta_response=$(github_fetch "https://api.github.com/repos/devmesis/betagrap/contents/beta" "$AUTH_HEADER")
      if [[ -z "$beta_response" ]]; then
        log_info "⚠️ Failed to fetch beta scripts"
        beta_response=""
      fi

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

else
  # For specific system (e.g., Windows, Mac, Linux, Other)
  for path in "${GH_PATHS[@]}"; do
    log_info "🔍 Checking: $path"
    response=$(github_fetch "https://api.github.com/repos/devmesis/scriptgrab/contents/$path" "$AUTH_HEADER")
    if [[ -z "$response" ]]; then
      log_info "⚠️ Failed to fetch $path"
      continue
    fi

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
    SCRIPTS_BY_FOLDER["$folder_name"]=$(printf '%s\n' "${filtered_files[@]}")

  done

  # If Beta enabled, fetch beta scripts
  if $BETA_ENABLED; then
    log_info "🔍 Checking: beta"
    beta_response=$(github_fetch "https://api.github.com/repos/devmesis/betagrap/contents/beta" "$AUTH_HEADER")
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

    filtered_beta_files=()
    for f in "${beta_files[@]}"; do
      [[ "$f" == Download_LocalGrab.* ]] && continue
      filtered_beta_files+=("$f")
    done
    SCRIPTS_BY_FOLDER["Beta"]=$(printf '%s\n' "${filtered_beta_files[@]}")
  fi
fi
else
    # Map SYSTEM to the correct folder name
    case "$SYSTEM" in
      Mac)   LOCAL_OS_FOLDER="MacOS" ;;
      Linux) LOCAL_OS_FOLDER="Linux" ;;
      Windows) LOCAL_OS_FOLDER="Windows" ;;
      Other) LOCAL_OS_FOLDER="Other" ;;
      All)   LOCAL_OS_FOLDER="All" ;;
      *)     LOCAL_OS_FOLDER="$SYSTEM" ;;
    esac

    echo -e "\n\e[1;36m📜 Scripts for $SYSTEM:\e[0m\n"
    INDEX=1
    declare -A INDEX_TO_SCRIPT

    if [[ "$LOCAL_OS_FOLDER" == "All" ]]; then
      FIND_PATH="$LOCAL_SCRIPT_DIR"
    else
      FIND_PATH="$LOCAL_SCRIPT_DIR/$LOCAL_OS_FOLDER"
    fi

    # Only list scripts if the folder exists
    if [[ -d "$FIND_PATH" ]]; then
        while IFS= read -r script; do
          base=$(basename "$script")
          pretty="${base%.*}"
          pretty="${pretty//_/ }"
          printf " %2d) %s\n" "$INDEX" "$pretty"
          INDEX_TO_SCRIPT["$INDEX"]="$script"
          ((INDEX++))
        done < <(find "$FIND_PATH" -type f \( -name "*.sh" -o -name "*.py" \) | sort)
    fi

    if [[ $INDEX -eq 1 ]]; then
      echo "⚠ No local scripts found for $SYSTEM in $FIND_PATH."
      exit 0
    fi

    while true; do
      read -rp $'\n\e[1;33m👉 Your choice: \e[0m' reply
      case "${reply,,}" in
        q) echo -e "\n\e[1;33m👋 Bye!\e[0m\n\n"; exit 0 ;;
        cheats)
              secret_menu
              continue
              ;;
        *)
          if [[ "$reply" =~ ^[0-9]+$ ]] && [[ -n "${INDEX_TO_SCRIPT[$reply]:-}" ]]; then
            script_path="${INDEX_TO_SCRIPT[$reply]}"
            echo -e "\n\e[1;34m🚀 Running $script_path\e[0m\n"
            if [[ "$script_path" == *.py ]]; then
              python3 "$script_path"
            else
              bash "$script_path"
            fi
            exit 0
          else
            echo "⚠ Invalid choice."
          fi
          ;;
      esac
    done

fi

# ────────────────────────────────────────────────
#  Interactive Menu (Global Index, Beta-aware, U=Update, A=Auto-Update)
# ────────────────────────────────────────────────

PS3=$'\n\e[1;31m❌ Q=Quit | U=Update | A=Auto-Update\e[0m\n\n\e[1;33m👉 Your choice : \e[0m'

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
        INDEX_TO_SCRIPT["$INDEX"]="$folder/$script"
        ((INDEX++))
      done <<< "${SCRIPTS_BY_FOLDER[$folder]}"
      echo
    fi
  done

  while true; do
    read -rp $'\n\e[1;33m👉 Your choice: \e[0m' reply

    case "${reply,,}" in
      q)
        printf "\n\e[1;33m👋 Bye!\e[0m\n\n"
        exit 0
        ;;
      u)
      echo -e "\n\e[1;34m🔄 Updating ScriptGrab to latest version...\e[0m\n"

      # Spinner animation for 2 seconds
      spin='|/-\'
      for i in {1..20}; do
        i=$(( (i+1) %4 ))
        printf "\r\e[1;36m[%c] Updating...\e[0m" "${spin:$i:1}"
        sleep 0.1
      done
      printf "\r\e[1;36m[✔] Restarting!\e[0m\n"
      sleep 0.3

      exec "$0" "$@"
        ;;
      a)
        if [[ -f $AUTO_UPDATE_FILE ]] && grep -q "yes" "$AUTO_UPDATE_FILE"; then
          echo "no" > "$AUTO_UPDATE_FILE"
          printf "\n\e[1;33mAuto-update disabled.\e[0m\n\n"
        else
          echo "yes" > "$AUTO_UPDATE_FILE"
          printf "\n\e[1;32mAuto-update enabled.\e[0m\n\n"
        fi
        continue
        ;;
        cheats)
              secret_menu
              continue
              ;;
              r)
                   echo -e "\n\e[1;34m🔁 Restarting ScriptGrab...\e[0m\n"
                   spin='|/-\'
                   for i in {1..20}; do
                     i=$(( (i+1) %4 ))
                     printf "\r\e[1;36m[%c] Restarting...\e[0m" "${spin:$i:1}"
                     sleep 0.1
                   done
                   printf "\r\e[1;36m[✔] Restarting!\e[0m\n"
                   sleep 0.3
                   exec "$0" "$@"
                   ;;
               esac

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
    echo -e "\n\e[1;36m📜 Scripts for $SYSTEM:\e[0m\n"
    declare -A INDEX_TO_SCRIPT
    INDEX=1

    folder="${GH_PATHS[0]#scripts/}"  # e.g. "MacOS"

    if [[ -n "${SCRIPTS_BY_FOLDER[$folder]}" ]]; then
      while IFS= read -r script; do
        [[ -z "$script" ]] && continue
        base="${script%.*}"
        pretty="${base//_/ }"
        printf " %2d) %s\n" "$INDEX" "$pretty"
        INDEX_TO_SCRIPT["$INDEX"]="$folder/$script"
        ((INDEX++))
      done <<< "${SCRIPTS_BY_FOLDER[$folder]}"
    else
      echo "⚠ No scripts found for $SYSTEM."
    fi

    # Add Beta scripts if Beta enabled
    if $BETA_ENABLED && [[ -n "${SCRIPTS_BY_FOLDER[Beta]}" ]]; then
      echo -e "\n\e[1;33m📜 Beta Scripts:\e[0m"
      while IFS= read -r script; do
        [[ -z "$script" ]] && continue
        base="${script%.*}"
        pretty="${base//_/ }"
        printf " %2d) [BETA] %s\n" "$INDEX" "$pretty"
        INDEX_TO_SCRIPT["$INDEX"]="Beta/$script"
        ((INDEX++))
      done <<< "${SCRIPTS_BY_FOLDER[Beta]}"
    fi

    echo

    PS3=$'\n\e[1;31m❌ Q=Quit | U=Update | A=Auto-Update\e[0m\n\n\e[1;33m👉 Your choice : \e[0m'

    while true; do
      read -rp $'\n\e[1;33m👉 Your choice: \e[0m' reply
      case "${reply,,}" in
        q)
          printf "\n\e[1;33m👋 Bye!\e[0m\n\n"
          exit 0
          ;;
        u)
          echo -e "\n\e[1;34m🔄 Updating ScriptGrab to latest version...\e[0m\n"
          spin='|/-\'
          for i in {1..20}; do
            i=$(( (i+1) %4 ))
            printf "\r\e[1;36m[%c] Updating...\e[0m" "${spin:$i:1}"
            sleep 0.1
          done
          printf "\r\e[1;36m[✔] Restarting!\e[0m\n"
          sleep 0.3
          exec "$0" "$@"
          ;;
        a)
          if [[ -f $AUTO_UPDATE_FILE ]] && grep -q "yes" "$AUTO_UPDATE_FILE"; then
            echo "no" > "$AUTO_UPDATE_FILE"
            printf "\n\e[1;33mAuto-update disabled.\e[0m\n\n"
          else
            echo "yes" > "$AUTO_UPDATE_FILE"
            printf "\n\e[1;32mAuto-update enabled.\e[0m\n\n"
          fi
          continue
          ;;
        cheats)
          secret_menu
          echo -e "\n\e[1;36m📜 Scripts for $SYSTEM:\e[0m\n"
          # Redisplay scripts after secret menu
          INDEX=1
          if [[ -n "${SCRIPTS_BY_FOLDER[$folder]}" ]]; then
            while IFS= read -r script; do
              [[ -z "$script" ]] && continue
              base="${script%.*}"
              pretty="${base//_/ }"
              printf " %2d) %s\n" "$INDEX" "$pretty"
              INDEX_TO_SCRIPT["$INDEX"]="$folder/$script"
              ((INDEX++))
            done <<< "${SCRIPTS_BY_FOLDER[$folder]}"
          fi
          if $BETA_ENABLED && [[ -n "${SCRIPTS_BY_FOLDER[Beta]}" ]]; then
            echo -e "\n\e[1;33m📜 Beta Scripts:\e[0m"
            while IFS= read -r script; do
              [[ -z "$script" ]] && continue
              base="${script%.*}"
              pretty="${base//_/ }"
              printf " %2d) [BETA] %s\n" "$INDEX" "$pretty"
              INDEX_TO_SCRIPT["$INDEX"]="Beta/$script"
              ((INDEX++))
            done <<< "${SCRIPTS_BY_FOLDER[Beta]}"
          fi
          continue
          ;;
        r)
          echo -e "\n\e[1;34m🔁 Restarting ScriptGrab...\e[0m\n"
          spin='|/-\'
          for i in {1..20}; do
            i=$(( (i+1) %4 ))
            printf "\r\e[1;36m[%c] Restarting...\e[0m" "${spin:$i:1}"
            sleep 0.1
          done
          printf "\r\e[1;36m[✔] Restarting!\e[0m\n"
          sleep 0.3
          exec "$0" "$@"
          ;;
        *)
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
          ;;
      esac
    done
  fi
