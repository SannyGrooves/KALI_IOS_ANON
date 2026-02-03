#!/bin/bash

# ────────────────────────────────────────────────────────────────
# SUPER iSH ETHICAL TOOLKIT v2.0 – 2026 • iPhone/iPad Compatible
# Root: ~/iSH-tool • Alpine-based • Ethical use only!
# ────────────────────────────────────────────────────────────────

r=$(tput setaf 1); g=$(tput setaf 2); y=$(tput setaf 3)
b=$(tput setaf 4); c=$(tput setaf 6); w=$(tput setaf 7); rst=$(tput sgr0)

BASE_DIR="$HOME/iSH-tool"
TOOLS_DIR="$BASE_DIR/tools"
WORDLISTS="$BASE_DIR/wordlists"
mkdir -p "$TOOLS_DIR" "$WORDLISTS"

banner() {
  clear
  cat << 'EOF'
   ╔════════════════════════════════════════════════════════════╗
   ║     ███████╗██╗   ██╗██████╗ ███████╗██████╗       iSH    ║
   ║     ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗     2026     ║
   ║     ███████╗██║   ██║██████╔╝█████╗  ██████╔╝            ║
   ║     ╚════██║╚██╗ ██╔╝██╔══██╗██╔══╝  ██╔══██╗   ETHICAL    ║
   ║     ███████║ ╚████╔╝ ██║  ██║███████╗██║  ██║   TOOLKIT   ║
   ║     ╚══════╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝             ║
   ╚════════════════════════════════════════════════════════════╝
EOF
  echo "  ${c}Root → $BASE_DIR    ${y}Alpine • iOS • $(date '+%Y-%m-%d %H:%M')${rst}"
  echo ""
}

check_dep() {
  local pkg="$1" cmd="$2"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "${y}[*] apk add $pkg ...${rst}"
    apk add --no-cache "$pkg" >/dev/null 2>&1 || echo "${r}[-] $pkg failed${rst}"
  }
}

install_tool() {
  local name="$1" repo="$2" extra="$3"
  local tgt="$TOOLS_DIR/$name"

  banner
  echo "${b}→ $name${rst}\n"

  if [ -d "$tgt/.git" ]; then
    git -C "$tgt" pull --ff-only 2>/dev/null && echo "${g}Updated.${rst}"
  else
    git clone --depth=1 "$repo" "$tgt" && echo "${g}Cloned.${rst}" || return 1
  fi

  [ -n "$extra" ] && (cd "$tgt" && eval "$extra" 2>/dev/null)

  echo "${g}[+] Ready.${rst}"; sleep 1
}

auto_install_common() {
  banner; echo "${c}Auto-installing popular iSH-compatible tools...${rst}\n"

  declare -A t=(
    ["recon-ng"]="https://github.com/lanmaster53/recon-ng | pip3 install --user -r REQUIREMENTS"
    ["sqlmap"]="https://github.com/sqlmapproject/sqlmap"
    ["XSStrike"]="https://github.com/s0md3v/XSStrike | pip3 install --user -r requirements.txt"
    ["theHarvester"]="https://github.com/laramies/theHarvester | pip3 install --user -r requirements/base.txt"
    ["dirsearch"]="https://github.com/maurosoria/dirsearch | pip3 install --user -r requirements.txt"
    ["infoga"]="https://github.com/m4ll0k/Infoga | pip3 install --user -r requirements.txt"
    ["gobuster"]="https://github.com/OJ/gobuster | go install github.com/OJ/gobuster/v3@latest || echo 'Go build needed – manual'"
    ["ffuf"]="https://github.com/ffuf/ffuf | go install github.com/ffuf/ffuf@latest || echo 'Go build needed'"
    ["whatweb"]="https://github.com/urbanadventurer/WhatWeb | gem install whatweb || apk add whatweb"
  )

  for k in "${!t[@]}"; do
    IFS='|' read repo extra <<< "${t[$k]}"
    install_tool "$k" "$repo" "${extra// / }"
  done

  echo -e "\n${g}Done. Some may need manual Go/Ruby tweaks.${rst}"
  read -p "${y}Enter...${rst}"
}

download_wordlist() {
  local name="$1" url="$2" file="$WORDLISTS/$name"
  banner; echo "${y}→ Downloading $name${rst}"
  wget -O "$file" "$url" && echo "${g}Saved → $file${rst}" || echo "${r}Failed${rst}"
  ls -lh "$WORDLISTS" | tail -n 5
  read -p "${y}Enter...${rst}"
}

wordlist_menu() {
  while true; do
    banner
    echo "${c}WORDLIST DOWNLOADER${rst} → $WORDLISTS\n"
    echo "1) rockyou.txt          (~133 MB)"
    echo "2) rockyou.txt.gz       (~51 MB)"
    echo "3) 10-million-passwords (~10 MB)"
    echo "4) SecLists raft-large-directories (~1.5 MB)"
    echo "5) SecLists raft-large-files      (~2 MB)"
    echo "6) crackstation-human-only (~1.5 GB – careful!)"
    echo "0) Back"
    read -p "${c}→ ${rst}" c
    case $c in
      1) download_wordlist "rockyou.txt" "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" ;;
      2) download_wordlist "rockyou.txt.gz" "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt.gz" ;;
      3) download_wordlist "10m-top.txt" "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt" ;;
      4) download_wordlist "raft-large-dirs.txt" "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-large-directories.txt" ;;
      5) download_wordlist "raft-large-files.txt" "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-large-files.txt" ;;
      6) download_wordlist "crackstation.txt" "https://crackstation.net/files/crackstation-human-only.txt.gz" ;;
      0) return ;;
    esac
  done
}

tool_status() {
  local cmd="$1" p="$2"
  [ -n "$p" ] && [ -e "$p" ] && echo "${g}✓${rst}" || command -v "$cmd" >/dev/null && echo "${g}✓ sys${rst}" || echo "${r}✗${rst}"
}

main_menu() {
  while true; do
    banner

    cat << EOF
  ${b}TOOLKIT${rst}                                 Status
  ───────────────────────────────────────────────────────────────
  1  Recon-ng                            $(tool_status "recon-ng" "$TOOLS_DIR/recon-ng/recon-ng")
  2  Nikto                               $(tool_status "nikto")
  3  sqlmap                              $(tool_status "sqlmap" "$TOOLS_DIR/sqlmap/sqlmap.py")
  4  XSStrike                            $(tool_status "" "$TOOLS_DIR/XSStrike/xsstrike.py")
  5  dirsearch                           $(tool_status "" "$TOOLS_DIR/dirsearch/dirsearch.py")
  6  theHarvester                        $(tool_status "" "$TOOLS_DIR/theHarvester/theHarvester.py")
  7  OpenSSL / GnuPG                     $(tool_status "openssl") / $(tool_status "gpg")
  8  Infoga (Email OSINT)                $(tool_status "" "$TOOLS_DIR/infoga/infoga.py")
  9  Gobuster (Dir / Subdomain brute)    $(tool_status "gobuster")
 10  ffuf (Fast web fuzzer)              $(tool_status "ffuf")
 11  WhatWeb (Tech fingerprint)          $(tool_status "whatweb")
 12  Nmap (Basic scan – limited)         $(tool_status "nmap")
 13  Hydra (Brute – http/ftp/ssh limited)$(tool_status "hydra")
 14  John the Ripper (jumbo preferred)   $(tool_status "john")
 15  Hashcat (CPU only – slow)           $(tool_status "hashcat")
 16  Wordlist Downloader Menu
 ───────────────────────────────────────────────────────────────
  ${g}A${rst} Auto-install common tools
  ${y}U${rst} Update system (apk upgrade)
  0  Exit – Stay ethical
EOF

    read -p "${c}Select → ${rst}" opt

    case $opt in
      1) check_dep "python3 py3-pip git" "python3"; cd "$TOOLS_DIR/recon-ng" 2>/dev/null && ./recon-ng || echo "${y}Install with A${rst}" ;;
      2) check_dep "nikto" "nikto"; nikto -H | less -R ;;
      3) python3 "$TOOLS_DIR/sqlmap/sqlmap.py" -h | less -R ;;
      4) python3 "$TOOLS_DIR/XSStrike/xsstrike.py" --help | less -R ;;
      5) python3 "$TOOLS_DIR/dirsearch/dirsearch.py" --help | less -R ;;
      6) python3 "$TOOLS_DIR/theHarvester/theHarvester.py" -h | less -R ;;
      7) openssl version; gpg --version | less -R ;;
      8) python3 "$TOOLS_DIR/infoga/infoga.py" --help | less -R ;;
      9) gobuster --help | less -R ;;
     10) ffuf --help | less -R ;;
     11) whatweb --help | less -R ;;
     12) nmap --help | less -R ;;
     13) hydra -h | less -R ;;
     14) john --help | less -R ;;
     15) hashcat --help | less -R ;;
     16) wordlist_menu ;;
      A|A) auto_install_common ;;
      U|U) apk update && apk upgrade ;;
      0) banner; echo "${g}Ethical only. Exit.${rst}"; exit 0 ;;
      *) echo "${r}Invalid.${rst}"; sleep 1 ;;
    esac

    read -p "${y}Enter to continue...${rst}"
  done
}

# ── Start ───────────────────────────────────────────────────────
banner
echo "${y}Basic deps...${rst}"
apk add --no-cache python3 py3-pip git curl wget bash ncurses make go ruby nmap nikto openssl gnupg john hashcat hydra 2>/dev/null

main_menu