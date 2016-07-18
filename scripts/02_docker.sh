#/bin/bash

 docker build -t nginx-ecoinformatics docker 
 docker run --name ecoinformatics.org -d -p 80:80 nginx-ecoinformatics
 docker exec -it ecoinformatics.org /bin/bash
