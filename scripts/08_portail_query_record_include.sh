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
        
  
   curl -X POST localhost:8080/namespace/record/sparql --data-urlencode \
'query=     
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
SELECT DISTINCT   ?modelUri  ?plateforme  ?modele  ?variablesimulate  ?process ?module   ?ecosystemes   ?person ?auteur   ?plateformeuri ?publication  WHERE {


		          ?modeleObs a oboe-core:Observation; oboe-core:ofEntity anaee:Model ; oboe-core:hasMeasurement ?modeleMeasurement.
		          ?modeleMeasurement  oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?modele.

		 		OPTIONAL {

		          ?modeleObs anaee:isComposedOfModule ?moduleObs.
		          ?moduleObs oboe-core:hasMeasurement ?moduleMeasurement.
		          ?moduleMeasurement oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?module ; oboe-core:usesStandard anaee:VsoilModuleNamingStandard.

		          ?moduleObs anaee:hasModellingInput ?inputmoduleObs.
		          ?inputmoduleObs oboe-core:hasMeasurement ?inputmoduleMeasurement.

                  ?moduleObs anaee:hasModellingOutput ?outputmoduleObs.
		          ?outputmoduleObs  oboe-core:hasMeasurement ?outputmoduleMeasurement.

		          ?moduleObs oboe-core:hasContext ?plateformecontext.
		          ?plateformecontext  oboe-core:ofEntity ?plateformeuri.
		          ?plateformeuri rdfs:subClassOf* anaee:Vsoil; rdfs:label ?plateforme.

                  {?inputmoduleMeasurement oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?variablesimulate  ; oboe-core:usesStandard  anaee:VsoilInoutNamingStandard.
                  }
		   		UNION {
             ?outputmoduleMeasurement oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?variablesimulate ; oboe-core:usesStandard anaee:VsoilInoutNamingStandard.
                }

                }
             	OPTIONAL {
                    ?modeleObs anaee:isComposedOfModule ?moduleObs.
                    ?moduleObs anaee:implementsProcess ?processObs.
                    ?processObs oboe-core:hasMeasurement ?processMeasurement.
                    ?processMeasurement oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?process ; oboe-core:usesStandard anaee:VsoilProcessNamingStandard.
                  }


		     	OPTIONAL {
                  ?modeleObs  anaee:hasModellingInput ?inputmodeleObs.
                  ?inputmodeleObs  oboe-core:hasMeasurement ?inputMeasurement.

                  ?modeleObs  anaee:hasModellingOutput ?outputmodeleObs.
                  ?outputmodeleObs  oboe-core:hasMeasurement ?outputMeasurement.

                  ?modeleObs oboe-core:hasContext ?plateformecontext.
                  ?plateformecontext  oboe-core:ofEntity ?plateformeuri.
                  ?plateformeuri rdfs:subClassOf* anaee:Record; rdfs:label ?plateforme.
                  ?modeleObs oboe-core:hasContext ?ecosystemescontext.
                  ?ecosystemescontext  oboe-core:ofEntity ?ecosystemesuri.
                  ?ecosystemesuri rdfs:subClassOf*  anaee:Ecosystem; rdfs:label ?ecosystemes.
                  FILTER(LANGMATCHES(LANG(?ecosystemes), "en"))

                  {?outputMeasurement  oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?variablesimulate  ; oboe-core:usesStandard anaee:RecordInoutNamingStandard.
		            }
		    UNION {
		          ?inputMeasurement  oboe-core:ofCharacteristic oboe-core:Name ; oboe-core:hasValue ?variablesimulate  ; oboe-core:usesStandard  anaee:RecordInoutNamingStandard.
		            }

		            }


		    OPTIONAL {

		        ?modeleObs anaee:hasPublication  ?publicationcontext.
		        ?publicationcontext  oboe-core:ofEntity ?publication.
		        ?publication a anaee:Publication.
		              }

			OPTIONAL {?modeleObs anaee:isComposedOfModule ?moduleObs.
                      ?moduleObs oboe-core:hasAuthor ?personcontext.
                      ?personcontext oboe-core:ofEntity ?person.
                      ?person a anaee:Person; foaf:name ?auteur.
            }
           OPTIONAL {
                    ?modeleObs anaee:hasAuthor ?personcontext.
                    ?personcontext  oboe-core:ofEntity ?person.
                    ?person a anaee:Person; foaf:name ?auteur.
           }

                  FILTER (isLiteral(?variablesimulate))
                  FILTER (isLiteral(?modele))
                  FILTER(LANGMATCHES(LANG(?plateforme), "en"))
			

					}
			      GROUP BY   ?modelUri  ?plateforme  ?modele  ?variablesimulate  ?process ?module   ?ecosystemes   ?person ?auteur   ?plateformeuri ?publication

				  ORDER BY   ?plateforme  ?modele  ?variablesimulate  ?process ?module   ?ecosystemes   ?person ?auteur   ?plateformeuri ?publication
    ' \
  
   -H 'Accept:text/csv' > $OUT
   
    echo ; echo 
