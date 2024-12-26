#========================================================================================
# Project Name: System Information for Server's and Workstation's for Linux and Unix Base
# Start Date:  16-12-2024 | Start Day:  Monday
# Finish Date: 18-12-2024 | Finish Day: Wednesday
# Author: Faisal Dawod
# GitHub: https://github.com/FaisalDawod
#========================================================================================
# LICENSE #
#==========

#Copyright [2024] [Faisal Dawod]

#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

#========================================================================================

#!/bin/bash

# Colors for text
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No color

# Stylish Header Border (with reflection)
divider() {
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════╗${NC}"
}
bottom_divider() {
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════╝${NC}"
}
print_header() {
    divider
    printf "${CYAN}║ %-49s ║${NC}\n" "$1"
    bottom_divider
}
section_divider() {
    echo -e "${GRAY}---------------------------------------------------${NC}"
}
check_command() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}⚠️  Error: Failed to execute $1${NC}"
        exit 1
    fi
}

subheader_icon="🌀"
success_icon="✅"

# Prompt user for Linux/Unix distribution with validation
select_distro() {
    while true; do
        print_header "SELECT SYSTEM TYPE"
        echo -e "${GREEN}1. RedHat-based${NC} (RHEL, CentOS, Rocky, AlmaLinux)"
        echo -e "${GREEN}2. Debian-based${NC} (Debian, Ubuntu, Mint)"
        echo -e "${GREEN}3. Arch-based${NC} (Arch, Manjaro)"
        echo -e "${GREEN}4. Unix-based${NC} (FreeBSD, Solaris, etc.)"
        echo -e "${GREEN}5. Unknown Distro${NC} (No specific system detected)"
        echo -e "${RED}6. Exit${NC} (Terminate the script)"
        read -p "Please select your system type [1-6]: " distro_choice

        case $distro_choice in
        1)
            if [ -f /etc/redhat-release ]; then
                distro="RedHat-based"
                break
            else
                echo -e "${RED}Error: RedHat-based system files not found.${NC}"
            fi
            ;;
        2)
            if [ -f /etc/debian_version ]; then
                distro="Debian-based"
                break
            else
                echo -e "${RED}Error: Debian-based system files not found.${NC}"
            fi
            ;;
        3)
            if [ -f /etc/arch-release ]; then
                distro="Arch-based"
                break
            else
                echo -e "${RED}Error: Arch-based system files not found.${NC}"
            fi
            ;;
        4)
            if uname | grep -qi "freebsd\|solaris\|darwin"; then
                distro="Unix-based"
                break
            else
                echo -e "${RED}Error: Unix-based system not detected.${NC}"
            fi
            ;;
        5)
            distro="Unknown Distro"
            echo -e "${GREEN}Selected: Unknown Distro (No specific system detected)${NC}"
            break
            ;;
        6)
            echo -e "${YELLOW}Exiting the script as requested.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice! Please select a valid option.${NC}"
            ;;
        esac
        echo -e "${YELLOW}Please try again or choose Unknown Distro.${NC}"
    done
}

# Call select_distro to prompt user for system type
select_distro

# Display system information for the selected distro
print_header "SYSTEM INFORMATION FOR $distro SYSTEMS"
echo -e "${subheader_icon} ${BLUE}Hostname:${NC}           $(hostname)"
echo -e "${subheader_icon} ${BLUE}User:${NC}               $(whoami)"
echo -e "${subheader_icon} ${BLUE}Current Directory:${NC}  $(pwd)"
echo -e "${subheader_icon} ${BLUE}Linux Kernel:${NC}       $(uname -r)"

# Distribution-specific checks, but skip Linux Release if "Unknown Distro" is selected
if [[ "$distro" == "RedHat-based" ]]; then
    if [ -f /etc/redhat-release ]; then
        echo -e "${subheader_icon} ${BLUE}Linux Release:${NC}      $(cat /etc/redhat-release)"
    else
        echo -e "${YELLOW}/etc/redhat-release not found. Trying /etc/os-release...${NC}"
        cat /etc/os-release || echo -e "${RED}Release information not available.${NC}"
    fi
elif [[ "$distro" == "Debian-based" ]]; then
    if [ -f /etc/debian_version ]; then
        echo -e "${subheader_icon} ${BLUE}Linux Release:${NC}      Debian $(cat /etc/debian_version)"
    else
        echo -e "${YELLOW}/etc/debian_version not found. Trying /etc/os-release...${NC}"
        cat /etc/os-release || echo -e "${RED}Release information not available.${NC}"
    fi
elif [[ "$distro" == "Arch-based" ]]; then
    if [ -f /etc/arch-release ]; then
        echo -e "${subheader_icon} ${BLUE}Linux Release:${NC}      Arch Linux"
    else
        echo -e "${YELLOW}/etc/arch-release not found. Trying /etc/os-release...${NC}"
        cat /etc/os-release || echo -e "${RED}Release information not available.${NC}"
    fi
elif [[ "$distro" == "Unix-based" ]]; then
    echo -e "${YELLOW}Unix-specific checks are minimal in this script.${NC}"
    uname -a
elif [[ "$distro" == "Unknown Distro" ]]; then
    echo -e "${YELLOW}No specific distribution detected, skipping Linux release information.${NC}"
else
    unsupported_message
fi

# CPU and Memory Usage
print_header "CPU AND MEMORY USAGE"
echo -e "${subheader_icon} ${BLUE}CPU Details:${NC}"
lscpu | awk -F: '/Architecture|^CPU\(s\)|Model name|Thread/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); printf "  %s: %s\n", $1, $2}' && \
check_command "lscpu"

section_divider
echo -e "${subheader_icon} ${BLUE}Memory Usage:${NC}"
free -h | awk 'NR==2 {printf "🧠 Mem - Total: %s | Used: %s | Free: %s\n", $2, $3, $4} NR==3 {printf "💾 Swap - Total: %s | Used: %s | Free: %s\n", $2, $3, $4}'
check_command "free"

# Disk Usage (df -h)
print_header "DISK USAGE"
echo -e "${subheader_icon} ${BLUE}(via df):${NC}"
df -h
check_command "df"

section_divider
echo -e "${subheader_icon} ${BLUE}(via lsblk):${NC}"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | awk '{printf "  📂 %-10s | Size: %-6s | Type: %-8s | Mount: %s\n", $1, $2, $3, $4}'
check_command "lsblk"

# Network Information
print_header "NETWORK INFORMATION"
echo -e "${subheader_icon} ${BLUE}Active Interfaces:${NC}"
ip -brief address | awk '{printf "  🌐 Interface: %-10s | IP: %s\n", $1, $3}'
check_command "ip"

section_divider
echo -e "${subheader_icon} ${BLUE}Default Gateway:${NC}     $(ip route | grep default | awk '{print $3}')"
echo -e "${subheader_icon} ${BLUE}DNS Servers:${NC}"
cat /etc/resolv.conf | grep nameserver | awk '{printf "  🌍 %s\n", $2}' || echo -e "${RED}No DNS information available.${NC}"

# Services and Processes
print_header "ACTIVE SERVICES AND PROCESSES"
echo -e "${subheader_icon} ${BLUE}Top 5 Services:${NC}"
systemctl list-units --type=service --state=running | head -10 | awk '{printf "  🔧 %-40s | Active\n", $1}'
check_command "systemctl"

section_divider
echo -e "${subheader_icon} ${BLUE}Top 5 Processes by CPU Usage:${NC}"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6 | awk '{printf "  🔥 PID: %s | Command: %-15s | CPU: %-5s | Mem: %-5s\n", $1, $2, $3, $4}'
check_command "ps"

section_divider
echo -e "${subheader_icon} ${BLUE}Top 5 Processes by Memory Usage:${NC}"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -6 | awk '{printf "  📊 PID: %s | Command: %-15s | CPU: %-5s | Mem: %-5s\n", $1, $2, $3, $4}'
check_command "ps"

# Last Login Information
print_header "LAST LOGIN INFORMATION"
last -a | head -3 | awk '{printf "  🕒 %s %-10s %s\n", $1, $2, $3}'
check_command "last"

# System Uptime
print_header "SYSTEM UPTIME"
uptime -p | awk '{printf "  ⏱️ %s\n", $0}'
check_command "uptime"

# Final Message
print_header "SUCCESSFUL MESSAGE"
echo -e "${success_icon} ${GREEN}All checks completed successfully!${NC}"

