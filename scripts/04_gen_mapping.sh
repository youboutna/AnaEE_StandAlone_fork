#!/bin/bash
  
  #INPUT="../data/yedGen"
  #OUTPUT="../mapping/mapping.obda"
  #EXTENSION=".graphml"
  
  INPUT=${1:-"../data/yedGen"} 
  OUTPUT=${2:-"../mapping/mapping.obda"}
  EXTENSION=${3:-".graphml"}
  
  tput setaf 2
  echo 
  echo -e " ######################################### "
  echo -e " ######## Info Generation ################ "
  echo -e " ----------------------------------------- "
  echo -e "\e[90m$0         \e[32m                    "
  echo
  echo -e " ##  INPUT     : $INPUT                    "
  echo -e " ##  EXTENTION : $EXTENSION                "
  echo
  echo -e " ##  OUTPUT    : $OUTPUT                   "
  echo
  echo -e " ######################################### "
  echo 
  sleep 1
  tput setaf 7

  cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

  if [ ! -d $INPUT ] ; then
     echo -e "\e[91m $INPUT is not a valid Directory ! \e[39m "
     exit 3
  fi

  echo -e "\e[90m Starting Generation... \e[39m "
  echo
  java -cp ../libs/yedGen.jar Main -d $INPUT -out $OUTPUT -ext $EXTENSION

  echo -e "\e[36m Mapping generated in : $OUTPUT \e[39m "
  echo
  
