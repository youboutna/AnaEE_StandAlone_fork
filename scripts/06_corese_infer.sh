#!/bin/bash

  # Default Arguments 
    # OWL="../mapping/ontology.owl"
    # TTL="../data/ontop/ontopMaterializedTriples.ttl"
    # QUERY=" SELECT ?S ?P ?O { ?S ?P ?O } "
    # OUTPUT="../data/corese"
    # f="100000"
    # F="ttl"
 
  OWL=${1:-"../mapping/ontology.owl"}
  TTL=${2:-"../data/ontop/ontopMaterializedTriples.ttl"}
  QUERY=${3:-" SELECT ?S ?P ?O { ?S ?P ?O } "}
  OUTPUT=${4:-"../data/corese"}
  f=${5:-"100000"}
  F=${6:-"ttl"}
  XMS=${7:-"-Xms1024M"}
  XMX=${8:-"-Xmx2048M"}

  EXIT() {
     parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
     if [ $parent_script = "bash" ] ; then
         echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         exit 2
     else
         echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         kill -9 `ps --pid $$ -oppid=`;
         exit 2
     fi
  } 
  
  tput setaf 2
  echo 
  echo -e " ######################################################### "
  echo -e " ######## Info Generation ################################ "
  echo -e " --------------------------------------------------------- "
  echo -e "\e[90m$0        \e[32m                                     "
  echo
  echo -e " ##  OWL      : $OWL                                       "  
  echo -e " ##  TTL      : $TTL                                       "
  echo -e " ##  QUERY    : $QUERY                                     "
  echo -e " ##  OUTPUT   : $OUTPUT                                    "
  echo -e " ##  FORMAT   : $F                                         "
  echo -e " ##  FRAGMENT : $f                                         "
  echo
  echo -e " ######################################################### "
  echo 
  sleep 1
  tput setaf 7

  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
  if [ ! -f $OWL ]  || [ ! -f $TTL ]  ; then
     echo -e "\e[91m Missing OWL or TTL Files ! \e[39m "
     EXIT
  fi
  
  echo -e "\e[90m Strating Generation... \e[39m "
  echo

  java  $XMS  $XMX  -cp  ../libs/CoreseInfer.jar corese.Main       \
  -owl "$OWL"                                                      \
  -ttl  "$TTL"                                                     \
  -q   "$QUERY"                                                    \
  -out "$OUTPUT"                                                   \
  -f   "$f"                                                        \
  -F   "$F"                                                        \
  -log "../libs/logs/corese/logs.log"                              \
  -e
  
  echo 
  echo -e "\e[36m Triples Generated in : $OUTPUT \e[39m "
  echo
        
