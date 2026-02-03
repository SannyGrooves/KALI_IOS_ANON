#!/bin/bash

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# ────────────────────────────────────────────────
# Centralized installation root (as requested)
# ────────────────────────────────────────────────
BASE_DIR="$HOME/iSH-tool"
TOOLS_DIR="$BASE_DIR/tools"
WORDLIST_DIR="$BASE_DIR/wordlists"

mkdir -p "$TOOLS_DIR" "$WORDLIST_DIR"

banner() {
  clear
  echo "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
  echo "${CYAN}║      SUPER iSH HACKER MENU - iOS ETHICAL TOOLKIT   ║${RESET}"
  echo "${CYAN}║      Root: ~/iSH-tool     • Alpine • 2026         ║${RESET}"
  echo "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
  echo ""
  echo " ${RED}WARNING:${RESET} Authorized testing only. Misuse is illegal."
}

tool_help() {
  local tool="$1" desc="$2" usage="$3" examples="$4" downloads="$5"
  banner
  echo "${GREEN}>> $tool Info & Help${RESET}"
  echo "Description: $desc"
  echo "Usage: $usage"
  echo "Examples:"
  echo "$examples"
  echo ""
  echo "Downloads / Required Files:"
  echo "$downloads"
  read -p "Press Enter to return..."
}

download_file() {
  local url="$1"
  local file="$WORDLIST_DIR/$(basename "$url")"
  echo "${YELLOW}[*] Downloading → $file${RESET}"
  if ! wget -O "$file" "$url" 2>/dev/null; then
    curl -L -o "$file" "$url" || { echo "${RED}[-] Download failed.${RESET}"; return 1; }
  fi
  if [[ "$file" == *.gz ]]; then
    gunzip -f "$file" && echo "${GREEN}[+] Unzipped.${RESET}"
    file="${file%.gz}"
  fi
  [ -f "$file" ] && echo "${GREEN}[+] Saved.${RESET}" || echo "${RED}[-] Failed.${RESET}"
}

auto_install_or_update_tool() {
  local name="$1" repo="$2" install_cmd="$3" post_install="$4"

  banner
  echo "${YELLOW}→ Processing $name${RESET}"

  local target_dir="$TOOLS_DIR/$name"

  if [ -d "$target_dir/.git" ]; then
    echo "→ Updating (git pull)..."
    git -C "$target_dir" pull --ff-only || echo "${RED}Pull failed.${RESET}"
  else
    echo "→ Cloning $repo ..."
    git clone "$repo" "$target_dir" || { echo "${RED}Clone failed.${RESET}"; return 1; }
  fi

  if [ -n "$install_cmd" ]; then
    echo "→ Running install: $install_cmd"
    (cd "$target_dir" && eval "$install_cmd") || echo "${RED}Install step failed.${RESET}"
  fi

  if [ -n "$post_install" ]; then
    echo "→ Post-install: $post_install"
    eval "$post_install"
  fi

  echo "${GREEN}[+] $name ready (or updated).${RESET}"
  sleep 1
}

auto_install_all() {
  banner
  echo "${CYAN}Auto-install / update common tools into ~/iSH-tool/tools ...${RESET}"
  echo ""

  # Some popular ones with known repos (add more as needed)
  auto_install_or_update_tool "recon-ng"     "https://github.com/lanmaster53/recon-ng.git"            "pip3 install --user -r REQUIREMENTS" ""
  auto_install_or_update_tool "sqlmap"       "https://github.com/sqlmapproject/sqlmap.git"             "" ""
  auto_install_or_update_tool "XSStrike"     "https://github.com/s0md3v/XSStrike.git"                 "pip3 install --user -r requirements.txt" ""
  auto_install_or_update_tool "theHarvester" "https://github.com/laramies/theHarvester.git"           "pip3 install --user -r requirements.txt" ""
  auto_install_or_update_tool "dirsearch"    "https://github.com/maurosoria/dirsearch.git"            "pip3 install --user -r requirements.txt" ""
  auto_install_or_update_tool "amass"        "https://github.com/owasp-amass/amass.git"               "" "echo 'Amass usually needs Go – limited auto support in iSH'""
  auto_install_or_update_tool "infoga"       "https://github.com/m4ll0k/infoga.git"                   "pip3 install --user -r requirements.txt" ""
  auto_install_or_update_tool "blackbird"    "https://github.com/p1ngul1n0/blackbird.git"             "pip3 install --user -r requirements.txt" ""

  echo ""
  echo "${GREEN}Auto-install round finished.${RESET}"
  echo "Some tools may still need manual apk/pip steps or patches in iSH."
  echo "Check each tool folder: $TOOLS_DIR"
  read -p "Press Enter..." dummy
}

tool_submenu() {
  local tool="$1" desc="$2" cmd="$3" help_desc="$4" help_usage="$5" help_examples="$6" download_info="$7"
  while true; do
    banner
    echo "${CYAN}>> $tool${RESET} - $desc"
    echo "Command: ${YELLOW}$cmd${RESET}"
    echo ""
    echo "1) Help / Info"
    echo "2) Launch Tool"
    echo "3) Download wordlists / files"
    echo "9) Update this tool (git pull)"
    echo "0) Back"
    read -p "${YELLOW}Select: ${RESET}" choice

    case $choice in
      1) tool_help "$tool" "$help_desc" "$help_usage" "$help_examples" "$download_info" ;;
      2) eval "$cmd" 2>&1 | less -R ;;
      3)
        banner
        echo "${YELLOW}Wordlist download options:${RESET}"
        echo "1) rockyou.txt          (~134 MB)"
        echo "2) rockyou.txt.gz       (~50 MB)"
        echo "3) 10M top passwords     (~10 MB)"
        echo "0) Cancel"
        read -p "Select (0-3): " dl
        case $dl in
          1) download_file "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" ;;
          2) download_file "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt.gz" ;;
          3) download_file "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt" ;;
        esac
        ls -lh "$WORDLIST_DIR" | tail -n 6
        ;;
      9)
        local tool_name=$(basename "$(echo "$cmd" | awk '{print $1}')")
        local dir="$TOOLS_DIR/$tool_name"
        if [ -d "$dir/.git" ]; then
          cd "$dir" && git pull && echo "${GREEN}Updated $tool_name.${RESET}"
        else
          echo "No git repo found for $tool_name in $dir"
        fi
        ;;
      0) return ;;
      *) echo "Invalid." ;;
    esac
    read -p "Press Enter..." dummy
  done
}

main_menu() {
  while true; do
    banner
    echo "Installation root → $BASE_DIR"
    echo ""
    echo "1) Recon-ng"
    echo "2) Nikto"
    echo "9) XSStrike"
    echo "10) sqlmap"
    echo "15) theHarvester"
    echo "16) dirsearch"
    echo "18) Amass"
    echo "19) Launch original / super menu"
    echo "${GREEN}20) Auto-install / update ALL tools${RESET}"
    echo "0) Exit"
    read -p "${YELLOW}Select: ${RESET}" opt

    case $opt in
      1) tool_submenu "Recon-ng" "OSINT Framework" "recon-ng" \
           "..." "recon-ng" "workspace create test\n..." "API keys..." ;;
      # ── add your other tools similarly, change paths to "$TOOLS_DIR/..." ──
      # Example for sqlmap:
      10) tool_submenu "sqlmap" "SQL injection tool" "python3 $TOOLS_DIR/sqlmap/sqlmap.py" \
            "..." "sqlmap -u url --batch --dbs" "..." "Tamper scripts optional" ;;
      # … your other cases …

      19)
        banner
        echo "1) Original cons0le7/iSH-tools (if exists)"
        echo "2) This super menu again"
        echo "3) Update original repo"
        echo "0) Back"
        read -p "Choose: " sub
        case $sub in
          1) [ -f "$HOME/iSH-tools/iSH-tools" ] && cd "$HOME/iSH-tools" && ./iSH-tools ;;
          2) exec "$0" ;;
          3) if [ -d "$HOME/iSH-tools" ]; then cd "$HOME/iSH-tools" && git pull; else echo "Not cloned."; fi ;;
        esac
        ;;
      20) auto_install_all ;;
      0) echo "${GREEN}Bye. Stay legal.${RESET}"; exit 0 ;;
      *) echo "${RED}Invalid.${RESET}" ;;
    esac
    read -p "Press Enter..." dummy
  done
}

# Quick check / welcome
banner
echo "Super menu using root → $BASE_DIR"
echo "Tools will be placed in $TOOLS_DIR"
echo ""

main_menu