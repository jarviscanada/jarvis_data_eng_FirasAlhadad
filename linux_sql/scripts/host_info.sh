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


lscpu_out=`lscpu`
hostname=$(hostname -f)

# Retrieve hardware specification variables

hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | grep "^Arc" | awk '{print $2}')
cpu_model=$(echo "$lscpu_out" | grep "M.*me:" | awk '{ print substr($0, index($0,$3)) }')
cpu_mhz=$(echo "$lscpu_out" | grep "^C.*z:" | awk '{print $3}')
l2_cache=$(echo "$lscpu_out" | grep "L2.*e:" | awk '{print $3}' | sed 's/.$//')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(vmstat -t | awk '{print $18 " " $19}' | tail -1)

# Subquery to find matching id in host_info table
id="(SELECT COUNT (*) + 1 from host_info)";

# PSQL command: Inserts hardware specufications data into host_info table

insert_stmt="INSERT INTO host_info(id, hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem) VALUES($id,'$hostname','$cpu_number', '$cpu_architecture','$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem');"

#set up env var for pql cmd
export PGPASSWORD=$psql_password

#Insert date into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?

