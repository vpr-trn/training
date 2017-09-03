FROM tomcat:7-jre8
ARG GITBRANCH  
ARG BUILD
ARG FILE

RUN wget http://192.168.50.50:8081/nexus/content/repositories/snapshots/$GITBRANCH/$BUILD/$FILE -P /usr/local/tomcat/webapps/

EXPOSE 8080
