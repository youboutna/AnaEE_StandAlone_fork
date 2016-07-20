# AnaEE_StandAlone

 **master_pipeline Parameters :**
 
-    `$1 : IP_HOST ( or Hostname )`

-    `$2 : NAME_SPACE `

-    `$3 : LOCAL_PORT `

-    `$4 : REMOTE_PORT `

-    `$5 : DATA_BASE { [postgresql] - mysql }`

Ex :

    ./master_pipeline.sh  \
      localhost           \
      ola                 \
      6981                \
      6982                \
      mysql               
     
     
Included Projects : 

-    [https://github.com/rac021/yedGen]( https://github.com/rac021/yedGen)

-    [https://github.com/rac021/ontop-matarializer]( https://github.com/rac021/ontop-matarializer)
   
-    [https://github.com/rac021/CoreseInfer]( https://github.com/rac021/CoreseInfer)

-    [Blazegraph 2.1.1]( https://www.blazegraph.com/)   
   

Requirements :

-    `JAVA 8`
    
-    `MAVEN`
   
-    `CURL `
    
-    `[ Postgres ] / MySql`

-    `Docker 1.10 and +  Optionnal ` 

