#!/usr/bin/env bash
# CIS Benchmark Level 1 quick checks for RHEL
set -euo pipefail
REPORT_DIR=${REPORT_DIR:-/var/reports/compliance}
mkdir -p "$REPORT_DIR"
REPORT="$REPORT_DIR/cis_$(hostname)_$(date +%Y%m%d).txt"
{
echo "=== CIS Benchmark Report: $(hostname) ==="
echo "Date: $(date)"
echo ""
echo "--- 1. Filesystem ---"
grep -q nodev /proc/mounts && echo "[PASS] nodev mounts OK" || echo "[FAIL] nodev not set"

echo ""
echo "--- 2. SSH ---"
sshd_cfg=/etc/ssh/sshd_config
grep -qiE "^PermitRootLogin no" "$sshd_cfg" && echo "[PASS] PermitRootLogin no" || echo "[FAIL] PermitRootLogin should be no"
grep -qiE "^Protocol 2" "$sshd_cfg" || echo "[INFO] Protocol line not present (default OK in new SSH)"
grep -qiE "^MaxAuthTries [1-4]$" "$sshd_cfg" && echo "[PASS] MaxAuthTries OK" || echo "[FAIL] MaxAuthTries not set"

echo ""
echo "--- 3. Password Policy ---"
grep -q "minlen=14" /etc/security/pwquality.conf 2>/dev/null && echo "[PASS] minlen=14" || echo "[FAIL] password minlen < 14"

echo ""
echo "--- 4. Firewall ---"
systemctl is-active firewalld &>/dev/null && echo "[PASS] firewalld active" || echo "[FAIL] firewalld not active"

echo ""
echo "--- 5. SELinux ---"
sestatus | grep -q "enforcing" && echo "[PASS] SELinux enforcing" || echo "[FAIL] SELinux not enforcing"

} | tee "$REPORT"
echo "Report saved: $REPORT"
