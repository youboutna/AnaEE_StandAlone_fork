#!/bin/bash

  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
  if [ $# -eq 0 ] ; then
  
       NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
       LINE=$(head -1 $NANO_END_POINT_FILE)
    
       IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
       IP=${INFO_NANO[0]}
       NAMESPACE=${INFO_NANO[1]}
       PORT=${INFO_NANO[2]}       
   
  elif [ $# -eq 4 ] ; then
       IP=$1
       PORT=$2
       NAMESPACE=$3
       OUT=$4
       
  else 
       echo
       echo -e "\e[91m 0 or 4 arguments ( IP PORT NAMESAPCE OUT_NAME_FILE ) ! \e[39m "
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
       echo "RES ---> $RES"    
    if  [ -z $RES ] || [ $RES -ne 200 ]  ; then 
        if [ `expr $COUNT % 3` -eq 0 ] ; then
              echo -e " attempt to contact $ENDPOINT .. "
        fi
    fi
           
  done
       
  echo " Yeah Connected !! "
  
	tput setaf 2
  echo 
  echo -e " ######################################################## "
  echo -e " ######## Info Demo  #################################### "
  echo -e " -------------------------------------------------------- "
  echo -e " \e[90m$0       \e[32m                                    "
  echo
  echo -e " # ENDPOINT  : $PREFIX_ENDPOINT                           "
  echo -e " # NAMESAPCE : $NAMESPACE                                 "
  echo -e " # OUT       : $OUT                                       "
  echo
  echo -e " ######################################################## "
  echo 
  sleep 1
  tput setaf 7
        
  curl -X POST $ENDPOINT/namespace/$NAMESPACE/sparql --data-urlencode \
  'query=
           PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
           PREFIX oboe-core: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-core.owl#>
           SELECT ?uri ?unite {
     	        ?uri a oboe-core:Measurement .
   	          ?uri oboe-core:hasValue ?unite
           }
           LIMIT 3
     ' \
    -H 'Accept:text/rdf+n3'
   
    echo ; echo 

