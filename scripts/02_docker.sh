#/bin/bash

 DEFAULT_IP="192.168.56.110"
 DEFAULT_PORT="80"
 IMAGE_NAME="nginx-ecoinformatics"
 HOST="ecoinformaticss.org"
 FOLDER_DOCKER_FILE="docker"
 
 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 cd $CURRENT_PATH
 
 if [ "$1" = "start" ] ; then 

    LINE="$IP $HOST"
    sudo -- sh -c "echo '$LINE' >> /etc/hosts" 
    
    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH/$FOLDER_DOCKER_FILE
      
    docker build --rm -t $IMAGE_NAME .
    docker run -d --net mynet123 --name $HOST --ip $DEFAULT_IP -d -p $DEFAULT_PORT:$DEFAULT_PORT $IMAGE_NAME
    
 fi
 
 if [ "$1" = "stop" ] ; then 

    removeContainerBasedOnImage() {
       IMAGE=$1
       echo
       echo -e " Remove container based on images  $IMAGE "
       docker ps -a | awk '{ print $1,$2 }' | grep $IMAGE | awk '{print $1 }' | xargs -I {} docker rm -f {}
       echo -e " All containers removed !! "
       echo
    } 
    
    removeContainerBasedOnImage $IMAGE_NAME
    
    sudo sed --in-place '/$LINE/d' /etc/hosts
   
 fi
 
