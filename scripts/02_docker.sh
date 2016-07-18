#/bin/bash

 IMAGE_NAME="nginx-ecoinformatics"
 IP="192.168.56.110"
 HOST="ecoinformaticss.org"
 FOLDER_DOCKER_FILE="docker"
 
 LINE="$IP $HOST"
 sudo -- sh -c "echo '$LINE' >> /etc/hosts" 
 
 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 cd $CURRENT_PATH/$FOLDER_DOCKER_FILE
   
 docker build -t $IMAGE_NAME .
 docker run -d --net mynet123 --name $HOST  --ip $IP -d -p 80:80 $IMAGE_NAME
 
 # On Stop
 #sudo sed -i "s/$LINE/#$LINE/g" /etc/hosts
