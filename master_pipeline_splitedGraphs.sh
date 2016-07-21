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
         TYPE_INSTALL="splited_graphs"
          
         YED_GEN_FOLDER="data/yedGen"
         EXTENSION_FILE="graphml"
         CONNEXION_FILE_PATTERN="$YED_GEN_FOLDER/connexion/connexion"
         CONNEXION_FILE="$CONNEXION_FILE_PATTERN.$EXTENSION_FILE"
         ONTOP_FOLDER="data/ontop"
         CORESE_FOLDER="data/corese"
         
         ClearFolders() {
         
            # Clear folders on each iteration
              
            rm $YED_GEN_FOLDER/*.*  2> /dev/null
            rm $ONTOP_FOLDER/*.*    2> /dev/null
            rm $CORESE_FOLDER/*.*   2> /dev/null 
            rm $CORESE_FOLDER/*     2> /dev/null
         }  

         chmod -R +x scripts/*
        
        ./scripts/utils/check_commands.sh java curl psql-mysql mvn
        
        ./scripts/03_nano_start_stop.sh stop
            
        ./scripts/00_install_libs.sh $DATABASE $TYPE_INSTALL
        
        ./scripts/01_build_config.sh  $IP_HOST $NAME_SPACE $LOCAL_PORT $REMOTE_PORT
    
        ./scripts/03_nano_start_stop.sh start rw
        
        if [ ! -f $CONNEXION_FILE  ]; then
            echo
            echo -e "\e[91m --> Connexion file : $CONNEXION_FILE not found ! Abort \e[39m"
            echo 
            exit 2
        fi

        for entry in `find $YED_GEN_FOLDER/* -type d -not -name '*connexion*'`; do
            
            if [ `ls -l $entry | egrep -c '^-'` -gt 0 ] ; then
              
              ClearFolders
              
              # Copy $CONNEXION_FILE  file to $YED_GEN_FOLDER Folder
             
              cp $CONNEXION_FILE $YED_GEN_FOLDER
              
              # Copy all files in $entry to $YED_GEN_FOLDER Folder
              
              cp -R $entry/*.*  $YED_GEN_FOLDER
              
              # Check if $YED_GEN_FOLDER Folder contains more than 2 files ( connexion.graphml included )
              
              if [ `ls -l $YED_GEN_FOLDER | egrep -c '^-'` -gt 1 ] ; then 
                
                 ./scripts/04_gen_mapping.sh
         
                 ./scripts/05_ontop_gen_triples.sh
        
                 ./scripts/06_corese_infer.sh
        
                 ./scripts/07_load_data.sh
            
                 sleep 0.5
              
              fi
            fi
            
        done
        
        ClearFolders
    
        ./scripts/08_portail_query.sh ../data/portail/ola_portal_synthesis.ttl
    
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

