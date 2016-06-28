#!/bin/bash

# Docker version min : 1.10 
# $1 IP_HOST
# $2 NameSpace
# $3 PORT Number

releasePort() {
  PORT=$1          
  if ! lsof -i:$PORT &> /dev/null
  then
    isFree="true"
  else    
    r_comm=`fuser -k $PORT/tcp  &> /dev/null`
    sleep 1
  fi
}  
    
if [ $# -eq 4 ] ; then

   # Get IP HOST
   IP_HOST=$1  
   # Get NameSpace
   NAMESPACE=$2
   # Get Local Port Number
   L_PORT=$3
   # Get Remote Port Number
   R_PORT=$4
   
   CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
   NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
 
   BLZ_INFO_INSTALL="$CURRENT_PATH/conf/BLZ_INFO_INSTALL"
   BLAZEGRAPH_PATH=`cat $BLZ_INFO_INSTALL`

   DIR_BLZ=$(dirname "${BLAZEGRAPH_PATH}")
    
   DEFAULT_NAMESPACE="MY_NAMESPACE"
   
   DATALOADER="$CURRENT_PATH/conf/blazegraph/namespace/dataloader.xml"
   
   tput setaf 2
   echo 
   echo -e " ##################################### "
   echo -e " ######### Build Config ############## "
   echo -e " ------------------------------------- "
   echo -e " \e[90m$0        \e[32m                "
   echo
   echo -e " ##  IP_HOST     : $IP_HOST            "
   echo
   echo -e " ##  NAMESPACE   : $NAMESPACE          "
   echo -e " ##  Local PORT  : $L_PORT             "
   echo -e " ##  Remote PORT : $R_PORT             "
   echo
   echo -e " ##################################### "
   echo 
   sleep 1
   tput setaf 7

   BLZ_JNL="$DIR_BLZ/data/blazegraph.jnl"
  
   if [ -e $BLZ_JNL ] ; then
      
      echo
      echo " $DIR_BLZ/data/blazegraph.jnl will be deteted "
      read -n1 -t 5 -r -p " Press SPACE to abort..." key
        
      if [ "$key" = '' ] ; then
          # Space pressed
          exit 2
      else
          # Anything else pressed
          rm -f $BLZ_JNL &> /dev/null
          echo " blazegraph.jnl deteted "
      fi
   fi
   
   echo "$IP_HOST $NAMESPACE $L_PORT $R_PORT" > $NANO_END_POINT_FILE
     
   releasePort $L_PORT  
   releasePort $R_PORT  

   java -server -XX:+UseG1GC -Dcom.bigdata.journal.AbstractJournal.file=$DIR_BLZ/data/blazegraph.jnl -Djetty.port=$L_PORT -Dcom.bigdata.rdf.sail.namespace=ola -jar $BLAZEGRAPH_PATH &
   
   sleep 3
   
   sed -i "s/$DEFAULT_NAMESPACE/$NAMESPACE/g" conf/blazegraph/namespace/dataloader.xml
   
   curl -X POST --data-binary @$DATALOADER --header 'Content-Type:application/xml' http://$IP_HOST:$L_PORT/blazegraph/dataloader
   
   sleep 2
   
   curl -X DELETE http://$IP_HOST:$L_PORT/blazegraph/namespace/kb &> /dev/null
 
   sleep 1
   
   sed -i "s/$NAMESPACE/$DEFAULT_NAMESPACE/g" conf/blazegraph/namespace/dataloader.xml
   
   fuser -k $L_PORT/tcp &> /dev/null
   
   echo
   echo 
   echo " namespace created !! "
   echo 

else
    echo
    echo " Invalid arguments :  Please pass exactly Four arguments  "
    echo " arg_1             :  IP Host                             "
    echo " arg_2             :  Blazegraph_namespace                "
    echo " arg_3             :  Local Ports number                  "
    echo " arg_4             :  Remote Ports number                 "
    echo
fi

