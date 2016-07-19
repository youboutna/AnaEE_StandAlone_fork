#/bin/bash

 DEFAULT_IP="192.168.56.110"
 SUBNET="mynet123"
 PLAGE_SUBNET="192.168.56.250/24"
 DEFAULT_PORT="80"
 IMAGE_NAME="nginx-ecoinformatics"
 HOST="ecoinformaticss.org"
 FOLDER_DOCKER_FILE="docker"
 
 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 cd $CURRENT_PATH/$FOLDER_DOCKER_FILE

 removeContainerBasedOnImage() {
   IMAGE=$1
   echo
   echo -e " Remove container based on image  $IMAGE "
   docker ps -a | awk '{ print $1,$2 }' | grep $IMAGE | awk '{print $1 }' | xargs -I {} docker rm -f {}
   echo -e " Containers removed !! "
   echo
 } 
    
 if [ "$1" = "start" ] ; then 
 
    SUBNET_CHECK=`docker network ls | grep $SUBNET`
    
    if [[ "${SUBNET_CHECK}" == *$SUBNET* ]]; then
           echo " subnet - $SUBNET - already exists "
    else
           echo " create subnet $SUBNET "
           docker network create --subnet=$PLAGE_SUBNET $SUBNET 
           # docker network rm $SUBNET
    fi
    
    if docker history -q $IMAGE_NAME >/dev/null 2>&1 ; then
	
        removeContainerBasedOnImage $DOCKER_BLZ_IMAGE
                    
        #echo " Remove Image  $IMAGE_NAME ... "
        #docker rmi -f $IMAGE_NAME
        #echo " Images removed !! "
        #echo
        
    else 
    
        fuser -k $DEFAULT_PORT/tcp
        LINE="$IP $HOST"
        sudo -- sh -c "echo '$LINE' >> /etc/hosts" 
      
        docker build -t $IMAGE_NAME .
        docker run -d --net mynet123 --name $HOST --ip $DEFAULT_IP -d -p $DEFAULT_PORT:$DEFAULT_PORT $IMAGE_NAME
    fi
    
 fi
 
 if [ "$1" = "stop" ] ; then 

    removeContainerBasedOnImage $IMAGE_NAME
    
    sudo sed --in-place '/$LINE/d' /etc/hosts
   
 fi
 
