#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

WORDLIST_DIR="$HOME/wordlists"
mkdir -p "$WORDLIST_DIR"

banner() {
  clear
  echo "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
  echo "${CYAN}║      SUPER iSH HACKER MENU - iOS ETHICAL TOOLKIT   ║${RESET}"
  echo "${CYAN}║             Non-Jailbroken • Alpine • 2026         ║${RESET}"
  echo "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
  echo ""
  echo " ${RED}WARNING:${RESET} Authorized testing only. Misuse illegal."
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
  echo "${YELLOW}[*] Downloading to $file...${RESET}"
  wget -O "$file" "$url" || curl -o "$file" "$url"
  if [[ "$file" == *.gz ]]; then
    gunzip -f "$file" && echo "${GREEN}[+] Unzipped.${RESET}"
  fi
  if [ -f "${file%.gz}" ] || [ -f "$file" ]; then
    echo "${GREEN}[+] Download complete.${RESET}"
  else
    echo "${RED}[-] Download failed.${RESET}"
  fi
}

tool_submenu() {
  local tool="$1" desc="$2" cmd="$3" help_desc="$4" help_usage="$5" help_examples="$6" download_info="$7"
  while true; do
    banner
    echo "${CYAN}>> $tool Submenu${RESET} - $desc"
    echo "Run command: $cmd"
    echo ""
    echo "1) Help / Info"
    echo "2) Launch Tool"
    echo "3) Download Required Files (wordlists, etc.)"
    echo "4) Example 1"
    echo "5) Example 2"
    echo "6) Example 3"
    echo "7) Example 4"
    echo "8) Example 5"
    echo "9) Update Tool (git pull if available)"
    echo "0) Back"
    read -p "${YELLOW}Select: ${RESET}" choice

    case $choice in
      1)
        tool_help "$tool" "$help_desc" "$help_usage" "$help_examples" "$download_info"
        ;;
      2)
        eval "$cmd" 2>&1 | less -R
        ;;
      3)
        banner
        echo "${YELLOW}Download options:${RESET}"
        echo "1) rockyou.txt          (~134 MB)   classic password list"
        echo "2) rockyou.txt.gz       (~50 MB)    compressed version"
        echo "3) 10-million top passwords (~10 MB) SecLists top-1M"
        echo "0) Cancel"
        read -p "Select number (0-3): " dl
        case $dl in
          1) download_file "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" ;;
          2) download_file "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt.gz" ;;
          3) download_file "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt" ;;
          *) echo "Cancelled." ;;
        esac
        ls -lh "$WORDLIST_DIR" | tail -n 5
        ;;
      4|5|6|7|8)
        echo "${YELLOW}Run example:${RESET}"
        echo "(adapt from help section)"
        ;;
      9)
        local dir=$(dirname "$(echo "$cmd" | cut -d' ' -f1)")
        if [ -d "$dir/.git" ]; then
          cd "$dir" && git pull && echo "${GREEN}Updated.${RESET}"
        else
          echo "No git repository found for this tool."
        fi
        ;;
      0) return ;;
      *) echo "Invalid choice." ;;
    esac
    read -p "Press Enter..." dummy
  done
}

main_menu() {
  while true; do
    banner
    echo "1) Recon-ng (OSINT Framework)"
    echo "2) Nikto (Web Scanner)"
    echo "3) DNSrecon (DNS Enum)"
    echo "4) UDPSCAN (UDP Scan)"
    echo "5) Infoga (Email OSINT)"
    echo "6) BlackBird (Social Search)"
    echo "7) NoSint (OSINT)"
    echo "8) IntelBase (Intel CLI)"
    echo "9) XSStrike (XSS Scanner)"
    echo "10) sqlmap (SQLi Tool)"
    echo "11) ZipBrute (ZIP Brute)"
    echo "12) PDFbrute (PDF Brute)"
    echo "13) OpenSSL (Crypto)"
    echo "14) GnuPG (Encryption)"
    echo "15) theHarvester (Extra OSINT)"
    echo "16) dirsearch (Path Brute)"
    echo "17) WhatWeb (Web Fingerprint)"
    echo "18) Amass (Subdomain Enum)"
    echo "19) ${GREEN}Launch Original iSH-tools or Super Menu${RESET}"
    echo "0) Exit"
    read -p "${YELLOW}Select tool: ${RESET}" opt

    case $opt in
      1) tool_submenu "Recon-ng" "Modular OSINT framework" "~/iSH-tools/tools/recon-ng.sh || ~/recon-ng/recon-ng" \
        "Powerful reconnaissance framework with many public modules" \
        "recon-ng" \
        "workspace create test\nmarketplace install all\nuse recon/domains-hosts/shodan_hostname\nset SOURCE example.com\nrun" \
        "API keys (Shodan, Hunter, Censys, etc.), optional wordlists" ;;
      2) tool_submenu "Nikto" "Web server vulnerability scanner" "nikto -h target" \
        "Scans web servers for outdated software, misconfigs, etc." \
        "nikto -h example.com" \
        "nikto -h https://example.com -o nikto-report.html" \
        "No special downloads needed" ;;
      3) tool_submenu "DNSrecon" "DNS enumeration tool" "dnsrecon -d example.com" \
        "Performs DNS enumeration (AXFR, brute, std, etc.)" \
        "dnsrecon -d domain -D wordlist.txt -t brt" \
        "dnsrecon -d domain --xml output.xml" \
        "Subdomain / DNS wordlists recommended" ;;
      4) tool_submenu "UDPSCAN" "Custom UDP scanner" "~/iSH-tools/tools/udpscan.sh" \
        "Simple UDP port scanner (limited by iSH)" \
        "./udpscan.sh 192.168.1.1 53,123,161" \
        "Limited usefulness in iSH (no raw sockets)" \
        "No downloads needed" ;;
      5) tool_submenu "Infoga" "Email reconnaissance" "infoga -d example.com" \
        "Gathers emails and related info from public sources" \
        "infoga --domain example.com --source all" \
        "infoga --email user@domain.com" \
        "Some sources may benefit from API keys" ;;
      6) tool_submenu "BlackBird" "Social media username/email search" "blackbird -u username" \
        "Checks username/email across many social platforms" \
        "blackbird -u targetuser" \
        "blackbird -e target@email.com" \
        "No special files needed" ;;
      7) tool_submenu "NoSint" "General OSINT tool" "nosint" \
        "Lightweight OSINT gathering" \
        "nosint help" \
        "nosint search keyword" \
        "Depends on tool implementation" ;;
      8) tool_submenu "IntelBase" "Intelligence gathering CLI" "intelbase" \
        "Custom intel collection tool" \
        "intelbase --help" \
        "intelbase query term" \
        "No special downloads" ;;
      9) tool_submenu "XSStrike" "Advanced XSS scanner" "xsstrike -u url" \
        "Detects and exploits XSS vulnerabilities" \
        "xsstrike -u https://example.com/search?q=test" \
        "xsstrike -u url --crawl" \
        "Custom payload lists optional" ;;
      10) tool_submenu "sqlmap" "Automated SQL injection tool" "sqlmap -u url" \
        "Detects & exploits SQL injection flaws" \
        "sqlmap -u 'https://example.com?id=1' --batch --dbs" \
        "sqlmap -r request.txt --level 3" \
        "Tamper scripts / wordlists optional" ;;
      11) tool_submenu "ZipBrute" "ZIP archive password brute-forcer" "zipbrute file.zip wordlist.txt" \
        "Brute-forces ZIP file passwords" \
        "zipbrute protected.zip $WORDLIST_DIR/rockyou.txt" \
        "zipbrute file.zip -p minlen=6" \
        "Password wordlists required" ;;
      12) tool_submenu "PDFbrute" "PDF password brute-forcer" "pdfbrute file.pdf wordlist.txt" \
        "Brute-forces PDF file passwords" \
        "pdfbrute secured.pdf $WORDLIST_DIR/rockyou.txt" \
        "pdfbrute file.pdf -p max=8" \
        "Password wordlists required" ;;
      13) tool_submenu "OpenSSL" "Cryptography toolkit" "openssl" \
        "Encryption, hashing, certificates, etc." \
        "openssl enc -aes-256-cbc -salt -in file -out file.enc" \
        "openssl dgst -sha256 file" \
        "No downloads needed" ;;
      14) tool_submenu "GnuPG" "OpenPGP encryption & signing" "gpg" \
        "PGP key management & file encryption" \
        "gpg --encrypt --recipient user@example.com file" \
        "gpg --decrypt file.gpg" \
        "Public/private keys optional" ;;
      15) tool_submenu "theHarvester" "Email & subdomain harvester" "python3 ~/theHarvester/theHarvester.py -d domain -b all" \
        "Collects emails, subdomains, hosts from public sources" \
        "theHarvester.py -d example.com -b google,bing -l 500" \
        "theHarvester.py -d domain -f output.html" \
        "API keys improve results (Hunter, Shodan, etc.)" ;;
      16) tool_submenu "dirsearch" "Web path / directory brute-forcer" "dirsearch -u https://example.com" \
        "Brute-forces directories & files" \
        "dirsearch -u target -w wordlist.txt -e php,asp" \
        "dirsearch -u url --exclude-status=404,403" \
        "Directory wordlists required" ;;
      17) tool_submenu "WhatWeb" "Web technology fingerprinting" "whatweb example.com" \
        "Identifies CMS, frameworks, servers, etc." \
        "whatweb -v https://example.com" \
        "whatweb --list-plugins" \
        "No downloads needed" ;;
      18) tool_submenu "Amass" "In-depth subdomain enumeration" "amass enum -d example.com" \
        "Advanced attack surface mapping & asset discovery" \
        "amass enum -d domain -brute -w wordlist.txt" \
        "amass intel -org 'Example Inc'" \
        "Subdomain wordlists improve brute force" ;;

      19)
        while true; do
          banner
          echo "${CYAN}>> Launch Toolkit Menu${RESET}"
          echo ""
          echo "1) Open original iSH-tools (cons0le7's classic menu)"
          echo "   → The original ethical hacking toolkit interface"
          echo "2) Open Super iSH Menu (this enhanced menu)"
          echo "   → Current menu with detailed submenus, help & downloads"
          echo "3) Update both tools (git pull where possible)"
          echo "0) Back to main menu"
          read -p "${YELLOW}Choose: ${RESET}" subchoice
          case $subchoice in
            1)
              if [ -f "$HOME/iSH-tools/iSH-tools" ]; then
                cd "$HOME/iSH-tools" && ./iSH-tools
              else
                echo "${RED}Original iSH-tools not found.${RESET}"
                echo "Run this to install:"
                echo "git clone https://github.com/cons0le7/iSH-tools"
                echo "cd iSH-tools && chmod +x iSH-tools tools/*.sh"
              fi
              ;;
            2)
              exec "$0"
              ;;
            3)
              if [ -d "$HOME/iSH-tools" ]; then
                cd "$HOME/iSH-tools" && git pull && echo "${GREEN}iSH-tools updated.${RESET}"
              else
                echo "iSH-tools not cloned yet."
              fi
              echo "${GREEN}This super menu is already the latest version.${RESET}"
              ;;
            0) break ;;
            *) echo "Invalid choice." ;;
          esac
          read -p "Press Enter..." dummy
        done
        ;;

      0)
        banner
        echo "${GREEN}Exiting. Stay ethical.${RESET}"
        exit 0
        ;;

      *)
        echo "${RED}Invalid selection.${RESET}"
        ;;
    esac

    read -p "Press Enter to continue..." dummy
  done
}

main_menu