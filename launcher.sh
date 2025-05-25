#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  📦 ScriptGrab — Your Script Launcher, Reimagined
#  By Devmesis
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ⚙️  Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MSG_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/message.txt"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/version.txt"
GH_USER="devmesis"
GH_REPO="scriptgrab"
GH_BRANCH="main"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  📝 Logging Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALL_LOGS=0  # Default logs off
INFO_LOGS=1
DEBUG_LOGS=1
WARN_LOGS=1
ERROR_LOGS=1

TERM_WIDTH=$(tput cols)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  🎯 Display Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

center_text() {
    local text="$1"
    local width=${#text}
    local padding=$(( (TERM_WIDTH - width) / 2 ))
    printf "%${padding}s%s\n" "" "$text"
}

center_colored_text() {
    local text="$1"
    local color="$2"
    local width=${#text}
    local padding=$(( (TERM_WIDTH - width) / 2 ))
    printf "%${padding}s$color%s\e[0m\n" "" "$text"
}

prompt_text() {
    local text="$1"
    printf "\e[1;37m%s\e[0m" "$text"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  🔊 Logging Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log_info() {
    if [[ $ALL_LOGS -eq 1 && $INFO_LOGS -eq 1 ]]; then
        center_colored_text "[LOG] $1" "\e[38;5;213m" >&2
    fi
}

log_debug() {
    if [[ $ALL_LOGS -eq 1 && $DEBUG_LOGS -eq 1 ]]; then
        center_colored_text "[DEBUG] $1" "\e[38;5;219m" >&2
    fi
}

log_warn() {
    if [[ $ALL_LOGS -eq 1 && $WARN_LOGS -eq 1 ]]; then
        center_colored_text "[WARN] $1" "\e[38;5;207m" >&2
    fi
}

log_error() {
    if [[ $ALL_LOGS -eq 1 || $ERROR_LOGS -eq 1 ]]; then
        center_colored_text "[ERROR] $1" "\e[38;5;198m" >&2
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  🌐 Network Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

github_fetch() {
    local url="$1"
    local tmpfile http_code response
    
    if [[ $ALL_LOGS -eq 1 ]]; then
        log_debug "Fetching from URL: $url" >&2
    fi
    
    tmpfile=$(mktemp)
    if [[ $ALL_LOGS -eq 1 ]]; then
        log_debug "Created temporary file: $tmpfile" >&2
    fi
    
    http_code=$(curl -s -w "%{http_code}" -H "User-Agent: ScriptGrab" --max-time 10 -o "$tmpfile" "$url")
    response=$(cat "$tmpfile")
    
    if [[ $ALL_LOGS -eq 1 ]]; then
        log_debug "HTTP Response Code: $http_code" >&2
    fi
    
    rm -f "$tmpfile"
    if [[ $ALL_LOGS -eq 1 ]]; then
        log_debug "Cleaned up temporary file" >&2
    fi

    if [[ "$http_code" == "403" || "$http_code" == "429" ]] && [[ "$response" == *"rate limit"* ]]; then
        log_error "Rate Limited — try again in 1hr" >&2
        if [[ $ALL_LOGS -eq 1 ]]; then
            log_info "GitHub says: $(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)" >&2
        fi
        exit 1
    fi

    if [[ "$http_code" != "200" ]]; then
        if [[ $ALL_LOGS -eq 1 ]]; then
            log_warn "Failed to fetch $url (HTTP $http_code)" >&2
        fi
        echo ""
        return 1
    fi

    printf "%s" "$response"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  🔄 Utility Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

restart_script() {
    log_info "Restarting ScriptGrab..."
    exec "$0" "$@"
}

urlencode() {
    local string="$1"
    local length="${#string}"
    local encoded=""
    local pos c o
    
    for (( pos=0 ; pos<length ; pos++ )); do
        c="${string:$pos:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) o="$c" ;;
            *) printf -v o '%%%02X' "'$c"
        esac
        encoded+="$o"
    done
    echo "$encoded"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ✅ Dependency Check
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

command -v python3 >/dev/null 2>&1 || { log_error "Python 3 required. Abort."; exit 1; }
command -v bash    >/dev/null 2>&1 || { log_error "Bash required. Abort."; exit 1; }

clear

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  🎨 ASCII Art Display
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

while IFS= read -r line; do
  center_colored_text "$line" "\e[1;34m"
  sleep 0.1
done <<'EOF'

  ██████  ▄████▄   ██▀███   ██▓ ██▓███  ▄▄▄█████▓  ▄████  ██▀███   ▄▄▄       ▄▄▄▄   
▒██    ▒ ▒██▀ ▀█  ▓██ ▒ ██▒▓██▒▓██░  ██▒▓  ██▒ ▓▒ ██▒ ▀█▒▓██ ▒ ██▒▒████▄    ▓█████▄ 
░ ▓██▄   ▒▓█    ▄ ▓██ ░▄█ ▒▒██▒▓██░ ██▓▒▒ ▓██░ ▒░▒██░▄▄▄░▓██ ░▄█ ▒▒██  ▀█▄  ▒██▒ ▄██
  ▒   ██▒▒▓▓▄ ▄██▒▒██▀▀█▄  ░██░▒██▄█▓▒ ▒░ ▓██▓ ░ ░▓█  ██▓▒██▀▀█▄  ░██▄▄▄▄██ ▒██░█▀  
▒██████▒▒▒ ▓███▀ ░░██▓ ▒██▒░██░▒██▒ ░  ░  ▒██▒ ░ ░▒▓███▀▒░██▓ ▒██▒ ▓█   ▓██▒░▓█  ▀█▓
▒ ▒▓▒ ▒ ░░ ░▒ ▒  ░░ ▒▓ ░▒▓░░▓  ▒▓▒░ ░  ░  ▒ ░░    ░▒   ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░▒▓███▀▒
░ ░▒  ░ ░  ░  ▒     ░▒ ░ ▒░ ▒ ░░▒ ░         ░      ░   ░   ░▒ ░ ▒░  ▒   ▒▒ ░▒░▒   ░ 
░  ░  ░  ░          ░░   ░  ▒ ░░░         ░      ░ ░   ░   ░░   ░   ░   ▒    ░    ░ 
      ░  ░ ░         ░      ░                          ░    ░           ░  ░ ░      
         ░                                                                        ░ 

EOF

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  📊 Info Display
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REMOTE_VERSION=$(curl -sf "$REMOTE_VERSION_URL" | tr -d '\r\n' || echo "Cracked")
center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
center_colored_text "By Devmesis | $(date '+%Y-%m-%d %H:%M:%S')" "\e[1;33m"
center_colored_text "Version: $REMOTE_VERSION" "\e[1;32m"
if [[ ${MSG+x} && -n "${MSG// }" ]]; then
    center_colored_text "$MSG" "\e[1;33m"
fi
center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"


MSG=$(curl -sf "$MSG_URL" || :)
if [[ ${MSG+x} && -n "${MSG// }" ]]; then
printf "\n"
    center_colored_text "$MSG" "\e[1;33m"
    printf "\n"
fi
sleep 0.5

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  📋 Main Menu
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


echo -e "\n"
center_colored_text "━━━━━━ 🖥️  Select Your Operating System ━━━━━━" "\e[1;36m"
printf "\n"

options=(Mac Windows Linux Other Download)
for i in "${!options[@]}"; do
    center_colored_text "$(printf "  %d) %s  " $((i+1)) "${options[i]}")" "\e[1;33m"
done
printf "\n"
center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
echo -e "\n"

while true; do
    printf "    "
    prompt_text "👉 Your choice: "
    read -r choice
    
    case "${choice,,}" in
        logs)
            ALL_LOGS=$((1-ALL_LOGS))  # Toggle between 0 and 1
            center_colored_text "🔄 Logging has been turned $([ "$ALL_LOGS" -eq 1 ] && echo "ON" || echo "OFF")" "\e[1;35m"
            sleep 1
            ;;
        q) 
            printf "\n"
            center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
            center_colored_text "👋 Thanks for using ScriptGrab!" "\e[1;33m"
            center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
            printf "\n"
            exit 0 
            ;;
        r) 
            restart_script 
            ;;
        [1-5])
            opt="${options[$((choice-1))]}"
            if [[ "$opt" == "Download" ]]; then
                echo -e "\n\e[1;34m🚀 Installing ScriptGrab...\e[0m"
                curl -sL "https://github.com/devmesis/scriptgrab/raw/main/scripts/Application/install.py" | python3
                echo -e "\n\e[1;32m✅ ScriptGrab installation completed.\e[0m\n"
                exit 0
            fi
            case "$opt" in
                Mac)      SYSTEM="MacOS";;
                Windows)  SYSTEM="Windows";;
                Linux)    SYSTEM="Linux";;
                Other)    SYSTEM="Other";;
            esac
            break
            ;;
        *) 
            center_colored_text "⚠️  Invalid choice. Please select 1-5, Q to quit, or R to restart." "\e[1;31m"
            ;;
    esac
done

clear

while IFS= read -r line; do
  center_colored_text "$line" "\e[1;34m"
  sleep 0.1
done <<'EOF'

  ██████  ▄████▄   ██▀███   ██▓ ██▓███  ▄▄▄█████▓  ▄████  ██▀███   ▄▄▄       ▄▄▄▄   
▒██    ▒ ▒██▀ ▀█  ▓██ ▒ ██▒▓██▒▓██░  ██▒▓  ██▒ ▓▒ ██▒ ▀█▒▓██ ▒ ██▒▒████▄    ▓█████▄ 
░ ▓██▄   ▒▓█    ▄ ▓██ ░▄█ ▒▒██▒▓██░ ██▓▒▒ ▓██░ ▒░▒██░▄▄▄░▓██ ░▄█ ▒▒██  ▀█▄  ▒██▒ ▄██
  ▒   ██▒▒▓▓▄ ▄██▒▒██▀▀█▄  ░██░▒██▄█▓▒ ▒░ ▓██▓ ░ ░▓█  ██▓▒██▀▀█▄  ░██▄▄▄▄██ ▒██░█▀  
▒██████▒▒▒ ▓███▀ ░░██▓ ▒██▒░██░▒██▒ ░  ░  ▒██▒ ░ ░▒▓███▀▒░██▓ ▒██▒ ▓█   ▓██▒░▓█  ▀█▓
▒ ▒▓▒ ▒ ░░ ░▒ ▒  ░░ ▒▓ ░▒▓░░▓  ▒▓▒░ ░  ░  ▒ ░░    ░▒   ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░▒▓███▀▒
░ ░▒  ░ ░  ░  ▒     ░▒ ░ ▒░ ▒ ░░▒ ░         ░      ░   ░   ░▒ ░ ▒░  ▒   ▒▒ ░▒░▒   ░ 
░  ░  ░  ░          ░░   ░  ▒ ░░░         ░      ░ ░   ░   ░░   ░   ░   ▒    ░    ░ 
      ░  ░ ░         ░      ░                          ░    ░           ░  ░ ░      
         ░                                                                        ░ 

EOF

printf "\n"
center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
center_colored_text "By Devmesis | $(date '+%Y-%m-%d %H:%M:%S')" "\e[1;33m"
center_colored_text "Version: $REMOTE_VERSION" "\e[1;32m"
if [[ ${MSG+x} && -n "${MSG// }" ]]; then
    center_colored_text "$MSG" "\e[1;33m"
fi
center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
printf "\n"

log_info "🌐 Fetching scripts for $SYSTEM..."
printf "\n"

GH_OSFOLDER="scripts/$SYSTEM"
response=$(github_fetch "https://api.github.com/repos/$GH_USER/$GH_REPO/contents/$GH_OSFOLDER")

if [[ "$response" =~ "<!DOCTYPE html>" ]]; then
    log_error "GitHub returned HTML (rate limit or bad URL)."
    printf "\e[1;31m❌ No scripts found for %s! (HTML response)\e[0m\n" "$SYSTEM"
    exit 1
fi

if ! echo "$response" | grep -q '^\s*\['; then
    api_msg=$(echo "$response" | grep -o '"message": *"[^"]*"' | cut -d'"' -f4)
    log_error "GitHub API error: ${api_msg:-Unknown error}"
    printf "\e[1;31m❌ No scripts found for %s! %s\e[0m\n" "$SYSTEM" "${api_msg:-}"
    exit 1
fi

names=()
if command -v jq >/dev/null 2>&1; then
    while IFS= read -r name; do
        names+=("$name")
    done < <(echo "$response" | jq -r '.[] | select(.name | test("\\.(py|sh|ps1)$"; "i")) | .name' 2>/dev/null)
else
    while IFS= read -r name; do
        names+=("$name")
    done < <(echo "$response" | grep -oE '"name":\s*"[^"]+\.(py|sh|ps1)"' | cut -d'"' -f4)
fi

if (( ${#names[@]} == 0 )); then
    printf "\e[1;31m❌ No scripts found!\e[0m\n"
    exit 1
fi

while true; do
    center_colored_text "━━━━━━━━━━━━━━ AVAILABLE SCRIPTS ━━━━━━━━━━━━━━" "\e[1;36m"
    printf "\n"
    for i in "${!names[@]}"; do
        base="${names[$i]%.*}"
        pretty="${base//_/ }"
        center_colored_text "$(printf "  %2d) %s  " "$((i+1))" "$pretty")" "\e[1;37m"
    done
    printf "\n"
    printf "    "
    prompt_text "👉 Pick script: "
    read -r reply
    
    case "${reply,,}" in
        q) 
            printf "\n"
            center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
            center_colored_text "👋 Thanks for using ScriptGrab!" "\e[1;33m"
            center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
            printf "\n\n"
            exit 0 
            ;;
        r) 
            restart_script 
            ;;
        [1-9]|[1-9][0-9]*)
            if (( reply >= 1 && reply <= ${#names[@]} )); then
                script_name="${names[$((reply-1))]}"
                
                encoded_script_name=$(urlencode "$script_name")
                url="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/scripts/$SYSTEM/$encoded_script_name"
                
                printf "\n"
                center_colored_text "━━━━━━━━━━━━━━ 🚀 Running $script_name... ━━━━━━━━━━━━━━" "\e[1;34m"
                printf "\n"

                if [[ "$script_name" == *.py ]]; then
                    curl -sL "$url" | python3
                elif [[ "$script_name" == *.ps1 ]]; then
                    curl -sL "$url" | pwsh -NoProfile -
                else
                    curl -sL "$url" | bash
                fi
                
                printf "\n"
                center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
                center_colored_text "▶️  Script completed!" "\e[1;32m"
                center_colored_text "Press any key to continue, Q to quit" "\e[1;33m"
                center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
                printf "\n    "  
                read -n 1 -s next
                
                if [[ "${next,,}" == "q" ]]; then
                    printf "\n"
                    center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
                    center_colored_text "👋 Thanks for using ScriptGrab!" "\e[1;33m"
                    center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
                    printf "\n\n"
                    exit 0
                fi
                clear

                while IFS= read -r line; do
                  center_colored_text "$line" "\e[1;34m"
                  sleep 0.1
                done <<'EOF'

  ██████  ▄████▄   ██▀███   ██▓ ██▓███  ▄▄▄█████▓  ▄████  ██▀███   ▄▄▄       ▄▄▄▄   
▒██    ▒ ▒██▀ ▀█  ▓██ ▒ ██▒▓██▒▓██░  ██▒▓  ██▒ ▓▒ ██▒ ▀█▒▓██ ▒ ██▒▒████▄    ▓█████▄ 
░ ▓██▄   ▒▓█    ▄ ▓██ ░▄█ ▒▒██▒▓██░ ██▓▒▒ ▓██░ ▒░▒██░▄▄▄░▓██ ░▄█ ▒▒██  ▀█▄  ▒██▒ ▄██
  ▒   ██▒▒▓▓▄ ▄██▒▒██▀▀█▄  ░██░▒██▄█▓▒ ▒░ ▓██▓ ░ ░▓█  ██▓▒██▀▀█▄  ░██▄▄▄▄██ ▒██░█▀  
▒██████▒▒▒ ▓███▀ ░░██▓ ▒██▒░██░▒██▒ ░  ░  ▒██▒ ░ ░▒▓███▀▒░██▓ ▒██▒ ▓█   ▓██▒░▓█  ▀█▓
▒ ▒▓▒ ▒ ░░ ░▒ ▒  ░░ ▒▓ ░▒▓░░▓  ▒▓▒░ ░  ░  ▒ ░░    ░▒   ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░▒▓███▀▒
░ ░▒  ░ ░  ░  ▒     ░▒ ░ ▒░ ▒ ░░▒ ░         ░      ░   ░   ░▒ ░ ▒░  ▒   ▒▒ ░▒░▒   ░ 
░  ░  ░  ░          ░░   ░  ▒ ░░░         ░      ░ ░   ░   ░░   ░   ░   ▒    ░    ░ 
      ░  ░ ░         ░      ░                          ░    ░           ░  ░ ░      
         ░                                                                        ░ 

EOF

                printf "\n"
                center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
                center_colored_text "By Devmesis | $(date '+%Y-%m-%d %H:%M:%S')" "\e[1;33m"
                center_colored_text "Version: $REMOTE_VERSION" "\e[1;32m"
                if [[ ${MSG+x} && -n "${MSG// }" ]]; then
                    center_colored_text "$MSG" "\e[1;33m"
                fi
                center_colored_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "\e[1;36m"
                printf "\n"

                log_info "🌐 Fetching scripts for $SYSTEM..."
                printf "\n"
                continue
            else
                center_colored_text "⚠️  Invalid choice. Please select a number between 1 and ${#names[@]}." "\e[1;31m"
            fi
            ;;
        *) 
            center_colored_text "⚠️  Invalid choice. Please select a number, Q to quit, or R to restart." "\e[1;31m"
            ;;
    esac
done