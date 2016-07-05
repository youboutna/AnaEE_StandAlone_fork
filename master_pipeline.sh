#!/bin/bash

# $1 IP_HOST  
# $2 NAME_SPACE  
# $3 LOCAL_PORT 
# $4 REMOTE_PORT
# $5 DATAB_BASE { [postgresql] - mysql } 

if [ $# -eq 4 -o $# -eq 5 ] ; then

   chmod -R +x scripts/*
   
  ./scripts/utils/check_commands.sh
   
  ./scripts/00_install_libs.sh $5
  
  ./scripts/01_build_config.sh  $1 $2 $3 $4

  ./scripts/02_nano_start_stop.sh start rw
  
  ./scripts/03_gen_mapping.sh
  
  ./scripts/04_ontop_gen_triples.sh
  
  ./scripts/05_corese_infer.sh
  
  ./scripts/06_load_data.sh
  
  ./scripts/07_portail_query.sh ola_portal_synthesis.ttl
  
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
