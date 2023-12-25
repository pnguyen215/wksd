# Show PIDs by SSH tunnel forwarding
function ssh_list_forwarding() {
    echo "🍺 SSH tunnels forwarding:"
    # ps aux | grep ssh | grep -v grep | grep -E '\-L|\-R|\-D' | awk '{printf "%-10s %-10s %-20s %-20s %-20s\n", $2, $11, $12, $13, $14}'
    wsd_exe_cmd ps aux | grep ssh | grep -v grep | grep -E '\-L|\-R|\-D' | awk 'BEGIN {printf "%-10s %-10s %-20s %-20s %-20s %-10s %-20s %-20s %-20s\n", "PID", "USER", "START", "TIME", "COMMAND", "LOCAL_PORT", "FORWARD_TYPE", "REMOTE_PORT", "REMOTE_HOST"} {printf "%-10s %-10s %-20s %-20s %-20s %-10s %-20s %-20s %-20s\n", $2, $1, $9, $10, $11, $12, $13, $14, $15}'
}
# Alias to show all jobs running
alias sshlistforwarding="ssh_list_forwarding"
