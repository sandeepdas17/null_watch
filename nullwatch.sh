#!/usr/bin/env bash
# =============================================================================
# health_monitor.sh - Automated Server Health Monitor & Alert System
#
# Checks:
#   1. Disk   : root filesystem (/) usage      -> alert if > DISK_THRESHOLD %
#   2. Memory : RAM usage (from free -m)       -> alert if > MEM_THRESHOLD %
#   3. CPU    : top 3 CPU-consuming processes  -> always reported
#
# Usage:
#   ./health_monitor.sh
#
# Cron example (run every 5 minutes):
#   */5 * * * * /home/youruser/health_monitor.sh >/dev/null 2>&1
# =============================================================================

set -u

# ---------------------------- Configuration ----------------------------------
DISK_THRESHOLD=80          # percent
MEM_THRESHOLD=85           # percent
LOG_FILE="${LOG_FILE:-$HOME/health_monitor.log}"
ALERT_EMAIL="${ALERT_EMAIL:-}"   # set to an address to enable email alerts (needs mail/mailx)
HOSTNAME_STR="$(hostname)"

ALERTS=()                  # collects alert messages

# ------------------------------ Helpers --------------------------------------
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
    # Write to log file and stdout
    echo "[$(timestamp)] $*" | tee -a "$LOG_FILE"
}

# ----------------------------- 1. Disk check ---------------------------------
check_disk() {
    # df -h / -> last line, 5th column is Use%, strip the % sign
    local usage
    usage=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

    if [[ -z "$usage" ]]; then
        log "ERROR: could not read disk usage"
        return
    fi

    log "Disk usage on / : ${usage}% (threshold ${DISK_THRESHOLD}%)"

    if (( usage > DISK_THRESHOLD )); then
        ALERTS+=("DISK ALERT: root filesystem is ${usage}% full (limit ${DISK_THRESHOLD}%)")
    fi
}

# ---------------------------- 2. Memory check --------------------------------
check_memory() {
    # free -m -> "Mem:" row: $2 = total, $7 = available (MB)
    local total available used_pct
    read -r total available < <(free -m | awk '/^Mem:/ {print $2, $7}')

    if [[ -z "${total:-}" || "$total" -eq 0 ]]; then
        log "ERROR: could not read memory usage"
        return
    fi

    # Usage based on *available* memory (more accurate than "used")
    used_pct=$(( (total - available) * 100 / total ))

    log "Memory usage: ${used_pct}% (${available}MB available of ${total}MB, threshold ${MEM_THRESHOLD}%)"

    if (( used_pct > MEM_THRESHOLD )); then
        ALERTS+=("MEMORY ALERT: RAM usage is ${used_pct}% (limit ${MEM_THRESHOLD}%)")
    fi
}

# ------------------------- 3. Top CPU processes ------------------------------
check_top_processes() {
    log "Top 3 CPU-consuming processes:"
    # --sort=-%cpu : highest CPU first; head -n 4 = header + 3 rows
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 4 | while IFS= read -r line; do
        log "  $line"
    done
}

# ------------------------------ Alerting -------------------------------------
send_alerts() {
    if (( ${#ALERTS[@]} == 0 )); then
        log "STATUS: OK - all checks passed on ${HOSTNAME_STR}"
        return
    fi

    local body
    body="Health alerts for ${HOSTNAME_STR} at $(timestamp):"$'\n'
    for a in "${ALERTS[@]}"; do
        log "$a"
        body+="- ${a}"$'\n'
    done

    # Optional email alert
    if [[ -n "$ALERT_EMAIL" ]] && command -v mail >/dev/null 2>&1; then
        echo "$body" | mail -s "[ALERT] ${HOSTNAME_STR} health warning" "$ALERT_EMAIL"
        log "Alert email sent to ${ALERT_EMAIL}"
    fi
}

# -------------------------------- Main ---------------------------------------
main() {
    log "===== Health check started on ${HOSTNAME_STR} ====="
    check_disk
    check_memory
    check_top_processes
    send_alerts
    log "===== Health check finished ====="
}

main "$@"
