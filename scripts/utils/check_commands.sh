#!/bin/bash

  # java - curl - [psql - mysql] - maven
  
  tput setaf 2
  echo 
  echo -e " ################################# "
  echo -e " ######### Check Commands ######## "
  echo -e " --------------------------------- "
  echo -e " \e[90m$0        \e[32m            "
  echo
  sleep 1
  tput setaf 7
  
  script_name="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
  parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
  
  checkCommand() {
  
    com=$1
    
    if which $com >/dev/null ; then
        
        echo " OK .... $com "
        sleep 0.4
       
    else
     
        echo
        echo -e "\e[91m $com  : Command not found. Aborting \e[39m" ; 
        echo
      
        if [ $parent_script = "bash" ] ; then
            exit 2
        else
            kill -9 `ps --pid $$ -oppid=`;
            exit 2
        fi
    fi
  }
  
  for com in "$@" ; do
  
    checkCommand $com
    
  done

  echo
  
