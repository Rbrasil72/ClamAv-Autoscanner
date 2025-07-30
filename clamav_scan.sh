#!/bin/bash

# === Setup ===
LOG_DIR="$HOME/clamav_logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/scan_$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

echo "============================"
echo " ClamAV Automated Scanner"
echo "============================"
echo "Choose scan type:"
echo "1) Full system scan"
echo "2) Custom directory scan"
read -rp "Enter option [1-2]: " SCAN_OPTION

# === Determine scan target ===
if [ "$SCAN_OPTION" == "1" ]; then
    SCAN_DIR="/"
    echo "[*] Full system scan selected."
elif [ "$SCAN_OPTION" == "2" ]; then
    read -rp "Enter full path to directory: " CUSTOM_DIR
    if [ ! -d "$CUSTOM_DIR" ]; then
        echo "❌ Directory not found: $CUSTOM_DIR"
        exit 1
    fi
    SCAN_DIR="$CUSTOM_DIR"
    echo "[*] Custom directory scan selected: $SCAN_DIR"
else
    echo "❌ Invalid option."
    exit 1
fi

echo "[*] Scan results will be saved to: $LOG_FILE"

# === Stop freshclam daemon ===
echo "[*] Stopping freshclam daemon (if running)..."
sudo systemctl stop clamav-freshclam 2>/dev/null

# === Update definitions ===
echo "[*] Updating virus definitions..."
sudo freshclam

# === Restart daemon ===
echo "[*] Restarting freshclam daemon..."
sudo systemctl start clamav-freshclam 2>/dev/null

# === Run scan with verbose output ===
echo "[*] Starting scan on: $SCAN_DIR ..."
clamscan -r -i --verbose "$SCAN_DIR" | tee "$LOG_FILE"

echo "[✓] Scan complete. Results saved to: $LOG_FILE"
