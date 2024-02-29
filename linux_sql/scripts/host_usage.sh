#! /bin/sh

# Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#assign CLI arguments to variables

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

memory_free=$(echo "$vmstat_mb" | tail -1 | awk -v col="4" '{print $col}')

cpu_idle=$(echo "$vmstat_mb" | tail -1 | awk '{ print $15 }')

cpu_kernel=$(echo "$vmstat_mb" | tail -1 | awk '{ print $14 }')

disk_io=$(vmstat -d | awk '{print $10}' | tail -1)

disk_available=$(df | awk 'NR==2 {print $4}')

timestamp=$(vmstat -t | awk '{print $18 " " $19}' | tail -1)

# Subquery to find matching id in host_usage table
id="(SELECT count(*) + 1  FROM host_usage)";

# PSQL command: Inserts server usage data into host_usage table

insert_stmt="INSERT INTO host_usage ("timestamp", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES ('$timestamp', $id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

#set up env var for pql cmd
export PGPASSWORD=$psql_password 
#Insert date into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?

