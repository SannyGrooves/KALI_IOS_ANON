mkdir -p ~/iSH-tools
cd iSH-tools
apk update && apk upgrade && \
apk add python3 py3-pip bash git nano curl wget whois bind-tools openssh nmap unzip zip whatweb amass 2>/dev/null && \
pip3 install pystyle requests beautifulsoup4 lxml dirsearch && \
git clone https://github.com/cons0le7/iSH-tools && cd iSH-tools && chmod +x iSH-tools tools/*.sh && cd ~ && \
git clone https://github.com/lanmaster53/recon-ng && cd recon-ng && pip3 install -r REQUIREMENTS && cd ~ && \
git clone https://github.com/laramies/theHarvester && cd theHarvester && pip3 install -r requirements.txt && cd ~ && \
mkdir -p ~/wordlists && \
wget -q -O ~/wordlists/rockyou.txt.gz https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt.gz && gunzip -f ~/wordlists/rockyou.txt.gz && \
echo "Setup finished. Now launch menu with: ~/super-ish-menu.sh"
apk update && apk upgrade && apk add python3 py3-pip bash git nano curl wget whois bind-tools openssh nmap unzip zip whatweb amass 2>/dev/null
pip3 install pystyle requests beautifulsoup4 lxml dirsearch
cd iSH-tools
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
# Paste this after installation finishes

cd ~

if [ -f super-ish-menu.sh ]; then
  chmod +x super-ish-menu.sh
fi

cat << 'EOF'

══════════════════════════════════════════════════════════
echo -e "${GREEN}Installation finished!${NC}"
══════════════════════════════════════════════════════════

What would you like to do next?

  1) Launch Super iSH Menu (enhanced)
  2) Launch original iSH-tools menu
  3) Fix permissions + re-download Super menu
  4) Exit to shell

EOF

echo -n "Enter number (1–4): "
read -r choice

case $choice in
  1) exec ~/super-ish-menu.sh 2>/dev/null || echo "Not found — run manually" ;;
  2) cd ~/iSH-tools 2>/dev/null && ./iSH-tools || echo "Original iSH-tools not found" ;;
  3)
    rm -f super-ish-menu.sh 2>/dev/null
    curl -o super-ish-menu.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/super-ish-menu.sh
    chmod +x super-ish-menu.sh
    echo "Done. Launch with:  ~/super-ish-menu.sh"
    ;;
  *) echo "Exiting. Use ~/super-ish-menu.sh later." ;;
esac
chmod +x ~/super-ish-menu.sh

# ─────────────────────────────────────────────────────────────
# Final choice menu after installation
# ─────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════════════════════"
echo "              Installation finished!"
echo "══════════════════════════════════════════════════════════"
echo ""
echo "What would you like to do next?"
echo ""
echo "  1) Launch Super iSH Menu (enhanced version with submenus)"
echo "  2) Launch original iSH-tools menu (cons0le7's classic menu)"
echo "  3) Fix permissions + re-download latest Super menu"
echo "  4) Exit to shell (do nothing)"
echo ""
echo -n "Enter number (1–4): "
read -r choice

case $choice in
  1)
    if [ -f "$HOME/super-ish-menu.sh" ]; then
      chmod +x "$HOME/super-ish-menu.sh"
      exec "$HOME/super-ish-menu.sh"
    else
      echo "Super menu not found → downloading now..."
      cd ~ && curl -o super-ish-menu.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/super-ish-menu.sh
      chmod +x super-ish-menu.sh
      exec ./super-ish-menu.sh
    fi
    ;;

  2)
    if [ -f "$HOME/iSH-tools/iSH-tools" ]; then
      cd "$HOME/iSH-tools" && ./iSH-tools
    else
      echo "Original iSH-tools not found."
      echo "Run: git clone https://github.com/cons0le7/iSH-tools"
      echo "cd iSH-tools && chmod +x iSH-tools tools/*.sh && ./iSH-tools"
    fi
    ;;

  3)
    echo "Fixing permissions + updating Super menu..."
    cd ~
    rm -f super-ish-menu.sh 2>/dev/null
    curl -o super-ish-menu.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/super-ish-menu.sh
    chmod +x super-ish-menu.sh
    echo ""
    echo "Updated. You can now run it with:"
    echo "  ~/super-ish-menu.sh"
    echo ""
    echo "Want to launch it now? (y/n)"
    read -r launch
    if [[ "$launch" =~ ^[Yy]$ ]]; then
      exec ./super-ish-menu.sh
    fi
    ;;

  4|*)
    echo ""
    echo "Exiting to shell. You can start the menu later with:"
    echo "  ~/super-ish-menu.sh"
    echo "  or"
    echo "  cd ~/iSH-tools && ./iSH-tools"
    echo ""
    ;;
esac
