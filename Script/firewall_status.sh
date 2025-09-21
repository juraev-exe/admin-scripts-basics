#!/usr/bin/env bash
# Show firewall status across common Linux stacks: UFW, firewalld, nftables, iptables.
# Usage:
#   ./firewall_status.sh          # краткий обзор
#   ./firewall_status.sh --full   # подробный вывод правил/зон
# Exit code: 0 — успешно, 1 — есть ошибки выполнения.

set -Eeuo pipefail

FULL=0
if [[ "${1:-}" == "--full" ]]; then FULL=1; fi

have() { command -v "$1" >/dev/null 2>&1; }
bold() { printf "\033[1m%s\033[0m\n" "$*"; }
hr() { printf "%s\n" "----------------------------------------"; }

# Use sudo if not root and sudo is available.
SUDO=""
if [[ ${EUID:-$(id -u)} -ne 0 ]] && have sudo; then
  SUDO="sudo"
fi

svc_state() {
  local svc="$1"
  if have systemctl; then
    if systemctl is-active --quiet "$svc"; then
      echo "active"
    else
      # print actual state text if available, else 'inactive'
      systemctl is-active "$svc" 2>/dev/null || echo "inactive"
    fi
  else
    echo "unknown"
  fi
}

summary_line() {
  # name | installed | service | note
  printf "%-12s | %-9s | %-8s | %s\n" "$1" "$2" "$3" "$4"
}

bold "Firewall summary"
hr
summary_line "Stack" "Installed" "Service" "Note"
hr

# --- UFW ---
if have ufw; then
  ufw_status="$($SUDO ufw status 2>/dev/null | head -n1 | awk -F': ' '{print $2}')"
  ufw_svc="$(svc_state ufw)"
  summary_line "UFW" "yes" "$ufw_svc" "Status: ${ufw_status:-unknown}"
else
  summary_line "UFW" "no" "-" "-"
fi

# --- firewalld ---
if have firewall-cmd; then
  fw_state="$($SUDO firewall-cmd --state 2>/dev/null || true)"
  fw_svc="$(svc_state firewalld)"
  summary_line "firewalld" "yes" "$fw_svc" "State: ${fw_state:-unknown}"
else
  summary_line "firewalld" "no" "-" "-"
fi

# --- nftables ---
if have nft; then
  nft_svc="$(svc_state nftables)"
  # Count tables for a tiny summary
  nft_tables="$($SUDO nft list tables 2>/dev/null | wc -l | tr -d ' ')"
  summary_line "nftables" "yes" "$nft_svc" "Tables: ${nft_tables:-0}"
else
  summary_line "nftables" "no" "-" "-"
fi

# --- iptables ---
if have iptables; then
  # Show default policies (filter table) in short form
  ipt_policies="$($SUDO iptables -S 2>/dev/null | awk '/^-P/ {printf "%s=%s ", $2, $3}')"
  # Some systems have a legacy iptables service; try to show it
  ipt_svc="$(svc_state iptables || true)"
  summary_line "iptables" "yes" "${ipt_svc:-"-"}" "Policies: ${ipt_policies:-unknown}"
else
  summary_line "iptables" "no" "-" "-"
fi
hr

# ----- Detailed sections -----
if (( FULL )); then
  echo
  bold "Detailed information"

  # UFW details
  if have ufw; then
    echo
    bold "[UFW]"
    $SUDO ufw status verbose || true
    echo
    $SUDO ufw status numbered || true
  fi

  # firewalld details
  if have firewall-cmd; then
    echo
    bold "[firewalld]"
    state="$($SUDO firewall-cmd --state 2>/dev/null || true)"
    echo "State: ${state:-unknown}"
    if [[ "${state:-}" == "running" ]]; then
      def_zone="$($SUDO firewall-cmd --get-default-zone)"
      echo "Default zone: ${def_zone}"
      echo "Active zones:"
      $SUDO firewall-cmd --get-active-zones || true
      echo
      echo "Zone details:"
      # list zone names (lines 1,3,5... contain zone names)
      while read -r zone _; do
        [[ -z "$zone" ]] && continue
        echo "--- $zone ---"
        $SUDO firewall-cmd --zone="$zone" --list-all || true
        echo
      done < <($SUDO firewall-cmd --get-active-zones | awk 'NR%2==1{print $1}')
    fi
  fi

  # nftables details
  if have nft; then
    echo
    bold "[nftables]"
    $SUDO nft list tables || true
    echo
    # Avoid dumping megabytes; show first 200 lines and hint
    if $SUDO nft list ruleset >/tmp/.nftdump 2>/dev/null; then
      echo "(ruleset, first 200 lines)"
      head -n 200 /tmp/.nftdump
      total=$(wc -l </tmp/.nftdump | tr -d ' ')
      if (( total > 200 )); then
        echo "[…truncated. Run 'sudo nft list ruleset' to see all ${total} lines.]"
      fi
      rm -f /tmp/.nftdump
    fi
  fi

  # iptables details
  if have iptables; then
    echo
    bold "[iptables]"
    echo "Filter table:"
    $SUDO iptables -L -n -v || true
    echo
    echo "NAT table:"
    $SUDO iptables -t nat -L -n -v || true
  fi
fi
