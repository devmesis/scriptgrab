#!/bin/bash
# =============================================================================
# Script: Network_Test.sh
# Description: Comprehensive network diagnostics and health check tool
# Author: Devmesis <devmesis@scriptgrab.com>
# Version: 1.0.0
# License: MIT
# =============================================================================

set -euo pipefail

# Script metadata
SCRIPT_NAME="network-test"
SCRIPT_VERSION="1.0.0"
SCRIPT_DESCRIPTION="Comprehensive network diagnostics and health check tool"
SCRIPT_AUTHOR="Devmesis"
SCRIPT_LICENSE="MIT"

# Script configuration
SCRIPT_REQUIRES_SUDO=false
SCRIPT_REQUIRES_INTERNET=true
SCRIPT_SUPPORTED_OS="darwin"

# Configuration variables
SERVER_LIST_URL="https://raw.githubusercontent.com/devmesis/scriptgrab/main/assets/servers.txt"
MAX_RETRIES=2
TIMEOUT=1

# Colors & Styles
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Function to print usage information
print_usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [options]

Options:
    -h, --help     Show this help message
    -v, --version  Show version information
    --debug        Enable debug mode
    --timeout N    Set ping timeout in seconds (default: ${TIMEOUT})
    --retries N    Set number of retries (default: ${MAX_RETRIES})

Description:
    ${SCRIPT_DESCRIPTION}
EOF
}

# Function to handle cleanup
cleanup() {
    # Add cleanup code here
    exit "${1:-0}"
}

# Error handler
error() {
    local line=$1
    local msg=$2
    echo "[ERROR] Line ${line}: ${msg}" >&2
    cleanup 1
}

# Set up error handling
trap 'cleanup $?' EXIT
trap 'cleanup 1' INT TERM
trap 'error ${LINENO} "$BASH_COMMAND"' ERR

# Helper Functions
print_section() {
    local title="$1"
    printf "\n${CYAN}%s${NC}\n" "┌─ ${title} ─────────────────────────────────────────"
}

print_kv() {
    printf "${BOLD}%-15s${NC} %s\n" "$1:" "$2"
}

# Function to check dependencies
check_dependencies() {
    local deps=("curl" "dig" "jq")
    
    for dep in "${deps[@]}"; do
        if ! command -v "${dep}" >/dev/null 2>&1; then
            error "${LINENO}" "Required dependency not found: ${dep}"
        fi
    done
}

# Function to check OS compatibility
check_os_compatibility() {
    local os
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    if [[ ! "${SCRIPT_SUPPORTED_OS}" =~ ${os} ]]; then
        error "${LINENO}" "Unsupported operating system: ${os}"
    fi
}

# Function to check internet connectivity
check_internet() {
    if ! ping -c1 -W1 8.8.8.8 &>/dev/null; then
        error "${LINENO}" "No internet connection available"
    fi
}

# Function to get local network info
get_local_network_info() {
    print_section "Local Network Info"
    print_kv "Hostname" "$(hostname)"
    
    local local_ip
    local_ip=$(ipconfig getifaddr en0 2>/dev/null)
    print_kv "Local IPv4" "${local_ip:-N/A}"
    
    local gateway
    gateway=$(netstat -rn | awk '/default|^0.0.0.0/ {print $2; exit}')
    print_kv "Gateway" "${gateway:-N/A}"
    
    printf "${BOLD}DNS Servers:${NC}\n"
    scutil --dns | grep 'nameserver\[[0-9]*\]' | awk '{print "  -",$3}'
}

# Function to get public IP and geo info
get_public_ip_info() {
    print_section "Public IP & Geo Info"
    if command -v jq &>/dev/null; then
        local geo
        geo=$(curl -s http://ip-api.com/json)
        print_kv "IP"      "$(echo "$geo" | jq -r .query)"
        print_kv "ISP"     "$(echo "$geo" | jq -r .isp)"
        print_kv "City"    "$(echo "$geo" | jq -r .city)"
        print_kv "Region"  "$(echo "$geo" | jq -r .regionName)"
        print_kv "Country" "$(echo "$geo" | jq -r .country)"
        local coords
        coords=$(echo "$geo" | jq -r '[.lat,.lon]|@csv' | sed 's/,/, /')
        print_kv "Coords"  "$coords"
    else
        local public_ip
        public_ip=$(curl -s ifconfig.me)
        print_kv "IP" "$public_ip"
        printf "  (Install jq for full geo info)\n"
    fi
}

# Function to check DNS health
check_dns_health() {
    print_section "DNS Resolver Health Check"
    printf "${BOLD}%-15s %s${NC}\n" "DNS Server" "Status"
    printf "──────────────────────────────────\n"
    
    local dns_servers
    dns_servers=$(scutil --dns | grep 'nameserver\[[0-9]*\]' | awk '{print $3}')
    
    while read -r dns; do
        [[ -z $dns ]] && continue
        if dig +time=1 +tries=1 @"$dns" google.com +short | grep -Eq '^[0-9]+\.'; then
            printf "%-15s ${GREEN}✅ resolves google.com${NC}\n" "$dns"
        else
            printf "%-15s ${RED}⛔ failed to resolve${NC}\n" "$dns"
        fi
    done <<< "$dns_servers"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            -v|--version)
                echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
                exit 0
                ;;
            --debug)
                set -x
                ;;
            --timeout)
                TIMEOUT="$2"
                shift
                ;;
            --retries)
                MAX_RETRIES="$2"
                shift
                ;;
            *)
                error "${LINENO}" "Unknown option: $1"
                ;;
        esac
        shift
    done

    # Check dependencies and OS compatibility
    check_dependencies
    check_os_compatibility
    check_internet

    # Run network diagnostics
    get_local_network_info
    get_public_ip_info
    check_dns_health
}

# Run the main function
main "$@"
