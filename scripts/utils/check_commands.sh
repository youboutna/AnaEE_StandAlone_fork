#!/bin/bash

  # java - curl - [postgres] - maven
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
  
  #!/bin/bash

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
  
  for com in "$@" ; do
    
     command -v $com >/dev/null 2>&1 || {
       
        echo
        echo " Require $com but it's not installed.  Aborting. " ; 
        echo
        
        if [ $parent_script = "bash" ] ; then
            exit 2
        else
            kill -9 `ps --pid $$ -oppid=`; 
        fi    
     }
  
     echo " OK....   $com "
     sleep 0.4
  
  done

  echo
  
  
