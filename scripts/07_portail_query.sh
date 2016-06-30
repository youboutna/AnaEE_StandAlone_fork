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
        
  curl -X POST $ENDPOINT/namespace/$NAMESPACE/sparql --data-urlencode \
  'query=
     PREFIX : <http://www.anaee-france.fr/ontology/anaee-france_ontology#> 
     PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
	   PREFIX oboe-core: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-core.owl#> 
	   PREFIX oboe-standard: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-standards.owl#>
	   PREFIX oboe-temporal: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-temporal.owl#>
	   PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	  		 
	   CONSTRUCT { 
         
	     ?idVariableSynthesis   a                     :Variable             .
		    
	     ?idVariableSynthesis  :ofVariable            ?variable             .
	     ?variable             :hasCategory           ?category             .
             ?variable        	   :hasAnaeeVariableName  ?anaeeVariableName    .
             ?variable             :hasLocalVariableName  ?localVariableName    .
	     ?variable             :hasUnit               ?unit                 .
	     
	     ?unit                 :hasAnaeeUnitName      ?anaeeUnitName        .
 	 
 	     ?category             :hasCategoryName       ?categoryName         .
 	     ?idVariableSynthesis  :hasSite               ?site                 .
 	     ?site		   :hasLocalSiteName      ?localSiteName        . 
             ?site	       	   :hasAnaeeSiteName      ?anaeeSiteName        .           
 	     ?site		   :hasSiteType           ?siteType             .
 	     ?site		   :hasSiteTypeName       ?siteTypeName         .
 	     ?site		   :hasInfra              ?infra                .
 	     ?infra                :hasInfraName          ?infraName            .
 	     
 	     ?idVariableSynthesis  :hasNbData             ?nbData               .
	     ?idVariableSynthesis  :hasYear               ?year                 .
	     
	   } 
      WHERE {
         
	    SELECT ?infra
	           ?infraName
	           ?idVariableSynthesis 
	           ?site  
	           ?anaeeSiteName
	           ?localSiteName	
		   ?siteType
		   ?siteTypeName
	           ?category
	           ?categoryName 
	           ?variable 
	           ?anaeeVariableName
		   ?localVariableName
	           ?unit
	           ?anaeeUnitName
	           ?year 
		   (COUNT(*) as ?nbData) 
		   
	    WHERE  {
		      
	        ?obs_var_1 a oboe-core:Observation ; 
			     oboe-core:ofEntity ?undefinedVariable ; 
			     oboe-core:hasMeasurement ?measu_unitAndValue_02 ; 
			     :hasVariableContext ?obs_variable_03 ;
	         oboe-core:hasContext+ ?obs_timeInstant_55 , ?obs_expPlot_57 .             
	                              
	        ?measu_unitAndValue_02 a oboe-core:Measurement ; 
			                             oboe-core:usesStandard ?unit .
	       
	        ?unit rdfs:label ?anaeeUnitName .
	         
	        FILTER (lang(?anaeeUnitName) = "en") .
	          
	        ?obs_variable_03 a oboe-core:Observation ; 
			           oboe-core:ofEntity :Variable ; 
			           oboe-core:hasMeasurement ?measu_variableStandardName_05 ; 
	               oboe-core:hasMeasurement ?measu_variableLocalName_04 ; 
			           oboe-core:hasContext ?obs_categ_06 .
	         
	        ?obs_categ_06 a oboe-core:Observation ; 
			        oboe-core:ofEntity :VariableCategory ; 
			        oboe-core:hasMeasurement ?measu_categName_07 .  
	              
	        ?measu_categName_07 a oboe-core:Measurement ; 
			                          oboe-core:usesStandard :Anaee-franceVariableCategoryNamingStandard ; 
			                          oboe-core:hasValue ?category .
	                  
	        ?category rdfs:label ?categoryName .
	        
	        ?measu_variableLocalName_04 a oboe-core:Measurement ; 
     	   	                              oboe-core:usesStandard :NamingStandard ; 
		            	                      oboe-core:hasValue ?localVariableName .
	
	        ?variable rdfs:label ?anaeeVariableName .
	            
	        ?measu_variableStandardName_05 a oboe-core:Measurement ; 
	   	                                     oboe-core:usesStandard :Anaee-franceVariableNamingStandard ; 
			                                     oboe-core:hasValue ?variable .
	                  
	        ?obs_timeInstant_55 a oboe-core:Observation ; 
			                          oboe-core:ofEntity 
			                          oboe-temporal:TimeInstant ; 
			                          oboe-core:hasMeasurement ?measu_date_56 .
		      
	        ?measu_date_56 a oboe-core:Measurement ;
		 	                     oboe-core:hasValue ?date .
	                   
	        ?obs_expPlot_57 a oboe-core:Observation ; 
			                      oboe-core:ofEntity :ExperimentalPlot ; 
			                      oboe-core:hasContext ?obs_site_62   .
			               
	        ?obs_site_62 a oboe-core:Observation ; 
	   	                   oboe-core:ofEntity :ExperimentalSite ;
			                   oboe-core:hasContext ?obs_type_site_67 ;
			                   oboe-core:hasContext ?obs_expNetWork_65 ;
			                   oboe-core:hasMeasurement ?meas_siteNameStandard_64, ?meas_siteName_63 .
			 
	        ?obs_type_site_67 a oboe-core:Observation ; 
			                        oboe-core:ofEntity ?siteType .
	        
	        ?siteType rdfs:label ?siteTypeName ;
	        
	        FILTER (lang(?siteTypeName ) = "en") .
	         
	        FILTER ( NOT EXISTS { ?obs_type_site_67 oboe-core:ofEntity :ExperimentalNetwork . }) . 
	         
	        ?obs_expNetWork_65 a oboe-core:Observation ; 
			                         oboe-core:ofEntity :ExperimentalNetwork ;
			                         oboe-core:hasMeasurement ?measu_expNetWorkName_66.
		
		      ?measu_expNetWorkName_66 a oboe-core:Measurement ; 
			                               oboe-core:usesStandard :Anaee-franceExperimentalNetworkNamingStandard ; 
			                               oboe-core:hasValue ?infra .
			            
		      ?infra rdfs:label ?infraName .
		
	        ?meas_siteNameStandard_64 a oboe-core:Measurement ; 
			                                oboe-core:usesStandard :Anaee-franceExperimentalSiteNamingStandard ; 
			                                oboe-core:hasValue ?anaeeSiteNameStandard .
		    
	        ?meas_siteName_63 a oboe-core:Measurement ; 
			                        oboe-core:usesStandard :NamingStandard ; 
			                        oboe-core:hasValue ?localSiteName .
		               
	        BIND(YEAR(?date) AS ?year).         
	                  
	        BIND (URI( REPLACE ( CONCAT("http://www.anaee-france.fr/ontology/anaee-france_ontology" , 
	                             ?anaeeSiteNameStandard ) , " ", "_") ) AS ?site ) .
	                  
	        ?site rdfs:label ?anaeeSiteName .
		   
	        BIND (URI( REPLACE ( CONCAT("http://anee-fr#ola/" , 
	                                     ?anaeeSiteName, "_" , 
	                                     ?categoryName, "_", 
	                                     ?anaeeVariableName, "_",
	                                     str(?year) ) , " ", "_") ) AS ?idVariableSynthesis ) 
	    }  
      GROUP BY ?infra ?infraName ?idVariableSynthesis ?site ?anaeeSiteName ?localSiteName 
               ?siteType ?siteTypeName ?category ?categoryName ?variable ?anaeeVariableName
               ?localVariableName ?unit ?anaeeUnitName ?year
     }
     ' \
    -H 'Accept:text/rdf+n3' > $OUT
   
    echo ; echo 

  portail_query='
    PREFIX : <http://www.anaee-france.fr/ontology/anaee-france_ontology#> 
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    PREFIX oboe-core: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-core.owl#> 
    PREFIX oboe-standard: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-standards.owl#>
    PREFIX oboe-temporal: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-temporal.owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  
  	SELECT ?infraName
  	       ?site 
  	       ?anaeeSiteName
  	       ?localSiteName 
  	       ?siteType 
  	       ?siteTypeName 
  	       ?category 
  	       ?categoryName
  	       ?variable 
  	       ?anaeeVariableName
  	       ?localVariableName 
  	       ?unit 
  	       ?anaeeUnitName
  	       ?year 
  	       ?nbData 
  	          
  	WHERE  {  
      		    
		  	   ?idVariableSynthesis   a                     :Variable            .
				    
			     ?idVariableSynthesis  :ofVariable            ?variable            .
			     ?variable             :hasCategory           ?category            .
		       ?variable             :hasAnaeeVariableName  ?anaeeVariableName   .
		       ?variable             :hasLocalVariableName  ?localVariableName   .
			     ?variable             :hasUnit               ?unit                .
		 	 
		 	     ?unit                 :hasAnaeeUnitName      ?anaeeUnitName       .
		 	     
		 	     ?category             :hasCategoryName       ?categoryName        .
		 	     ?idVariableSynthesis  :hasSite               ?site                .
		 	     ?site	          	   :hasLocalSiteName      ?localSiteName       . 
		       ?site		             :hasAnaeeSiteName      ?anaeeSiteName       .           
		 	     ?site		             :hasSiteType           ?siteType            .
		 	     ?site		             :hasSiteTypeName       ?siteTypeName        .
		 	     ?site		             :hasInfra              ?infra               .
 	  	     ?infra                :hasInfraName          ?infraName           .
 	   	     ?idVariableSynthesis  :hasNbData             ?nbData              .
			     ?idVariableSynthesis  :hasYear               ?year                .
  }
  		    
  ORDER BY ?site ?year  '
  		    
