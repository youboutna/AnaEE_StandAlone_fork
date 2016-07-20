#!/bin/bash

# $1 IP_HOST  
# $2 NAME_SPACE  
# $3 LOCAL_PORT 
# $4 REMOTE_PORT
# $5 DATAB_BASE { [postgresql] - mysql } 

if [ $# -eq 4 -o $# -eq 5 ] ; then

  IP_HOST="$1"
  NAME_SPACE="$2"
  LOCAL_PORT="$3"
  REMOTE_PORT="$4"
  DATABASE=${5:-psql}
  
  chmod -R +x scripts/*
  
  ./scripts/utils/check_commands.sh java curl psql mvn
   
  ./scripts/03_nano_start_stop.sh stop
   
  ./scripts/00_install_libs.sh $DATABASE demo
  
  ./scripts/01_build_config.sh  $IP_HOST $NAME_SPACE $LOCAL_PORT $REMOTE_PORT

  ./scripts/03_nano_start_stop.sh start rw
  
  ./scripts/04_gen_mapping.sh
  
  ./scripts/05_ontop_gen_triples.sh
  
  ./scripts/06_corese_infer.sh
  
  ./scripts/07_load_data.sh
  
  ./scripts/08_portail_query.sh ola_portal_synthesis.ttl
  
else

    echo
    echo " Invalid arguments :  please pass Four or Five arguments  "
    echo " arg_1             :  IP_HOST ( or Hostname )             "
    echo " arg_2             :  NAME_SPACE                          "
    echo " arg_3             :  LOCAL_PORT                          "
    echo " arg_4             :  REMOTE_PORT                         "        
    echo " arg_5             :  DATA_BASE { [postgresql] - mysql }  "
    echo
fi

