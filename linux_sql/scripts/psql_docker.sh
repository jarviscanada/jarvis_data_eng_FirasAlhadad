#! /bin/sh

#Capture CLI arguments 

cmd=$1
db_username=$2
db_password=$3

# Start docker normally but prevent from running the start docker command if it already started , in this case it will display the status 
sudo systemctl status docker || system ctl start docker 


#Check container status and save command exit status to see if the container already exists
docker container inspect jrvs-psql
container_status=$?

#We use switch case in bash in order to manage the possibility of having create, start or stop

case $cmd in 
        create)

#making sure that all of the necessary arguments are given and display eventually a message accordingly 
        if [ $container_status -eq 0 ]; then
                echo 'Container already exists'
                exit 1
        fi

        if [ $# -ne 3 ]; then
                echo 'Create requires username and password'
                exit 1
        fi

#create container (knowing that we have all the necessary arguments)
        docker volume create pgdata 

        # Start the container
        docker run --name db_username -e POSTGRES_PASSWORD=db_password -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine

#As we are supposed to be done creating and running database, we exit successfully or not accordingly

        exit $?
		;;

        start|stop)

#if the container doesnt exist (exit code != 0) we exit 1
        if [ $container_status -ne 0 ]; then
                exit 1
        fi

# Start or stop the container
        docker container $cmd jrvs-psql
        exit $?
		;;

        *)
        echo 'Illegal command'
        echo 'Commands: start|stop|create'
        exit 1
        	;;
esac 

