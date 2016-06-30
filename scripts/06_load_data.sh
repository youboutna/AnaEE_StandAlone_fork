#!/bin/bash

  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
  if [ $# -eq 1 ] ; then
     DATA_DIR=$1
  else
    # Default Folder
    DATA_DIR="../data/corese"
  fi 
    
  if [ $# -eq 3 -o $# -eq 4 ] ; then
      
    IP=$1
    PORT=$2
    NAMESPACE=$3
    
    if [ $# -eq 4 ] ; then
      DATA_DIR=$4
    fi
   
  elif [ $# -eq 0 -o  $# -eq 1 ] ; then
   
    NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
    
    LINE=$(head -1 $NANO_END_POINT_FILE)        
          
    IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
    IP=${INFO_NANO[0]}
    NAMESPACE=${INFO_NANO[1]}
    PORT=${INFO_NANO[2]}       
   
  else 
      echo
      echo -e "\e[91m 0 or 3 arguments ( IP PORT NAMESAPCE ) ! \e[39m "
      echo
      exit 3
  fi
   
  PREFIX_ENDPOINT="http://$IP:$PORT"
  SUFFIX_ENDPOINT="blazegraph/namespace/$NAMESPACE/sparql"
  
  ENDPOINT=$PREFIX_ENDPOINT/$SUFFIX_ENDPOINT
 
  # Test connexion to namespace 
  check="cat < /dev/null > /dev/tcp/http://$IP/$PORT"
      
  echo ; echo -e " Try connection : $ENDPOINT "
        
  TRYING=50
  COUNT=0
        
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
        
  OK=$?
        
  while [ $OK -ne 0 -a $COUNT -lt $TRYING  ] ; do
        
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
           
    OK=$?
           
    if [ $COUNT == 0 ] ; then echo ; fi 
           
    if [ $OK == 1 ] ; then 
             
      echo " .. "
      sleep 0.4 
             
    elif [ $OK != 0 ] ; then 
          
      echo " attempt ( $COUNT ) : Try again.. "
      sleep 0.8
             
    fi
           
    let "COUNT++"
           
    if [ $COUNT == $TRYING ] ; then
          
      echo
      echo -e "\e[31m ENDPOINT $ENDPOINT Not reachable !! \e[39m"
      echo
      exit 3
             
    fi
           
  done
        
  RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
        
  COUNT=0
        
  while  [ -z $RES ] || [ $RES -ne 200 ] ;do
        
    sleep 1
    RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
    let "COUNT++" 
           
    if  [ -z $RES ] || [ $RES -ne 200 ] ; then 
        if [ `expr $COUNT % 3` -eq 0 ] ; then
           echo -e " attempt to join $ENDPOINT .. "
        fi
    fi
           
  done
       
  echo " Yeah Connected !! "
        
  if [ ! -d $DATA_DIR ] ; then
     echo -e "\e[91m $DATA_DIR is not valid Directory ! \e[39m "
     exit 3
  fi
            
  # Remove the sparql file automatically created by blazegraph
  if [ -f "$DATA_DIR/sparql" ] ; then
    rm -f "$DATA_DIR/sparql" 
  fi

  sleep 0.5  # Waits 0.5 second .

  cd $DATA_DIR
        
  tput setaf 2
  echo 
  echo -e " ################################################################ "
  echo -e " ######## Info Load Data ######################################## "
  echo -e " ---------------------------------------------------------------- "
  echo -e " \e[90m$0                                                  \e[32m "
  echo
  echo -e " # ENDPOINT : $PREFIX_ENDPOINT                                    "
  echo -e "\e[90m   Folder     $DATA_DIR                              \e[32m "
  echo
  echo -e " ################################################################ "
  echo 
  sleep 1
  tput setaf 7
       
  nbFiles=`ls | wc -l`
     
  if [ $nbFiles -ne 0 ] ; then
      
      for FILE in `ls -a *`
      do
        echo " ---------------------                                                   "
        echo -e " \e[39m Upload file :\e[92m $DATA_DIR/$FILE \e[39m                    " 
        echo " ----------------------------------------------------------------------- "
        echo
        curl -D- -H 'Content-Type: text/turtle' --upload-file $FILE -X POST $ENDPOINT -O
        echo
        echo " ----------------------------------------------------------------------- "
      done
      
  else 
  echo
   echo -e "\e[91m empty Folder \e[39m"
   echo
 fi
  
