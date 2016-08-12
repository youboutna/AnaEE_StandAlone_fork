#!/bin/bash

  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
  if [ $# -eq 1 ] ; then
  
       OUT=$1
       
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
       echo -e "\e[91m 1 or 4 arguments ( OUT_NAME_FILE / IP PORT NAMESAPCE OUT_NAME_FILE ) ! \e[39m "
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
  echo -e " ######## Info Synthesis ################################ "
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
        

  portail_query='
    	PREFIX dc:<http://purl.org/dc/elements/1.1/>
	PREFIX wgs84_pos:<http://www.w3.org/2003/01/geo/wgs84_pos#>
	PREFIX foaf:<http://xmlns.com/foaf/0.1/>
	PREFIX org:<http://www.w3.org/ns/org#>
	PREFIX dcterms:<http://purl.org/dc/terms/>
	PREFIX time:<http://www.w3.org/2006/time#>
	PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>
	PREFIX doap:<http://usefulinc.com/ns/doap#>
	PREFIX oboe-core:<http://ecoinformatics.org/oboe/oboe.1.0/oboe-core.owl#>
	PREFIX oboe-char:<http://ecoinformatics.org/oboe/oboe.1.0/oboe-characteristics.owl#>
	PREFIX  oboe-spatial:<http://ecoinformatics.org/oboe/oboe.1.0/oboe-spatial.owl#>
	PREFIX anaee:<http://www.anaee-france.fr/ontology/anaee-france_ontology#>
	PREFIX standard:<http://ecoinformatics.org/oboe/oboe.1.0/oboe-standards.owl#>
	PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
	PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
	PREFIX skosxl:<http://www.w3.org/2008/05/skos-xl#>
	SELECT DISTINCT  ?ecosystemes  ?plateforme ?modele  ?variablesimulate ?auteur ?publication ?project    WHERE {
		
		?modeleObs a oboe-core:Observation; oboe-core:ofEntity anaee:Model; oboe-core:hasMeasurement ?modeleMeasurement.

		?modeleMeasurement a oboe-core:Measurement ; oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?modele.

		?modeleObs anaee:hasModellingInput ?inputmodeleObs.
		?modeleObs anaee:hasModellingOutput ?outputmodeleObs.
		

		?inputmodeleObs a oboe-core:Observation; oboe-core:ofEntity anaee:Inout; oboe-core:hasMeasurement ?inputMeasurement.
		?outputmodeleObs a oboe-core:Observation; oboe-core:ofEntity anaee:Inout; oboe-core:hasMeasurement ?outputMeasurement.

		{?inputMeasurement a oboe-core:Measurement ; oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?variablesimulate.}
		UNION 
		{?outputMeasurement a oboe-core:Measurement ; oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?variablesimulate.}
      
		OPTIONAL { 
			 ?modelObs oboe-core:hasContext ?plateformecontext.
			?modelObs oboe-core:hasContext ?ecosystemescontext.
		   
			?plateformecontext a oboe-core:Observation; oboe-core:ofEntity ?plateformeuri.
			?plateformeuri  rdfs:subClassOf* anaee:ModellingPlatform; rdfs:label ?platforme.		

			?ecosystemescontext a oboe-core:Observation; oboe-core:ofEntity ?ecosystemesuri.  

			?ecosystemesuri rdfs:subClassOf*  anaee:Ecosystem; rdfs:label ?ecosystemes. 
          	        FILTER(LANGMATCHES(LANG(?ecosystemes), "en"))
	       		FILTER(LANGMATCHES(LANG(?plateforme), "en"))
		    
		    }

		OPTIONAL {

			?modelObs anaee:hasPublication  ?publicationcontext. 
			?modelObs anaee:ispartOfProject  ?projectcontext.
			?modelObs anaee:hasAuthor ?personcontext.

			?personcontext a oboe-core:Observation; oboe-core:ofEntity ?person.
			 ?person a anaee:Person; foaf:name ?auteur.		
			 
			?projectcontext a oboe-core:Observation; oboe-core:ofEntity ?project.

			?project a anaee:Project; doap:homepage ?url; foaf:name ?projectname.

			?publicationcontext  a oboe-core:Observation; oboe-core:ofEntity ?publication.

			?publication a anaee:Publication.

		}

	        FILTER (isLiteral(?variablesimulate))	
	        FILTER (isLiteral(?modele))   			      		
		
		}
           ' \
    -H 'Accept:text/csv' > $OUT
  		    
