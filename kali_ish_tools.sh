#!/bin/bash

# Configuration
WORDLIST_GITHUB_URL="https://github.com/kkrypt0nn/wordlists/tree/main/wordlists/passwords"
WORDLIST_RAW_BASE="https://raw.githubusercontent.com/kkrypt0nn/wordlists/main/wordlists/passwords"
WORDLIST_DIR="/usr/share/wordlists"

# Check internet connectivity
check_internet() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: No internet connection. Please connect to the internet."
        echo "Press Enter to continue."
        read
        return 1
    fi
    return 0
}

# Check and set file permissions
check_permissions() {
    local file="$1"
    local perms="$2"
    if [ -f "$file" ]; then
        chmod "$perms" "$file" 2>/dev/null || echo "Warning: Failed to set permissions on $file."
    fi
}

# Display main menu
display_menu() {
    clear
    echo "============================================================="
    echo "       _          _ _       ___ _   _ ______   ____  "
    echo "      | |__   ___| | | ___ / __| | | |  _ \\ \\ / /  \\ "
    echo "      | '_ \\ / __| | |/ _ \\| | | |_| | | | \\ V /|   |"
    echo "      | | | | (__| | |  __/| | |  _  | |_| || | |   |"
    echo "      | |_| |_| \\___|_|_|\\___|___|_| |_|____/|_| |___|"
    echo "          (Kali iOS Security Tools)                  "
    echo "============================================================="
    echo "Welcome to Kali Linux on iSH! Select a tool by number (1-20)."
    echo "Type '?' for help, including usage examples and iSH notes."
    echo "Type '0' to exit to the shell."
    echo ""
    echo "=== Network Analysis ==="
    echo " 1. Nmap        - Network exploration and port scanning"
    echo " 2. Wireshark   - Packet analysis (text mode via tshark)"
    echo " 3. Netcat      - TCP/UDP data transfer and network testing"
    echo " 4. Hping3      - Packet crafting for network/firewall testing"
    echo " 5. Snmpcheck   - Enumerate SNMP data from network devices"
    echo "=== Wireless Tools (Limited in iSH) ==="
    echo " 6. Aircrack-ng - WiFi security assessment (limited functionality)"
    echo " 7. Kismet      - Wireless network detector (limited functionality)"
    echo "=== Web Application Testing ==="
    echo " 8. Sqlmap      - Automated SQL injection and database takeover"
    echo " 9. Burp Suite  - Web vulnerability scanner (CLI, manual setup needed)"
    echo "10. Nikto       - Web server vulnerability scanner"
    echo "11. Dirb        - Web content scanner for hidden directories"
    echo "12. W3af        - Web application audit framework (console mode)"
    echo "13. XSSPY       - Detect cross-site scripting (XSS) vulnerabilities"
    echo "=== Password Cracking ==="
    echo "14. Hydra       - Brute-force password cracking"
    echo "15. John        - Offline password cracker"
    echo "16. Hashcat     - Advanced hash cracking (CPU-only in iSH)"
    echo "=== Exploitation ==="
    echo "17. Metasploit  - Penetration testing and exploit framework"
    echo "18. SET         - Social-Engineer Toolkit for social attacks"
    echo "=== Reconnaissance ==="
    echo "19. Recon-ng    - Open-source intelligence gathering framework"
    echo "20. Maltego     - OSINT and forensics (CLI mode, manual setup needed)"
    echo "============================================================="
    echo "Enter a number (1-20), '0' to exit, or '?' for help: "
}

# Enhanced help system with usage examples and iSH notes
display_help() {
    clear
    echo "============================================================="
    echo "       Kali iOS Security Tools - Help Menu                  "
    echo "============================================================="
    echo "Usage: Enter a number (1-20) to select a tool, '0' to exit, or '?' to redisplay this help."
    echo "Each tool has a sub-menu with recommended commands for real-world use."
    echo "For Aircrack-ng, Dirb, Hydra, John, and Hashcat, select 'w' to choose a wordlist from GitHub."
    echo "iSH Notes:"
    echo "- iSH runs in text mode only; GUI tools are not supported."
    echo "- Wireless tools (Aircrack-ng, Kismet) have limited functionality due to iOS network restrictions."
    echo "- Performance may be slow for CPU-intensive tools (e.g., Hashcat, Metasploit)."
    echo "- Ensure 7GB+ free storage and a stable internet connection."
    echo "- Some tools may require additional setup or dependencies (e.g., Burp Suite, Maltego)."
    echo ""
    echo "Tool Usage Examples:"
    echo "1. Nmap: 'nmap -sV 192.168.1.1' (scan for services on IP)"
    echo "2. Wireshark: 'tshark -i eth0' (capture packets, interface limited in iSH)"
    echo "3. Netcat: 'nc -l 12345' (listen on port 12345)"
    echo "4. Hping3: 'hping3 -S 192.168.1.1' (SYN flood test)"
    echo "5. Snmpcheck: 'snmpcheck -t 192.168.1.1' (enumerate SNMP)"
    echo "6. Aircrack-ng: 'aircrack-ng -w wordlist.txt capture.cap' (crack WiFi, limited)"
    echo "7. Kismet: 'kismet -c wlan0' (wireless sniffer, limited)"
    echo "8. Sqlmap: 'sqlmap -u http://target.com --dbs' (enumerate databases)"
    echo "9. Burp Suite: Requires manual proxy setup; run 'burpsuite' for CLI"
    echo "10. Nikto: 'nikto -h http://target.com' (scan web server)"
    echo "11. Dirb: 'dirb http://target.com wordlist.txt' (scan for directories)"
    echo "12. W3af: 'w3af_console' then 'help' for commands"
    echo "13. XSSPY: 'xsspy http://target.com' (scan for XSS)"
    echo "14. Hydra: 'hydra -l user -P wordlist.txt ssh://192.168.1.1' (brute-force SSH)"
    echo "15. John: 'john --wordlist=wordlist.txt hash.txt' (crack password hashes)"
    echo "16. Hashcat: 'hashcat -m 0 hash.txt wordlist.txt' (crack MD5 hashes)"
    echo "17. Metasploit: 'msfconsole' then 'help' for commands"
    echo "18. SET: 'setoolkit' then follow prompts for social engineering"
    echo "19. Recon-ng: 'recon-ng' then 'marketplace search' for modules"
    echo "20. Maltego: 'maltego --help' for CLI options (setup required)"
    echo "============================================================="
    echo "Disclaimer: Use these tools responsibly and only on authorized systems."
    echo "Press Enter to return to the menu."
    read
}

# Fetch wordlist files from GitHub
fetch_wordlists() {
    local github_url="$1"
    local temp_file="/tmp/wordlists.html"
    echo "Fetching wordlist files from $github_url..."
    check_internet || return 1
    wget -q "$github_url" -O "$temp_file" || { echo "Failed to fetch wordlist files."; rm -f "$temp_file"; return 1; }
    wordlists=$(grep -oE 'href="/kkrypt0nn/wordlists/blob/main/wordlists/passwords/[^"]+\.txt"' "$temp_file" | \
                sed -E 's/.*\/([^"]+\.txt)".*/\1/' | sort | uniq)
    rm -f "$temp_file"
    if [ -z "$wordlists" ]; then
        echo "Error: No wordlist files found."
        echo "Press Enter to continue."
        read
        return 1
    fi
    local i=1
    wordlist_array=()
    echo "$wordlists" | while IFS= read -r wl; do
        echo "$i. $wl"
        wordlist_array[$i]="$wl"
        i=$((i + 1))
    done
    return 0
}

# Download selected wordlist and suggest cracking method
download_wordlist() {
    local choice="$1"
    local tool_name="$2"
    local wordlist="${wordlist_array[$choice]}"
    if [ -z "$wordlist" ]; then
        echo "Error: Invalid wordlist selection."
        echo "Press Enter to continue."
        read
        return 1
    fi
    local wordlist_url="${WORDLIST_RAW_BASE}/${wordlist}"
    local wordlist_path="${WORDLIST_DIR}/${wordlist}"
    echo "Downloading $wordlist to $wordlist_path..."
    check_internet || return 1
    if ! wget -q "$wordlist_url" -O "$wordlist_path"; then
        echo "Error: Failed to download $wordlist."
        echo "Press Enter to continue."
        read
        return 1
    fi
    check_permissions "$wordlist_path" "644"
    echo "$wordlist downloaded successfully to $wordlist_path."
    echo ""
    echo "=== Recommended Commands for $tool_name with $wordlist ==="
    case "$tool_name" in
        "Aircrack-ng")
            echo "echo '$wordlist' | grep -q 'probable_wpa.txt' && echo 'Note: probable_wpa.txt is tailored for WPA/WPA2 cracking, ideal for Aircrack-ng.'"
            echo "1. aircrack-ng -w $wordlist_path capture.cap # Crack WEP/WPA key from capture file"
            echo "2. aircrack-ng -w $wordlist_path -b 00:11:22:33:44:55 capture.cap # Crack with specific BSSID"
            echo "3. aircrack-ng -w $wordlist_path -e ESSID capture.cap # Crack for ESSID"
            echo "Tips:"
            echo "- Requires a capture file (e.g., capture.cap, not obtainable in iSH)."
            echo "- Use authorized systems only."
            echo "- Check 'man aircrack-ng' for more options."
            echo "- iSH lacks WiFi hardware access, limiting functionality."
            ;;
        "Dirb")
            echo "echo '$wordlist' | grep -q 'common.txt' && echo 'Note: common.txt is optimized for directory brute-forcing with Dirb.'"
            echo "1. dirb http://target.com $wordlist_path # Scan for directories"
            echo "2. dirb http://target.com $wordlist_path -X .php # Scan for .php files"
            echo "3. dirb http://target.com $wordlist_path -o output.txt # Save results"
            echo "Tips:"
            echo "- Replace 'http://target.com' with the target URL."
            echo "- Use larger wordlists like 'rockyou.txt' for broader scans."
            echo "- Check 'dirb -h' for advanced options."
            ;;
        "Hydra")
            echo "echo '$wordlist' | grep -q 'default_passwords_for_services.txt' && echo 'Note: This wordlist contains default service credentials, ideal for SSH/FTP brute-forcing.'"
            echo "1. hydra -l user -P $wordlist_path ssh://192.168.1.1 # Brute-force SSH with single username"
            echo "2. hydra -L users.txt -P $wordlist_path ftp://192.168.1.1 # Brute-force FTP with username list"
            echo "3. hydra -l admin -P $wordlist_path http-post-form '/login:username=admin&password=^PASS^:Invalid' # Brute-force web form"
            echo "Tips:"
            echo "- Replace '192.168.1.1' with target IP."
            echo "- Use a username list for broader attacks."
            echo "- Check 'hydra -U <protocol>' for supported services."
            ;;
        "John the Ripper")
            echo "echo '$wordlist' | grep -q 'rockyou.txt' && echo 'Note: rockyou.txt is a comprehensive list from a major breach, ideal for general cracking.'"
            echo "1. john --wordlist=$wordlist_path hash.txt # Crack hashes with wordlist"
            echo "2. john --wordlist=$wordlist_path --rules hash.txt # Apply mangling rules for variations"
            echo "3. john --wordlist=$wordlist_path --format=md5crypt hash.txt # Specify hash format"
            echo "Tips:"
            echo "- Prepare hashes in hash.txt (e.g., /etc/shadow format)."
            echo "- Use '--show' to view cracked passwords."
            echo "- Check 'john --list=formats' for supported hash types."
            ;;
        "Hashcat")
            echo "echo '$wordlist' | grep -q 'probable_wpa.txt' && echo 'Note: probable_wpa.txt is tailored for WPA/WPA2 cracking.'"
            echo "1. hashcat -m 0 -a 0 hash.txt $wordlist_path # Crack MD5 hashes (straight attack)"
            echo "2. hashcat -m 1000 -a 0 hash.txt $wordlist_path # Crack NTLM hashes"
            echo "3. hashcat -m 0 -a 0 -r rules/best64.rule hash.txt $wordlist_path # Apply rules for variations"
            echo "Tips:"
            echo "- Use '-m' to specify hash type (e.g., 0 for MD5, 1000 for NTLM)."
            echo "- Create hash.txt with hashes to crack."
            echo "- iSH is CPU-only; expect slow performance."
            echo "- Check 'hashcat --help' for hash modes."
            ;;
    esac
    echo "============================================================="
    echo "Press Enter to return to $tool_name sub-menu."
    read
}

# Check if tool is installed and compatible
check_tool() {
    local tool_cmd="$1"
    local tool_name="$2"
    if ! command -v "$tool_cmd" >/dev/null 2>&1; then
        echo "Error: $tool_name is not installed or not found."
        echo "Try running 'sudo apt update && sudo apt install $tool_cmd' in the Kali environment."
        echo "Press Enter to return to the menu."
        read
        return 1
    fi
    case "$tool_cmd" in
        aircrack-ng|kismet)
            echo "Warning: $tool_name has limited functionality in iSH due to iOS network restrictions."
            echo "WiFi hardware access is not available."
            ;;
        burpsuite|maltego)
            echo "Note: $tool_name requires manual setup for full functionality in CLI mode."
            echo "Run '$tool_cmd --help' for setup instructions."
            ;;
        hashcat|msfconsole)
            echo "Note: $tool_name may be slow in iSH due to CPU-intensive operations."
            echo "Ensure sufficient memory (7GB+ recommended)."
            ;;
    esac
    return 0
}

# Sub-menu for each tool with recommended commands and wordlist option
display_sub_menu() {
    local choice="$1"
    local tool_cmd=""
    local tool_name=""
    local desc=""
    local cmd1=""
    local cmd2=""
    local cmd3=""
    case $choice in
        1)
            tool_cmd="nmap"; tool_name="Nmap"; desc="Network exploration and port scanning"
            cmd1="nmap -sV 192.168.1.1 # Scan for services and versions"
            cmd2="nmap -p 1-65535 192.168.1.1 # Full port scan"
            cmd3="nmap -sS -T4 192.168.1.0/24 # Stealth scan network"
            ;;
        2)
            tool_cmd="tshark"; tool_name="Wireshark"; desc="Packet analysis (text mode via tshark)"
            cmd1="tshark -i eth0 # Capture packets on eth0 (limited in iSH)"
            cmd2="tshark -r capture.pcap # Analyze saved capture file"
            cmd3="tshark -f 'tcp port 80' # Filter HTTP traffic"
            ;;
        3)
            tool_cmd="nc"; tool_name="Netcat"; desc="TCP/UDP data transfer and network testing"
            cmd1="nc -l 12345 # Listen on port 12345"
            cmd2="nc 192.168.1.1 80 # Connect to a web server"
            cmd3="nc -zv 192.168.1.1 1-100 # Scan ports 1-100"
            ;;
        4)
            tool_cmd="hping3"; tool_name="Hping3"; desc="Packet crafting for network/firewall testing"
            cmd1="hping3 -S 192.168.1.1 # SYN scan"
            cmd2="hping3 -c 10 -p 80 192.168.1.1 # Send 10 packets to port 80"
            cmd3="hping3 --scan 1-100 192.168.1.1 # Scan ports 1-100"
            ;;
        5)
            tool_cmd="snmpcheck"; tool_name="Snmpcheck"; desc="Enumerate SNMP data from network devices"
            cmd1="snmpcheck -t 192.168.1.1 # Enumerate SNMP data"
            cmd2="snmpcheck -t 192.168.1.1 -c public # Use community string 'public'"
            cmd3="snmpcheck -t 192.168.1.1 -v 2c # Specify SNMP version 2c"
            ;;
        6)
            tool_cmd="aircrack-ng"; tool_name="Aircrack-ng"; desc="WiFi security assessment (limited in iSH)"
            cmd1="aircrack-ng -w wordlist.txt capture.cap # Crack WEP/WPA key"
            cmd2="aircrack-ng -w wordlist.txt -b 00:11:22:33:44:55 capture.cap # Crack with BSSID"
            cmd3="aircrack-ng -w wordlist.txt -e ESSID capture.cap # Crack for ESSID"
            ;;
        7)
            tool_cmd="kismet"; tool_name="Kismet"; desc="Wireless network detector (limited in iSH)"
            cmd1="kismet -c wlan0 # Start wireless sniffing (limited)"
            cmd2="kismet -n # Run in non-interactive mode"
            cmd3="kismet --no-gps # Run without GPS"
            ;;
        8)
            tool_cmd="sqlmap"; tool_name="Sqlmap"; desc="Automated SQL injection and database takeover"
            cmd1="sqlmap -u http://target.com --dbs # Enumerate databases"
            cmd2="sqlmap -u http://target.com --tables -D mydb # List tables"
            cmd3="sqlmap -u http://target.com --dump -D mydb -T users # Dump table"
            ;;
        9)
            tool_cmd="burpsuite"; tool_name="Burp Suite"; desc="Web vulnerability scanner (CLI, manual setup needed)"
            cmd1="burpsuite # Start CLI mode (setup proxy manually)"
            cmd2="burpsuite --help # View CLI options"
            cmd3="burpsuite -c # Start in console mode"
            ;;
        10)
            tool_cmd="nikto"; tool_name="Nikto"; desc="Web server vulnerability scanner"
            cmd1="nikto -h http://target.com # Scan web server"
            cmd2="nikto -h https://target.com -ssl # Scan HTTPS server"
            cmd3="nikto -h http://target.com -Tuning x # Custom scan tuning"
            ;;
        11)
            tool_cmd="dirb"; tool_name="Dirb"; desc="Web content scanner for hidden directories"
            cmd1="dirb http://target.com wordlist.txt # Scan for directories"
            cmd2="dirb http://target.com wordlist.txt -X .php # Scan for .php files"
            cmd3="dirb http://target.com wordlist.txt -o output.txt # Save results"
            ;;
        12)
            tool_cmd="w3af_console"; tool_name="W3af"; desc="Web application audit framework (console mode)"
            cmd1="w3af_console # Start console, then 'help'"
            cmd2="w3af_console -s scan.w3af # Run saved scan script"
            cmd3="w3af_console # Use 'profiles list' to view scan profiles"
            ;;
        13)
            tool_cmd="xsspy"; tool_name="XSSPY"; desc="Detect cross-site scripting (XSS) vulnerabilities"
            cmd1="xsspy http://target.com # Scan for XSS"
            cmd2="xsspy http://target.com -v # Verbose scan"
            cmd3="xsspy http://target.com --depth 2 # Deep crawl"
            ;;
        14)
            tool_cmd="hydra"; tool_name="Hydra"; desc="Brute-force password cracking"
            cmd1="hydra -l user -P wordlist.txt ssh://192.168.1.1 # Brute-force SSH"
            cmd2="hydra -L users.txt -P wordlist.txt ftp://192.168.1.1 # Brute-force FTP"
            cmd3="hydra -l admin -P wordlist.txt http-post-form '/login:username=admin&password=^PASS^:Invalid' # Brute-force web form"
            ;;
        15)
            tool_cmd="john"; tool_name="John the Ripper"; desc="Offline password cracker"
            cmd1="john --wordlist=wordlist.txt hash.txt # Crack hashes with wordlist"
            cmd2="john --wordlist=wordlist.txt --rules hash.txt # Apply mangling rules"
            cmd3="john --wordlist=wordlist.txt --format=md5crypt hash.txt # Specify hash format"
            ;;
        16)
            tool_cmd="hashcat"; tool_name="Hashcat"; desc="Advanced hash cracking (CPU-only in iSH)"
            cmd1="hashcat -m 0 -a 0 hash.txt wordlist.txt # Crack MD5 hashes"
            cmd2="hashcat -m 1000 -a 0 hash.txt wordlist.txt # Crack NTLM hashes"
            cmd3="hashcat -m 0 -a 0 -r rules/best64.rule hash.txt wordlist.txt # Apply rules"
            ;;
        17)
            tool_cmd="msfconsole"; tool_name="Metasploit Framework"; desc="Penetration testing and exploit framework"
            cmd1="msfconsole # Start console, then 'help'"
            cmd2="msfconsole -q -x 'use exploit/windows/smb/ms17_010_eternalblue; set RHOSTS 192.168.1.1; run' # Exploit example"
            cmd3="msfconsole -q -x 'search type:exploit apache' # Search exploits"
            ;;
        18)
            tool_cmd="setoolkit"; tool_name="SET"; desc="Social-Engineer Toolkit for social attacks"
            cmd1="setoolkit # Start SET, follow prompts"
            cmd2="setoolkit -t # Run in terminal mode"
            cmd3="setoolkit # Select 'Social Engineering Attacks'"
            ;;
        19)
            tool_cmd="recon-ng"; tool_name="Recon-ng"; desc="Open-source intelligence gathering framework"
            cmd1="recon-ng # Start, then 'marketplace search'"
            cmd2="recon-ng -m recon/domains-hosts/hackertarget # Run OSINT module"
            cmd3="recon-ng -w my_workspace # Use custom workspace"
            ;;
        20)
            tool_cmd="maltego"; tool_name="Maltego"; desc="OSINT and forensics (CLI mode, manual setup needed)"
            cmd1="maltego --help # View CLI options"
            cmd2="maltego -c # Start in console mode"
            cmd3="maltego --list-transforms # List available transforms"
            ;;
        *)
            echo "Invalid option. Type '?' for help or a number (1-20)."
            return 1
            ;;
    esac

    if ! check_tool "$tool_cmd" "$tool_name"; then
        return 1
    fi

    while true; do
        clear
        echo "============================================================="
        echo "       $tool_name - Sub-Menu"
        echo "============================================================="
        echo "Description: $desc"
        echo "Recommended Commands for Real-World Use:"
        echo "1. $cmd1"
        echo "2. $cmd2"
        echo "3. $cmd3"
        echo "============================================================="
        echo "Options:"
        echo "1-3. Run recommended command"
        echo "c. Enter custom command"
        echo "$([[ $choice == 6 || $choice == 11 || $choice == 14 || $choice == 15 || $choice == 16 ]] && echo 'w. Select wordlist from GitHub')"
        echo "m. Return to main menu"
        echo "?. View help for $tool_name"
        echo "============================================================="
        echo "Enter your choice: "
        read sub_choice
        case "$sub_choice" in
            1)
                echo "Run: ${cmd1%% #*} ? (y/n)"
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    echo "Executing: ${cmd1%% #*}"
                    ${cmd1%% #*} || { echo "Error: Command failed."; }
                    echo "Press Enter to continue."
                    read
                fi
                ;;
            2)
                echo "Run: ${cmd2%% #*} ? (y/n)"
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    echo "Executing: ${cmd2%% #*}"
                    ${cmd2%% #*} || { echo "Error: Command failed."; }
                    echo "Press Enter to continue."
                    read
                fi
                ;;
            3)
                echo "Run: ${cmd3%% #*} ? (y/n)"
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    echo "Executing: ${cmd3%% #*}"
                    ${cmd3%% #*} || { echo "Error: Command failed."; }
                    echo "Press Enter to continue."
                    read
                fi
                ;;
            c)
                echo "Enter custom command for $tool_name:"
                read custom_cmd
                if [ -n "$custom_cmd" ]; then
                    echo "Run: $custom_cmd ? (y/n)"
                    read confirm
                    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                        echo "Executing: $custom_cmd"
                        $custom_cmd || { echo "Error: Command failed."; }
                        echo "Press Enter to continue."
                        read
                    fi
                else
                    echo "No command entered."
                    echo "Press Enter to continue."
                    read
                fi
                ;;
            w)
                if [ "$choice" != "6" ] && [ "$choice" != "11" ] && [ "$choice" != "14" ] && [ "$choice" != "15" ] && [ "$choice" != "16" ]; then
                    echo "Invalid option."
                    echo "Press Enter to continue."
                    read
                    continue
                fi
                if ! fetch_wordlists "$WORDLIST_GITHUB_URL"; then
                    continue
                fi
                echo
                echo "Enter a number to select a wordlist: "
                read wordlist_choice
                if [[ "$wordlist_choice" =~ ^[0-9]+$ ]] && [ "$wordlist_choice" -ge 1 ] && [ "$wordlist_choice" -le "${#wordlist_array[@]}" ]; then
                    download_wordlist "$wordlist_choice" "$tool_name"
                else
                    echo "Invalid wordlist number."
                    echo "Press Enter to continue."
                    read
                fi
                ;;
            m)
                return 0
                ;;
            ?)
                clear
                echo "============================================================="
                echo "       $tool_name - Help"
                echo "============================================================="
                echo "Description: $desc"
                echo "iSH Notes:"
                case "$tool_cmd" in
                    aircrack-ng|kismet)
                        echo "- Limited functionality due to iOS network restrictions."
                        echo "- Cannot access WiFi hardware or inject packets."
                        echo "- Use pre-captured files for analysis."
                        ;;
                    burpsuite|maltego)
                        echo "- Requires manual setup for full functionality."
                        echo "- Run '$tool_cmd --help' for CLI options."
                        ;;
                    hashcat|msfconsole)
                        echo "- May be slow due to CPU-intensive operations in iSH."
                        echo "- Ensure sufficient memory and storage."
                        ;;
                esac
                echo "Recommended Commands:"
                echo "- $cmd1"
                echo "- $cmd2"
                echo "- $cmd3"
                echo "Tips:"
                echo "- Always test on authorized systems only."
                echo "- Check 'man $tool_cmd' or '$tool_cmd --help' for more options."
                echo "- Save output to files (e.g., '$tool_cmd > output.txt') for analysis."
                echo "- Ensure 7GB+ free storage as per Kali iOS requirements."
                if [[ $choice == 6 || $choice == 11 || $choice == 14 || $choice == 15 || $choice == 16 ]]; then
                    echo "- Use 'w' to select a wordlist from GitHub for applicable tools."
                fi
                echo "============================================================="
                echo "Press Enter to return to $tool_name sub-menu."
                read
                ;;
            *)
                echo "Invalid option. Choose 1-3, c, w (for Aircrack-ng/Dirb/Hydra/John/Hashcat), m, or ?."
                echo "Press Enter to continue."
                read
                ;;
        esac
    done
}

# Main menu loop
echo "Welcome to Kali Linux on iSH!"
echo "Set iSH font size to 9 in Appearance Settings for best display."
echo "Ensure 7GB+ free storage and a stable internet connection."
echo "Use these tools responsibly and only on authorized systems."
display_menu
while true; do
    echo -n "Enter your choice: "
    read choice
    if [ "$choice" = "?" ]; then
        display_help
        display_menu
    elif [ "$choice" = "0" ]; then
        echo "Exiting to shell..."
        exit 0
    else
        display_sub_menu "$choice" || display_menu
    fi
done