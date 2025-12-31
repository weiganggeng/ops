#!/bin/bash
HOSTFILE="ib-condition-hosts.txt"
CLUSTER="kepler01"
PARALLEL=5

SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

check_host() {
    host="$1"

    echo "===================================="
    echo "🔵 Checking host: $host"
    echo "===================================="

    # Detect mlx5 devices
    iface_list=$($SSH "$host" "ls /sys/class/infiniband | grep mlx5" 2>/dev/null)

    if [ -z "$iface_list" ]; then
        echo "❌ No mlx5 interfaces or SSH failure on $host"
        return
    fi

    all_good=true

    for iface in $iface_list; do
        echo "--- Checking $iface ---"

        out=$($SSH "$host" "ibstat $iface" 2>/dev/null)

        echo "$out"
        echo

        echo "$out" | grep -q "State: Active"
        state_ok=$?

        echo "$out" | grep -q "Physical state: LinkUp"
        phys_ok=$?

        if [ $state_ok -ne 0 ] || [ $phys_ok -ne 0 ]; then
            echo "❌ $host → $iface NOT healthy"
            all_good=false
        else
            echo "✅ $host → $iface healthy"
        fi
    done

    if $all_good; then
        echo "🎉 ALL mlx5 interfaces healthy on $host"
        echo "➡️ Marking GPU as healthy using lksctl..."
        # lksctl ops toolbox "$CLUSTER" -- k-nvidia-gpud-set-healthy "$host"
        lksctl ops toolbox kepler01 -- k-nvidia-gpud-set-healthy "$host"
    else
        echo "⚠️ $host not fully healthy — skipping GPUD mark."
    fi

    echo
}

export -f check_host
export SSH

cat "$HOSTFILE" | xargs -n1 -P "$PARALLEL" -I{} bash -c 'check_host "$@"' _ {}
