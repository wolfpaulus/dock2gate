# Simple Tomcat container with a custom war deployed
FROM tomcat:9.0.24-jdk11-openjdk-slim
MAINTAINER Wolf Paulus <wolf@paulus.com>
#re-configure tomcat
COPY conf/server.xml /usr/local/tomcat/conf
# remove default webapps and deploy webapp
RUN rm -rf /usr/local/tomcat/webapps/*
COPY build/libs/ROOT.war /usr/local/tomcat/webapps

EXPOSE 80

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
