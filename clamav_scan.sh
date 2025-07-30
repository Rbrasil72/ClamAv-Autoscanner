#!/bin/bash

# === Configuration ===
LOG_DIR="$HOME/clamav_logs"
SCAN_DIR="$HOME"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/scan_$TIMESTAMP.log"

# === Create log directory ===
mkdir -p "$LOG_DIR"

echo "[*] Starting ClamAV scan on $SCAN_DIR"
echo "[*] Saving results to $LOG_FILE"

# === Stop auto-updater to avoid lock issues ===
echo "[*] Stopping freshclam daemon (if running)..."
sudo systemctl stop clamav-freshclam 2>/dev/null

# === Update virus database ===
echo "[*] Updating ClamAV definitions..."
sudo freshclam

# === Restart daemon ===
echo "[*] Restarting freshclam daemon..."
sudo systemctl start clamav-freshclam 2>/dev/null

# === Run the scan ===
echo "[*] Scanning $SCAN_DIR ..."
clamscan -r -i --verbose "$SCAN_DIR" | tee "$LOG_FILE"

echo "[✓] Scan complete."
echo "[*] Results saved to: $LOG_FILE"
