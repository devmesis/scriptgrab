#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ────────────────────────────────────────────────
#  ScriptGrab — Your Script Launcher, Reimagined
#  By Devmesis
# ────────────────────────────────────────────────

# ========== CONFIGURATION ==========
MSG_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/message.txt"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/scriptgrab/version.txt"
GH_USER="devmesis"
GH_REPO="scriptgrab"
GH_BRANCH="main"

# ========== LOGGING & FETCH HELPERS ==========
log_info()  { echo -e "\e[1;35m[LOG] $1\e[0m"; }
log_warn()  { echo -e "\e[1;33m[WARN] $1\e[0m"; }
log_error() { echo -e "\e[1;31m[ERROR] $1\e[0m"; }

github_fetch() {
    local url="$1"
    local tmpfile http_code response
    tmpfile=$(mktemp)
    http_code=$(curl -s -w "%{http_code}" -H "User-Agent: ScriptGrab" --max-time 10 -o "$tmpfile" "$url")
    response=$(cat "$tmpfile")
    rm -f "$tmpfile"

    if [[ "$http_code" == "403" || "$http_code" == "429" ]] && [[ "$response" == *"rate limit"* ]]; then
        log_error "Rate Limited — try again in 1hr"
        log_info "GitHub says: $(echo "$response" | grep -o '"message":"[^"]*"' | cut -d: -f2-)"
        exit 1
    fi

    if [[ "$http_code" != "200" ]]; then
        log_warn "Failed to fetch $url (HTTP $http_code)"
        echo ""
        return 1
    fi

    echo "$response"
}

restart_script() {
    log_info "Restarting ScriptGrab..."
    exec "$0" "$@"
}

# ========== URL ENCODING FUNCTION ==========
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

# ========== DEPENDENCY CHECK ==========
command -v python3 >/dev/null 2>&1 || { log_error "Python 3 required. Abort."; exit 1; }
command -v bash    >/dev/null 2>&1 || { log_error "Bash required. Abort."; exit 1; }

# ========== SPLASH & VERSION ==========
clear

while IFS= read -r line; do
  printf "\e[1;34m%s\e[0m\n" "$line"
  sleep 0.1
done <<'EOF'
┏┓   •   ┏┓    ┓
┗┓┏┏┓┓┏┓╋┃┓┏┓┏┓┣┓
┗┛┗┛ ┗┣┛┗┗┛┛ ┗┻┗┛
      ┛
EOF

# ────────────── INFO BAR ─────────────
printf "\e[1;33mBy Devmesis\e[0m | "
printf "\e[1;37m%s\e[0m\n" "$(date '+%Y-%m-%d %H:%M:%S')"

REMOTE_VERSION=$(curl -sf "$REMOTE_VERSION_URL" | tr -d '\r\n' || echo "Cracked")
printf "\e[1;32mVersion: %s\e[0m\n" "$REMOTE_VERSION"

MSG=$(curl -sf "$MSG_URL" || :)
if [[ ${MSG+x} && -n "${MSG// }" ]]; then
    printf "\n\e[1;33m%s\e[0m\n" "$MSG"
fi
printf "\n"
sleep 0.5

# ────────────────────────────────────────────────
#  MAIN MENU
# ────────────────────────────────────────────────
OPTIONS=("Mac" "Windows" "Linux" "Other" "Download")
echo -e "\e[1;36m─────────────── MAIN MENU ───────────────\e[0m"
for i in "${!OPTIONS[@]}"; do
    printf "%d) %s\n" $((i+1)) "${OPTIONS[i]}"
done
echo -e "Q) Quit\n"

while true; do
    read -rp $'\e[1;33m👉 Your choice: \e[0m' choice
    case "${choice,,}" in
        q) printf "\n\e[1;33m👋 Bye!\e[0m\n\n"; exit 0 ;;
        r) restart_script ;;
        [1-5])
            opt="${OPTIONS[$((choice-1))]}"
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
        *) echo -e "\e[1;31m⚠ Invalid choice.\e[0m" ;;
    esac
done

# ────────────────────────────────────────────────
#  FETCH SCRIPTS FOR SELECTED SYSTEM
# ────────────────────────────────────────────────
GH_OSFOLDER="scripts/$SYSTEM"
printf "\n\e[1;34m🌐 Fetching scripts for %s...\e[0m\n" "$SYSTEM"

response=$(github_fetch "https://api.github.com/repos/$GH_USER/$GH_REPO/contents/$GH_OSFOLDER")

# DEBUG: Uncomment to see raw API output
# echo "DEBUG: API response:"; echo "$response"

# Robust error and format check
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
    echo -e "\n\e[1;36m─────────────── AVAILABLE SCRIPTS ───────────────\e[0m\n"
    for i in "${!names[@]}"; do
        base="${names[$i]%.*}"
        pretty="${base//_/ }"
        printf "%2d) %s\n" "$((i+1))" "$pretty"
    done
    echo -e " Q) Quit\n"

    read -rp $'\e[1;33m👉 Pick your script: \e[0m' reply
    case "${reply,,}" in
        q) printf "\n\e[1;33m👋 Bye!\e[0m\n\n"; exit 0 ;;
        r) restart_script ;;
        [1-9]|[1-9][0-9]*)
            if (( reply >= 1 && reply <= ${#names[@]} )); then
                script_name="${names[$((reply-1))]}"
                encoded_script_name=$(urlencode "$script_name")
                url="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/scripts/$SYSTEM/$encoded_script_name"
                echo -e "\n\e[1;34m🚀 Running $script_name...\e[0m\n"
                if [[ "$script_name" == *.py ]]; then
                    curl -sL "$url" | python3
                elif [[ "$script_name" == *.ps1 ]]; then
                    curl -sL "$url" | pwsh -NoProfile -
                else
                    curl -sL "$url" | bash
                fi
                echo -e "\n\e[1;32m▶️  Done. Press any key to continue, or Q to quit...\e[0m"
                # Read one char, no Enter required
                read -n 1 -s next
                if [[ "${next,,}" == "q" ]]; then
                    printf "\n\e[1;33m👋 Bye!\e[0m\n\n"
                    exit 0
                fi
                clear
                continue
            else
                echo -e "\e[1;31m⚠ Invalid choice.\e[0m"
            fi
            ;;
        *) echo -e "\e[1;31m⚠ Invalid choice.\e[0m" ;;
    esac
done


# ────────────────────────────────────────────────
#  END OF SCRIPTGRAB
# ────────────────────────────────────────────────
