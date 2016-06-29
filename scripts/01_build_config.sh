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
   cd $CURRENT_PATH
   
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
      echo -e "\e[91m $DIR_BLZ/data/blazegraph.jnl will be deteted \e[39m "
      echo
      read -n1 -t 10 -r -p " Press Enter to continue, Any other Key to abort.. else delete in 10 s " key
      echo  
      if [ "$key" = '' ] ; then
          # Nothing pressed
          rm -f $BLZ_JNL &> /dev/null
          echo " blazegraph.jnl deteted "
          echo
      else
          # Anything pressed
          echo
          echo " Script aborted "
          echo
          exit 2
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
   echo ; echo
   echo -e "\e[92m Namespace created \e[39m "
   sleep 0.5 ; echo
   echo -e "\e[93m Stopping Blazegraph \e[39m "
   KILL_PROCESS=$(fuser -k $L_PORT/tcp &>/dev/null )
   sleep 0.5
   echo -e "\e[93m Blazegraph Stopped \e[39m "
   echo
   echo -e "\e[92m Use 02_nano_start_stop.sh script to start-stop Blazegraph \e[39m "
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

