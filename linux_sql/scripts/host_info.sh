#!/bin/bash

# Check number of arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <psql_host> <psql_port> <db_name> <psql_user> <psql_password>"
    exit 1
fi

# Assign CLI arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Log file
log_file="script.log"

# Function to log messages
log() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

# Log start of script
log "Starting script"

# Retrieve hardware specifications
hostname=$(hostname -f)
cpu_info=$(lscpu)
cpu_number=$(echo "$cpu_info" | awk '/^CPU\(s\)/ {print $2}')
cpu_architecture=$(echo "$cpu_info" | awk '/^Architecture:/ {print $2}')
cpu_model=$(echo "$cpu_info" | awk '/^Model name:/ {print substr($0, index($0,$3))}')
cpu_mhz=$(echo "$cpu_info" | awk '/^CPU MHz:/ {print $3}')
l2_cache=$(echo "$cpu_info" | awk '/^L2 cache:/ {print $3}' | sed 's/.$//')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(vmstat -t | awk 'END {print $18 " " $19}')

# Construct SQL insert statement (parameterized query)
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem) VALUES($1, $2, $3, $4, $5, $6, $7, $8)"

# Log SQL insert statement
log "SQL insert statement: $insert_stmt"

# Set up environment variable for psql command
export PGPASSWORD="$psql_password"

# Execute SQL insert statement
psql_command="psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c \"$insert_stmt\""
log "Executing: $psql_command"
eval "$psql_command"
exit_status=$?

# Log end of script
log "Script execution completed with exit status $exit_status"

exit $exit_status
