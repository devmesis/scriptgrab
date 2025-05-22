#!/usr/bin/env bash

# ────────────────────────────────────────────────
#  🐍 ScriptGrab: Run any shell or Python script straight from LOCAL FOLDER — no fluff, just speed.
# By Devmesis
# ────────────────────────────────────────────────

# Config Zone
SERVER_LIST_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/assets/servers.txt"
max_retries=2
timeout=1

# Colors & Styles
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Helpers
print_section() {
  local title="$1"
  printf "\n${CYAN}%s${NC}\n" "┌─ ${title} ─────────────────────────────────────────"
}
print_kv() {
  printf "${BOLD}%-15s${NC} %s\n" "$1:" "$2"
}

# Speed up DNS
export RES_OPTIONS="timeout:1 attempts:1"

# 1) Early exit if offline
if ! ping -c1 -W1 8.8.8.8 &>/dev/null; then
  printf "${RED}🚨 No internet – aborting.${NC}\n"
  exit 1
fi

# 2) Fetch server list from GitHub
print_section "Fetching Server List"
if ! raw=$(curl -fsSL "$SERVER_LIST_URL"); then
  printf "${RED}❌ Failed to fetch server list.${NC}\n"
  exit 1
fi

# Populate SERVERS array without readarray
SERVERS=()
while IFS= read -r line; do
  [[ -n $line ]] && SERVERS+=("$line")
done <<<"$raw"

if [ ${#SERVERS[@]} -eq 0 ]; then
  printf "${RED}❌ Server list is empty.${NC}\n"
  exit 1
fi

# 3) Local Network Info
print_section "Local Network Info"
print_kv "Hostname" "$(hostname)"
local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
[[ -z $local_ip ]] && local_ip=$(ipconfig getifaddr en0 2>/dev/null)
print_kv "Local IPv4" "${local_ip:-N/A}"
local_ipv6=$(ip -6 addr show 2>/dev/null \
  | awk '/inet6/ && !/fe80/ && !/::1/ {print $2; exit}')
print_kv "Local IPv6" "${local_ipv6:-N/A}"
gateway=$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')
[[ -z $gateway ]] && gateway=$(netstat -rn \
  | awk '/default|^0.0.0.0/ {print $2; exit}')
print_kv "Gateway" "${gateway:-N/A}"
printf "${BOLD}DNS Servers:${NC}\n"
grep -E '^nameserver' /etc/resolv.conf | awk '{printf "  - %s\n",$2}' || printf "  - N/A\n"

# 4) Public IP & Geo Info
print_section "Public IP & Geo Info"
if command -v jq &>/dev/null; then
  geo=$(curl -s http://ip-api.com/json)
  print_kv "IP"      "$(echo "$geo" | jq -r .query)"
  print_kv "ISP"     "$(echo "$geo" | jq -r .isp)"
  print_kv "City"    "$(echo "$geo" | jq -r .city)"
  print_kv "Region"  "$(echo "$geo" | jq -r .regionName)"
  print_kv "Country" "$(echo "$geo" | jq -r .country)"
  coords=$(echo "$geo" | jq -r '[.lat,.lon]|@csv' | sed 's/,/, /')
  print_kv "Coords"  "$coords"
else
  public_ip=$(curl -s ifconfig.me)
  print_kv "IP" "$public_ip"
  printf "  (Install jq for full geo info)\n"
fi

# 5) DNS Resolver Health Check
print_section "DNS Resolver Health Check"
printf "${BOLD}%-15s %s${NC}\n" "DNS Server" "Status"
printf "──────────────────────────────────\n"
awk '/^nameserver/ {print $2}' /etc/resolv.conf | while read -r dns; do
  [[ -z $dns ]] && continue
  if dig +time=1 +tries=1 @"$dns" google.com +short | grep -Eq '^[0-9]+\.'; then
    printf "%-15s ${GREEN}✅ resolves google.com${NC}\n" "$dns"
  else
    printf "%-15s ${RED}⛔ failed to resolve${NC}\n" "$dns"
  fi
done

# 6) DNS Profile for Targets
print_section "DNS Profile for Targets"
printf "${BOLD}%-20s %-15s %s${NC}\n" "Server" "A Record" "AAAA Record"
printf "────────────────────────────────────────────\n"
for server in "${SERVERS[@]}"; do
  a=$(dig +short A    "$server" | head -1 || echo "N/A")
  b=$(dig +short AAAA "$server" | head -1 || echo "N/A")
  printf "%-20s %-15s %s\n" "$server" "$a" "$b"
done

# 7) Network Health Check
print_section "Network Health Check @ $(date +'%Y-%m-%d %H:%M:%S')"
printf "${BOLD}%-20s %-15s %8s  %s${NC}\n" "Timestamp" "Server" "Latency" "Status"
printf "──────────────────────────────────────────────────────\n"
total=0; successes=0; failures=0; failed_servers=()
for server in "${SERVERS[@]}"; do
  ((total++))
  timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  status_label="FAILED"; status_icon="⛔"; response_time="TIMEOUT"; status_color="$RED"
  for ((i=0; i<=max_retries; i++)); do
    out=$(ping -c1 -W$timeout "$server" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
      response_time=$(awk -F'/' 'END{print $5}' <<<"$out"|cut -d'.' -f1)ms
      status_label="SUCCESS"; status_icon="✅"; status_color="$GREEN"; ((successes++))
      break
    fi
  done
  [[ $status_label == "FAILED" ]] && { ((failures++)); failed_servers+=("$server"); }
  printf "%-20s %-15s %8s  ${status_color}%s %s${NC}\n" \
    "$timestamp" "$server" "$response_time" "$status_icon" "$status_label"
done

# 8) Summary & Alerts
print_section "Network Summary"
failure_percent=$(( failures * 100 / total ))
print_kv "Date"       "$(date +'%Y-%m-%d')"
print_kv "Servers"    "$total"
print_kv "Successes"  "$successes"
print_kv "Failures"   "$failures"
print_kv "Fail Rate"  "${failure_percent}%"
if (( failures > 0 )); then
  print_section "🚨 Critical Alert"
  for s in "${failed_servers[@]}"; do
    printf "  - %s\n" "$s"
  done
fi
